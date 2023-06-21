import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../providers/electrum_connection.dart';
import '../../tools/share_wrapper.dart';
import '../../providers/wallet_provider.dart';
import '/../tools/app_localizations.dart';
import '/../models/available_coins.dart';
import '/../models/coin.dart';
import '/../models/coin_wallet.dart';
import '/../widgets/buttons.dart';
import '/../widgets/double_tab_to_clipboard.dart';
import '/../widgets/service_container.dart';
import '/../widgets/wallet/wallet_balance_header.dart';
import '/../widgets/wallet/wallet_home_qr.dart';

class ReceiveTab extends StatefulWidget {
  final String unusedAddress;
  final ElectrumConnectionState connectionState;
  final CoinWallet wallet;
  const ReceiveTab({
    required this.unusedAddress,
    required this.connectionState,
    required this.wallet,
    Key? key,
  }) : super(key: key);

  @override
  State<ReceiveTab> createState() => _ReceiveTabState();
}

class _ReceiveTabState extends State<ReceiveTab> {
  bool _initial = true;
  final amountController = TextEditingController();
  final labelController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _amountKey = GlobalKey<FormFieldState>();
  final _labelKey = GlobalKey<FormFieldState>();
  late Coin _availableCoin;
  String? _qrString;

  @override
  void didChangeDependencies() {
    if (_initial == true) {
      _availableCoin = AvailableCoins.getSpecificCoin(widget.wallet.name);
      stringBuilder();
      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  void stringBuilder() {
    final convertedValue = amountController.text == ''
        ? 0
        : double.parse(amountController.text.replaceAll(',', '.'));
    final label = labelController.text;
    var builtString = '';

    if (convertedValue == 0) {
      builtString = '${_availableCoin.uriCode}:${widget.unusedAddress}';
      if (label != '') {
        builtString =
            '${_availableCoin.uriCode}:${widget.unusedAddress}?label=$label';
      }
    } else {
      builtString =
          '${_availableCoin.uriCode}:${widget.unusedAddress}?amount=$convertedValue';
      if (label != '') {
        builtString =
            '${_availableCoin.uriCode}:${widget.unusedAddress}?amount=$convertedValue&label=$label';
      }
    }
    setState(() {
      _qrString = builtString;
    });
  }

  RegExp getValidator(int fractions) {
    var expression = r'^([1-9]{1}[0-9]{0,' +
        fractions.toString() +
        r'}(,[0-9]{3})*(.[0-9]{0,' +
        fractions.toString() +
        r'})?|[1-9]{1}[0-9]{0,}(.[0-9]{0,' +
        fractions.toString() +
        r'})?|0(.[0-9]{0,' +
        fractions.toString() +
        r'})?|(.[0-9]{1,' +
        fractions.toString() +
        r'})?)$';

    return RegExp(expression);
  }

  void launchURL(String url) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.instance.translate('buy_peercoin_dialog_title'),
          ),
          content: Text(
            AppLocalizations.instance.translate('buy_peercoin_dialog_content'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.instance
                    .translate('server_settings_alert_cancel'),
              ),
            ),
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                await canLaunchUrlString(url)
                    ? await launchUrlString(url)
                    : throw 'Could not launch $url';

                navigator.pop();
              },
              child: Text(
                AppLocalizations.instance.translate('continue'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WalletBalanceHeader(widget.connectionState, widget.wallet),
        ListView(
          children: [
            SizedBox(
              height: widget.wallet.unconfirmedBalance > 0 ? 125 : 110,
            ),
            Container(
              height: 30,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    BottomAppBarTheme.of(context).color!,
                    Theme.of(context).primaryColor,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Align(
              child: PeerContainer(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      PeerServiceTitle(
                        title: AppLocalizations.instance
                            .translate('wallet_bottom_nav_receive'),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(4),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FittedBox(
                            child: DoubleTabToClipboard(
                              clipBoardData: widget.unusedAddress,
                              child: SelectableText(
                                widget.unusedAddress,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        textInputAction: TextInputAction.done,
                        key: _labelKey,
                        controller: labelController,
                        autocorrect: false,
                        onChanged: (String newString) {
                          stringBuilder();
                        },
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.bookmark,
                            color: Theme.of(context).primaryColor,
                          ),
                          labelText:
                              AppLocalizations.instance.translate('send_label'),
                        ),
                        maxLength: 32,
                      ),
                      TextFormField(
                        textInputAction: TextInputAction.done,
                        key: _amountKey,
                        controller: amountController,
                        onChanged: (String newString) {
                          stringBuilder();
                        },
                        autocorrect: false,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            getValidator(_availableCoin.fractions),
                          ),
                        ],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.money,
                            color: Theme.of(context).primaryColor,
                          ),
                          labelText: AppLocalizations.instance
                              .translate('receive_requested_amount'),
                          suffix: Text(widget.wallet.letterCode),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return AppLocalizations.instance
                                .translate('receive_enter_amount');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      PeerButtonBorder(
                        text: AppLocalizations.instance
                            .translate('receive_show_qr'),
                        action: () {
                          WalletHomeQr.showQrDialog(context, _qrString!, true);
                        },
                      ),
                      const SizedBox(height: 8),
                      PeerButton(
                        text: AppLocalizations.instance
                            .translate('receive_share'),
                        action: () async {
                          if (labelController.text != '') {
                            context.read<WalletProvider>().updateLabel(
                                  widget.wallet.name,
                                  widget.unusedAddress,
                                  labelController.text,
                                );
                          }
                          await ShareWrapper.share(
                            context: context,
                            message: _qrString ?? widget.unusedAddress,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.instance
                            .translate('wallet_receive_label_hint'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.instance
                            .translate('wallet_receive_label_hint_privacy'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            widget.wallet.letterCode == 'tPPC'
                ? Align(
                    child: PeerContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          PeerServiceTitle(
                            title: AppLocalizations.instance
                                .translate('receive_obtain'),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            AppLocalizations.instance
                                .translate('receive_website_faucet'),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          PeerButton(
                            text: AppLocalizations.instance
                                .translate('receive_faucet'),
                            action: () {
                              launchURL('https://ppc.lol/faucet/');
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                : Align(
                    child: PeerContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          PeerServiceTitle(
                            title: AppLocalizations.instance
                                .translate('buy_peercoin'),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            AppLocalizations.instance
                                .translate('receive_website_description'),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          PeerButton(
                            text: AppLocalizations.instance
                                .translate('receive_website_credit'),
                            action: () {
                              launchURL('https://ppc.lol/buy');
                            },
                          ),
                          const SizedBox(height: 20),
                          PeerButton(
                            text: AppLocalizations.instance
                                .translate('receive_website_exchandes'),
                            action: () {
                              launchURL('https://ppc.lol/exchanges');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ],
    );
  }
}
