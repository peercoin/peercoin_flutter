import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/models/hive/roast_client.dart';

class ROASTStorage implements ClientStorageInterface {
  final ROASTClient roastClient;
  ROASTStorage(this.roastClient);

  @override
  Future<void> addOrReplaceAck(SignedDkgAck ack) async {
    final groupKey = ack.signed.obj.groupKey;
    final key = roastClient.keys[groupKey]!;
    final ourKeys = roastClient.keys;

    ourKeys[groupKey] = FrostKeyWithDetails(
      keyInfo: key.keyInfo,
      name: key.name,
      description: key.description,
      acks: {
        ...key.acks.where((existing) => existing != ack),
        ack,
      },
    );

    roastClient.keys = ourKeys;
  }

  @override
  Future<void> addNewFrostKey(FrostKeyWithDetails newKey) async {
    final ourKeys = roastClient.keys;
    ourKeys[newKey.groupKey] = newKey;
    roastClient.keys = ourKeys;
  }

  @override
  Future<void> addRejectedSigsRequest(
    SignaturesRequestId id,
    FinalExpirable expirable,
  ) async {
    final ourSigsRejected = roastClient.sigsRejected;
    ourSigsRejected[id] = expirable;
    roastClient.sigsRejected = ourSigsRejected;
  }

  @override
  Future<void> addSignaturesNonces(
    SignaturesRequestId id,
    SignaturesNonces nonces,
    int capacity,
  ) async {
    final sigNonces = roastClient.sigNonces;

    if (sigNonces.containsKey(id)) {
      sigNonces[id]!.map.addEntries(nonces.map.entries);
    } else {
      sigNonces[id] = nonces;
    }

    roastClient.sigNonces = sigNonces;
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
