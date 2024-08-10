import 'dart:convert';

import 'package:hive/hive.dart';
import 'hive_frost_client_config.dart';

class HiveFrostClientConfigAdapter extends TypeAdapter<HiveFrostClientConfig> {
  @override
  final typeId = 0; // You can change this to a unique typeId

  @override
  HiveFrostClientConfig read(BinaryReader reader) {
    final json = reader.readString();
    return HiveFrostClientConfig.fromJson(jsonDecode(json));
  }

  @override
  void write(BinaryWriter writer, HiveFrostClientConfig obj) {
    final json = jsonEncode(obj.toJson());
    writer.writeString(json);
  }
}
