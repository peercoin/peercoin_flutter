import 'package:flutter/material.dart';
import 'package:peercoin/tools/app_localizations.dart';

class AppSettingsNotificationsScreen extends StatefulWidget {
  const AppSettingsNotificationsScreen({Key? key}) : super(key: key);

  @override
  _AppSettingsNotificationsScreenState createState() =>
      _AppSettingsNotificationsScreenState();
}

class _AppSettingsNotificationsScreenState
    extends State<AppSettingsNotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.instance.translate('app_settings_notifications'),
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Container(),
      ),
    );
  }
}
