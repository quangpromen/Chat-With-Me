// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_db.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoomDbAdapter extends TypeAdapter<RoomDb> {
  @override
  final int typeId = 2;

  @override
  RoomDb read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoomDb()
      ..roomId = fields[0] as String
      ..name = fields[1] as String
      ..createdAt = fields[2] as DateTime
      ..hostId = fields[3] as String?
      ..members = (fields[4] as List).cast<String>();
  }

  @override
  void write(BinaryWriter writer, RoomDb obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.roomId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.hostId)
      ..writeByte(4)
      ..write(obj.members);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomDbAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
