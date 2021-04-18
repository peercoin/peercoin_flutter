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
      address: fields[1] as String,
      priority: fields[8] as int,
    )
      .._label = fields[0] as String
      .._connectable = fields[2] as bool
      .._userGenerated = fields[3] as bool
      .._donationAddress = fields[4] as String
      .._serverBanner = fields[5] as String
      .._lastConnection = fields[6] as DateTime
      .._hidden = fields[7] as bool;
  }

  @override
  void write(BinaryWriter writer, Server obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj._label)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj._connectable)
      ..writeByte(3)
      ..write(obj._userGenerated)
      ..writeByte(4)
      ..write(obj._donationAddress)
      ..writeByte(5)
      ..write(obj._serverBanner)
      ..writeByte(6)
      ..write(obj._lastConnection)
      ..writeByte(7)
      ..write(obj._hidden)
      ..writeByte(8)
      ..write(obj.priority);
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
