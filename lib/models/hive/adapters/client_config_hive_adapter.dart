import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:hive_ce/hive.dart';

class HiveROASTClientConfigAdapter extends TypeAdapter<ClientConfig> {
  @override
  final typeId = 15;

  @override
  ClientConfig read(BinaryReader reader) {
    return ClientConfig.fromBytes(reader.readByteList());
  }

  @override
  void write(BinaryWriter writer, ClientConfig obj) {
    writer.writeByteList(obj.toBytes());
  }
}
