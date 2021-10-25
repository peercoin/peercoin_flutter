// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pendingNotifications.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingNotificationAdapter extends TypeAdapter<PendingNotification> {
  @override
  final int typeId = 7;

  @override
  PendingNotification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingNotification(
      address: fields[0] as String,
      tx: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PendingNotification obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.address)
      ..writeByte(1)
      ..write(obj.tx);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingNotificationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
