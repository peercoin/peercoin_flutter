import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:hive/hive.dart';

class HiveECPrivateKeyAdapter extends TypeAdapter<ECPrivateKey> {
  @override
  final typeId = 9;

  @override
  ECPrivateKey read(BinaryReader reader) {
    return ECPrivateKey.fromHex(
      bytesToHex(reader.readByteList()),
    );
  }

  @override
  void write(BinaryWriter writer, ECPrivateKey obj) {
    writer.writeByteList(obj.data);
  }
}
