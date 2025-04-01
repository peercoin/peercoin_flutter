// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roast_wallet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ROASTWalletAdapter extends TypeAdapter<ROASTWallet> {
  @override
  final int typeId = 8;

  @override
  ROASTWallet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ROASTWallet(
      fields[0] as String,
      fields[1] as bool,
      fields[10] as ECPrivateKey,
    )
      .._clientConfig = fields[2] as ClientConfig?
      .._serverUrl = fields[3] as String?
      .._groupId = fields[4] as String?
      .._participantNames = (fields[5] as Map).cast<String, String>()
      .._keys = (fields[6] as Map).cast<ECPublicKey, FrostKeyWithDetails>()
      .._sigNonces =
          (fields[7] as Map).cast<SignaturesRequestId, SignaturesNonces>()
      .._sigsRejected =
          (fields[8] as Map).cast<SignaturesRequestId, FinalExpirable>()
      .._ourName = fields[9] as String?;
  }

  @override
  void write(BinaryWriter writer, ROASTWallet obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj._title)
      ..writeByte(1)
      ..write(obj._isCompleted)
      ..writeByte(2)
      ..write(obj._clientConfig)
      ..writeByte(3)
      ..write(obj._serverUrl)
      ..writeByte(4)
      ..write(obj._groupId)
      ..writeByte(5)
      ..write(obj._participantNames)
      ..writeByte(6)
      ..write(obj._keys)
      ..writeByte(7)
      ..write(obj._sigNonces)
      ..writeByte(8)
      ..write(obj._sigsRejected)
      ..writeByte(9)
      ..write(obj._ourName)
      ..writeByte(10)
      ..write(obj._ourKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ROASTWalletAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
