import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peercoin/providers/wallet_provider.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/double_tab_to_clipboard.dart';
import 'package:peercoin/widgets/service_container.dart';
import 'package:provider/provider.dart';

class WalletSignTransactionScreen extends StatefulWidget {
  const WalletSignTransactionScreen({super.key});

  @override
  State<WalletSignTransactionScreen> createState() =>
      _WalletSignTransactionScreenState();
}

class _WalletSignTransactionScreenState
    extends State<WalletSignTransactionScreen> {
  late String _walletName;
  late WalletProvider _walletProvider;
  bool _initial = true;
  bool _signingDone = false;
  String _signingError = '';
  String _signedTx = '';
  String _signingAddress = '';
  final TextEditingController _txInputController = TextEditingController();
  final Map<int, bool> _checkedInputs = {};

  @override
  void didChangeDependencies() {
    if (_initial == true) {
      _walletName = ModalRoute.of(context)!.settings.arguments as String;
      _walletProvider = Provider.of<WalletProvider>(context);
      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
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

  Future<bool> _showInputSelector(int inputN) async {
    return await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      isDismissible: false,
      context: context,
      enableDrag: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return ModalBottomSheetContainer(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.instance.translate(
                      'sign_transaction_input_selector_title',
                    ),
                    style: TextStyle(
                      letterSpacing: 1.4,
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (ctx, n) => CheckboxListTile(
                        title: Text('Input $n'),
                        value: _checkedInputs[n] ?? false,
                        onChanged: (value) {
                          setState(() {
                            _checkedInputs[n] = value!;
                          });
                        },
                      ),
                      itemCount: inputN,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
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
                        label: Text(
                          AppLocalizations.instance
                              .translate('jail_dialog_button'),
                        ),
                        icon: const Icon(Icons.check),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
      final selectedInputResult = await _showInputSelector(tx.inputs.length);
      if (selectedInputResult == false) return;
      if (_checkedInputs.values.every((element) => element == false)) return;

      // conversion step for cointoolkit start
      tx = Transaction(
        inputs: tx.inputs.mapIndexed((i, input) {
          if (!_checkedInputs.containsKey(i) || !_checkedInputs[i]!) {
            //don't convert this unselected input, return as is
            return input;
          }

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
      _checkedInputs.forEach((key, value) {
        if (value) {
          txToSign = tx.sign(
            inputN: key,
            key: privKey,
          );
        }
      });
      final signedTx = txToSign.toHex();

      setState(() {
        _signedTx = signedTx;
        _signingDone = true;
      });

      LoggerWrapper.logInfo(
        'WalletTransactionSigning',
        'handleSign',
        'tx produced $signedTx',
      );
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
                  if (route.settings.name == '/wallet-home') {
                    return true;
                  }
                  return false;
                },
                arguments: _walletName,
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
                                AppLocalizations.instance
                                    .translate('sign_step_1'),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: _signingAddress == ''
                                ? Text(
                                    AppLocalizations.instance.translate(
                                      'sign_transaction_step_1_description',
                                    ),
                                  )
                                : DoubleTabToClipboard(
                                    clipBoardData: _signingAddress,
                                    child: SelectableText(_signingAddress),
                                  ),
                          ),
                          PeerButton(
                            action: () =>
                                _signingDone ? null : _showAddressSelector(),
                            text: AppLocalizations.instance.translate(
                              _signingAddress == ''
                                  ? 'sign_step_1_button'
                                  : 'sign_step_1_button_alt',
                            ),
                            small: true,
                            active: !_signingDone,
                          ),
                          _signingAddress.isNotEmpty && !_signingDone
                              ? PeerButton(
                                  action: () => _copyPubKeyToClipboard(
                                    _signingAddress,
                                  ),
                                  text: AppLocalizations.instance.translate(
                                    'sign_transaction_step_1_copy_pubkey',
                                  ),
                                  small: true,
                                  active: !_signingDone,
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
                        readOnly: _signingDone,
                        minLines: 5,
                        maxLines: 5,
                        onChanged: (_) => setState(
                          () {},
                        ), //to activate sign button on key stroke
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () async {
                              if (_signingDone) return;
                              final data =
                                  await Clipboard.getData('text/plain');
                              setState(() {
                                _txInputController.text = data!.text!.trim();
                              });
                            },
                            icon: Icon(
                              Icons.paste_rounded,
                              color: _signingDone
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).primaryColor,
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
                      _signedTx.isNotEmpty
                          ? Column(
                              children: [
                                DoubleTabToClipboard(
                                  clipBoardData: _signedTx,
                                  child: SelectableText(
                                    _signedTx,
                                    key: const Key('signature'),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  AppLocalizations.instance.translate(
                                    'sign_transaction_step_3_description',
                                  ),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      const SizedBox(
                        height: 10,
                      ),
                      _signedTx.isNotEmpty
                          ? PeerButton(
                              action: () => DoubleTabToClipboard.tapEvent(
                                context,
                                _signedTx,
                              ),
                              text: AppLocalizations.instance.translate(
                                'sign_transaction_step_3_button_alt',
                              ),
                              small: true,
                              active: _signingAddress.isNotEmpty &&
                                  _txInputController.text.isNotEmpty,
                            )
                          : PeerButton(
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
                      _signingDone
                          ? PeerButton(
                              text: AppLocalizations.instance
                                  .translate('sign_reset_button'),
                              small: true,
                              action: () async => await _performReset(context),
                            )
                          : Container(),
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
