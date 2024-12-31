import 'package:frost_noosphere/frost_noosphere.dart';
import 'package:peercoin/models/hive/roast_group.dart';

class ROASTStorage implements ClientStorageInterface {
  final ROASTGroup roastGroup;
  ROASTStorage(this.roastGroup);

  @override
  Future<void> addAck(SignedDkgAck ack) {
    // TODO: implement addAck
    throw UnimplementedError();
  }

  @override
  Future<void> addNewFrostKey(FrostKeyWithDetails newKey) {
    // TODO: implement addNewFrostKey
    throw UnimplementedError();
  }

  @override
  Future<void> addRejectedSigsRequest(
      SignaturesRequestId id, FinalExpirable expirable) {
    // TODO: implement addRejectedSigsRequest
    throw UnimplementedError();
  }

  @override
  Future<void> addSignaturesNonces(
      SignaturesRequestId id, SignaturesNonces nonces) {
    // TODO: implement addSignaturesNonces
    throw UnimplementedError();
  }

  @override
  Future<Set<FrostKeyWithDetails>> loadKeys() {
    // TODO: implement loadKeys
    throw UnimplementedError();
  }

  @override
  Future<Map<SignaturesRequestId, FinalExpirable>> loadRejectedSigsRequests() {
    // TODO: implement loadRejectedSigsRequests
    throw UnimplementedError();
  }

  @override
  Future<Map<SignaturesRequestId, SignaturesNonces>> loadSigNonces() {
    // TODO: implement loadSigNonces
    throw UnimplementedError();
  }
}
