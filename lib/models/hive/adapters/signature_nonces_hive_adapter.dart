import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:hive_ce/hive.dart';

class HiveSignaturesNoncesAdapter extends TypeAdapter<SignaturesNonces> {
  @override
  final typeId = 13;

  @override
  SignaturesNonces read(BinaryReader reader) {
    // Read the map and convert it to Map<int, SigningNonces>
    final rawMap = reader.readMap();
    final typedMap = Map<int, SigningNonces>.fromEntries(
      rawMap.entries.map(
        (entry) => MapEntry(entry.key as int, entry.value as SigningNonces),
      ),
    );

    return SignaturesNonces(
      typedMap,
      Expiry.fromBytes(reader.readByteList()),
    );
  }

  @override
  void write(BinaryWriter writer, SignaturesNonces obj) {
    writer.writeMap(obj.map);
    writer.writeByteList(obj.expiry.toBytes());
  }
}
