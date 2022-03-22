// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WalletTransactionAdapter extends TypeAdapter<WalletTransaction> {
  @override
  final int typeId = 3;

  @override
  WalletTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WalletTransaction(
      txid: fields[0] as String,
      timestamp: fields[1] as int?,
      value: fields[2] as int,
      fee: fields[3] as int,
      address: fields[4] as String,
      direction: fields[5] as String,
      broadCasted: fields[7] as bool,
      broadcastHex: fields[8] as String,
      confirmations: fields[6] as int,
      opReturn: fields[9] == null ? '' : fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WalletTransaction obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.txid)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.value)
      ..writeByte(3)
      ..write(obj.fee)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.direction)
      ..writeByte(6)
      ..write(obj.confirmations)
      ..writeByte(7)
      ..write(obj.broadCasted)
      ..writeByte(8)
      ..write(obj.broadcastHex)
      ..writeByte(9)
      ..write(obj.opReturn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
