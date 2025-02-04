import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:frost_noosphere/frost_noosphere.dart';
import 'package:hive/hive.dart';
part 'roast_client.g.dart';

@HiveType(typeId: 8)
class ROASTClient extends HiveObject {
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
  Map<ECPublicKey, FrostKeyWithDetails> keys = {};

  @HiveField(7)
  Map<SignaturesRequestId, SignaturesNonces> sigNonces = {};

  @HiveField(8)
  Map<SignaturesRequestId, FinalExpirable> sigsRejected = {};

  @HiveField(9)
  String? _ourName;

  @HiveField(10)
  final ECPrivateKey _ourKey;

  ROASTClient(
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
}
