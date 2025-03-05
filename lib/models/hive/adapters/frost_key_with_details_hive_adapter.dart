import 'package:frost_noosphere/frost_noosphere.dart';
import 'package:hive_ce/hive.dart';

class HiveFrostKeyWithDetailsAdapter extends TypeAdapter<FrostKeyWithDetails> {
  @override
  final typeId = 11;

  @override
  FrostKeyWithDetails read(BinaryReader reader) {
    return FrostKeyWithDetails.fromBytes(reader.readByteList());
  }

  @override
  void write(BinaryWriter writer, FrostKeyWithDetails obj) {
    writer.writeByteList(obj.toBytes());
  }
}
