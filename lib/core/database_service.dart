import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/models/message.dart';
import '../data/models/peer_db.dart';
import '../data/models/room_db.dart';
import '../data/models/peer.dart';
import '../data/models/room.dart';
import '../providers/app_state.dart';

class DatabaseService {
  late Box _settingsBox;
  late Box<Message> _messagesBox;
  late Box<PeerDb> _peersBox;
  late Box<RoomDb> _roomsBox;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      // Register Hive adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(MessageAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(PeerDbAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(RoomDbAdapter());
      }

      // Initialize Hive for Flutter
      if (!kIsWeb) {
        await Hive.initFlutter();
      }

      // Open boxes
      _messagesBox = await Hive.openBox<Message>('messages');
      _peersBox = await Hive.openBox<PeerDb>('peers');
      _roomsBox = await Hive.openBox<RoomDb>('rooms');
      _settingsBox = await Hive.openBox('settings');

      _initialized = true;
    } catch (err) {
      if (kDebugMode) {
        debugPrint('Failed to initialize Hive database: $err');
      }
    }
  }

  // Permissions persistence
  Future<void> savePermissions(Set permissions) async {
    if (!_initialized) return;
    try {
      await _settingsBox.put(
        'permissions',
        permissions.map((e) => e.toString()).toList(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving permissions: $e');
      }
    }
  }

  Set<AppPermission> loadPermissions() {
    if (!_initialized) return <AppPermission>{};
    try {
      final list = _settingsBox.get('permissions', defaultValue: <dynamic>[]);
      return Set<AppPermission>.from(
        list.map((e) {
          final name = e.toString().split('.').last;
          return AppPermission.values.firstWhere(
            (p) => p.toString().split('.').last == name,
          );
        }),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading permissions: $e');
      }
      return <AppPermission>{};
    }
  }

  bool get isAvailable => _initialized;

  // Message operations
  Future<void> saveMessage(Message message) async {
    if (!_initialized) return;
    try {
      await _messagesBox.put(message.id, message);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving message: $e');
      }
    }
  }

  Future<List<Message>> loadMessagesForRoom(String roomId) async {
    if (!_initialized) return [];
    try {
      return _messagesBox.values.where((msg) => msg.roomId == roomId).toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading messages for room: $e');
      }
      return [];
    }
  }

  Future<void> deleteMessagesForRoom(String roomId) async {
    if (!_initialized) return;
    try {
      final keysToDelete = <dynamic>[];
      for (final key in _messagesBox.keys) {
        final message = _messagesBox.get(key);
        if (message != null && message.roomId == roomId) {
          keysToDelete.add(key);
        }
      }
      await _messagesBox.deleteAll(keysToDelete);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting messages for room: $e');
      }
    }
  }

  // Peer operations
  Future<void> savePeer(Peer peer) async {
    if (!_initialized) return;
    try {
      final peerDb = PeerDb.fromPeer(
        id: peer.id,
        name: peer.name,
        ip: peer.ip,
        verified: peer.verified,
        lastSeen: peer.lastSeen,
        isHosting: peer.isHosting,
        hostPort: peer.hostPort,
      );
      await _peersBox.put(peer.id, peerDb);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving peer: $e');
      }
    }
  }

  Future<List<Peer>> loadAllPeers() async {
    if (!_initialized) return [];
    try {
      final peersDb = _peersBox.values.toList()
        ..sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
      return peersDb
          .map(
            (p) => Peer(
              id: p.peerId,
              name: p.name,
              ip: p.ip,
              verified: p.verified,
              lastSeen: p.lastSeen,
              isHosting: p.isHosting,
              hostPort: p.hostPort,
            ),
          )
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading peers: $e');
      }
      return [];
    }
  }

  Future<void> deletePeer(String peerId) async {
    if (!_initialized) return;
    try {
      await _peersBox.delete(peerId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting peer: $e');
      }
    }
  }

  Future<void> deleteOldPeers(Duration maxAge) async {
    if (!_initialized) return;
    try {
      final cutoff = DateTime.now().subtract(maxAge);
      final keysToDelete = <dynamic>[];
      for (final key in _peersBox.keys) {
        final peer = _peersBox.get(key);
        if (peer != null && peer.lastSeen.isBefore(cutoff)) {
          keysToDelete.add(key);
        }
      }
      await _peersBox.deleteAll(keysToDelete);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting old peers: $e');
      }
    }
  }

  // Room operations
  Future<void> saveRoom(Room room) async {
    if (!_initialized) return;
    try {
      final roomDb = RoomDb.fromRoom(
        id: room.id,
        name: room.name,
        createdAt: room.createdAt,
        hostId: room.hostId,
        members: room.members,
      );
      await _roomsBox.put(room.id, roomDb);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving room: $e');
      }
    }
  }

  Future<List<Room>> loadAllRooms() async {
    if (!_initialized) return [];
    try {
      final roomsDb = _roomsBox.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return roomsDb
          .map(
            (r) => Room(
              id: r.roomId,
              name: r.name,
              createdAt: r.createdAt,
              hostId: r.hostId,
              members: List<String>.from(r.members),
            ),
          )
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading rooms: $e');
      }
      return [];
    }
  }

  Future<Room?> loadRoom(String roomId) async {
    if (!_initialized) return null;
    try {
      final roomDb = _roomsBox.get(roomId);
      if (roomDb == null) return null;
      return Room(
        id: roomDb.roomId,
        name: roomDb.name,
        createdAt: roomDb.createdAt,
        hostId: roomDb.hostId,
        members: List<String>.from(roomDb.members),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading room: $e');
      }
      return null;
    }
  }

  Future<void> deleteRoom(String roomId) async {
    if (!_initialized) return;
    try {
      await _roomsBox.delete(roomId);
      await deleteMessagesForRoom(roomId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting room: $e');
      }
    }
  }

  Future<void> close() async {
    try {
      await _messagesBox.close();
      await _peersBox.close();
      await _roomsBox.close();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error closing database: $e');
      }
    }
    _initialized = false;
  }
}

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final service = DatabaseService();
  ref.onDispose(() {
    service.close();
  });
  return service;
});
