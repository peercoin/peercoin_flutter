import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:hive_ce/hive.dart';

class HiveECPublicKeyAdapter extends TypeAdapter<ECPublicKey> {
  @override
  final typeId = 10;

  @override
  ECPublicKey read(BinaryReader reader) {
    return ECPublicKey.fromHex(bytesToHex(reader.readByteList()));
  }

  @override
  void write(BinaryWriter writer, ECPublicKey obj) {
    writer.writeByteList(obj.data);
  }
}
