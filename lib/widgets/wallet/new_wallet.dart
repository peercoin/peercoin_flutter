import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/available_coins.dart';
import '../../models/coin.dart';
import '../../providers/active_wallets.dart';
import '../../providers/app_settings.dart';
import '../../tools/app_localizations.dart';
import '../../tools/app_routes.dart';
import '../../tools/auth.dart';

class NewWalletDialog extends StatefulWidget {
  const NewWalletDialog({Key? key}) : super(key: key);

  @override
  State<NewWalletDialog> createState() => _NewWalletDialogState();
}

Map<String, Coin> availableCoins = AvailableCoins.availableCoins;
List activeCoins = [];

class _NewWalletDialogState extends State<NewWalletDialog> {
  String _coin = '';
  bool _initial = true;

  Future<void> addWallet() async {
    try {
      var appSettings = context.read<AppSettings>();
      final navigator = Navigator.of(context);
      await context.read<ActiveWallets>().addWallet(
            _coin,
            availableCoins[_coin]!.displayName,
            availableCoins[_coin]!.letterCode,
          );

      //enable notifications
      var notificationList = appSettings.notificationActiveWallets;
      notificationList.add(availableCoins[_coin]!.letterCode);
      appSettings.setNotificationActiveWallets(notificationList);

      var prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('importedSeed') == true) {
        await navigator.pushNamedAndRemoveUntil(
          Routes.walletImportScan,
          (_) => false,
          arguments: _coin,
        );
      } else {
        navigator.pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _coin == ''
                ? AppLocalizations.instance.translate('select_coin')
                : AppLocalizations.instance.translate('add_coin_failed'),
            textAlign: TextAlign.center,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void didChangeDependencies() async {
    if (_initial) {
      var appSettings = context.read<AppSettings>();
      var activeWallets = context.read<ActiveWallets>();
      if (appSettings.authenticationOptions!['newWallet']!) {
        await Auth.requireAuth(
          context: context,
          biometricsAllowed: appSettings.biometricsAllowed,
          canCancel: false,
        );
      }
      var activeWalletList = activeWallets.activeWalletsKeys;
      for (var element in activeWalletList) {
        if (availableCoins.keys.contains(element)) {
          setState(() {
            activeCoins.add(element);
          });
        }
      }
      setState(() {
        _initial = false;
      });
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var list = <Widget>[];
    final actualAvailableWallets = availableCoins.keys
        .where((element) => !activeCoins.contains(element))
        .toList();

    if (actualAvailableWallets.isNotEmpty) {
      for (var wallet in actualAvailableWallets) {
        list.add(
          SimpleDialogOption(
            onPressed: () {
              _coin = wallet;
              addWallet();
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                child: Image.asset(
                  AvailableCoins.getSpecificCoin(availableCoins[wallet]!.name)
                      .iconPath,
                  width: 16,
                ),
              ),
              title: Text(availableCoins[wallet]!.displayName),
            ),
          ),
        );
      }
    } else {
      list.add(
        Center(
          child: Text(AppLocalizations.instance.translate('no_new_wallet')),
        ),
      );
    }

    return SimpleDialog(
      title: Text(AppLocalizations.instance.translate('add_new_wallet')),
      children: list,
    );
  }
}
