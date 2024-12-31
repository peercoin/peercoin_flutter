import 'package:frost_noosphere/frost_noosphere.dart';
import 'package:peercoin/models/hive/roast_group.dart';

class ROASTStorage implements ClientStorageInterface {
  final ROASTGroup roastGroup;
  ROASTStorage(this.roastGroup);

  @override
  Future<void> addAck(SignedDkgAck ack) async {
    final groupKey = ack.signed.obj.groupKey;
    final key = roastGroup.keys[groupKey]!;

    roastGroup.keys[groupKey] = FrostKeyWithDetails(
      keyInfo: key.keyInfo,
      name: key.name,
      description: key.description,
      acks: {...key.acks, ack},
    );
  }

  @override
  Future<void> addNewFrostKey(FrostKeyWithDetails newKey) async {
    roastGroup.keys[newKey.groupKey] = newKey;
  }

  @override
  Future<void> addRejectedSigsRequest(
    SignaturesRequestId id,
    FinalExpirable expirable,
  ) async {
    roastGroup.sigsRejected[id] = expirable;
  }

  @override
  Future<void> addSignaturesNonces(
    SignaturesRequestId id,
    SignaturesNonces nonces,
  ) async {
    final sigNonces = roastGroup.sigNonces;

    if (sigNonces.containsKey(id)) {
      sigNonces[id]!.map.addEntries(nonces.map.entries);
    } else {
      sigNonces[id] = nonces;
    }
  }

  @override
  Future<Set<FrostKeyWithDetails>> loadKeys() async =>
      roastGroup.keys.values.toSet();

  @override
  Future<Map<SignaturesRequestId, FinalExpirable>>
      loadRejectedSigsRequests() async => roastGroup.sigsRejected;

  @override
  Future<Map<SignaturesRequestId, SignaturesNonces>> loadSigNonces() async =>
      roastGroup.sigNonces;
}
