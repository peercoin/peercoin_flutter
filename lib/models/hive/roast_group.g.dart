// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roast_group.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ROASTGroupAdapter extends TypeAdapter<ROASTGroup> {
  @override
  final int typeId = 8;

  @override
  ROASTGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ROASTGroup(
      fields[0] as String,
      fields[1] as bool,
    )
      .._clientConfig = fields[2] as ClientConfig?
      .._serverUrl = fields[3] as String?
      .._groupId = fields[4] as String?
      .._participantNames =
          fields[5] == null ? {} : (fields[5] as Map).cast<String, String>();
  }

  @override
  void write(BinaryWriter writer, ROASTGroup obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj._name)
      ..writeByte(1)
      ..write(obj._isCompleted)
      ..writeByte(2)
      ..write(obj._clientConfig)
      ..writeByte(3)
      ..write(obj._serverUrl)
      ..writeByte(4)
      ..write(obj._groupId)
      ..writeByte(5)
      ..write(obj._participantNames);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ROASTGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
