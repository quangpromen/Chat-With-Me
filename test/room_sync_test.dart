import 'package:flutter_test/flutter_test.dart';
import '../lib/core/database_service.dart';
import '../lib/data/models/room.dart';

void main() {
  group('Room Sync', () {
    late DatabaseService db;

    setUp(() async {
      db = DatabaseService();
      await db.initialize();
    });

    test('Room list updates on create', () async {
      final room1 = Room(
        id: 'sync-room-1',
        name: 'Sync Room 1',
        createdAt: DateTime.now(),
        hostId: 'host-1',
        members: ['A'],
      );
      await db.saveRoom(room1);
      final rooms = await db.loadAllRooms();
      expect(rooms.any((r) => r.id == 'sync-room-1'), isTrue);
    });

    test('Room list updates on delete', () async {
      final room2 = Room(
        id: 'sync-room-2',
        name: 'Sync Room 2',
        createdAt: DateTime.now(),
        hostId: 'host-2',
        members: ['B'],
      );
      await db.saveRoom(room2);
      await db.deleteRoom('sync-room-2');
      final rooms = await db.loadAllRooms();
      expect(rooms.any((r) => r.id == 'sync-room-2'), isFalse);
    });
  });
}
