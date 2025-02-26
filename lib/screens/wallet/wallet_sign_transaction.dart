import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peercoin/models/available_coins.dart';
import 'package:peercoin/providers/wallet_provider.dart';
import 'package:peercoin/screens/wallet/wallet_sign_transaction_confirmation.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/double_tab_to_clipboard.dart';
import 'package:peercoin/widgets/service_container.dart';
import 'package:provider/provider.dart';

class WalletSignTransactionArguments {
  final String walletName;
  final String coinLetterCode;
  WalletSignTransactionArguments({
    required this.walletName,
    required this.coinLetterCode,
  });
}

class WalletSignTransactionScreen extends StatefulWidget {
  const WalletSignTransactionScreen({super.key});

  @override
  State<WalletSignTransactionScreen> createState() =>
      _WalletSignTransactionScreenState();
}

class _WalletSignTransactionScreenState
    extends State<WalletSignTransactionScreen> {
  late String _walletName;
  late String _coinLetterCode;
  late WalletProvider _walletProvider;
  bool _initial = true;
  String _signingError = '';
  String _signingAddress = '';
  final List<int> _successfullySignedInputs = [];
  final TextEditingController _txInputController = TextEditingController();

  @override
  void didChangeDependencies() {
    if (_initial == true) {
      final args = ModalRoute.of(context)!.settings.arguments
          as WalletSignTransactionArguments;
      _walletProvider = Provider.of<WalletProvider>(context);
      _walletName = args.walletName;
      _coinLetterCode = args.coinLetterCode;

      // Check the addresses list
      _initializeSigningAddress();

      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  Future<void> _initializeSigningAddress() async {
    final addresses = await _walletProvider.getWalletAddresses(_walletName);

    if (addresses.length == 1) {
      // Automatically set the signing address if only one address exists
      setState(() {
        _signingAddress = addresses.first.address;
      });
    }
  }

  void _saveSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.instance.translate(
            'sign_snack_text',
            {'address': _signingAddress},
          ),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showAddressSelector() async {
    final oldAddr = _signingAddress;
    var result = await Navigator.of(context).pushNamed(
      Routes.addressSelector,
      arguments: {
        'addresses': await _walletProvider.getWalletAddresses(_walletName),
        'selectedAddress': _signingAddress,
      },
    );
    setState(() {
      _signingAddress = result as String;
    });
    if (result != '' && result != oldAddr) {
      _saveSnack();
    }
  }

  Future<void> _handleSign() async {
    LoggerWrapper.logInfo(
      'WalletTransactionSigning',
      'handleSign',
      'signing tx with $_signingAddress on $_walletName, tx: ${_txInputController.text}',
    );

    try {
      var wif = await _walletProvider.getWif(
        identifier: _walletName,
        address: _signingAddress,
      );
      final privKey = WIF.fromString(wif).privkey;

      Transaction tx = Transaction.fromHex(_txInputController.text);

      // conversion step for cointoolkit start
      tx = Transaction(
        inputs: tx.inputs.mapIndexed((i, input) {
          // Determine program from cointoolkit input script data
          final program = Program.decompile(input.scriptSig);

          if (program is P2PKH) {
            return P2PKHInput(
              prevOut: input.prevOut,
              publicKey: privKey.pubkey,
            );
          }

          if (program is MultisigProgram) {
            return P2SHMultisigInput(
              prevOut: input.prevOut,
              program: program,
            );
          }

          return input;
        }),
        outputs: tx.outputs,
        version: tx.version,
        locktime: tx.locktime,
      );
      // conversion step for cointoolkit end

      Transaction txToSign = tx;
      //try to sign all inputs
      String errorMessage = '';
      for (var i in tx.inputs) {
        final index = tx.inputs.indexOf(i);
        try {
          txToSign = txToSign.sign(
            inputN: index,
            key: privKey,
          );
          _successfullySignedInputs.add(index);
        } catch (e) {
          LoggerWrapper.logError(
            'WalletTransactionSigning',
            'handleSign',
            'failed to sign input $i: $e',
          );
          errorMessage = e.toString();
        }
      }
      final signedTx = txToSign.toHex();
      LoggerWrapper.logInfo(
        'WalletTransactionSigning',
        'handleSign',
        'tx produced $signedTx',
      );

      //if no inputs were signed, show error
      if (_successfullySignedInputs.isEmpty) {
        setState(() {
          _signingError = errorMessage;
        });
        return;
      }

      //show confirmation
      if (!mounted) return;
      await Navigator.of(context).pushNamed(
        Routes.walletTransactionSigningConfirmation,
        arguments: WalletSignTransactionConfirmationArguments(
          tx: txToSign,
          decimalProduct: AvailableCoins.getDecimalProduct(
            identifier: _walletName,
          ),
          network: AvailableCoins.getSpecificCoin(
            _walletName,
          ).networkType,
          coinLetterCode: _coinLetterCode,
          selectedInputs: _successfullySignedInputs,
        ),
      );

      //reset state
      setState(() {
        _successfullySignedInputs.clear();
        _signingError = '';
      });
    } catch (e) {
      LoggerWrapper.logError(
        'WalletTransactionSigning',
        'handleSign',
        e.toString(),
      );
      setState(() {
        _signingError = e.toString();
      });
    }
  }

  void _copyPubKeyToClipboard(String address) async {
    final wif = await _walletProvider.getWif(
      identifier: _walletName,
      address: _signingAddress,
    );
    final pubKey = WIF.fromString(wif).privkey.pubkey.hex;

    Clipboard.setData(ClipboardData(text: pubKey));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.instance.translate(
              'snack_copied',
            ),
            textAlign: TextAlign.center,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _performReset(BuildContext ctx) async {
    return await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          AppLocalizations.instance.translate('sign_reset_alert_title'),
        ),
        content: Text(
          AppLocalizations.instance.translate('sign_reset_alert_body'),
        ),
        actions: <Widget>[
          TextButton.icon(
            label: Text(
              AppLocalizations.instance
                  .translate('server_settings_alert_cancel'),
            ),
            icon: const Icon(Icons.cancel),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton.icon(
            label:
                Text(AppLocalizations.instance.translate('sign_reset_button')),
            icon: const Icon(Icons.check),
            onPressed: () async {
              LoggerWrapper.logInfo(
                'WalletTransactionSigning',
                '_performReset',
                'reset performed',
              );
              await Navigator.of(ctx).pushNamedAndRemoveUntil(
                Routes.walletTransactionSigning,
                (route) {
                  if (route.settings.name ==
                      Routes.standardAndWatchOnlyWalletHome) {
                    return true;
                  }
                  return false;
                },
                arguments: WalletSignTransactionArguments(
                  walletName: _walletName,
                  coinLetterCode: _coinLetterCode,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.instance.translate(
            'wallet_pop_menu_signing_transactions',
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Align(
                child: PeerContainer(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _signingAddress.isEmpty
                                    ? AppLocalizations.instance
                                        .translate('sign_step_1')
                                    : AppLocalizations.instance
                                        .translate('send_address'),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: _signingAddress.isEmpty
                                ? Text(
                                    AppLocalizations.instance.translate(
                                      'sign_transaction_step_1_description',
                                    ),
                                  )
                                : DoubleTabToClipboard(
                                    withHintText: false,
                                    clipBoardData: _signingAddress,
                                    child: SelectableText(_signingAddress),
                                  ),
                          ),
                          if (_signingAddress.isEmpty)
                            PeerButton(
                              action: () => _showAddressSelector(),
                              text: AppLocalizations.instance.translate(
                                _signingAddress.isEmpty
                                    ? 'sign_step_1_button'
                                    : 'sign_step_1_button_alt',
                              ),
                              small: true,
                            ),
                          // else just show address label
                          if (_signingAddress.isNotEmpty && kIsWeb)
                            const SizedBox(
                              height: 20,
                            ),
                          _signingAddress.isNotEmpty
                              ? PeerButton(
                                  action: () => _copyPubKeyToClipboard(
                                    _signingAddress,
                                  ),
                                  text: AppLocalizations.instance.translate(
                                    'sign_transaction_step_1_copy_pubkey',
                                  ),
                                  small: true,
                                )
                              : Container(),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.instance
                                .translate('sign_transaction_step_2'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      TextFormField(
                        textInputAction: TextInputAction.done,
                        key: const Key('transactionHexInput'),
                        controller: _txInputController,
                        autocorrect: false,
                        minLines: 5,
                        maxLines: 5,
                        onChanged: (_) => setState(
                          () {},
                        ), //to activate sign button on key stroke
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () async {
                              final data =
                                  await Clipboard.getData('text/plain');
                              setState(() {
                                _txInputController.text = data!.text!.trim();
                              });
                            },
                            icon: Icon(
                              Icons.paste_rounded,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          icon: Icon(
                            Icons.message,
                            color: Theme.of(context).primaryColor,
                          ),
                          labelText: AppLocalizations.instance
                              .translate('sign_transaction_input_label'),
                        ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.instance
                                .translate('sign_transaction_step_3'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      PeerButton(
                        action: () => _handleSign(),
                        text: AppLocalizations.instance
                            .translate('sign_step_3_button'),
                        small: true,
                        active: _signingAddress.isNotEmpty &&
                            _txInputController.text.isNotEmpty,
                      ),
                      _signingError.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                key: const Key('signingError'),
                                '${AppLocalizations.instance.translate(
                                  'sign_transaction_signing_failed',
                                )}\n$_signingError',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            )
                          : Container(),
                      if (kIsWeb)
                        const SizedBox(
                          height: 20,
                        ),
                      PeerButton(
                        text: AppLocalizations.instance
                            .translate('sign_reset_button'),
                        small: true,
                        action: () async => await _performReset(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
