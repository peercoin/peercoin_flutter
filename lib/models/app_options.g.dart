// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_options.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppOptionsStoreAdapter extends TypeAdapter<AppOptionsStore> {
  @override
  final int typeId = 5;

  @override
  AppOptionsStore read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppOptionsStore(
      fields[1] as bool,
    ).._authenticationOptions = (fields[0] as Map)?.cast<String, bool>();
  }

  @override
  void write(BinaryWriter writer, AppOptionsStore obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj._authenticationOptions)
      ..writeByte(1)
      ..write(obj._allowBiometrics);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppOptionsStoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
