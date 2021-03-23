// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_options.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppOptionsAdapter extends TypeAdapter<AppOptions> {
  @override
  final int typeId = 5;

  @override
  AppOptions read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppOptions()
      .._authenticationOptions = (fields[0] as Map)?.cast<String, bool>();
  }

  @override
  void write(BinaryWriter writer, AppOptions obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj._authenticationOptions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppOptionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
