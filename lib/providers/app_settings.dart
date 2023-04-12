import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';

import '../models/app_options.dart';
import 'encrypted_box.dart';

class AppSettings with ChangeNotifier {
  late AppOptionsStore _appOptions;
  final EncryptedBox _encryptedBox;
  late SharedPreferences _sharedPrefs;
  String? _selectedLang;
  bool camerasAvailble = false;
  AppSettings(this._encryptedBox);

  Future<void> init([bool fromSetup = false]) async {
    if (fromSetup == false) {
      var optionsBox = await (_encryptedBox.getGenericBox('optionsBox'));
      _appOptions = await optionsBox!.get('appOptions');
    }
    _sharedPrefs = await SharedPreferences.getInstance();

    if (!kIsWeb) {
      try {
        await availableCameras();
        camerasAvailble = true;
      } catch (e) {
        camerasAvailble = false;
      }
    }
  }

  Future<void> createInitialSettings({
    required bool allowBiometrics,
    required String lang,
    required bool ledgerMode,
  }) async {
    var optionsBox =
        await _encryptedBox.getGenericBox('optionsBox') as Box<dynamic>;
    await optionsBox.put(
      'appOptions',
      AppOptionsStore(
        allowBiometrics,
      ),
    );
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

  Future<void> setSelectedLang(String newLang) async {
    _selectedLang = newLang;
    await _sharedPrefs.setString('language_code', newLang);
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

  String get selectedCurrency {
    return _appOptions.selectedCurrency;
  }

  void setSelectedCurrency(String newCurrency) {
    _appOptions.selectedCurrency = newCurrency;
    notifyListeners();
  }

  DateTime get latestTickerUpdate {
    return _appOptions.latestTickerUpdate;
  }

  void setLatestTickerUpdate(DateTime newTime) {
    _appOptions.latestTickerUpdate = newTime;
  }

  Map<String, dynamic> get exchangeRates {
    return _appOptions.exchangeRates;
  }

  void setExchangeRates(Map<String, dynamic> newExchangeRates) {
    _appOptions.exchangeRates = newExchangeRates;
    notifyListeners();
  }

  String get buildIdentifier {
    return _appOptions.buildIdentifier;
  }

  void setBuildIdentifier(String newIdentifier) {
    _appOptions.buildIdentifier = newIdentifier;
    notifyListeners();
  }

  int get notificationInterval {
    return _appOptions.notificationInterval;
  }

  void setNotificationInterval(int newInterval) {
    _appOptions.notificationInterval = newInterval;
    notifyListeners();
  }

  List<String> get notificationActiveWallets {
    return _appOptions.notificationActiveWallets;
  }

  void setNotificationActiveWallets(List<String> newList) {
    _appOptions.notificationActiveWallets = newList;
    notifyListeners();
  }

  Map<String, DateTime> get periodicReminterItemsNextView {
    return _appOptions.periodicReminterItemsNextView;
  }

  void setPeriodicReminterItemsNextView(Map<String, DateTime> newMap) {
    _appOptions.periodicReminterItemsNextView = newMap;
    notifyListeners();
  }
}
