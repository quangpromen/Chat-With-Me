// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'peer_db.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PeerDbAdapter extends TypeAdapter<PeerDb> {
  @override
  final int typeId = 1;

  @override
  PeerDb read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PeerDb()
      ..peerId = fields[0] as String
      ..name = fields[1] as String
      ..ip = fields[2] as String
      ..verified = fields[3] as bool
      ..lastSeen = fields[4] as DateTime
      ..isHosting = fields[5] as bool
      ..hostPort = fields[6] as int?;
  }

  @override
  void write(BinaryWriter writer, PeerDb obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.peerId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.ip)
      ..writeByte(3)
      ..write(obj.verified)
      ..writeByte(4)
      ..write(obj.lastSeen)
      ..writeByte(5)
      ..write(obj.isHosting)
      ..writeByte(6)
      ..write(obj.hostPort);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeerDbAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
