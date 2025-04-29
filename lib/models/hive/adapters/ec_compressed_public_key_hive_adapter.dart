import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:hive_ce/hive.dart';

class HiveECCompressedPublicKeyAdapter
    extends TypeAdapter<ECCompressedPublicKey> {
  @override
  final typeId = 16;

  @override
  ECCompressedPublicKey read(BinaryReader reader) {
    return ECCompressedPublicKey.fromHex(bytesToHex(reader.readByteList()));
  }

  @override
  void write(BinaryWriter writer, ECCompressedPublicKey obj) {
    writer.writeByteList(obj.data);
  }
}
