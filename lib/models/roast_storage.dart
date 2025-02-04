import 'package:frost_noosphere/frost_noosphere.dart';
import 'package:peercoin/models/hive/roast_client.dart';

class ROASTStorage implements ClientStorageInterface {
  final ROASTClient roastClient;
  ROASTStorage(this.roastClient);

  @override
  Future<void> addOrReplaceAck(SignedDkgAck ack) async {
    final groupKey = ack.signed.obj.groupKey;
    final key = roastClient.keys[groupKey]!;

    roastClient.keys[groupKey] = FrostKeyWithDetails(
      keyInfo: key.keyInfo,
      name: key.name,
      description: key.description,
      acks: {
        ...key.acks.where((existing) => existing != ack),
        ack,
      },
    );
  }

  @override
  Future<void> addNewFrostKey(FrostKeyWithDetails newKey) async {
    roastClient.keys[newKey.groupKey] = newKey;
  }

  @override
  Future<void> addRejectedSigsRequest(
    SignaturesRequestId id,
    FinalExpirable expirable,
  ) async {
    roastClient.sigsRejected[id] = expirable;
  }

  @override
  Future<void> addSignaturesNonces(
    SignaturesRequestId id,
    SignaturesNonces nonces,
    int capacity,
  ) async {
    // TODO capacity?
    final sigNonces = roastClient.sigNonces;

    if (sigNonces.containsKey(id)) {
      sigNonces[id]!.map.addEntries(nonces.map.entries);
    } else {
      sigNonces[id] = nonces;
    }
  }

  @override
  Future<Set<FrostKeyWithDetails>> loadKeys() async =>
      roastClient.keys.values.toSet();

  @override
  Future<Map<SignaturesRequestId, FinalExpirable>>
      loadRejectedSigsRequests() async => roastClient.sigsRejected;

  @override
  Future<Map<SignaturesRequestId, SignaturesNonces>> loadSigNonces() async =>
      roastClient.sigNonces;

  @override
  Future<void> removeRejectionOfSigsRequest(SignaturesRequestId id) async {
    roastClient.sigsRejected.remove(id);
  }

  @override
  Future<void> removeSigsRequest(SignaturesRequestId id) async {
    roastClient.sigNonces.remove(id);
    roastClient.sigsRejected.remove(id);
  }
}
