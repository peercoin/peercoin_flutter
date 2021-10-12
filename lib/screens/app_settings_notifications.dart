import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:provider/provider.dart';

class AppSettingsNotificationsScreen extends StatefulWidget {
  const AppSettingsNotificationsScreen({Key? key}) : super(key: key);

  @override
  _AppSettingsNotificationsScreenState createState() =>
      _AppSettingsNotificationsScreenState();
}

class _AppSettingsNotificationsScreenState
    extends State<AppSettingsNotificationsScreen> {
  bool _initial = true;
  late AppSettings _appSettings;
  @override
  void didChangeDependencies() {
    if (_initial == true) {
      _appSettings = Provider.of<AppSettings>(context);
      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  Widget enableBlock() {
    return Column(
      children: [
        PeerButton(
            text: 'Enable',
            action: () {
              _appSettings.setNotificationInterval(15);
            })
      ],
    );
  }

  Widget manageBlock() {
    return Column(
      children: [
        PeerButton(
          text: 'Turn off',
          action: () async {
            await BackgroundFetch.stop();
            _appSettings.setNotificationInterval(0);
          },
        )
      ],
    );
  }

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
        child: Container(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _appSettings.notificationInterval == 0
                      ? enableBlock()
                      : manageBlock()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
