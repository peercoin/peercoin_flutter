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
  late Coin _activeCoin;
  late String _walletName;
  bool _initial = true;
  late ActiveWallets _activeWallets;
  final _wifGlobalKey = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();
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

  bool validatePrivKey(String privKey) {
    var _error = false;
    try {
      Wallet.fromWIF(privKey, _activeCoin.networkType);
    } catch (e) {
      _error = true;
    }
    return _error;
  }

  Future<void> performImport(String wif, String address) async {
    await _activeWallets.addAddressFromWif(_walletName, wif, address);
    //subscribe
    //pop
  }

  Future<void> triggerConfirmMessage(BuildContext ctx, String privKey) async {
    final publicAddress =
        Wallet.fromWIF(privKey, _activeCoin.networkType).address ?? '';
    await showDialog(
      context: ctx,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.instance.translate('paperwallet_confirm_import'),
            textAlign: TextAlign.center,
          ),
          content: Text(
            AppLocalizations.instance.translate(
              'import_wif_alert_content',
              {'address': publicAddress},
            ),
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
                Navigator.pop(context);
                await performImport(privKey, publicAddress);
              },
              child: Text(
                AppLocalizations.instance.translate('import_button'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.instance.translate('wallet_pop_menu_wif'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      textInputAction: TextInputAction.done,
                      key: _wifGlobalKey,
                      controller: _wifController,
                      autocorrect: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.instance
                              .translate('import_wif_error_empty');
                        } else if (validatePrivKey(value)) {
                          return AppLocalizations.instance
                              .translate('import_wif_error_failed_parse');
                        } else {
                          triggerConfirmMessage(context, value);
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.vpn_key,
                          color: Theme.of(context).primaryColor,
                        ),
                        labelText: AppLocalizations.instance
                            .translate('import_wif_textfield_label'),
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
                      minLines: 4,
                      maxLines: 4,
                    ),
                    SizedBox(height: 10),
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
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PeerButton(
                          action: () {
                            _formKey.currentState!.save();
                            _formKey.currentState!.validate();
                          },
                          text: AppLocalizations.instance
                              .translate('import_button'),
                          small: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ))
        ],
      ),
    );
  }
}

//TODO add hint that key needs to be WIF format
//TODO add hint that key has to be imported again when restoring the wallet from seed
//TODO check if we have that addr already