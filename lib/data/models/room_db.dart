import 'package:hive/hive.dart';
import 'room.dart';
part 'room_db.g.dart';

@HiveType(typeId: 2)
class RoomDb {
  @HiveField(0)
  late String roomId;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late DateTime createdAt;

  @HiveField(3)
  late String? hostId;

  @HiveField(4)
  late List<String> members;

  @HiveField(5)
  String? password;

  @HiveField(6)
  RoomAccessMethod accessMethod = RoomAccessMethod.open;

  RoomDb();

  RoomDb.fromRoom({
    required String id,
    required String name,
    required DateTime createdAt,
    String? hostId,
    List<String>? members,
    String? password,
    RoomAccessMethod accessMethod = RoomAccessMethod.open,
  }) : roomId = id,
       name = name,
       createdAt = createdAt,
       hostId = hostId,
       members = members ?? <String>[],
       password = password,
       accessMethod = accessMethod;
}
