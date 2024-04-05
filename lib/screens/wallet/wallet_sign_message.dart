import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/available_coins.dart';
import '../../models/coin.dart';
import '../../providers/wallet_provider.dart';
import '../../tools/app_localizations.dart';
import '../../tools/app_routes.dart';
import '../../tools/logger_wrapper.dart';
import '../../widgets/buttons.dart';
import '../../widgets/double_tab_to_clipboard.dart';
import '../../widgets/service_container.dart';

class WalletMessageSigningScreen extends StatefulWidget {
  const WalletMessageSigningScreen({super.key});

  @override
  State<WalletMessageSigningScreen> createState() =>
      _WalletMessageSigningScreenState();
}

class _WalletMessageSigningScreenState
    extends State<WalletMessageSigningScreen> {
  late String _walletName;
  late WalletProvider _walletProvider;
  bool _initial = true;
  late Coin _activeCoin;
  bool _signingDone = false;
  String _signature = '';
  String _signingAddress = '';
  final TextEditingController _messageInputController = TextEditingController();

  @override
  void didChangeDependencies() {
    if (_initial == true) {
      _walletName = ModalRoute.of(context)!.settings.arguments as String;
      _walletProvider = Provider.of<WalletProvider>(context);
      _activeCoin = AvailableCoins.getSpecificCoin(_walletName);
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

  Future<void> _handleSign() async {
    LoggerWrapper.logInfo(
      'WalletMessageSigning',
      'handleSign',
      'signing message with $_signingAddress on $_walletName, message: ${_messageInputController.text}',
    );

    try {
      var wif = await _walletProvider.getWif(
        identifier: _walletName,
        address: _signingAddress,
      );

      var result = MessageSignature.sign(
        key: WIF.fromString(wif).privkey,
        message: _messageInputController.text,
        prefix: _activeCoin.networkType.messagePrefix,
      );

      setState(() {
        _signature = result.toString();
        _signingDone = true;
      });

      LoggerWrapper.logInfo(
        'WalletMessageSigning',
        'handleSign',
        'signature produced $_signature',
      );
    } catch (e) {
      LoggerWrapper.logError(
        'WalletMessageSigning',
        'handleSign',
        e.toString(),
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
                'WalletMessageSigning',
                '_performReset',
                'reset performed',
              );
              await Navigator.of(ctx).pushNamedAndRemoveUntil(
                Routes.walletMessageSigning,
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
          AppLocalizations.instance.translate('wallet_pop_menu_signing'),
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
                                    AppLocalizations.instance
                                        .translate('sign_step_1_description'),
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
                            AppLocalizations.instance.translate('sign_step_2'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      TextFormField(
                        textInputAction: TextInputAction.done,
                        key: const Key('signMessageInput'),
                        controller: _messageInputController,
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
                              var data = await Clipboard.getData('text/plain');
                              _messageInputController.text = data!.text!.trim();
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
                              .translate('sign_input_label'),
                        ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.instance.translate('sign_step_3'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      _signature.isNotEmpty
                          ? Column(
                              children: [
                                DoubleTabToClipboard(
                                  clipBoardData: _signature,
                                  child: SelectableText(
                                    _signature,
                                    key: const Key('signature'),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  AppLocalizations.instance
                                      .translate('sign_step_3_description'),
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
                      _signature.isNotEmpty
                          ? PeerButton(
                              action: () => DoubleTabToClipboard.tapEvent(
                                context,
                                _signature,
                              ),
                              text: AppLocalizations.instance
                                  .translate('sign_step_3_button_alt'),
                              small: true,
                              active: _signingAddress.isNotEmpty &&
                                  _messageInputController.text.isNotEmpty,
                            )
                          : PeerButton(
                              action: () => _handleSign(),
                              text: AppLocalizations.instance
                                  .translate('sign_step_3_button'),
                              small: true,
                              active: _signingAddress.isNotEmpty &&
                                  _messageInputController.text.isNotEmpty,
                            ),
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
