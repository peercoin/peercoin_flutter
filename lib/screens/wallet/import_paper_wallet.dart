import 'package:coinslib/coinslib.dart';
import 'package:flutter/material.dart';
import 'package:peercoin/models/buildresult.dart';
import 'package:provider/provider.dart';

import '../../models/available_coins.dart';
import '../../models/coin.dart';
import '../../models/hive/wallet_utxo.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/connection_provider.dart';
import '../../tools/app_localizations.dart';
import '../../tools/app_routes.dart';
import '../../tools/logger_wrapper.dart';
import '../../widgets/buttons.dart';
import '../../widgets/loading_indicator.dart';

class ImportPaperWalletScreen extends StatefulWidget {
  const ImportPaperWalletScreen({Key? key}) : super(key: key);

  @override
  State<ImportPaperWalletScreen> createState() =>
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
  late ConnectionProvider _connectionProvider;
  late WalletProvider _walletProvider;
  late Map<String, List?> _paperWalletUtxos = {};
  late final int _decimalProduct;

  @override
  void didChangeDependencies() {
    if (_initial == true) {
      setState(() {
        _walletName = ModalRoute.of(context)!.settings.arguments as String;
        _activeCoin = AvailableCoins.getSpecificCoin(_walletName);
        _connectionProvider = Provider.of<ConnectionProvider>(context);
        //TODO FIX! broken
        _walletProvider = Provider.of<WalletProvider>(context);
        _decimalProduct = AvailableCoins.getDecimalProduct(
          identifier: _walletName,
        );
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
      Routes.qrScan,
      arguments: AppLocalizations.instance.translate(
        keyType == 'pub'
            ? 'paperwallet_step_1_text'
            : 'paperwallet_step_2_text',
      ),
    );
    if (result != null) {
      keyType == 'pub'
          ? validatePubKey(result as String)
          : validatePrivKey(result as String);
    }
  }

  void validatePubKey(String pubKey) {
    String newKey;
    if (validateAddress(pubKey, _activeCoin.networkType)) {
      newKey = pubKey;
      moveStep(2);
    } else {
      newKey = 'Invalid address';
    }
    setState(() {
      _pubKey = newKey;
    });
  }

  void validatePrivKey(String privKey) {
    String newKey;
    late Wallet wallet;
    var error = false;
    try {
      wallet = Wallet.fromWIF(privKey, _activeCoin.networkType);
    } catch (e) {
      error = true;
    }

    if (error == false && wallet.address == _pubKey) {
      newKey = privKey;
      moveStep(3);
    } else {
      newKey = 'Invalid private key';
    }
    setState(() {
      _privKey = newKey;
    });
  }

  void requestUtxos() async {
    setState(() {
      _balanceLoading = true;
    });
    _connectionProvider.requestPaperWalletUtxos(
      _walletProvider.getScriptHash(_walletName, _pubKey),
      _pubKey,
    );
  }

  void calculateBalance() {
    var totalValue = 0;
    for (var element in _paperWalletUtxos[_pubKey]!) {
      totalValue += element['value'] as int;
    }
    setState(() {
      _balanceLoading = false;
      _balanceInt = totalValue;
      _balance =
          '${(totalValue / _decimalProduct).toString()} ${_activeCoin.letterCode}';
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
          duration: const Duration(seconds: 5),
        ),
      );
    } else {
      var firstPress = true;
      var buildResult = await buildImportTx();
      var txFee = buildResult.fee;

      // ignore: use_build_context_synchronously
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.instance.translate(
                      'send_fee',
                      {
                        'amount': '${txFee / _decimalProduct}',
                        'letter_code': _activeCoin.letterCode
                      },
                    ),
                  ),
                  Text(
                    AppLocalizations.instance.translate(
                      'send_total',
                      {
                        'amount': '${_balanceInt / _decimalProduct}',
                        'letter_code': _activeCoin.letterCode
                      },
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: PeerButton(
                  text: AppLocalizations.instance
                      .translate('paperwallet_confirm_import'),
                  action: () async {
                    if (firstPress == false) return; //prevent double tap
                    try {
                      firstPress = false;
                      //broadcast
                      _connectionProvider.broadcastTransaction(
                        buildResult.hex,
                        buildResult.id,
                      );
                      //pop message
                      Navigator.of(context).pop();
                      //pop again to close import screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.instance
                                .translate('paperwallet_success'),
                            textAlign: TextAlign.center,
                          ),
                          duration: const Duration(seconds: 5),
                        ),
                      );
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

  Future<BuildResult> buildImportTx() async {
    //build list of paperWaleltUtxos
    var parsedWalletUtxos = <WalletUtxo>[];
    for (var utxo in _paperWalletUtxos[_pubKey]!) {
      LoggerWrapper.logInfo('ImportPaperWallet', 'buildImportTx', 'utxo $utxo');
      parsedWalletUtxos.add(
        WalletUtxo(
          hash: utxo['tx_hash'],
          txPos: utxo['tx_pos'],
          height: utxo['height'],
          value: utxo['value'],
          address: _walletProvider.getUnusedAddress(_walletName),
        ),
      );
    }

    return await _walletProvider.buildTransaction(
      identifier: _activeCoin.name,
      recipients: {_walletProvider.getUnusedAddress(_walletName): _balanceInt},
      fee: 0,
      paperWalletPrivkey: _privKey,
      paperWalletUtxos: parsedWalletUtxos,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
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
                    SizedBox(height: 30, child: Text(_pubKey)),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.instance
                              .translate('paperwallet_step_2'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        PeerButton(
                          action: () => handlePress(2),
                          text: AppLocalizations.instance
                              .translate('paperwallet_step_2_text'),
                          small: true,
                          active: _currentStep == 2,
                        ),
                      ],
                    ),
                    SizedBox(height: 60, child: Text(_privKey)),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.instance
                              .translate('paperwallet_step_3'),
                          style: Theme.of(context).textTheme.titleLarge,
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
                    SizedBox(
                      height: 30,
                      child: _balanceLoading == true
                          ? const LoadingIndicator()
                          : Text(_balance),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.instance
                              .translate('paperwallet_step_4'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        PeerButton(
                          small: true,
                          action: () => handlePress(4),
                          text: AppLocalizations.instance
                              .translate('paperwallet_step_4_text'),
                          active: _currentStep == 4,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Divider()
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
