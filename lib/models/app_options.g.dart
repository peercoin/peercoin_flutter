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
      fields[1] == null ? false : fields[1] as bool,
      fields[10] == null ? false : fields[10] as bool,
    )
      .._defaultWallet = fields[2] == null ? '' : fields[2] as String
      .._selectedCurrency = fields[3] == null ? '' : fields[3] as String
      .._latestTickerUpdate = fields[4] as DateTime?
      .._exchangeRates =
          fields[5] == null ? {} : (fields[5] as Map).cast<String, dynamic>()
      .._buildIdentifier = fields[6] == null ? '' : fields[6] as String
      .._notificationInterval = fields[7] == null ? 0 : fields[7] as int
      .._notificationActiveWallets =
          fields[8] == null ? [] : (fields[8] as List).cast<String>()
      .._periodicReminterItemsNextView =
          fields[9] == null ? {} : (fields[9] as Map).cast<String, DateTime>();
  }

  @override
  void write(BinaryWriter writer, AppOptionsStore obj) {
    writer
      ..writeByte(11)
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
      ..write(obj._exchangeRates)
      ..writeByte(6)
      ..write(obj._buildIdentifier)
      ..writeByte(7)
      ..write(obj._notificationInterval)
      ..writeByte(8)
      ..write(obj._notificationActiveWallets)
      ..writeByte(9)
      ..write(obj._periodicReminterItemsNextView)
      ..writeByte(10)
      ..write(obj._ledgerMode);
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
