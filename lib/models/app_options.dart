import 'package:hive/hive.dart';
part "app_options.g.dart";

@HiveType(typeId: 5)
class AppOptionsStore extends HiveObject {
  @HiveField(0)
  Map<String, bool> _authenticationOptions = {
    "walletList": false,
    "walletHome": false,
    "sendTransaction": true,
    "newWallet": false,
  };

  @HiveField(1)
  bool _allowBiometrics = true;

  @HiveField(2)
  String _selectedLang = "en";

  AppOptionsStore(this._allowBiometrics, this._selectedLang);

  bool get allowBiometrics {
    return _allowBiometrics;
  }

  set allowBiometrics(bool newStatus) {
    _allowBiometrics = newStatus;
    this.save();
  }

  Map<String, bool> get authenticationOptions {
    return _authenticationOptions;
  }

  void changeAuthenticationOptions(String field, bool value) {
    _authenticationOptions[field] = value;
    this.save();
  }

  String get selectedLang {
    return _selectedLang;
  }

  set changeLang(String newLang) {
    _selectedLang = newLang;
    this.save();
  }
}
