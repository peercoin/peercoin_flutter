import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:hive_ce/hive.dart';

abstract class BaseWritableAdapter extends TypeAdapter<Writable> {
  @override
  final int typeId;

  @override
  read(BinaryReader reader) {
    throw UnimplementedError();
  }

  @override
  void write(BinaryWriter writer, Writable obj) {
    writer.writeByteList(obj.toBytes());
  }

  BaseWritableAdapter(this.typeId);
}
