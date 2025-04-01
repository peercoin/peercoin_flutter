import 'package:noosphere_roast_client/noosphere_roast_client.dart';
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
