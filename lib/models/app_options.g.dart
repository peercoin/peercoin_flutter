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
      fields[1] as bool?,
    )
      .._authenticationOptions = (fields[0] as Map?)?.cast<String, bool>()
      .._defaultWallet = fields[2] as String?
      .._selectedCurrency = fields[3] as String?
      .._latestTickerUpdate = fields[4] as DateTime?
      .._exchangeRates = (fields[5] as Map?)?.cast<String, dynamic>();
  }

  @override
  void write(BinaryWriter writer, AppOptionsStore obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj._authenticationOptions)
      ..writeByte(1)
      ..write(obj._allowBiometrics)
      ..writeByte(2)
      ..write(obj._defaultWallet)
      ..writeByte(3)
      ..write(obj._selectedCurrency)
      ..writeByte(4)
      ..write(obj._latestTickerUpdate)
      ..writeByte(5)
      ..write(obj._exchangeRates);
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
