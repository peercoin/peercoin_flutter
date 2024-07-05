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
    return FrostGroup();
  }

  @override
  void write(BinaryWriter writer, FrostGroup obj) {
    writer.writeByte(0);
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
