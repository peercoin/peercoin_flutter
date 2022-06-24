// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../tools/app_localizations.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppLocalizations.instance.translate('logout_title'),
        textAlign: TextAlign.center,
      ),
      content: Text(
        AppLocalizations.instance.translate('logout_content'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            AppLocalizations.instance.translate('server_settings_alert_cancel'),
          ),
        ),
        TextButton(
          onPressed: () async {
            await clearData();

            LoggerWrapper.logInfo(
              'LogoutDialog',
              'AlertDialog',
              'Data cleared - reloading',
            );

            Navigator.of(context).pop();
            reloadWindow();
          },
          child: Text(
            AppLocalizations.instance.translate('logout'),
          ),
        ),
      ],
    );
  }

  static Future<void> clearData() async {
    var preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    LoggerWrapper.logInfo('Logout', 'clearData', 'SharedPreferences cleared');

    var storage = const FlutterSecureStorage();
    await storage.deleteAll();
    LoggerWrapper.logInfo(
      'Logout',
      'clearData',
      'FlutterSecureStorage cleared',
    );

    //clear hive
    window.indexedDB?.deleteDatabase('vaultbox');
    window.indexedDB?.deleteDatabase('wallets');
    window.indexedDB?.deleteDatabase('optionsbox');
    window.indexedDB?.deleteDatabase('serverbox-peercoin');
    window.indexedDB?.deleteDatabase('serverbox-peercointestnet');
    await Future.delayed(const Duration(seconds: 1));

    LoggerWrapper.logInfo('Logout', 'clearData', 'Hive Storage cleared');
  }

  static void reloadWindow() {
    window.location.reload();
  }
}
