import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_offline/core/signaling_service.dart';
import 'package:chat_offline/core/database_service.dart';
import 'package:chat_offline/data/models/message.dart';

class ChatService {
  ChatService(this._signaling, this._database) {
    _messageSubscription = _signaling.messages.listen(_handleInboundMessage);
    _initializeDatabase();
  }

  final SignalingService _signaling;
  final DatabaseService _database;
  final Map<String, List<Map<String, dynamic>>> _messagesByRoom =
      <String, List<Map<String, dynamic>>>{};
  final Map<String, Set<String>> _messageIdsByRoom =
      <String, Set<String>>{};
  final Map<String, StreamController<List<Map<String, dynamic>>>>
      _roomControllers = <String, StreamController<List<Map<String, dynamic>>>>{};
  late final StreamSubscription<String> _messageSubscription;
  bool _databaseInitialized = false;

  static final Random _random = Random();

  Future<void> _initializeDatabase() async {
    if (_databaseInitialized) return;
    await _database.initialize();
    _databaseInitialized = true;
  }

  Future<List<Map<String, dynamic>>> loadMessages(String roomId) async {
    // Load from database if not in memory
    if (!_messagesByRoom.containsKey(roomId) && _database.isAvailable) {
      final dbMessages = await _database.loadMessagesForRoom(roomId);
      final messages = dbMessages.map((m) => m.toMap()).toList();
      _messagesByRoom[roomId] = messages;
      _messageIdsByRoom[roomId] = dbMessages.map((m) => m.id.toString()).toSet();
    }
    return List<Map<String, dynamic>>.unmodifiable(
      _messagesByRoom[roomId] ?? const <Map<String, dynamic>>[],
    );
  }

  Stream<List<Map<String, dynamic>>> watchRoom(String roomId) {
    final controller = _roomControllers.putIfAbsent(
      roomId,
      () => StreamController<List<Map<String, dynamic>>>.broadcast(
        onListen: () => _emitRoom(roomId),
        onCancel: () {
          final roomController = _roomControllers[roomId];
          if (roomController != null && !roomController.hasListener) {
            _roomControllers.remove(roomId);
          }
        },
      ),
    );
    return controller.stream;
  }

  Future<Map<String, dynamic>> sendMessage({
    required String roomId,
    required String senderId,
    required String senderName,
    required String content,
  }) async {
    final messageId = _generateMessageId();
    final timestamp = DateTime.now().toUtc();
    final payload = <String, dynamic>{
      'type': 'chat_message',
      'id': messageId,
      'roomId': roomId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'relay': false,
    };

    _storeMessage(payload, fromSelf: true);

    try {
      await _signaling.sendString(jsonEncode(payload));
    } catch (err) {
      if (kDebugMode) {
        debugPrint('Failed to send message: $err');
      }
      rethrow;
    }

    return payload;
  }

  void dispose() {
    _messageSubscription.cancel();
    for (final controller in _roomControllers.values) {
      controller.close();
    }
    _roomControllers.clear();
  }

  void _handleInboundMessage(String raw) {
    if (raw.isEmpty) {
      return;
    }
    Map<String, dynamic>? decoded;
    try {
      decoded = jsonDecode(raw) as Map<String, dynamic>;
    } catch (err) {
      if (kDebugMode) {
        debugPrint('Unable to decode signaling payload: $err');
      }
      return;
    }

    final type = decoded['type'];
    if (type == 'chat_message') {
      final wasStored = _storeMessage(decoded, fromSelf: false);
      if (wasStored && _signaling.isServer && decoded['relay'] != true) {
        final relayPayload = Map<String, dynamic>.from(decoded)
          ..['relay'] = true;
        unawaited(
          _signaling.sendString(jsonEncode(relayPayload)),
        );
      }
    }
  }

  bool _storeMessage(Map<String, dynamic> packet, {required bool fromSelf}) {
    final roomId = packet['roomId'] as String?;
    final messageId = packet['id'] as String?;
    if (roomId == null || messageId == null) {
      return false;
    }

    final store = _messagesByRoom.putIfAbsent(
      roomId,
      () => <Map<String, dynamic>>[],
    );
    final idSet = _messageIdsByRoom.putIfAbsent(
      roomId,
      () => <String>{},
    );
    if (idSet.contains(messageId)) {
      return false;
    }
    idSet.add(messageId);

    final timestamp = packet['timestamp'];
    final messageData = <String, dynamic>{
      'id': messageId,
      'roomId': roomId,
      'senderId': packet['senderId'],
      'senderName': packet['senderName'],
      'content': packet['content'],
      'timestamp': timestamp,
      'fromSelf': fromSelf,
    };
    store.add(messageData);
    
    // Save to database
    if (_database.isAvailable) {
      try {
        final message = Message.fromMap(messageData);
        unawaited(_database.saveMessage(message));
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to save message to database: $e');
        }
      }
    }
    
    _emitRoom(roomId);
    return true;
  }

  void _emitRoom(String roomId) {
    final controller = _roomControllers[roomId];
    if (controller == null || controller.isClosed) {
      return;
    }
    final data = List<Map<String, dynamic>>.unmodifiable(
      _messagesByRoom[roomId] ?? const <Map<String, dynamic>>[],
    );
    try {
      controller.add(data);
    } catch (err) {
      if (kDebugMode) {
        debugPrint('Failed to emit room update: $err');
      }
    }
  }

  String _generateMessageId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    final randomPart = _random.nextInt(0xFFFFFFFF).toRadixString(16).padLeft(8, '0');
    return '$timestamp$randomPart';
  }
}

final chatServiceProvider = Provider<ChatService>((ref) {
  final chatService = ChatService(
    ref.read(signalingServiceProvider),
    ref.read(databaseServiceProvider),
  );
  ref.onDispose(chatService.dispose);
  return chatService;
});
