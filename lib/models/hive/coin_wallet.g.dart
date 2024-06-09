// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_wallet.dart';

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
      fields[9] == null ? 0 : fields[9] as int,
      fields[10] == null ? false : fields[10] as bool,
      fields[11] == null ? false : fields[11] as bool,
    )
      .._addresses = (fields[2] as List).cast<WalletAddress>()
      .._transactions = (fields[3] as List).cast<WalletTransaction>()
      .._utxos = (fields[4] as List).cast<WalletUtxo>()
      .._balance = fields[5] as int
      .._unconfirmedBalance = fields[7] as int
      .._pendingTransactionNotifications =
          (fields[8] as List?)?.cast<PendingNotification>()
      .._hidden = fields[12] == null ? false : fields[12] as bool;
  }

  @override
  void write(BinaryWriter writer, CoinWallet obj) {
    writer
      ..writeByte(13)
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
      ..write(obj._unconfirmedBalance)
      ..writeByte(8)
      ..write(obj._pendingTransactionNotifications)
      ..writeByte(9)
      ..write(obj._walletIndex)
      ..writeByte(10)
      ..write(obj._dueForRescan)
      ..writeByte(11)
      ..write(obj._watchOnly)
      ..writeByte(12)
      ..write(obj._hidden);
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
