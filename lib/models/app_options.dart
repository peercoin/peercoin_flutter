import 'package:hive/hive.dart';
part "app_options.g.dart";

@HiveType(typeId: 5)
class AppOptions extends HiveObject {
  @HiveField(0)
  Map<String, bool> _authenticationOptions = {
    "walletList": true,
    "walletHome": true,
    "sendTransaction": true,
    "newWallet": true,
  };

  Map<String, bool> get authenticationOptions {
    return _authenticationOptions;
  }

  void changeAuthenticationOptions(field, value) {
    _authenticationOptions[field] = value;
    this.save();
  }
}
