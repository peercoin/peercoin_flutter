import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:peercoin/models/coinwallet.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/backgroundsync.dart';
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
  late ActiveWallets _activeWallets;
  List<CoinWallet> _availableWallets = [];

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      _appSettings = Provider.of<AppSettings>(context);
      _activeWallets = context.watch<ActiveWallets>();
      _availableWallets = await _activeWallets.activeWalletsValues;
      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  Future<void> enableNotifications(BuildContext ctx) async {
    await showDialog(
      context: ctx,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.instance.translate('setup_continue_alert_title'),
            textAlign: TextAlign.center,
          ),
          content: Text(
            AppLocalizations.instance
                .translate('app_settings_notifications_alert_content'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.instance
                    .translate('server_settings_alert_cancel'),
              ),
            ),
            TextButton(
              onPressed: () async {
                _appSettings.setNotificationInterval(15);

                var walletList = <String>[];
                _availableWallets.forEach((element) {
                  walletList.add(element.letterCode);
                });
                _appSettings.setNotificationActiveWallets(walletList);

                await BackgroundSync.init(
                  notificationInterval: _appSettings.notificationInterval,
                  needsStart: true,
                );
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.instance.translate('continue'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget enableBlock() {
    return Column(
      children: [
        Text(
          AppLocalizations.instance
              .translate('app_settings_notifications_not_enabled'),
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(height: 10),
        Divider(),
        PeerButton(
          text: AppLocalizations.instance
              .translate('app_settings_notifications_enable_button'),
          action: () async {
            await enableNotifications(context);
          },
        )
      ],
    );
  }

  void saveSnack(context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        AppLocalizations.instance.translate('app_settings_saved_snack'),
        textAlign: TextAlign.center,
      ),
      duration: Duration(seconds: 2),
    ));
  }

  Widget manageBlock() {
    return Column(
      children: [
        Text(
          AppLocalizations.instance
              .translate('app_settings_notifications_heading_manage_wallets'),
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(height: 10),
        Column(
          children: _availableWallets.map((wallet) {
            return SwitchListTile(
              key: Key(wallet.letterCode),
              title: Text(wallet.title),
              value: _appSettings.notificationActiveWallets
                  .contains(wallet.letterCode),
              onChanged: (newState) {
                var _newList = _appSettings.notificationActiveWallets;
                if (newState == true) {
                  _newList.add(wallet.letterCode);
                } else {
                  _newList.remove(wallet.letterCode);
                }
                _appSettings.setNotificationActiveWallets(_newList);
                saveSnack(context);
              },
            );
          }).toList(),
        ),
        SizedBox(height: 10),
        Divider(),
        SizedBox(height: 10),
        Text(
          AppLocalizations.instance
              .translate('app_settings_notifications_heading_interval'),
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(height: 10),
        Text(
          AppLocalizations.instance
              .translate('app_settings_notifications_hint_sync_1', {
            'minutes': _appSettings.notificationInterval.toString(),
          }),
        ),
        Slider(
          activeColor: Theme.of(context).primaryColor,
          inactiveColor: Theme.of(context).shadowColor,
          value: _appSettings.notificationInterval.toDouble(),
          min: 15,
          max: 60,
          divisions: 3,
          onChangeEnd: (e) => saveSnack(context),
          label: _appSettings.notificationInterval.toString(),
          onChanged: (e) => _appSettings.setNotificationInterval(
            e.toInt(),
          ),
        ),
        Text(
            AppLocalizations.instance
                .translate('app_settings_notifications_hint_sync_2'),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.secondary,
            )),
        SizedBox(height: 10),
        Divider(),
        SizedBox(height: 10),
        PeerButton(
          text: AppLocalizations.instance
              .translate('app_settings_notifications_disable_button'),
          action: () async {
            await BackgroundFetch.stop();
            _appSettings.setNotificationInterval(0);
            _appSettings.setNotificationActiveWallets([]);
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
//TODO add background notifications to setup
}
