import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:frost_noosphere/frost_noosphere.dart';
import 'package:convert/convert.dart'; // Add this import for hex decoding
import 'dart:typed_data'; // Add this import for Uint8List

class HiveFrostClientConfig extends ClientConfig {
  HiveFrostClientConfig({required super.group, required super.id});

  factory HiveFrostClientConfig.fromJson(Map<String, dynamic> json) {
    final reader = BytesReader(
      Uint8List.fromList(
        hex.decode(json['data'] as String),
      ),
    );
    return ClientConfig.fromReader(reader) as HiveFrostClientConfig;
  }

  Map<String, dynamic> toJson() {
    final writer = BytesWriter(Uint8List(0));
    write(writer);
    return {
      'data': hex.encode(writer.bytes.buffer.asUint8List()),
    };
  }
}
