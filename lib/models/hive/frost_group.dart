import 'package:hive/hive.dart';
import 'package:frost_noosphere/frost_noosphere.dart';
part 'frost_group.g.dart';

@HiveType(typeId: 8)
class FrostGroup extends HiveObject {
  @HiveField(0)
  final String _name;

  @HiveField(1)
  bool _isCompleted = false;

  @HiveField(2)
  ClientConfig _clientConfig;

  @HiveField(3)
  String _serverUrl;

  FrostGroup(
    this._name,
    this._isCompleted,
    this._clientConfig,
    this._serverUrl,
  );

  String get name => _name;

  bool get isCompleted => _isCompleted;
  set isCompleted(bool value) {
    _isCompleted = value;
    save();
  }

  ClientConfig get clientConfig => _clientConfig;
  set clientConfig(ClientConfig value) {
    _clientConfig = value;
    save();
  }

  String get serverUrl => _serverUrl;
  set serverUrl(String value) {
    _serverUrl = value;
    save();
  }
}
