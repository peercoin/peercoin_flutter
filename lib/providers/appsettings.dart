import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:peercoin/models/app_options.dart';
import 'package:peercoin/providers/encryptedbox.dart';

class AppSettings with ChangeNotifier {
  AppOptionsStore _appOptions;
  EncryptedBox _encryptedBox;
  AppSettings(this._encryptedBox);

  Future<void> init() async {
    Box _optionsBox = await _encryptedBox.getGenericBox("optionsBox");
    _appOptions = _optionsBox.get("appOptions");
  }

  Future<void> createInitialSettings(bool allowBiometrics) async {
    Box _optionsBox = await _encryptedBox.getGenericBox("optionsBox");
    _optionsBox.put("appOptions", AppOptionsStore(allowBiometrics));
  }

  bool get biometricsAllowed {
    return _appOptions.allowBiometrics;
  }

  void setBiometricsAllowed(bool newStatus) {
    _appOptions.allowBiometrics = newStatus;
    notifyListeners();
  }
}
