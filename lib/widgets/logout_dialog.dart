import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
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
            await Navigator.of(context).pushReplacementNamed('/');
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
    LoggerWrapper.logInfo('Logout', 'clear data', 'SharedPreferences cleared');

    var storage = FlutterSecureStorage();
    await storage.deleteAll();
    LoggerWrapper.logInfo(
      'Logout',
      'clear data',
      'FlutterSecureStorage cleared',
    );

    //clear hive
    await Hive.close();
    await Hive.deleteBoxFromDisk('vaultbox');
    await Hive.deleteBoxFromDisk('optionsbox');
    await Hive.deleteBoxFromDisk('wallets');
    LoggerWrapper.logInfo('Logout', 'clear data', 'Hive Storage cleared');
  }
}
