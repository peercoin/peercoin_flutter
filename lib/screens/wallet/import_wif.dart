import 'package:coinslib/coinslib.dart';
import 'package:flutter/material.dart';
import 'package:peercoin/models/availablecoins.dart';
import 'package:peercoin/models/coin.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class ImportWifScreen extends StatefulWidget {
  @override
  _ImportWifScreenState createState() => _ImportWifScreenState();
}

class _ImportWifScreenState extends State<ImportWifScreen> {
  int _currentStep = 1;
  String _privKey = '';
  late Coin _activeCoin;
  late String _walletName;
  bool _initial = true;
  late ActiveWallets _activeWallets;

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

  void handlePress(int step) {
    if (step == _currentStep) {
      switch (step) {
        case 1:
          createQrScanner('pub');
          break;
        case 2:
          createQrScanner('priv');
          break;
        case 3:
          break;
        case 4:
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
      arguments: AppLocalizations.instance.translate('paperwallet_step_2_text'),
    );
    if (result != null) {
      validatePrivKey(result as String);
    }
  }

  void validatePrivKey(String privKey) {
    String _newKey;
    var _error = false;
    try {
      Wallet.fromWIF(privKey, _activeCoin.networkType);
    } catch (e) {
      _error = true;
    }

    if (_error == false) {
      _newKey = privKey;
      moveStep(3);
    } else {
      _newKey = 'Invalid private key';
    }
    setState(() {
      _privKey = _newKey;
    });
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            AppLocalizations.instance
                                .translate('paperwallet_step_1'),
                            style: Theme.of(context).textTheme.headline6),
                        PeerButton(
                          action: () => handlePress(1),
                          text: AppLocalizations.instance.translate(
                            'paperwallet_step_1_text',
                          ),
                          small: true,
                          active: _currentStep == 1,
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            AppLocalizations.instance
                                .translate('paperwallet_step_2'),
                            style: Theme.of(context).textTheme.headline6),
                        PeerButton(
                          action: () => handlePress(2),
                          text: AppLocalizations.instance
                              .translate('paperwallet_step_2_text'),
                          small: true,
                          active: _currentStep == 2,
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
                        PeerButton(
                          action: () => handlePress(3),
                          text: AppLocalizations.instance
                              .translate('paperwallet_step_3_text'),
                          small: true,
                          active: _currentStep == 3,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            AppLocalizations.instance
                                .translate('paperwallet_step_4'),
                            style: Theme.of(context).textTheme.headline6),
                        PeerButton(
                          action: () => handlePress(4),
                          text: AppLocalizations.instance
                              .translate('paperwallet_step_4_text'),
                          active: _currentStep == 4,
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
