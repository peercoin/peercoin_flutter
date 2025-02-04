import 'package:frost_noosphere/frost_noosphere.dart';
import 'package:hive/hive.dart';
import 'package:peercoin/models/hive/adapters/base_writable_adapter.dart';

class HiveSignaturesRequestIdAdapter extends BaseWritableAdapter {
  HiveSignaturesRequestIdAdapter() : super(12);

  @override
  SignaturesRequestId read(BinaryReader reader) {
    return SignaturesRequestId.fromBytes(reader.readByteList());
  }
}
