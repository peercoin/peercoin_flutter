import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peercoin/models/availablecoins.dart';
import 'package:peercoin/models/coin.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/providers/electrumconnection.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class ImportPaperWalletScreen extends StatefulWidget {
  @override
  _ImportPaperWalletScreenState createState() =>
      _ImportPaperWalletScreenState();
}

class _ImportPaperWalletScreenState extends State<ImportPaperWalletScreen> {
  int _currentStep = 1;
  String _pubKey = "";
  String _privKey = "";
  String _balance = "";
  Coin _activeCoin;
  String _walletName;
  bool _initial = true;
  bool _balanceLoading = false;
  ElectrumConnection _connectionProvider;
  ActiveWallets _activeWallets;
  Map<String, List> _paperWalletUtxos = {};

  @override
  void didChangeDependencies() {
    if (_initial == true) {
      setState(() {
        _walletName = ModalRoute.of(context).settings.arguments;
        _activeCoin = AvailableCoins().getSpecificCoin(_walletName);
        _connectionProvider = Provider.of<ElectrumConnection>(context);
        _activeWallets = Provider.of<ActiveWallets>(context);
        _initial = false;
      });
    }
    if (_connectionProvider.paperWalletUtxos.length > 0 &&
        _connectionProvider.paperWalletUtxos != _paperWalletUtxos) {
      _paperWalletUtxos = _connectionProvider.paperWalletUtxos;
      calculateBalance();
    }
    super.didChangeDependencies();
  }

  @override
  void deactivate() {
    _connectionProvider.cleanPaperWallet();
    super.deactivate();
  }

  void handlePress(int step) {
    if (step == _currentStep) {
      switch (step) {
        case 1:
          createQrScanner("pub");
          break;
        case 2:
          createQrScanner("priv");
          break;
        case 3:
          requestUtxos();
          break;
      }
    }
  }

  void moveStep(int newStep) {
    setState(() {
      _currentStep = newStep;
    });
  }

  void createQrScanner(String keyType) async {
    final result = await Navigator.of(context).pushNamed(
      Routes.QRScan,
      arguments: AppLocalizations.instance.translate(keyType == "pub"
          ? 'paperwallet_step_1_text'
          : 'paperwallet_step_2_text'),
    );
    if (result != null) {
      keyType == "pub" ? validatePubKey(result) : validatePrivKey(result);
    }
  }

  void validatePubKey(String pubKey) {
    String _newKey;
    if (Address.validateAddress(pubKey, _activeCoin.networkType)) {
      _newKey = pubKey;
      moveStep(2);
    } else {
      _newKey = "Invalid address";
    }
    setState(() {
      _pubKey = _newKey;
    });
  }

  void validatePrivKey(String privKey) {
    String _newKey;
    Wallet _wallet;
    bool _error = false;
    try {
      _wallet = Wallet.fromWIF(privKey, _activeCoin.networkType);
    } catch (e) {
      _error = true;
    }

    if (_error == false && _wallet.address == _pubKey) {
      _newKey = privKey;
      moveStep(3);
    } else {
      _newKey = "Invalid private key";
    }
    setState(() {
      _privKey = _newKey;
    });
  }

  void requestUtxos() async {
    setState(() {
      _balanceLoading = true;
    });
    _connectionProvider.requestPaperWalletUtxos(
        _activeWallets.getScriptHash(_walletName, _pubKey), _pubKey);
  }

  void calculateBalance() {
    int _totalValue = 0;
    _paperWalletUtxos[_pubKey].forEach((element) {
      _totalValue += element["value"];
    });
    setState(() {
      _balanceLoading = false;
      _balance =
          "${(_totalValue / 1000000).toString()} ${_activeCoin.letterCode}";
    });
    moveStep(4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.instance.translate("wallet_pop_menu_paperwallet"),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            AppLocalizations.instance
                                .translate('paperwallet_step_1'),
                            style: Theme.of(context).textTheme.headline6),
                        TextButton.icon(
                          onPressed: () => handlePress(1),
                          icon: Icon(Icons.camera,
                              color: _currentStep == 1
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).accentColor),
                          label: Text(
                            AppLocalizations.instance
                                .translate('paperwallet_step_1_text'),
                            style: TextStyle(
                                color: _currentStep == 1
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).accentColor),
                          ),
                        ),
                      ],
                    ),
                    Container(height: 30, child: Text(_pubKey)),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            AppLocalizations.instance
                                .translate('paperwallet_step_2'),
                            style: Theme.of(context).textTheme.headline6),
                        TextButton.icon(
                          onPressed: () => handlePress(2),
                          icon: Icon(Icons.camera,
                              color: _currentStep == 2
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).accentColor),
                          label: Text(
                            AppLocalizations.instance
                                .translate('paperwallet_step_2_text'),
                            style: TextStyle(
                                color: _currentStep == 2
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).accentColor),
                          ),
                        ),
                      ],
                    ),
                    Container(height: 60, child: Text(_privKey)),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            AppLocalizations.instance
                                .translate('paperwallet_step_3'),
                            style: Theme.of(context).textTheme.headline6),
                        TextButton.icon(
                          onPressed: () => handlePress(3),
                          icon: Icon(Icons.payments,
                              color: _currentStep == 3
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).accentColor),
                          label: Text(
                            AppLocalizations.instance
                                .translate('paperwallet_step_3_text'),
                            style: TextStyle(
                                color: _currentStep == 3
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).accentColor),
                          ),
                        ),
                      ],
                    ),
                    Container(
                        height: 30,
                        child: _balanceLoading == true
                            ? LoadingIndicator()
                            : Text(_balance)),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            AppLocalizations.instance
                                .translate('paperwallet_step_4'),
                            style: Theme.of(context).textTheme.headline6),
                        TextButton.icon(
                          onPressed: () => handlePress(4),
                          icon: Icon(Icons.arrow_circle_down,
                              color: _currentStep == 4
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).accentColor),
                          label: Text(
                            AppLocalizations.instance
                                .translate('paperwallet_step_4_text'),
                            style: TextStyle(
                                color: _currentStep == 4
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).accentColor),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Divider()
                  ],
                ),
              ),
            ))
          ],
        ));
  }
}
