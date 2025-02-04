import 'package:frost_noosphere/frost_noosphere.dart';
import 'package:hive/hive.dart';
import 'package:peercoin/models/hive/adapters/base_writable_adapter.dart';

class HiveFrostKeyWithDetailsAdapter extends BaseWritableAdapter {
  HiveFrostKeyWithDetailsAdapter() : super(11);

  @override
  FrostKeyWithDetails read(BinaryReader reader) {
    return FrostKeyWithDetails.fromBytes(reader.readByteList());
  }
}
