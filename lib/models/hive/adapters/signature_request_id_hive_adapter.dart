import 'package:frost_noosphere/frost_noosphere.dart';
import 'package:hive_ce/hive.dart';

class HiveSignaturesRequestIdAdapter extends TypeAdapter<SignaturesRequestId> {
  @override
  final typeId = 12;

  @override
  SignaturesRequestId read(BinaryReader reader) {
    return SignaturesRequestId.fromBytes(reader.readByteList());
  }

  @override
  void write(BinaryWriter writer, SignaturesRequestId obj) {
    writer.writeByteList(obj.toBytes());
  }
}
