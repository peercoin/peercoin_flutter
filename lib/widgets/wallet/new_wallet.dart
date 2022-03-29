import 'package:flutter/material.dart';
import 'package:peercoin/providers/app_settings.dart';
import 'package:peercoin/providers/unencrypted_options.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/models/available_coins.dart';
import 'package:peercoin/models/coin.dart';
import 'package:peercoin/providers/active_wallets.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/tools/auth.dart';
import 'package:provider/provider.dart';

class NewWalletDialog extends StatefulWidget {
  @override
  _NewWalletDialogState createState() => _NewWalletDialogState();
}

Map<String, Coin> availableCoins = AvailableCoins().availableCoins;
List activeCoins = [];

class _NewWalletDialogState extends State<NewWalletDialog> {
  String _coin = '';
  bool _initial = true;

  Future<void> addWallet(ctx) async {
    try {
      await Provider.of<ActiveWallets>(context, listen: false).addWallet(
          _coin,
          availableCoins[_coin]!.displayName,
          availableCoins[_coin]!.letterCode);

      //enable notifications
      var _appSettings = Provider.of<AppSettings>(context, listen: false);
      var _notificationList = _appSettings.notificationActiveWallets;
      _notificationList.add(availableCoins[_coin]!.letterCode);
      _appSettings.setNotificationActiveWallets(_notificationList);

      var prefs =
          await Provider.of<UnencryptedOptions>(context, listen: false).prefs;

      if (prefs.getBool('importedSeed') == true) {
        await Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.WalletImportScan, (_) => false,
            arguments: _coin);
      } else {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          _coin == ''
              ? AppLocalizations.instance.translate('select_coin')
              : AppLocalizations.instance.translate('add_coin_failed'),
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 2),
      ));
    }
  }

  @override
  void didChangeDependencies() async {
    if (_initial) {
      var _appSettings = Provider.of<AppSettings>(context, listen: false);
      if (_appSettings.authenticationOptions!['newWallet']!) {
        await Auth.requireAuth(
          context: context,
          biometricsAllowed: _appSettings.biometricsAllowed,
          canCancel: false,
        );
      }
      setState(() {
        _initial = false;
      });
    }
    var activeWalletList =
        await Provider.of<ActiveWallets>(context, listen: false)
            .activeWalletsKeys;
    activeWalletList.forEach((element) {
      if (availableCoins.keys.contains(element)) {
        setState(() {
          activeCoins.add(element);
        });
      }
    });

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
        list.add(SimpleDialogOption(
          onPressed: () {
            _coin = wallet;
            addWallet(context);
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              child: Image.asset(
                  AvailableCoins()
                      .getSpecificCoin(availableCoins[wallet]!.name)
                      .iconPath,
                  width: 16),
            ),
            title: Text(availableCoins[wallet]!.displayName),
          ),
        ));
      }
    } else {
      list.add(Center(
        child: Text(AppLocalizations.instance.translate('no_new_wallet')),
      ));
    }

    return SimpleDialog(
      title: Text(AppLocalizations.instance.translate('add_new_wallet')),
      children: list,
    );
  }
}
