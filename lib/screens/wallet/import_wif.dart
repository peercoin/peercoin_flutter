import 'package:coinslib/coinslib.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peercoin/widgets/service_container.dart';
import 'package:provider/provider.dart';

import '../../models/available_coins.dart';
import '../../models/coin.dart';
import '../../providers/active_wallets.dart';
import '../../providers/electrum_connection.dart';
import '../../tools/app_localizations.dart';
import '../../tools/app_routes.dart';
import '../../tools/background_sync.dart';
import '../../widgets/buttons.dart';

class ImportWifScreen extends StatefulWidget {
  const ImportWifScreen({Key? key}) : super(key: key);

  @override
  _ImportWifScreenState createState() => _ImportWifScreenState();
}

class _ImportWifScreenState extends State<ImportWifScreen> {
  late Coin _activeCoin;
  late String _walletName;
  bool _initial = true;
  late ActiveWallets _activeWallets;
  late ElectrumConnection _electrumConnection;
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
        _electrumConnection = Provider.of<ElectrumConnection>(context);
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
      _wifController.text = (result as String).trim();
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
    //write to wallet
    await _activeWallets.addAddressFromWif(_walletName, wif, address);

    //subscribe
    _electrumConnection.subscribeToScriptHashes(
      {
        address: _activeWallets.getScriptHash(_walletName, address),
      },
    );

    //set to watched
    await _activeWallets.updateAddressWatched(_walletName, address, true);

    //sync background notification
    await BackgroundSync.executeSync(fromScan: true);

    //send snack notification for success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.instance.translate('import_wif_success_snack'),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    //pop import wif
    Navigator.of(context).pop();
  }

  Future<void> triggerConfirmMessage(BuildContext ctx, String privKey) async {
    final publicAddress =
        Wallet.fromWIF(privKey, _activeCoin.networkType).address ??
            ''; //TODO won't return a bech32 addr

    //check if that address is already in the list
    final _walletAddresses =
        await _activeWallets.getWalletAddresses(_walletName);
    final _specificAddressResult = _walletAddresses.where(
      (element) => element.address == publicAddress,
    );

    if (_specificAddressResult.isNotEmpty) {
      //we have that address already
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          AppLocalizations.instance.translate('import_wif_error_snack'),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 3),
      ));
    } else {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.instance.translate('wallet_pop_menu_wif'),
        ),
      ),
      body: Align(
        child: PeerContainer(
          noSpacers: true,
          child: Column(
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
                          Text(
                            AppLocalizations.instance
                                .translate('import_wif_intro'),
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.done,
                            key: _wifGlobalKey,
                            controller: _wifController,
                            autocorrect: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.instance
                                    .translate('import_wif_error_empty');
                              }
                              if (validatePrivKey(value)) {
                                return AppLocalizations.instance
                                    .translate('import_wif_error_failed_parse');
                              }

                              triggerConfirmMessage(context, value);
                              return null;
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
                                  var data =
                                      await Clipboard.getData('text/plain');
                                  _wifController.text = data!.text!.trim();
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
                          if (!kIsWeb) const SizedBox(height: 10),
                          if (!kIsWeb)
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
                          const SizedBox(height: 10),
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
                          const SizedBox(height: 10),
                          Text(
                            AppLocalizations.instance
                                .translate('import_wif_hint'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
