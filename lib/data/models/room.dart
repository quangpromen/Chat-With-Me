class Room {
  Room({
    required this.id,
    required this.name,
    required this.createdAt,
    this.hostId,
    List<String>? members,
  }) : members = members ?? <String>[];

  final String id;
  final String name;
  final DateTime createdAt;
  final String? hostId;
  final List<String> members;
}
