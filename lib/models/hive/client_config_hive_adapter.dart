import 'dart:convert';
import 'dart:typed_data';

import 'package:frost_noosphere/frost_noosphere.dart';
import 'package:hive/hive.dart';

class HiveFrostClientConfigAdapter extends TypeAdapter<ClientConfig> {
  @override
  final typeId = 0;

  @override
  ClientConfig read(BinaryReader reader) {
    final json = reader.readString();
    return ClientConfig.fromBytes(
      Uint8List.fromList(
        List<int>.from(
          jsonDecode(
            json,
          ),
        ),
      ),
    );
  }

  @override
  void write(BinaryWriter writer, ClientConfig obj) {
    final json = jsonEncode(obj.toBytes());
    writer.writeString(json);
  }
}
