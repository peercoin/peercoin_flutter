import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:hive_ce/hive.dart';

class HiveFinalExpirableAdapter extends TypeAdapter<FinalExpirable> {
  @override
  final typeId = 14;

  @override
  FinalExpirable read(BinaryReader reader) {
    return FinalExpirable(Expiry.fromBytes(reader.readByteList()));
  }

  @override
  void write(BinaryWriter writer, FinalExpirable obj) {
    writer.writeByteList(obj.expiry.toBytes());
  }
}
