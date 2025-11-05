import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Simple TCP server that coordinates chat rooms for LAN peers.
class LanChatServer {
  LanChatServer({this.port = 53371});

  final int port;
  ServerSocket? _server;
  String? _hostDeviceId;

  final Map<Socket, _ClientConnection> _clients = <Socket, _ClientConnection>{};
  final StreamController<LanHostEvent> _eventController =
      StreamController<LanHostEvent>.broadcast();

  List<Map<String, dynamic>> _roomsSnapshot = const <Map<String, dynamic>>[];
  Map<String, List<Map<String, dynamic>>> _messagesSnapshot =
      const <String, List<Map<String, dynamic>>>{};

  Stream<LanHostEvent> get events => _eventController.stream;
  bool get isRunning => _server != null;

  Future<void> start({required String deviceId}) async {
    if (_server != null) {
      return;
    }
    _hostDeviceId = deviceId;
    final server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    _server = server;
    server.listen(
      _handleClient,
      onError: (_) => unawaited(stop()),
      onDone: () => unawaited(stop()),
    );
  }

  Future<void> stop() async {
    final server = _server;
    if (server == null) {
      return;
    }
    _server = null;
    await server.close();

    final cancelFutures = <Future<void>>[];
    for (final entry in _clients.values) {
      cancelFutures.add(entry.subscription.cancel());
      entry.socket.destroy();
    }
    _clients.clear();
    if (cancelFutures.isNotEmpty) {
      await Future.wait(cancelFutures, eagerError: false);
    }
  }

  void dispose() {
    if (!_eventController.isClosed) {
      _eventController.close();
    }
    unawaited(stop());
  }

  void replaceState({
    required List<Map<String, dynamic>> rooms,
    required Map<String, List<Map<String, dynamic>>> messages,
  }) {
    _roomsSnapshot = rooms;
    _messagesSnapshot = messages;
  }

  void broadcastRoom(Map<String, dynamic> room) {
    if (_clients.isEmpty) {
      return;
    }
    final payload = <String, dynamic>{'type': 'room_created', 'room': room};
    _broadcast(payload);
  }

  void broadcastMessage(Map<String, dynamic> message) {
    if (_clients.isEmpty) {
      return;
    }
    final payload = <String, dynamic>{
      'type': 'message_posted',
      'message': message,
    };
    _broadcast(payload);
  }

  void _broadcast(Map<String, dynamic> payload) {
    final encoded = jsonEncode(payload);
    for (final info in _clients.values) {
      _safeSend(info, encoded);
    }
  }

  void _handleClient(Socket socket) {
    final connection = _ClientConnection(socket: socket);
    _clients[socket] = connection;
    connection.subscription = utf8.decoder
        .bind(socket)
        .transform(const LineSplitter())
        .listen(
          (line) => _handleMessage(connection, line),
          onError: (_) => _removeClient(connection),
          onDone: () => _removeClient(connection),
          cancelOnError: true,
        );
  }

  void _removeClient(_ClientConnection connection) {
    connection.subscription.cancel();
    _clients.remove(connection.socket);
    connection.socket.destroy();

    if (connection.deviceId != null && !_eventController.isClosed) {
      _eventController.add(
        ClientDisconnectedEvent(
          deviceId: connection.deviceId!,
          displayName: connection.displayName ?? 'Unknown',
        ),
      );
    }
  }

  void _handleMessage(_ClientConnection connection, String line) {
    Map<String, dynamic> message;
    try {
      message = jsonDecode(line) as Map<String, dynamic>;
    } catch (_) {
      _safeSend(
        connection,
        jsonEncode(<String, dynamic>{'type': 'error', 'code': 'invalid_json'}),
      );
      return;
    }

    final type = message['type'];
    switch (type) {
      case 'hello':
        _handleHello(connection, message);
        break;
      case 'create_room':
        _handleCreateRoom(connection, message);
        break;
      case 'send_message':
        _handleSendMessage(connection, message);
        break;
      default:
        _safeSend(
          connection,
          jsonEncode(<String, dynamic>{
            'type': 'error',
            'code': 'unknown_type',
          }),
        );
    }
  }

