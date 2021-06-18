import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/screens/wallet_home.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/models/availablecoins.dart';
import 'package:peercoin/models/coin.dart';
import 'package:peercoin/models/coinwallet.dart';
import 'package:peercoin/widgets/wallet_home_connection.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ReceiveTab extends StatefulWidget {
  final _unusedAddress;
  final _connectionState;
  ReceiveTab(this._unusedAddress,this._connectionState);

  @override
  _ReceiveTabState createState() => _ReceiveTabState();
}

class _ReceiveTabState extends State<ReceiveTab> {
  bool _initial = true;
  final amountController = TextEditingController();
  final labelController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _amountKey = GlobalKey<FormFieldState>();
  final _labelKey = GlobalKey<FormFieldState>();
  CoinWallet _wallet;
  Coin _availableCoin;
  String _qrString;

  @override
  void didChangeDependencies() {
    if (_initial == true) {
      _wallet = ModalRoute.of(context).settings.arguments as CoinWallet;
      _availableCoin = AvailableCoins().getSpecificCoin(_wallet.name);
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
    var _builtString = '';

    if (convertedValue == 0) {
      _builtString = '${_availableCoin.uriCode}:${widget._unusedAddress}';
      if (label != '') {
        _builtString =
            '${_availableCoin.uriCode}:${widget._unusedAddress}?label=$label';
      }
    } else {
      _builtString =
          '${_availableCoin.uriCode}:${widget._unusedAddress}?amount=$convertedValue';
      if (label != '') {
        _builtString =
            '${_availableCoin.uriCode}:${widget._unusedAddress}?amount=$convertedValue&label=$label';
      }
    }
    setState(() {
      _qrString = _builtString;
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

  void _launchURL(_url) async {
    await canLaunch(_url)
        ? await launch(
      _url,
    )
        : throw 'Could not launch $_url';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [

            SizedBox(height: 20,),
            WalletHomeConnection(widget._connectionState),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      (_wallet.balance / 1000000).toString(),
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.grey[100],
                        letterSpacing: 1.2,
                      ),
                    ),
                    _wallet.unconfirmedBalance > 0
                        ? Text(
                      (_wallet.unconfirmedBalance / 1000000)
                          .toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[100],
                      ),
                    )
                        : Container(),
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  _wallet.letterCode,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey[100],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        ListView(
          children: [
            SizedBox(height: 150,),
            PeerContainer(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    PeerServiceTitle(title: AppLocalizations.instance.translate('wallet_bottom_nav_receive')),
                    /*InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(children: [
                              Center(
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.33,
                                  width: MediaQuery.of(context).size.width * 1,
                                  child: Center(
                                    child: QrImage(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      data: _qrString,
                                    ),
                                  ),
                                ),
                              )
                            ]);
                          },
                        );
                      },
                      child: QrImage(
                        data: _qrString,
                        size: MediaQuery.of(context).size.width * 0.2,
                        padding: EdgeInsets.all(1),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                    ),*/
                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                          color: const Color(0x55717C89),
                          borderRadius: BorderRadius.all(Radius.circular(4))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FittedBox(
                          child: SelectableText(
                            widget._unusedAddress,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      textInputAction: TextInputAction.done,
                      key: _labelKey,
                      controller: labelController,
                      autocorrect: false,
                      onChanged: (String newString) {
                        stringBuilder();
                      },
                      decoration: InputDecoration(
                        icon: Icon(Icons.bookmark),
                        labelText: AppLocalizations.instance.translate('send_label'),
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
                              getValidator(_availableCoin.fractions)),
                        ],
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          icon: Icon(Icons.money),
                          labelText: AppLocalizations.instance
                              .translate('receive_requested_amount'),
                          suffix: Text(_wallet.letterCode),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return AppLocalizations.instance
                                .translate('receive_enter_amount');
                          }
                          return null;
                        }),
                    SizedBox(height: 30),
                    PeerButtonBorder(text: 'Show QR-Code',
                      action: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(children: [
                              Center(
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.33,
                                  width: MediaQuery.of(context).size.width * 1,
                                  child: Center(
                                    child: QrImage(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      data: _qrString,
                                    ),
                                  ),
                                ),
                              )
                            ]);
                          },
                        );
                      },
                    ),
                    SizedBox(height: 8),
                    PeerButton(
                      text: AppLocalizations.instance.translate('receive_share'),
                      action: () async {
                        if (labelController.text != '') {
                          context.read<ActiveWallets>().updateLabel(_wallet.name,
                              widget._unusedAddress, labelController.text);
                        }
                        await Share.share(_qrString ?? widget._unusedAddress);
                      },
                    ),
                    SizedBox(height: 10),
                    Text(
                        AppLocalizations.instance
                            .translate('wallet_receive_label_hint'),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).accentColor,
                        )),
                  ],
                ),
              ),
            ),
            _wallet.title.contains('Testnet') ? PeerContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  PeerServiceTitle(title: 'Obtain Peercoin'),
                  SizedBox(height: 20),
                  Text(
                    AppLocalizations.instance
                        .translate('buy_peercoin_dialog_title'),
                    textAlign: TextAlign.center,
                  ),
                  Text(AppLocalizations.instance
                      .translate('buy_peercoin_dialog_content'),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  PeerButton(
                    text: 'Open faucet',
                    action: () { _launchURL('https://peercoinexplorer.net/faucet/'); },
                  ),
                ],
              ),
            ) : PeerContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  PeerServiceTitle(title: AppLocalizations.instance.translate('buy_peercoin')),
                  SizedBox(height: 20),
                  Text(
                    AppLocalizations.instance
                        .translate('buy_peercoin_dialog_title'),
                    textAlign: TextAlign.center,
                  ),
                  Text(AppLocalizations.instance
                      .translate('buy_peercoin_dialog_content'),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  PeerButton(
                    text: 'Open website',
                    action: () { _launchURL('https://ppc.lol/buy'); },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
