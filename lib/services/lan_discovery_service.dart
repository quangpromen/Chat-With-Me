import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../data/models/peer.dart';

typedef RawDatagramSocketFactory =
    Future<RawDatagramSocket> Function(
      InternetAddress address,
      int port, {
      bool reuseAddress,
      bool reusePort,
    });

class LanDiscoveryService {
  LanDiscoveryService({RawDatagramSocketFactory? socketFactory})
    : _socketFactory = socketFactory ?? RawDatagramSocket.bind;

  static const int _discoveryPort = 53370;
  static const Duration _heartbeatInterval = Duration(seconds: 5);
  static const Duration _stalePeerThreshold = Duration(seconds: 15);
  static const String _messageType = 'lan_chat_discovery';

  final RawDatagramSocketFactory _socketFactory;
  final _peersController = StreamController<List<Peer>>.broadcast();
  final Map<String, _PeerRecord> _knownPeers = <String, _PeerRecord>{};

  RawDatagramSocket? _socket;
  Timer? _heartbeatTimer;
  Timer? _cleanupTimer;
  bool _running = false;
  String? _selfDeviceId;
  String? _selfName;
  bool _isHosting = false;
  int? _hostPort;

  Stream<List<Peer>> get peersStream => _peersController.stream;

  bool get isRunning => _running;

  Future<void> start({
    required String deviceId,
    required String displayName,
  }) async {
    _selfDeviceId = deviceId;
    _selfName = displayName;

    if (_running) {
      _announcePresence();
      return;
    }

    final socket = await _bindSocket();
    _socket = socket;
    _running = true;

    socket.broadcastEnabled = true;
    socket.listen(_onSocketEvent, onError: (_) => stop(), onDone: stop);

    _heartbeatTimer = Timer.periodic(
      _heartbeatInterval,
      (_) => _announcePresence(),
    );
    _cleanupTimer = Timer.periodic(
      _heartbeatInterval,
      (_) => _removeStalePeers(),
    );

    _announcePresence();
  }

  void updateIdentity({String? displayName}) {
    if (displayName != null) {
      _selfName = displayName;
    }
    if (_running) {
      _announcePresence();
    }
  }

  void setHostingStatus({required bool isHosting, int? port}) {
    _isHosting = isHosting;
    _hostPort = isHosting ? port : null;
    if (_running) {
      _announcePresence();
    }
  }

  void stop() {
    if (!_running) return;

    _heartbeatTimer?.cancel();
    _cleanupTimer?.cancel();
    _heartbeatTimer = null;
    _cleanupTimer = null;

    _socket?.close();
    _socket = null;
    _running = false;
    _isHosting = false;
    _hostPort = null;

    if (_knownPeers.isNotEmpty) {
      _knownPeers.clear();
      _emitPeers();
    }
  }

  void dispose() {
    stop();
    _peersController.close();
  }

  Future<RawDatagramSocket> _bindSocket() async {
    try {
      return await _socketFactory(
        InternetAddress.anyIPv4,
        _discoveryPort,
        reuseAddress: true,
        reusePort: true,
      );
    } on SocketException {
      return await _socketFactory(
        InternetAddress.anyIPv4,
        _discoveryPort,
        reuseAddress: true,
      );
    }
  }

  void _announcePresence() {
    final socket = _socket;
    if (socket == null || _selfDeviceId == null || _selfName == null) {
      return;
    }
    final payload = jsonEncode({
      'type': _messageType,
      'deviceId': _selfDeviceId,
      'name': _selfName,
      'ts': DateTime.now().toIso8601String(),
      'hosting': _isHosting,
      'port': _hostPort,
    });
    final data = utf8.encode(payload);
    socket.send(data, InternetAddress('255.255.255.255'), _discoveryPort);
  }

  void _removeStalePeers() {
    if (_knownPeers.isEmpty) {
      return;
    }
    final cutoff = DateTime.now().subtract(_stalePeerThreshold);
    final keysToRemove = _knownPeers.entries
        .where((entry) => entry.value.lastSeen.isBefore(cutoff))
        .map((entry) => entry.key)
        .toList(growable: false);
    if (keysToRemove.isEmpty) {
      return;
    }
    for (final key in keysToRemove) {
      _knownPeers.remove(key);
    }
    _emitPeers();
  }

  void _onSocketEvent(RawSocketEvent event) {
    if (event != RawSocketEvent.read) {
      return;
    }
    final socket = _socket;
    if (socket == null) return;

    final datagram = socket.receive();
    if (datagram == null) {
      return;
    }

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(utf8.decode(datagram.data)) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    if (decoded['type'] != _messageType) {
      return;
    }

    final senderId = decoded['deviceId'] as String?;
    final senderName = decoded['name'] as String?;
    if (senderId == null || senderName == null) {
      return;
    }
    if (senderId == _selfDeviceId) {
      return;
    }

    final now = DateTime.now();
    final peer = Peer(
      id: senderId,
      name: senderName,
      ip: datagram.address.address,
      verified: decoded['verified'] == true,
      lastSeen: now,
      isHosting: decoded['hosting'] == true,
      hostPort: _parsePort(decoded['port']),
    );

    final existing = _knownPeers[senderId];
    if (existing == null) {
      _knownPeers[senderId] = _PeerRecord(peer: peer, lastSeen: now);
    } else {
      existing
        ..peer = peer
        ..lastSeen = now;
    }
    _emitPeers();
  }

  void _emitPeers() {
    final list =
        _knownPeers.values.map((record) => record.peer).toList(growable: false)
          ..sort((a, b) => a.name.compareTo(b.name));
    _peersController.add(List<Peer>.unmodifiable(list));
  }
}

class _PeerRecord {
  _PeerRecord({required this.peer, required this.lastSeen});

  Peer peer;
  DateTime lastSeen;
}

int? _parsePort(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}
