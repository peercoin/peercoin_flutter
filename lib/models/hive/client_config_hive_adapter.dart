import 'package:frost_noosphere/frost_noosphere.dart';
import 'package:hive/hive.dart';

class HiveFrostClientConfigAdapter extends TypeAdapter<ClientConfig> {
  @override
  final typeId = 0;

  @override
  ClientConfig read(BinaryReader reader) {
    return ClientConfig.fromHex(reader.readString());
  }

  @override
  void write(BinaryWriter writer, ClientConfig obj) {
    writer.writeString(obj.toHex());
  }
}
