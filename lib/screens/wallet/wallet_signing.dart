import 'dart:convert';

import 'package:coinslib/coinslib.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:peercoin/widgets/double_tab_to_clipboard.dart';
import 'package:provider/provider.dart';

import '../../models/available_coins.dart';
import '../../models/coin.dart';
import '../../providers/active_wallets.dart';
import '../../tools/app_localizations.dart';
import '../../widgets/buttons.dart';

class WalletSigningScreen extends StatefulWidget {
  const WalletSigningScreen({Key? key}) : super(key: key);

  @override
  State<WalletSigningScreen> createState() => _WalletSigningScreenState();
}

class _WalletSigningScreenState extends State<WalletSigningScreen> {
  late String _walletName;
  late ActiveWallets _activeWallets;
  bool _initial = true;
  late Coin _activeCoin;
  bool _signingInProgress = false;
  String _signature = '';
  String _signingAddress = '';
  final TextEditingController _messageInputController = TextEditingController();

  @override
  void didChangeDependencies() {
    if (_initial == true) {
      setState(() {
        _walletName = ModalRoute.of(context)!.settings.arguments as String;
        _activeWallets = Provider.of<ActiveWallets>(context);
        _activeCoin = AvailableCoins().getSpecificCoin(_walletName);
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  void _saveSnack(context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.instance.translate(
            'sign_snack_text',
            {'address': _signingAddress},
          ),
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _showAddressSelector() async {
    final _oldAddr = _signingAddress;
    var result = await Navigator.of(context).pushNamed(
      Routes.AddressSelector,
      arguments: [
        await _activeWallets.getWalletAddresses(_walletName),
        _signingAddress
      ],
    );
    setState(() {
      _signingAddress = result as String;
    });
    if (result != '' && result != _oldAddr) {
      _saveSnack(context);
    }
  }

  Future<void> _handleSign() async {
    LoggerWrapper.logInfo('WalletSigning', 'handleSign',
        'signing message with $_signingAddress on $_walletName, message: ${_messageInputController.text}');
    try {
      var result = Wallet.fromWIF(
              await _activeWallets.getWif(_walletName, _signingAddress),
              _activeCoin.networkType)
          .sign(_messageInputController.text);
      print(result);
      setState(() {
        _signature = result.toString();
      });
    } catch (e) {
      LoggerWrapper.logError('WalletSigning', 'handleSign', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.instance.translate('wallet_pop_menu_signing'),
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
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.instance
                                  .translate('sign_step_1'),
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            _signingAddress == ''
                                ? AppLocalizations.instance
                                    .translate('sign_step_1_description')
                                : _signingAddress,
                          ),
                        ),
                        PeerButton(
                          action: () => _showAddressSelector(),
                          text: AppLocalizations.instance.translate(
                            _signingAddress == ''
                                ? 'sign_step_1_button'
                                : 'sign_step_1_button_alt',
                          ),
                          small: true,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.instance.translate('sign_step_2'),
                            style: Theme.of(context).textTheme.headline6),
                      ],
                    ),
                    TextFormField(
                      textInputAction: TextInputAction.done,
                      key: Key('messageInput'),
                      controller: _messageInputController,
                      autocorrect: false,
                      minLines: 5,
                      maxLines: 5,
                      onChanged: (_) => setState(
                          () {}), //to activate sign button on key stroke
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () async {
                            var data = await Clipboard.getData('text/plain');
                            _messageInputController.text = data!.text!.trim();
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
                            .translate('sign_input_label'),
                      ),
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.instance.translate('sign_step_3'),
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _signature.isNotEmpty
                        ? Column(
                            children: [
                              DoubleTabToClipboard(
                                clipBoardData: _signature,
                                child: SelectableText(_signature),
                              ),
                              SizedBox(
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
                    SizedBox(
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
//TODO fire sign