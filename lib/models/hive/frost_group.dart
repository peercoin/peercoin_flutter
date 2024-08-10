import 'package:frost_noosphere/frost_noosphere.dart';
import 'package:hive/hive.dart';
part 'frost_group.g.dart';

@HiveType(typeId: 8)
class FrostGroup extends HiveObject {
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

  FrostGroup(
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
}
