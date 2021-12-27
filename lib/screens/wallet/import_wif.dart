import 'package:coinslib/coinslib.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peercoin/models/availablecoins.dart';
import 'package:peercoin/models/coin.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:provider/provider.dart';

class ImportWifScreen extends StatefulWidget {
  @override
  _ImportWifScreenState createState() => _ImportWifScreenState();
}

class _ImportWifScreenState extends State<ImportWifScreen> {
  String _privKey = '';
  late Coin _activeCoin;
  late String _walletName;
  bool _initial = true;
  late ActiveWallets _activeWallets;
  final _wifGlobalKey = GlobalKey<FormState>();
  final _wifController = TextEditingController();

  @override
  void didChangeDependencies() {
    if (_initial == true) {
      setState(() {
        _walletName = ModalRoute.of(context)!.settings.arguments as String;
        _activeCoin = AvailableCoins().getSpecificCoin(_walletName);
        _activeWallets = Provider.of<ActiveWallets>(context);
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  void createQrScanner(String keyType) async {
    final result = await Navigator.of(context).pushNamed(
      Routes.QRScan,
      arguments: AppLocalizations.instance.translate('paperwallet_step_2_text'),
    );
    if (result != null) {
      validatePrivKey(result as String);
    }
  }

  void validatePrivKey(String privKey) {
    var _error = false;
    try {
      Wallet.fromWIF(privKey, _activeCoin.networkType);
    } catch (e) {
      _error = true;
    }

    if (_error == false) {
      //show check mark
    } else {
      //show error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.instance.translate('wallet_pop_menu_paperwallet'),
          ),
        ),
        body: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      textInputAction: TextInputAction.done,
                      key: _wifGlobalKey,
                      controller: _wifController,
                      autocorrect: false,
                      onChanged: (String newString) {
                        print(newString);
                      },
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.vpn_key,
                          color: Theme.of(context).primaryColor,
                        ),
                        labelText:
                            AppLocalizations.instance.translate('send_label'),
                        suffixIcon: IconButton(
                          onPressed: () async {
                            var data = await Clipboard.getData('text/plain');
                            _wifController.text = data!.text!;
                          },
                          icon: Icon(
                            Icons.paste_rounded,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      maxLength: 32,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PeerButton(
                          action: () => createQrScanner('priv'),
                          text: AppLocalizations.instance
                              .translate('paperwallet_step_2_text'),
                          small: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ))
          ],
        ));
  }
}
