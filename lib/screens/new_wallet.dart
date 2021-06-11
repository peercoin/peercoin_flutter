import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/providers/unencryptedOptions.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/models/availablecoins.dart';
import 'package:peercoin/models/coin.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/tools/auth.dart';
import 'package:provider/provider.dart';

class NewWalletScreen extends StatefulWidget {
  @override
  _NewWalletScreenState createState() => _NewWalletScreenState();
}

Map<String, Coin> availableCoins = AvailableCoins().availableCoins;
List activeCoins = [];

class _NewWalletScreenState extends State<NewWalletScreen> {
  String _coin = '';
  bool _initial = true;

  Future<void> addWallet(ctx) async {
    try {
      await Provider.of<ActiveWallets>(context, listen: false).addWallet(
          _coin,
          availableCoins[_coin]!.displayName,
          availableCoins[_coin]!.letterCode);
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
              ? AppLocalizations.instance.translate('select_coin')!
              : AppLocalizations.instance.translate('add_coin_failed')!,
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
        await Auth.requireAuth(context, _appSettings.biometricsAllowed!);
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
    final actualAvailableWallets = availableCoins.keys
        .where((element) => !activeCoins.contains(element))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.instance.translate('add_new_wallet')!),
        actions: [
          if (actualAvailableWallets.isNotEmpty)
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: IconButton(
                  key: Key('confirm_add_wallet'),
                  onPressed: () => addWallet(context),
                  icon: Icon(Icons.add),
                ))
        ],
      ),
      body: Container(
        child: actualAvailableWallets.isEmpty
            ? Center(
                child:
                    Text(AppLocalizations.instance.translate('no_new_wallet')!),
              )
            : Column(children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: actualAvailableWallets.length,
                    itemBuilder: (ctx, item) {
                      return ListTile(
                        title: InkWell(
                          onTap: () {
                            setState(
                              () {
                                _coin = actualAvailableWallets[item];
                              },
                            );
                          },
                          child: ListTile(
                            trailing: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Image.asset(
                                  AvailableCoins()
                                      .getSpecificCoin(availableCoins[
                                              actualAvailableWallets[item]]!
                                          .name)
                                      .iconPath,
                                  width: 20),
                            ),
                            title: Text(
                                availableCoins[actualAvailableWallets[item]]!
                                    .displayName),
                            leading: Radio(
                              value: actualAvailableWallets[item],
                              groupValue: _coin,
                              onChanged: (dynamic value) {
                                setState(
                                  () {
                                    _coin = value;
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ]),
      ),
    );
  }
}
