import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignalingService {
  bool isServer = false;
  String? connectedEndpoint;

  ServerSocket? _server;
  final List<Socket> _serverClients = [];
  Socket? _client;
  final StreamController<String> _messageStream =
      StreamController<String>.broadcast();
  final Map<Socket, String> _serverBuffers = <Socket, String>{};
  String _clientBuffer = '';

  // Retry/backoff state
  Timer? _reconnectTimer;
  String? _pendingHostIp;
  int? _pendingPort;
  int _retryCount = 0;
  static const int _maxRetries = 5;
  static const Duration _initialBackoff = Duration(seconds: 1);
  static const Duration _maxBackoff = Duration(seconds: 30);

  Stream<String> get messages => _messageStream.stream;

  Future<void> startServer({int port = 8080}) async {
    if (kIsWeb) {
      throw UnsupportedError('Server sockets are not supported on web builds');
    }
    await stop();
    _server = await ServerSocket.bind(
      InternetAddress.anyIPv4,
      port,
      shared: true,
    );
    connectedEndpoint = await _describeLocalEndpoint(port);
    isServer = true;
    _server!.listen(
      _handleIncomingConnection,
      onError: (Object err) {
        if (kDebugMode) {
          debugPrint('Server socket error: $err');
        }
      },
    );
  }

  Future<void> connectToHost(
    String hostIp, {
    int port = 8080,
    bool enableRetry = true,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('TCP sockets are not supported on web builds');
    }
    _validateIp(hostIp);
    if (port <= 0 || port > 65535) {
      throw FormatException('Invalid port');
    }

    // Cancel any pending retry
    _cancelRetry();

    await _connectToHostInternal(hostIp, port, enableRetry: enableRetry);
  }

  Future<void> _connectToHostInternal(
    String hostIp,
    int port, {
    bool enableRetry = true,
  }) async {
    try {
      await _client?.close();
      _client = await Socket.connect(
        hostIp,
        port,
        timeout: const Duration(seconds: 5),
      );
      _client!.setOption(SocketOption.tcpNoDelay, true);
      connectedEndpoint = '$hostIp:$port';
      isServer = false;
      _retryCount = 0; // Reset on successful connection

      _client!.listen(
        (data) => _handleInboundData(source: null, data: data),
        onDone: () {
          _handleClientClosed();
          if (enableRetry && _pendingHostIp == null) {
            _scheduleReconnect(hostIp, port);
          }
        },
        onError: (Object err) {
          _handleClientClosed();
          if (kDebugMode) {
            debugPrint('Client socket error: $err');
          }
          if (enableRetry && _pendingHostIp == null) {
            _scheduleReconnect(hostIp, port);
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Connection failed: $e');
      }
      if (enableRetry) {
        _scheduleReconnect(hostIp, port);
        rethrow;
      }
      rethrow;
    }
  }

  void _scheduleReconnect(String hostIp, int port) {
    if (_retryCount >= _maxRetries) {
      if (kDebugMode) {
        debugPrint(
          'Max retries reached, giving up connection to $hostIp:$port',
        );
      }
      _pendingHostIp = null;
      _pendingPort = null;
      _retryCount = 0;
      return;
    }

    _pendingHostIp = hostIp;
    _pendingPort = port;
    _retryCount++;

    final backoff = _calculateBackoff(_retryCount);
    if (kDebugMode) {
      debugPrint(
        'Scheduling reconnect attempt $_retryCount/$_maxRetries in ${backoff.inSeconds}s',
      );
    }

    _reconnectTimer = Timer(backoff, () {
      if (_pendingHostIp != null && _pendingPort != null) {
        unawaited(
          _connectToHostInternal(
            _pendingHostIp!,
            _pendingPort!,
            enableRetry: true,
          ),
        );
      }
    });
  }

  Duration _calculateBackoff(int attempt) {
    // Exponential backoff: 1s, 2s, 4s, 8s, 16s, capped at maxBackoff
    final baseDelay = _initialBackoff.inSeconds * pow(2, attempt - 1).toInt();
    final delaySeconds = min(baseDelay, _maxBackoff.inSeconds).toInt();
    return Duration(seconds: delaySeconds);
  }

  void _cancelRetry() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _pendingHostIp = null;
    _pendingPort = null;
    _retryCount = 0;
  }

  void cancelAutoReconnect() {
    _cancelRetry();
  }

  Future<void> sendString(String message) async {
    final data = utf8.encode('$message\n');
    await sendBytes(data);
  }

  Future<void> sendBytes(List<int> data) async {
    if (isServer && _serverClients.isNotEmpty) {
      final sockets = List<Socket>.from(_serverClients);
      for (final socket in sockets) {
        socket.add(data);
      }
      await Future.wait(sockets.map((socket) => socket.flush()));
      return;
    }

    final socket = _client;
    if (socket == null) {
      throw StateError('No active connection to send data through');
    }
    socket.add(data);
    await socket.flush();
  }

  Future<void> stop() async {
    _cancelRetry();

    final futures = <Future<void>>[];

    if (_client != null) {
      futures.add(_client!.close());
      _client = null;
    }

    for (final client in _serverClients) {
      futures.add(client.close());
    }
    _serverClients.clear();

    final server = _server;
    if (server != null) {
      futures.add(server.close());
      _server = null;
    }

    connectedEndpoint = null;
    isServer = false;

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  Future<void> dispose() async {
    _cancelRetry();
    await stop();
    if (!_messageStream.isClosed) {
      await _messageStream.close();
    }
  }

  void _handleIncomingConnection(Socket socket) {
    socket
      ..setOption(SocketOption.tcpNoDelay, true)
      ..listen(
        (data) => _handleInboundData(source: socket, data: data),
        onDone: () => _handleServerClientClosed(socket),
        onError: (Object err) {
          _handleServerClientClosed(socket);
          if (kDebugMode) {
            debugPrint('Inbound client error: $err');
          }
        },
      );
    _serverClients.add(socket);
    _serverBuffers[socket] = '';
  }

  void _handleInboundData({Socket? source, required List<int> data}) {
    if (data.isEmpty || _messageStream.isClosed) {
      return;
    }
    final chunk = utf8.decode(data, allowMalformed: true);
    if (source == null) {
      _clientBuffer = _accumulateBuffer(_clientBuffer + chunk);
    } else {
      final existing = _serverBuffers[source] ?? '';
      _serverBuffers[source] = _accumulateBuffer(existing + chunk);
    }
  }

  void _handleClientClosed() {
    _client?.destroy();
    _client = null;
    connectedEndpoint = null;
  }

  void _handleServerClientClosed(Socket socket) {
    socket.destroy();
    _serverClients.remove(socket);
    _serverBuffers.remove(socket);
  }

  void _validateIp(String hostIp) {
    final parts = hostIp.split('.');
    if (parts.length != 4) {
      throw FormatException('Invalid IPv4 address');
    }
    for (final part in parts) {
      final value = int.tryParse(part);
      if (value == null || value < 0 || value > 255) {
        throw FormatException('Invalid IPv4 address');
      }
    }
  }

  Future<String?> _describeLocalEndpoint(int port) async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );
      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          if (!address.isLoopback) {
            return '${address.address}:$port';
          }
        }
      }
    } catch (err) {
      if (kDebugMode) {
        debugPrint('Unable to resolve local endpoint: $err');
      }
    }
    return '0.0.0.0:$port';
  }

  String _accumulateBuffer(String buffer) {
    var remaining = buffer;
    while (true) {
      final index = remaining.indexOf('\n');
      if (index == -1) {
        break;
      }
      final message = remaining.substring(0, index);
      remaining = remaining.substring(index + 1);
      if (message.trim().isEmpty) {
        continue;
      }
      try {
        _messageStream.add(message);
      } catch (err) {
        if (kDebugMode) {
          debugPrint('Failed to emit message: $err');
        }
      }
    }
    return remaining;
  }
}

final signalingServiceProvider = Provider<SignalingService>((ref) {
  final service = SignalingService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});
