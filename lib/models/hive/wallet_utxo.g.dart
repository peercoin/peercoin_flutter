// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_utxo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WalletUtxoAdapter extends TypeAdapter<WalletUtxo> {
  @override
  final int typeId = 4;

  @override
  WalletUtxo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WalletUtxo(
      hash: fields[0] as String,
      txPos: (fields[1] as num).toInt(),
      height: (fields[2] as num).toInt(),
      value: (fields[3] as num).toInt(),
      address: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WalletUtxo obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.hash)
      ..writeByte(1)
      ..write(obj.txPos)
      ..writeByte(2)
      ..write(obj.height)
      ..writeByte(3)
      ..write(obj.value)
      ..writeByte(4)
      ..write(obj.address);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletUtxoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
