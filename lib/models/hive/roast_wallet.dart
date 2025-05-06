import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:hive_ce/hive.dart';
part 'roast_wallet.g.dart';

@HiveType(typeId: 8)
class ROASTWallet extends HiveObject {
  @HiveField(0)
  final String _title;

  @HiveField(1)
  bool _isCompleted = false;

  @HiveField(2)
  ClientConfig? _clientConfig;

  @HiveField(3)
  String? _serverUrl;

  @HiveField(4)
  String? _groupId;

  @HiveField(5)
  Map<String, String> _participantNames = {};

  @HiveField(6)
  Map<ECPublicKey, FrostKeyWithDetails> _keys = {};

  @HiveField(7)
  Map<SignaturesRequestId, SignaturesNonces> _sigNonces = {};

  @HiveField(8)
  Map<SignaturesRequestId, FinalExpirable> _sigsRejected = {};

  @HiveField(9)
  String? _ourName;

  @HiveField(10)
  final ECPrivateKey _ourKey;

  @HiveField(13, defaultValue: {}) //deliberately skipped 11 and 12
  Map<ECPublicKey, Set<int>> _derivedKeys =
      {}; // list of group keys and their deriviation path indices

  ROASTWallet(
    this._title,
    this._isCompleted,
    this._ourKey,
  );

  String get title => _title;

  String get ourName => _ourName ?? '';
  set ourName(String value) {
    _ourName = value;
    save();
  }

  ECPrivateKey get ourKey => _ourKey;

  String get groupId => _groupId ?? '';
  set groupId(String value) {
    _groupId = value;
    save();
  }

  bool get isCompleted => _isCompleted;
  set isCompleted(bool value) {
    _isCompleted = value;
    save();
  }

  ClientConfig? get clientConfig {
    return _clientConfig;
  }

  set clientConfig(ClientConfig? value) {
    if (value == null) {
      return;
    }

    _clientConfig = value;
    save();
  }

  String get serverUrl => _serverUrl ?? '';
  set serverUrl(String value) {
    _serverUrl = value;
    save();
  }

  set setServerUrl(String value) {
    _serverUrl = value;
    save();
  }

  Map<String, String> get participantNames => _participantNames;

  set participantNames(Map<String, String> value) {
    _participantNames = value;
    save();
  }

  Map<ECPublicKey, FrostKeyWithDetails> get keys => _keys;
  set keys(Map<ECPublicKey, FrostKeyWithDetails> newKey) {
    _keys = newKey;
    save();
  }

  Map<SignaturesRequestId, SignaturesNonces> get sigNonces => _sigNonces;
  set sigNonces(Map<SignaturesRequestId, SignaturesNonces> newSigNonces) {
    _sigNonces = newSigNonces;
    save();
  }

  Map<SignaturesRequestId, FinalExpirable> get sigsRejected => _sigsRejected;
  set sigsRejected(Map<SignaturesRequestId, FinalExpirable> newSigsRejected) {
    _sigsRejected = newSigsRejected;
    save();
  }

  Map<ECPublicKey, Set<int>> get derivedKeys => _derivedKeys;
  set derivedKeys(Map<ECPublicKey, Set<int>> newDerivedKeys) {
    _derivedKeys = newDerivedKeys;
    save();
  }
}
