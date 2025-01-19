import 'package:frost_noosphere/frost_noosphere.dart';
import 'package:hive/hive.dart';

class HiveROASTClientConfigAdapter extends TypeAdapter<ClientConfig> {
  @override
  final typeId = 0;

  @override
  ClientConfig read(BinaryReader reader) {
    return ClientConfig.fromBytes(reader.readByteList());
  }

  @override
  void write(BinaryWriter writer, ClientConfig obj) {
    writer.writeByteList(obj.toBytes());
  }
}
