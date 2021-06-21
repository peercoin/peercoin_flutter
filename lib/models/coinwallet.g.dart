// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coinwallet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CoinWalletAdapter extends TypeAdapter<CoinWallet> {
  @override
  final int typeId = 1;

  @override
  CoinWallet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CoinWallet(
      fields[0] as String,
      fields[6] as String,
      fields[1] as String,
    )
      .._addresses = (fields[2] as List).cast<WalletAddress>()
      .._transactions = (fields[3] as List).cast<WalletTransaction>()
      .._utxos = (fields[4] as List).cast<WalletUtxo>()
      .._balance = fields[5] as int
      .._unconfirmedBalance = fields[7] as int;
  }

  @override
  void write(BinaryWriter writer, CoinWallet obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj._name)
      ..writeByte(1)
      ..write(obj._letterCode)
      ..writeByte(2)
      ..write(obj._addresses)
      ..writeByte(3)
      ..write(obj._transactions)
      ..writeByte(4)
      ..write(obj._utxos)
      ..writeByte(5)
      ..write(obj._balance)
      ..writeByte(6)
      ..write(obj._title)
      ..writeByte(7)
      ..write(obj._unconfirmedBalance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoinWalletAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
