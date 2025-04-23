import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:hive_ce/hive.dart';

class HiveSignaturesNoncesAdapter extends TypeAdapter<SignaturesNonces> {
  @override
  final typeId = 13;

  @override
  SignaturesNonces read(BinaryReader reader) {
    return SignaturesNonces(
      reader.readMap as Map<int,
          SigningNonces>, // FIXME this does seems to work but if we are bug hunting, this is a good place to start
      Expiry.fromBytes(reader.readByteList()),
    );
  }

  @override
  void write(BinaryWriter writer, SignaturesNonces obj) {
    writer.writeMap(obj.map);
    writer.writeByteList(obj.expiry.toBytes());
  }
}
