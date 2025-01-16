// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roast_client.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ROASTClientAdapter extends TypeAdapter<ROASTClient> {
  @override
  final int typeId = 8;

  @override
  ROASTClient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ROASTClient(
      fields[0] as String,
      fields[1] as bool,
    )
      .._clientConfig = fields[2] as ClientConfig?
      .._serverUrl = fields[3] as String?
      .._groupId = fields[4] as String?
      .._participantNames =
          fields[5] == null ? {} : (fields[5] as Map).cast<String, String>()
      .._keys = fields[6] == null
          ? {}
          : (fields[6] as Map).cast<ECPublicKey, FrostKeyWithDetails>()
      .._sigNonces = fields[7] == null
          ? {}
          : (fields[7] as Map).cast<SignaturesRequestId, SignaturesNonces>()
      .._sigsRejected = fields[8] == null
          ? {}
          : (fields[8] as Map).cast<SignaturesRequestId, FinalExpirable>();
  }

  @override
  void write(BinaryWriter writer, ROASTClient obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj._name)
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
      ..write(obj._sigsRejected);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ROASTClientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
