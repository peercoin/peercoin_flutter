import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/available_coins.dart';
import '../../models/coin.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../tools/app_localizations.dart';
import '../../tools/auth.dart';

class NewWalletDialog extends StatefulWidget {
  const NewWalletDialog({super.key});

  @override
  State<NewWalletDialog> createState() => _NewWalletDialogState();
}

Map<String, Coin> _availableCoins = AvailableCoins.availableCoins;

class _NewWalletDialogState extends State<NewWalletDialog> {
  String _coin = '';
  bool _initial = true;
  bool _watchOnly = false;
  late AppSettingsProvider _appSettings;

  Future<void> addWallet() async {
    try {
      var appSettings = context.read<AppSettingsProvider>();
      final navigator = Navigator.of(context);
      final WalletProvider walletProvider = context.read<WalletProvider>();
      final letterCode = _availableCoins[_coin]!.letterCode;
      final nOfWalletOfLetterCode = walletProvider.availableWalletValues
          .where((element) => element.letterCode == letterCode)
          .length;
      final walletName = '${_coin}_$nOfWalletOfLetterCode';

      String title = _availableCoins[_coin]!.displayName;
      if (nOfWalletOfLetterCode > 0) {
        title = '$title ${nOfWalletOfLetterCode + 1}';
      }
      final prefs = await SharedPreferences.getInstance();

      await walletProvider.addWallet(
        name: walletName,
        title: title,
        letterCode: letterCode,
        isImportedSeed: prefs.getBool('importedSeed') == true,
        watchOnly: _watchOnly,
      );

      //add to order list
      _appSettings.setWalletOrder(_appSettings.walletOrder..add(walletName));

      //enable notifications
      var notificationList = appSettings.notificationActiveWallets;
      notificationList.add(walletName);
      appSettings.setNotificationActiveWallets(notificationList);

      navigator.pop();
    } catch (e) {
      if (mounted) {
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
  }

  @override
  void didChangeDependencies() async {
    if (_initial) {
      _appSettings = context.read<AppSettingsProvider>();
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

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var list = <Widget>[];
    final actualAvailableWallets = _availableCoins.keys;

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
                  AvailableCoins.getSpecificCoin(_availableCoins[wallet]!.name)
                      .iconPath,
                  width: 16,
                ),
              ),
              title: Text(_availableCoins[wallet]!.displayName),
            ),
          ),
        );
        if (_appSettings.activatedExperimentalFeatures.contains('frost')) {
          list.add(
            SimpleDialogOption(
              onPressed: () {
                _coin = wallet; //TODO
                addWallet();
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    AvailableCoins.getSpecificCoin(
                      _availableCoins[wallet]!.name,
                    ).iconPath,
                    width: 16,
                  ),
                ),
                title: Text(
                  '${_availableCoins[wallet]!.letterCode == "tPPC" ? "Testnet " : ""}FROST Group',
                ),
              ),
            ),
          );
        }
      }
    } else {
      list.add(
        Center(
          child: Text(AppLocalizations.instance.translate('no_new_wallet')),
        ),
      );
    }
    list.add(
      SimpleDialogOption(
        child: GestureDetector(
          onTap: () => setState(() {
            _watchOnly = !_watchOnly;
          }),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: _watchOnly,
                onChanged: (e) => setState(() {
                  _watchOnly = e!;
                }),
              ),
              Text(AppLocalizations.instance.translate('watch_only')),
            ],
          ),
        ),
      ),
    );

    return SimpleDialog(
      title: Text(AppLocalizations.instance.translate('add_new_wallet')),
      children: list,
    );
  }
}
