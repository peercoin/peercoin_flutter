// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'frost_group.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FrostGroupAdapter extends TypeAdapter<FrostGroup> {
  @override
  final int typeId = 8;

  @override
  FrostGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FrostGroup(
      fields[0] as String,
      fields[1] as bool,
    )
      .._clientConfig = fields[2] as ClientConfig?
      .._serverUrl = fields[3] as String?;
  }

  @override
  void write(BinaryWriter writer, FrostGroup obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj._name)
      ..writeByte(1)
      ..write(obj._isCompleted)
      ..writeByte(2)
      ..write(obj._clientConfig)
      ..writeByte(3)
      ..write(obj._serverUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FrostGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}