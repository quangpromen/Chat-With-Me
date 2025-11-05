class Peer {
  const Peer({
    required this.id,
    required this.name,
    required this.ip,
    required this.verified,
    required this.lastSeen,
    this.isHosting = false,
    this.hostPort,
  });

  final String id;
  final String name;
  final String ip;
  final bool verified;
  final DateTime lastSeen;
  final bool isHosting;
  final int? hostPort;
}
