import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:hive_ce/hive.dart';

class HiveSigingNoncesAdapter extends TypeAdapter<SigningNonces> {
  @override
  final typeId = 17;

  @override
  SigningNonces read(BinaryReader reader) {
    return SigningNonces.fromBytes(reader.readByteList());
  }

  @override
  void write(BinaryWriter writer, SigningNonces obj) {
    writer.writeByteList(obj.toBytes());
  }
}
