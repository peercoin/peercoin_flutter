import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:peercoin/models/app_options.dart';
import 'package:peercoin/providers/encryptedbox.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings with ChangeNotifier {
  AppOptionsStore _appOptions;
  EncryptedBox _encryptedBox;
  SharedPreferences _sharedPrefs;
  String _selectedLang;
  AppSettings(this._encryptedBox);

  Future<void> init() async {
    Box _optionsBox = await _encryptedBox.getGenericBox("optionsBox");
    _appOptions = _optionsBox.get("appOptions");
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  Future<void> createInitialSettings(bool allowBiometrics, String lang) async {
    Box _optionsBox = await _encryptedBox.getGenericBox("optionsBox");
    await _optionsBox.put("appOptions", AppOptionsStore(allowBiometrics));
    await _sharedPrefs.setString("language_code", lang);
  }

  bool get biometricsAllowed {
    return _appOptions.allowBiometrics;
  }

  void setBiometricsAllowed(bool newStatus) {
    _appOptions.allowBiometrics = newStatus;
    notifyListeners();
  }

  Map<String, bool> get authenticationOptions {
    return _appOptions.authenticationOptions;
  }

  String get selectedLang {
    return _selectedLang;
  }

  Future<void> setSelectedLang(String newLang) async {
    _selectedLang = newLang;
    await _sharedPrefs.setString("language_code", newLang);
    notifyListeners();
  }

  void setAuthenticationOptions(String field, bool newStatus) {
    _appOptions.changeAuthenticationOptions(field, newStatus);
    notifyListeners();
  }

  String get defaultWallet {
    return _appOptions.defaultWallet ?? "";
  }

  void setDefaultWallet(String newWallet) {
    _appOptions.defaultWallet = newWallet;
    notifyListeners();
  }
}
