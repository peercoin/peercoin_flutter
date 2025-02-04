import 'package:frost_noosphere/frost_noosphere.dart';
import 'package:hive/hive.dart';

class HiveSignaturesNoncesAdapter extends TypeAdapter<SignaturesNonces> {
  @override
  final typeId = 13;

  @override
  SignaturesNonces read(BinaryReader reader) {
    return SignaturesNonces(
      reader.readMap as Map<int, SigningNonces>, // FIXME this will not work !?
      Expiry.fromBytes(reader.readByteList()),
    );
  }

  @override
  void write(BinaryWriter writer, SignaturesNonces obj) {
    writer.writeMap(obj.map);
    writer.writeByteList(obj.expiry.toBytes());
  }
}
