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

  Widget enableBlock() {
    return Column(
      children: [
        PeerButton(
          text: 'Enable',
          action: () async {
            _appSettings.setNotificationInterval(15);
            await BackgroundSync.init(
              notificationInterval: _appSettings.notificationInterval,
              needsStart: true,
            );
          },
        )
      ],
    );
  }

  Widget manageBlock() {
    return Column(
      children: [
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
              },
            );
          }).toList(),
        ),
        PeerButton(
          text: 'Turn off',
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
}

//TODO i18n
//TODO slider for interval
//TODO add data protection notice and enable dialog
//TODO add background notifications to setup
//TODO enable background notifications on wallet create 
//TODO save snack for the toggle
//TODO enable bg sync for all wallets when turing them on