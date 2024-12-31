import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:frost_noosphere/frost_noosphere.dart';
import 'package:hive/hive.dart';
part 'roast_group.g.dart';

@HiveType(typeId: 8)
class ROASTGroup extends HiveObject {
  @HiveField(0)
  final String _name;

  @HiveField(1)
  bool _isCompleted = false;

  @HiveField(2)
  ClientConfig? _clientConfig;

  @HiveField(3)
  String? _serverUrl;

  @HiveField(4)
  String? _groupId;

  @HiveField(5, defaultValue: {})
  Map<String, String> _participantNames = {};

  @HiveField(6, defaultValue: {})
  Map<ECPublicKey, FrostKeyWithDetails> _keys = {};

  @HiveField(7, defaultValue: {})
  Map<SignaturesRequestId, SignaturesNonces> _sigNonces = {};

  @HiveField(8, defaultValue: {})
  Map<SignaturesRequestId, FinalExpirable> _sigsRejected = {};

  ROASTGroup(
    this._name,
    this._isCompleted,
  );

  String get name => _name;

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
  set keys(Map<ECPublicKey, FrostKeyWithDetails> value) {
    _keys = value;
    save();
  }

  Map<SignaturesRequestId, SignaturesNonces> get sigNonces => _sigNonces;
  set sigNonces(Map<SignaturesRequestId, SignaturesNonces> value) {
    _sigNonces = value;
    save();
  }

  Map<SignaturesRequestId, FinalExpirable> get sigsRejected => _sigsRejected;
  set sigsRejected(Map<SignaturesRequestId, FinalExpirable> value) {
    _sigsRejected = value;
    save();
  }
}

// TODO probably have to write adapters for the maps (keys, sigNonces, sigsRejected)
