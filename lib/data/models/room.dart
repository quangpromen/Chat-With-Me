enum RoomAccessMethod { open, password, manual }

class Room {
  Room({
    required this.id,
    required this.name,
    required this.createdAt,
    this.hostId,
    List<String>? members,
    this.password,
    this.accessMethod = RoomAccessMethod.open,
  }) : members = members ?? <String>[];

  final String id;
  final String name;
  final DateTime createdAt;
  final String? hostId;
  final List<String> members;
  final String? password;
  final RoomAccessMethod accessMethod;
}
