import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/models/hive/roast_wallet.dart';

class ROASTStorage implements ClientStorageInterface {
  final ROASTWallet roastWallet;
  ROASTStorage(this.roastWallet);

  @override
  Future<void> addOrReplaceAck(SignedDkgAck ack) async {
    final groupKey = ack.signed.obj.groupKey;
    final key = roastWallet.keys[groupKey]!;
    final ourKeys = roastWallet.keys;

    ourKeys[groupKey] = FrostKeyWithDetails(
      keyInfo: key.keyInfo,
      name: key.name,
      description: key.description,
      acks: {
        ...key.acks.where((existing) => existing != ack),
        ack,
      },
    );

    roastWallet.keys = ourKeys;
  }

  @override
  Future<void> addNewFrostKey(FrostKeyWithDetails newKey) async {
    final ourKeys = roastWallet.keys;
    ourKeys[newKey.groupKey] = newKey;
    roastWallet.keys = ourKeys;
  }

  @override
  Future<void> addRejectedSigsRequest(
    SignaturesRequestId id,
    FinalExpirable expirable,
  ) async {
    final ourSigsRejected = roastWallet.sigsRejected;
    ourSigsRejected[id] = expirable;
    roastWallet.sigsRejected = ourSigsRejected;
  }

  @override
  Future<void> addSignaturesNonces(
    SignaturesRequestId id,
    SignaturesNonces nonces,
    int capacity,
  ) async {
    final sigNonces = roastWallet.sigNonces;

    if (sigNonces.containsKey(id)) {
      sigNonces[id]!.map.addEntries(nonces.map.entries);
    } else {
      sigNonces[id] = nonces;
    }

    roastWallet.sigNonces = sigNonces;
  }

  @override
  Future<Set<FrostKeyWithDetails>> loadKeys() async =>
      roastWallet.keys.values.toSet();

  @override
  Future<Map<SignaturesRequestId, FinalExpirable>>
      loadRejectedSigsRequests() async => roastWallet.sigsRejected;

  @override
  Future<Map<SignaturesRequestId, SignaturesNonces>> loadSigNonces() async =>
      roastWallet.sigNonces;

  @override
  Future<void> removeRejectionOfSigsRequest(SignaturesRequestId id) async {
    roastWallet.sigsRejected.remove(id);
  }

  @override
  Future<void> removeSigsRequest(SignaturesRequestId id) async {
    roastWallet.sigNonces.remove(id);
    roastWallet.sigsRejected.remove(id);
  }
}
