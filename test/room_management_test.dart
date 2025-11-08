import 'package:flutter_test/flutter_test.dart';
import '../lib/core/database_service.dart';
import '../lib/data/models/room.dart';

void main() {
  group('Room Management', () {
    late DatabaseService db;

    setUp(() async {
      db = DatabaseService();
      await db.initialize();
    });

    test('Create and load room', () async {
      final room = Room(
        id: 'test-room',
        name: 'Test Room',
        createdAt: DateTime.now(),
        hostId: 'host-1',
        members: ['Alice', 'Bob'],
      );
      await db.saveRoom(room);
      final loaded = await db.loadRoom('test-room');
      expect(loaded, isNotNull);
      expect(loaded!.name, 'Test Room');
      expect(loaded.members, contains('Alice'));
    });

    test('Delete room', () async {
      final room = Room(
        id: 'delete-room',
        name: 'Delete Room',
        createdAt: DateTime.now(),
        hostId: 'host-2',
        members: ['Charlie'],
      );
      await db.saveRoom(room);
      await db.deleteRoom('delete-room');
      final loaded = await db.loadRoom('delete-room');
      expect(loaded, isNull);
    });
  });
}
