import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kDiscoveryPort = 39777;
const _kPeerTimeout = Duration(seconds: 6);

class DiscoveryService {
  DiscoveryService._(this.deviceId);

  factory DiscoveryService() => DiscoveryService._(_generateDeviceId());

  final String deviceId;
  String? hostIp;
  bool isHost = false;

  RawDatagramSocket? _socket;
  Timer? _cleanupTimer;
  final Map<String, _PeerRecord> _peers = {};
  final StreamController<List<Map<String, dynamic>>> _peerStream =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<List<Map<String, dynamic>>> get peersStream => _peerStream.stream;

  Future<void> advertiseSelf({
    int port = 8080,
    String? name,
    bool asHost = false,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('LAN discovery is not supported on web builds');
    }
    await _ensureSocket();
    hostIp ??= await _resolvePrimaryIp();
    isHost = asHost;
    final payload = jsonEncode({
      'deviceId': deviceId,
      'port': port,
      'name': name ?? deviceId,
      'host': asHost,
    });
    final data = utf8.encode(payload);
    _socket!.send(
      data,
      InternetAddress('255.255.255.255'),
      _kDiscoveryPort,
    );
  }

  Future<List<Map<String, dynamic>>> scanPeers({
    int timeoutMs = 600,
    int expectedServicePort = 8080,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('LAN discovery is not supported on web builds');
    }
    await _ensureSocket();
    await advertiseSelf(port: expectedServicePort, asHost: false);
    await Future.delayed(Duration(milliseconds: max(timeoutMs, 200)));
    _prunePeers();
    return _currentPeers();
  }

  Future<void> electHost({int port = 8080}) async {
    await advertiseSelf(port: port, asHost: true);
  }

  Future<void> reconnectIfHostChanges() async {
    _prunePeers();
  }

  Future<void> dispose() async {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    _socket?.close();
    _socket = null;
    if (!_peerStream.isClosed) {
      await _peerStream.close();
    }
    _peers.clear();
    hostIp = null;
    isHost = false;
  }

  Future<void> _ensureSocket() async {
    if (_socket != null) return;
    try {
      _socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        _kDiscoveryPort,
        reuseAddress: true,
        reusePort: true,
      );
    } on SocketException {
      _socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        _kDiscoveryPort,
        reuseAddress: true,
      );
    }
    _socket!
      ..broadcastEnabled = true
      ..listen(_handleSocketEvent, onError: (Object error) {
        if (kDebugMode) {
          debugPrint('Discovery socket error: $error');
        }
      });
    _cleanupTimer =
        Timer.periodic(const Duration(seconds: 2), (_) => _prunePeers());
  }

  void _handleSocketEvent(RawSocketEvent event) {
    if (event != RawSocketEvent.read) {
      return;
    }
    final datagram = _socket?.receive();
    if (datagram == null) return;
    try {
      final payload = utf8.decode(datagram.data);
      final decoded = jsonDecode(payload) as Map<String, dynamic>;
      final senderId = decoded['deviceId'] as String?;
      if (senderId == null || senderId == deviceId) {
        return;
      }
      final port = (decoded['port'] as num?)?.toInt() ?? 8080;
      final key = '${datagram.address.address}:$port';
      _peers[key] = _PeerRecord(
        deviceId: senderId,
        name: (decoded['name'] as String?) ?? senderId,
        ip: datagram.address.address,
        port: port,
        isHost: decoded['host'] == true,
        lastSeen: DateTime.now(),
      );
      _emitPeers();
    } catch (err, stack) {
      if (kDebugMode) {
        debugPrint('Failed to parse discovery datagram: $err');
        debugPrint('$stack');
      }
    }
  }

  void _emitPeers() {
    if (_peerStream.isClosed) return;
    final peers = _currentPeers();
    try {
      _peerStream.add(peers);
    } catch (err) {
      if (kDebugMode) {
        debugPrint('Failed to emit peers: $err');
      }
    }
  }

  void _prunePeers() {
    final now = DateTime.now();
    final keysToRemove = _peers.entries
        .where((entry) => now.difference(entry.value.lastSeen) > _kPeerTimeout)
        .map((entry) => entry.key)
        .toList();
    for (final key in keysToRemove) {
      _peers.remove(key);
    }
    if (keysToRemove.isNotEmpty) {
      _emitPeers();
    }
  }

  List<Map<String, dynamic>> _currentPeers() {
    return _peers.values
        .map(
          (peer) => {
            'deviceId': peer.deviceId,
            'ip': peer.ip,
            'port': peer.port,
            'name': peer.name,
            'host': peer.isHost,
            'lastSeen': peer.lastSeen.toIso8601String(),
          },
        )
        .toList(growable: false);
  }

  static String _generateDeviceId() {
    final random = (_rng.nextInt(1 << 16)).toRadixString(16).padLeft(4, '0');
    final hostname = _tryGetHostname();
    return hostname != null ? '$hostname-$random' : 'device-$random';
  }

  static String? _tryGetHostname() {
    try {
      final value = Platform.localHostname.trim();
      return value.isEmpty ? null : value;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> _resolvePrimaryIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );
      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          if (!address.isLoopback) {
            return address.address;
          }
        }
      }
    } catch (err) {
      if (kDebugMode) {
        debugPrint('Unable to resolve local IP: $err');
      }
    }
    return null;
  }
}

class _PeerRecord {
  _PeerRecord({
    required this.deviceId,
    required this.name,
    required this.ip,
    required this.port,
    required this.isHost,
    required this.lastSeen,
  });

  final String deviceId;
  final String name;
  final String ip;
  final int port;
  final bool isHost;
  final DateTime lastSeen;
}

final Random _rng = Random();

final discoveryServiceProvider = Provider<DiscoveryService>((ref) {
  final service = DiscoveryService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});
