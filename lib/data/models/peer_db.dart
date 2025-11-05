import 'package:hive/hive.dart';
part 'peer_db.g.dart';

@HiveType(typeId: 1)
class PeerDb {
  @HiveField(0)
  late String peerId;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String ip;

  @HiveField(3)
  late bool verified;

  @HiveField(4)
  late DateTime lastSeen;

  @HiveField(5)
  late bool isHosting;

  @HiveField(6)
  late int? hostPort;

  PeerDb();

  PeerDb.fromPeer({
    required String id,
    required String name,
    required String ip,
    required bool verified,
    required DateTime lastSeen,
    bool isHosting = false,
    int? hostPort,
  }) : peerId = id,
       name = name,
       ip = ip,
       verified = verified,
       lastSeen = lastSeen,
       isHosting = isHosting,
       hostPort = hostPort;
}