  void _handleHello(
    _ClientConnection connection,
    Map<String, dynamic> payload,
  ) {
    final deviceId = payload['deviceId'] as String?;
    final displayName = payload['displayName'] as String?;
    if (deviceId == null || deviceId.isEmpty) {
      _safeSend(
        connection,
        jsonEncode(<String, dynamic>{
          'type': 'error',
          'code': 'missing_device_id',
        }),
      );
      return;
    }

    connection
      ..deviceId = deviceId
      ..displayName = displayName;

    final welcome = <String, dynamic>{
      'type': 'welcome',
      'hostDeviceId': _hostDeviceId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    _safeSend(connection, jsonEncode(welcome));
    _sendFullState(connection);

    if (!_eventController.isClosed) {
      _eventController.add(
        ClientRegisteredEvent(
          deviceId: deviceId,
          displayName: displayName ?? 'Guest',
        ),
      );
    }
  }

  void _handleCreateRoom(
    _ClientConnection connection,
    Map<String, dynamic> payload,
  ) {
    final name = (payload['name'] as String?)?.trim();
    if (name == null || name.isEmpty || connection.deviceId == null) {
      return;
    }
    if (!_eventController.isClosed) {
      _eventController.add(
        ClientCreateRoomEvent(
          deviceId: connection.deviceId!,
          displayName: connection.displayName ?? 'Guest',
          roomName: name,
        ),
      );
    }
  }

  void _handleSendMessage(
    _ClientConnection connection,
    Map<String, dynamic> payload,
  ) {
    final roomId = payload['roomId'] as String?;
    final text = (payload['text'] as String?)?.trim();
    if (roomId == null || roomId.isEmpty || text == null || text.isEmpty) {
      return;
    }
    if (connection.deviceId == null) {
      return;
    }
    if (!_eventController.isClosed) {
      _eventController.add(
        ClientSendMessageEvent(
          deviceId: connection.deviceId!,
          displayName: connection.displayName ?? 'Guest',
          roomId: roomId,
          text: text,
        ),
      );
    }
  }

  void _sendFullState(_ClientConnection connection) {
    final payload = <String, dynamic>{
      'type': 'state',
      'rooms': _roomsSnapshot,
      'messages': _messagesSnapshot,
    };
    _safeSend(connection, jsonEncode(payload));
  }

  void _safeSend(_ClientConnection connection, String encoded) {
    try {
      connection.socket.write(encoded);
      connection.socket.write('\n');
    } catch (_) {
      _removeClient(connection);
    }
  }
}

abstract class LanHostEvent {}

class ClientRegisteredEvent extends LanHostEvent {
  ClientRegisteredEvent({required this.deviceId, required this.displayName});

  final String deviceId;
  final String displayName;
}

class ClientCreateRoomEvent extends LanHostEvent {
  ClientCreateRoomEvent({
    required this.deviceId,
    required this.displayName,
    required this.roomName,
  });

  final String deviceId;
  final String displayName;
  final String roomName;
}

class ClientSendMessageEvent extends LanHostEvent {
  ClientSendMessageEvent({
    required this.deviceId,
    required this.displayName,
    required this.roomId,
    required this.text,
  });

  final String deviceId;
  final String displayName;
  final String roomId;
  final String text;
}

class ClientDisconnectedEvent extends LanHostEvent {
  ClientDisconnectedEvent({required this.deviceId, required this.displayName});

  final String deviceId;
  final String displayName;
}

class _ClientConnection {
  _ClientConnection({required this.socket});

  final Socket socket;
  late final StreamSubscription<String> subscription;
  String? deviceId;
  String? displayName;
}
