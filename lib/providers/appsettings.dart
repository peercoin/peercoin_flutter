import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:peercoin/models/app_options.dart';
import 'package:peercoin/providers/encryptedbox.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings with ChangeNotifier {
  late AppOptionsStore _appOptions;
  final EncryptedBox _encryptedBox;
  late SharedPreferences _sharedPrefs;
  String? _selectedLang;
  late String _selectedTheme;
  AppSettings(this._encryptedBox);

  Future<void> init([bool fromSetup = false]) async {
    if (fromSetup == false) {
      var _optionsBox = await (_encryptedBox.getGenericBox('optionsBox'));
      _appOptions = _optionsBox!.get('appOptions');
    }
    _sharedPrefs = await SharedPreferences.getInstance();
    _selectedTheme = _sharedPrefs.getString('theme_mode') ?? 'system';
  }

  Future<void> createInitialSettings(bool allowBiometrics, String lang) async {
    var _optionsBox =
        await _encryptedBox.getGenericBox('optionsBox') as Box<dynamic>;
    await _optionsBox.put('appOptions', AppOptionsStore(allowBiometrics));
    await _sharedPrefs.setString('language_code', lang);
  }

  bool get biometricsAllowed {
    return _appOptions.allowBiometrics;
  }

  void setBiometricsAllowed(bool newStatus) {
    _appOptions.allowBiometrics = newStatus;
    notifyListeners();
  }

  Map<String, bool>? get authenticationOptions {
    return _appOptions.authenticationOptions;
  }

  String? get selectedLang {
    return _selectedLang;
  }

  String? get selectedTheme {
    return _selectedTheme;
  }

  Future<void> setSelectedLang(String newLang) async {
    _selectedLang = newLang;
    await _sharedPrefs.setString('language_code', newLang);
    notifyListeners();
  }

  Future<void> setSelectedTheme(String newTheme) async {
    _selectedTheme = newTheme;
    await _sharedPrefs.setString('theme_mode', newTheme);
    notifyListeners();
  }

  void setAuthenticationOptions(String field, bool newStatus) {
    _appOptions.changeAuthenticationOptions(field, newStatus);
    notifyListeners();
  }

  String get defaultWallet {
    return _appOptions.defaultWallet;
  }

  void setDefaultWallet(String newWallet) {
    _appOptions.defaultWallet = newWallet;
    notifyListeners();
  }
}
