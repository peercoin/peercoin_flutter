import 'package:frost_noosphere/frost_noosphere.dart';
import 'package:hive_ce/hive.dart';
import 'package:peercoin/models/hive/adapters/base_writable_adapter.dart';

class HiveROASTClientConfigAdapter extends BaseWritableAdapter {
  HiveROASTClientConfigAdapter() : super(0);

  @override
  ClientConfig read(BinaryReader reader) {
    return ClientConfig.fromBytes(reader.readByteList());
  }
}
