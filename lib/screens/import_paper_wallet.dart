import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peercoin/models/availablecoins.dart';
import 'package:peercoin/models/coin.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/app_routes.dart';

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

  @override
  void didChangeDependencies() {
    if (_initial == true) {
      setState(() {
        _walletName = ModalRoute.of(context).settings.arguments;
        _activeCoin = AvailableCoins().getSpecificCoin(_walletName);
        _initial = false;
      });
    }
    super.didChangeDependencies();
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
      }
    }
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

  void moveStep(int newStep) {
    setState(() {
      _currentStep = newStep;
    });
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
                    Container(height: 20, child: Text(_pubKey)),
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
                    Container(height: 20, child: Text(_privKey)),
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
                    Container(height: 20, child: Text(_balance)),
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
                    SizedBox(height: 20),
                    Divider()
                  ],
                ),
              ),
            ))
          ],
        ));
  }
}
