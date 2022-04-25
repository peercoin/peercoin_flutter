import 'package:coinslib/coinslib.dart';
import 'package:flutter/material.dart';
import 'package:peercoin/models/wallet_utxo.dart';
import 'package:provider/provider.dart';

import '../../models/available_coins.dart';
import '../../models/coin.dart';
import '../../providers/active_wallets.dart';
import '../../providers/electrum_connection.dart';
import '../../tools/app_localizations.dart';
import '../../tools/app_routes.dart';
import '../../tools/logger_wrapper.dart';
import '../../widgets/buttons.dart';
import '../../widgets/loading_indicator.dart';

class ImportPaperWalletScreen extends StatefulWidget {
  @override
  _ImportPaperWalletScreenState createState() =>
      _ImportPaperWalletScreenState();
}

class _ImportPaperWalletScreenState extends State<ImportPaperWalletScreen> {
  int _currentStep = 1;
  String _pubKey = '';
  String _privKey = '';
  String _balance = '';
  int _balanceInt = 0;
  late Coin _activeCoin;
  late String _walletName;
  bool _initial = true;
  bool _balanceLoading = false;
  late ElectrumConnection _connectionProvider;
  late ActiveWallets _activeWallets;
  late Map<String, List?> _paperWalletUtxos = {};

  @override
  void didChangeDependencies() {
    if (_initial == true) {
      setState(() {
        _walletName = ModalRoute.of(context)!.settings.arguments as String;
        _activeCoin = AvailableCoins().getSpecificCoin(_walletName);
        _connectionProvider = Provider.of<ElectrumConnection>(context);
        _activeWallets = Provider.of<ActiveWallets>(context);
        _initial = false;
      });
    }
    if (_connectionProvider.paperWalletUtxos.isNotEmpty &&
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
          createQrScanner('pub');
          break;
        case 2:
          createQrScanner('priv');
          break;
        case 3:
          requestUtxos();
          break;
        case 4:
          emptyWallet();
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
      arguments: AppLocalizations.instance.translate(keyType == 'pub'
          ? 'paperwallet_step_1_text'
          : 'paperwallet_step_2_text'),
    );
    if (result != null) {
      keyType == 'pub'
          ? validatePubKey(result as String)
          : validatePrivKey(result as String);
    }
  }

  void validatePubKey(String pubKey) {
    String _newKey;
    if (Address.validateAddress(pubKey, _activeCoin.networkType)) {
      _newKey = pubKey;
      moveStep(2);
    } else {
      _newKey = 'Invalid address';
    }
    setState(() {
      _pubKey = _newKey;
    });
  }

  void validatePrivKey(String privKey) {
    String _newKey;
    late Wallet _wallet;
    var _error = false;
    try {
      _wallet = Wallet.fromWIF(privKey, _activeCoin.networkType);
    } catch (e) {
      _error = true;
    }

    if (_error == false && _wallet.address == _pubKey) {
      _newKey = privKey;
      moveStep(3);
    } else {
      _newKey = 'Invalid private key';
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
    var _totalValue = 0;
    _paperWalletUtxos[_pubKey]!.forEach((element) {
      _totalValue += element['value'] as int;
    });
    setState(() {
      _balanceLoading = false;
      _balanceInt = _totalValue;
      _balance =
          '${(_totalValue / 1000000).toString()} ${_activeCoin.letterCode}';
    });
    moveStep(4);
  }

  Future<void> emptyWallet() async {
    if (_balanceInt == 0 || _balanceInt < _activeCoin.minimumTxValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.instance.translate('paperwallet_error_1'),
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 5),
        ),
      );
    } else {
      var _firstPress = true;
      var _buildResult = await buildImportTx();
      var _txFee = _buildResult['fee'];

      await showDialog(
        context: context,
        builder: (_) {
          return SimpleDialog(
            title: Text(
              AppLocalizations.instance.translate('send_confirm_transaction'),
              textAlign: TextAlign.center,
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Column(
                  children: [
                    Text(
                      'Importing $_balance',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.instance.translate(
                      'send_fee',
                      {
                        'amount': '${_txFee / 1000000}',
                        'letter_code': '${_activeCoin.letterCode}'
                      },
                    ),
                  ),
                  Text(
                    AppLocalizations.instance.translate(
                      'send_total',
                      {
                        'amount': '${_balanceInt / 1000000}',
                        'letter_code': '${_activeCoin.letterCode}'
                      },
                    ),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: PeerButton(
                  text: AppLocalizations.instance
                      .translate('paperwallet_confirm_import'),
                  action: () async {
                    if (_firstPress == false) return; //prevent double tap
                    try {
                      _firstPress = false;
                      //broadcast
                      Provider.of<ElectrumConnection>(context, listen: false)
                          .broadcastTransaction(
                        _buildResult['hex'],
                        _buildResult['id'],
                      );
                      //pop message
                      Navigator.of(context).pop();
                      //pop again to close import screen
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          AppLocalizations.instance
                              .translate('paperwallet_success'),
                          textAlign: TextAlign.center,
                        ),
                        duration: Duration(seconds: 5),
                      ));
                      Navigator.of(context).pop();
                    } catch (e) {
                      LoggerWrapper.logError(
                        'ImportPaperWallet',
                        'emptyWallet',
                        e.toString(),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.instance.translate(
                              'send_oops',
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              )
            ],
          );
        },
      );
    }
  }

  Future<Map> buildImportTx() async {
    //build list of paperWaleltUtxos
    var parsedWalletUtxos = <WalletUtxo>[];
    _paperWalletUtxos[_pubKey]!.forEach(
      (utxo) {
        print('utxo $utxo');
        parsedWalletUtxos.add(
          WalletUtxo(
            hash: utxo['tx_hash'],
            txPos: utxo['tx_pos'],
            height: utxo['height'],
            value: utxo['value'],
            address: _activeWallets.getUnusedAddress,
          ),
        );
      },
    );

    return await _activeWallets.buildTransaction(
      identifier: _activeCoin.name,
      address: _activeWallets.getUnusedAddress,
      amount: (_balanceInt / 1000000).toString(),
      fee: 0,
      paperWalletPrivkey: _privKey,
      paperWalletUtxos: parsedWalletUtxos,
    );
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
                    Container(height: 30, child: Text(_pubKey)),
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
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        PeerButton(
                          action: () => handlePress(3),
                          text: AppLocalizations.instance
                              .translate('paperwallet_step_3_text'),
                          small: true,
                          active: _currentStep == 3,
                        ),
                      ],
                    ),
                    Container(
                      height: 30,
                      child: _balanceLoading == true
                          ? LoadingIndicator()
                          : Text(_balance),
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            AppLocalizations.instance
                                .translate('paperwallet_step_4'),
                            style: Theme.of(context).textTheme.headline6),
                        PeerButton(
                          small: true,
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
            ),
          )
        ],
      ),
    );
  }
}
