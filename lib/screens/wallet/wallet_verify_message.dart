import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peercoin/tools/validators.dart';

import '../../models/available_coins.dart';
import '../../models/coin.dart';
import '../../tools/app_localizations.dart';
import '../../tools/logger_wrapper.dart';
import '../../widgets/buttons.dart';
import '../../widgets/service_container.dart';

class WaleltMessagesVerificationScreen extends StatefulWidget {
  const WaleltMessagesVerificationScreen({super.key});

  @override
  State<WaleltMessagesVerificationScreen> createState() =>
      _WaleltMessagesVerificationScreenState();
}

class _WaleltMessagesVerificationScreenState
    extends State<WaleltMessagesVerificationScreen> {
  late String _walletName;
  bool _initial = true;
  bool _verificationPerformed = false;
  bool _verificationResult = false;
  late Coin _activeCoin;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _signatureInputController =
      TextEditingController();
  final TextEditingController _addressInputController = TextEditingController();
  final TextEditingController _messageInputController = TextEditingController();

  @override
  void didChangeDependencies() {
    if (_initial == true) {
      _walletName = ModalRoute.of(context)!.settings.arguments as String;
      _activeCoin = AvailableCoins.getSpecificCoin(_walletName);
      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  Future<void> _handleVerification() async {
    final message = _messageInputController.text;
    final address = _addressInputController.text;
    final signature = _signatureInputController.text;

    _formKey.currentState!.save();
    if (_formKey.currentState!.validate() == false) {
      setState(() {
        _verificationResult = false;
      });
    }

    LoggerWrapper.logInfo(
      'WalletVerification',
      'handleVerification',
      'verifiying message: $message, signature $signature, address $address',
    );

    try {
      final sig = MessageSignature.fromBase64(signature);
      final verificationResult = sig.verifyAddress(
        address: Address.fromString(
          address,
          _activeCoin.networkType,
        ),
        message: message,
        prefix: _activeCoin.networkType.messagePrefix,
      );

      setState(() {
        _verificationPerformed = true;
        _verificationResult = verificationResult;
      });

      LoggerWrapper.logInfo(
        'WalletSigning',
        'handleSign',
        'signature valid: $verificationResult',
      );
    } catch (e) {
      setState(() {
        _verificationPerformed = true;
        _verificationResult = false;
      });
      LoggerWrapper.logError(
        'WalletVerification',
        'handleVerification',
        e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.instance.translate('wallet_pop_menu_verification'),
        ),
        actions: [
          IconButton(
            key: const Key('verifyRestart'),
            icon: const Icon(Icons.restart_alt),
            onPressed: () {
              _messageInputController.text = '';
              _addressInputController.text = '';
              _signatureInputController.text = '';
              setState(() {
                _verificationPerformed = false;
                _verificationResult = false;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Align(
                child: PeerContainer(
                  child: Form(
                    key: _formKey,
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
                                      .translate('verify_step_1'),
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                            TextFormField(
                              textInputAction: TextInputAction.done,
                              key: const Key('verifyAddressInput'),
                              controller: _addressInputController,
                              autocorrect: false,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return AppLocalizations.instance.translate(
                                    'send_enter_address',
                                  );
                                }
                                var sanitized = value.trim();
                                if (validateAddress(
                                      sanitized,
                                      _activeCoin.networkType,
                                    ) ==
                                    false) {
                                  return AppLocalizations.instance.translate(
                                    'send_invalid_address',
                                  );
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    var data =
                                        await Clipboard.getData('text/plain');
                                    _addressInputController.text =
                                        data!.text!.trim();
                                  },
                                  icon: Icon(
                                    Icons.paste_rounded,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                labelText: AppLocalizations.instance
                                    .translate('verify_input_label_address'),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.instance
                                  .translate('sign_step_2'),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.done,
                          key: const Key('verifyMessageInput'),
                          controller: _messageInputController,
                          autocorrect: false,
                          minLines: 5,
                          maxLines: 5,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return AppLocalizations.instance.translate(
                                'verify_enter_message',
                              );
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () async {
                                var data =
                                    await Clipboard.getData('text/plain');
                                _messageInputController.text =
                                    data!.text!.trim();
                              },
                              icon: Icon(
                                Icons.paste_rounded,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            labelText: AppLocalizations.instance
                                .translate('verify_input_label_message'),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.instance
                                  .translate('verify_step_3'),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.done,
                          key: const Key('verifSignatureInput'),
                          controller: _signatureInputController,
                          autocorrect: false,
                          minLines: 5,
                          maxLines: 5,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return AppLocalizations.instance.translate(
                                'verify_enter_signature',
                              );
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () async {
                                var data =
                                    await Clipboard.getData('text/plain');
                                _signatureInputController.text =
                                    data!.text!.trim();
                              },
                              icon: Icon(
                                Icons.paste_rounded,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            labelText: AppLocalizations.instance
                                .translate('verify_input_label_signature'),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (kIsWeb)
                          const SizedBox(
                            height: 20,
                          ),
                        if (_verificationPerformed)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              AppLocalizations.instance.translate(
                                _verificationResult == true
                                    ? 'verify_success'
                                    : 'verify_fail',
                              ),
                              style: TextStyle(
                                color: _verificationResult == true
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        PeerButton(
                          action: () => _handleVerification(),
                          text: AppLocalizations.instance.translate(
                            'verify_step_3_button',
                          ),
                          small: true,
                        ),
                      ],
                    ),
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
