import 'package:frost_noosphere/frost_noosphere.dart';
import 'package:hive/hive.dart';

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
