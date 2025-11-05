import 'package:hive/hive.dart';
part 'message.g.dart';

@HiveType(typeId: 0)
class Message {
  @HiveField(0)
  String id;

  @HiveField(1)
  late String roomId;

  @HiveField(2)
  late String senderId;

  @HiveField(3)
  late String senderName;

  @HiveField(4)
  late String content;

  @HiveField(5)
  late DateTime timestamp;

  @HiveField(6)
  late bool fromSelf;

  Message({String? id})
    : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Message.fromMap(Map<String, dynamic> map)
    : id =
          map['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      roomId = map['roomId'] as String,
      senderId = map['senderId'] as String? ?? '',
      senderName = map['senderName'] as String,
      content = map['content'] as String,
      timestamp = DateTime.parse(map['timestamp'] as String),
      fromSelf = map['fromSelf'] as bool? ?? false;

  Map<String, dynamic> toMap() => {
    'id': id,
    'roomId': roomId,
    'senderId': senderId,
    'senderName': senderName,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'fromSelf': fromSelf,
  };
}
