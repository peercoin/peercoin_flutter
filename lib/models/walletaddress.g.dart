// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'walletaddress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WalletAddressAdapter extends TypeAdapter<WalletAddress> {
  @override
  final int typeId = 2;

  @override
  WalletAddress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WalletAddress(
      address: fields[0] as String,
      addressBookName: fields[1] as String?,
      used: fields[3] as bool,
      status: fields[2] as String?,
      isOurs: fields[4] as bool?,
      wif: fields[5] as String?,
    )
      .._isChangeAddr = fields[6] as bool?
      ..notificationBackendCount = fields[7] == null ? 0 : fields[7] as int;
  }

  @override
  void write(BinaryWriter writer, WalletAddress obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.address)
      ..writeByte(1)
      ..write(obj.addressBookName)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.used)
      ..writeByte(4)
      ..write(obj.isOurs)
      ..writeByte(5)
      ..write(obj.wif)
      ..writeByte(6)
      ..write(obj._isChangeAddr)
      ..writeByte(7)
      ..write(obj.notificationBackendCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletAddressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
