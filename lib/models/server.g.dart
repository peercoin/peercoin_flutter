// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServerAdapter extends TypeAdapter<Server> {
  @override
  final int typeId = 6;

  @override
  Server read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Server(
      address: fields[1] as InternetAddress,
    )
      ..label = fields[0] as String
      ..connectable = fields[2] as bool
      ..userGenerated = fields[3] as bool
      ..donationAddress = fields[4] as String
      ..serverBanner = fields[5] as String
      ..lastConnection = fields[6] as DateTime;
  }

  @override
  void write(BinaryWriter writer, Server obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.connectable)
      ..writeByte(3)
      ..write(obj.userGenerated)
      ..writeByte(4)
      ..write(obj.donationAddress)
      ..writeByte(5)
      ..write(obj.serverBanner)
      ..writeByte(6)
      ..write(obj.lastConnection);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
