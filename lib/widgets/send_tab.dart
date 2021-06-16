import 'dart:async';

import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:peercoin/models/walletaddress.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/screens/wallet_home.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/models/availablecoins.dart';
import 'package:peercoin/models/coin.dart';
import 'package:peercoin/models/coinwallet.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/providers/electrumconnection.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/tools/auth.dart';
import 'package:provider/provider.dart';

class SendTab extends StatefulWidget {
  final Function changeIndex;
  SendTab(this.changeIndex);

  @override
  _SendTabState createState() => _SendTabState();
}

class _SendTabState extends State<SendTab> {
  final _formKey = GlobalKey<FormState>();
  final _addressKey = GlobalKey<FormFieldState>();
  final _amountKey = GlobalKey<FormFieldState>();
  final _labelKey = GlobalKey<FormFieldState>();
  final addressController = TextEditingController();
  final amountController = TextEditingController();
  final labelController = TextEditingController();
  bool _initial = true;
  CoinWallet _wallet;
  Coin _availableCoin;
  ActiveWallets _activeWallets;
  int _txFee = 0;
  int _totalValue = 0;
  WalletAddress _transferedAddress;
  List<WalletAddress> _availableAddresses = [];

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      _wallet = ModalRoute.of(context).settings.arguments as CoinWallet;
      _availableCoin = AvailableCoins().getSpecificCoin(_wallet.name);
      _activeWallets = Provider.of<ActiveWallets>(context);
      _availableAddresses =
          await _activeWallets.getWalletAddresses(_wallet.name);
      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  Future<Map> buildTx(bool dryrun, [int fee = 0]) async {
    return await _activeWallets.buildTransaction(
      _wallet.name,
      _addressKey.currentState.value.trim(),
      _amountKey.currentState.value,
      fee,
      dryrun,
    );
  }

  void parseQrResult(String code) {
    var parsed = Uri.parse(code);
    parsed.queryParameters.forEach((key, value) {
      if (key == 'amount') {
        amountController.text = value;
      } else if (key == 'label') {
        labelController.text = value;
      }
    });
    addressController.text = parsed.path;
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

  void showTransactionConfirmation(context) async {
    Map _buildResult;
    var _firstPress = true;
    _buildResult = await buildTx(true);

    int _destroyedChange = _buildResult['destroyedChange'];
    _txFee = _buildResult['fee'];
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          String _displayValue = _amountKey.currentState.value;
          _totalValue =
              (double.parse(_amountKey.currentState.value) * 1000000).toInt();
          if (_totalValue == _wallet.balance) {
            var newValue = double.parse(_amountKey.currentState.value) -
                (_txFee / 1000000);
            _displayValue = newValue.toStringAsFixed(_availableCoin.fractions);
          } else {
            _totalValue = _totalValue + _txFee;
          }
          if (_destroyedChange > 0) {
            var newValue = (double.parse(_amountKey.currentState.value) -
                (_txFee / 1000000));
            _displayValue = newValue.toString();
            _totalValue = _totalValue - _txFee + _destroyedChange;
          }
          return SimpleDialog(
            title: Text(AppLocalizations.instance
                .translate('send_confirm_transaction')),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: AppLocalizations.instance
                            .translate('send_transferring'),
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          TextSpan(
                              text: '$_displayValue ${_wallet.letterCode}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: AppLocalizations.instance
                                  .translate('send_to')),
                          TextSpan(
                              text: _addressKey.currentState.value,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(AppLocalizations.instance.translate('send_fee', {
                      'amount': '${_txFee / 1000000}',
                      'letter_code': '${_wallet.letterCode}'
                    })),
                    if (_destroyedChange > 0)
                      Text(
                        AppLocalizations.instance.translate('send_dust', {
                          'amount': '${_destroyedChange / 1000000}',
                          'letter_code': '${_wallet.letterCode}'
                        }),
                        style: TextStyle(color: Theme.of(context).errorColor),
                      ),
                    Text(
                        AppLocalizations.instance.translate('send_total', {
                          'amount': '${_totalValue / 1000000}',
                          'letter_code': '${_wallet.letterCode}'
                        }),
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).accentColor,
                      ),
                      label: Text(AppLocalizations.instance
                          .translate('send_confirm_send')),
                      icon: Icon(Icons.send),
                      onPressed: () async {
                        if (_firstPress == false) return; //prevent double tap
                        try {
                          _firstPress = false;
                          var _buildResult = await buildTx(false, _txFee);
                          //write tx to history
                          await _activeWallets.putOutgoingTx(
                              _wallet.name, _addressKey.currentState.value, {
                            'txid': _buildResult['id'],
                            'hex': _buildResult['hex'],
                            'outValue': _totalValue - _txFee,
                            'outFees': _txFee + _destroyedChange
                          });
                          //broadcast
                          Provider.of<ElectrumConnection>(context,
                                  listen: false)
                              .broadcastTransaction(
                                  _buildResult['hex'], _buildResult['id']);
                          //store label if exists
                          if (_labelKey.currentState.value != '') {
                            _activeWallets.updateLabel(
                              _wallet.name,
                              _addressKey.currentState.value,
                              _labelKey.currentState.value,
                            );
                          }
                          //pop message
                          Navigator.of(context).pop();
                          //navigate back to tx list
                          widget.changeIndex(1);
                        } catch (e) {
                          print('error $e');
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
                    )
                  ],
                ),
              ),
            ],
          );
        });
  }

  Future<Iterable> getSuggestions(String pattern) async {
    return _availableAddresses.where((element) {
      if (element.isOurs == false && element.address.contains(pattern)) {
        return true;
      } else if (element.isOurs == false &&
          element.addressBookName != null &&
          element.addressBookName.contains(pattern)) {
        return true;
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _transferedAddress = _activeWallets.transferedAddress;
    if (_transferedAddress != null &&
        _transferedAddress.address != addressController.text) {
      addressController.text = _transferedAddress.address;
      labelController.text = _transferedAddress.addressBookName ?? '';
      _activeWallets.transferedAddress = null; //reset transfer
    }

    return PeerContainer(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PeerServiceTitle(title: AppLocalizations.instance.translate('wallet_bottom_nav_send')),
            TypeAheadFormField(
              hideOnEmpty: true,
              key: _addressKey,
              textFieldConfiguration: TextFieldConfiguration(
                controller: addressController,
                autocorrect: false,
                decoration: InputDecoration(
                  icon: Icon(Icons.shuffle),
                  labelText: AppLocalizations.instance.translate('tx_address'),
                  suffixIcon: IconButton(
                    onPressed: () async {
                      var data = await Clipboard.getData('text/plain');
                      addressController.text = data.text;
                    },
                    icon: Icon(Icons.paste_rounded,
                        color: Theme.of(context).accentColor,),
                  ),
                ),
              ),
              suggestionsCallback: (pattern) {
                return getSuggestions(pattern);
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion.addressBookName ?? ''),
                  subtitle: Text(suggestion.address),
                );
              },
              transitionBuilder: (context, suggestionsBox, controller) {
                return suggestionsBox;
              },
              onSuggestionSelected: (suggestion) {
                addressController.text = suggestion.address;
                labelController.text = suggestion.addressBookName;
              },
              validator: (value) {
                if (value.isEmpty) {
                  return AppLocalizations.instance
                      .translate('send_enter_address');
                }
                var sanitized = value.trim();
                if (Address.validateAddress(
                        sanitized, _availableCoin.networkType) ==
                    false) {
                  return AppLocalizations.instance
                      .translate('send_invalid_address');
                }
                return null;
              },
            ),
            TextFormField(
              textInputAction: TextInputAction.done,
              key: _labelKey,
              controller: labelController,
              autocorrect: false,
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
                autocorrect: false,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      getValidator(_availableCoin.fractions)),
                ],
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  icon: Icon(Icons.money),
                  labelText: AppLocalizations.instance.translate('send_amount'),
                  suffix: Text(_wallet.letterCode),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return AppLocalizations.instance
                        .translate('send_enter_amount');
                  }
                  final convertedValue = value.replaceAll(',', '.');
                  amountController.text = convertedValue;
                  var txValueInSatoshis =
                      (double.parse(convertedValue) * 1000000).toInt();
                  print('req value $txValueInSatoshis - ${_wallet.balance}');
                  if (convertedValue.contains('.') &&
                      convertedValue.split('.')[1].length >
                          _availableCoin.fractions) {
                    return AppLocalizations.instance
                        .translate('send_amount_small');
                  }
                  if (txValueInSatoshis > _wallet.balance) {
                    return AppLocalizations.instance
                        .translate('send_amount_exceeds');
                  }
                  if (txValueInSatoshis < _availableCoin.minimumTxValue) {
                    return AppLocalizations.instance.translate(
                        'send_amount_below_minimum', {
                      'amount': '${_availableCoin.minimumTxValue / 1000000}'
                    });
                  }
                  if (txValueInSatoshis == _wallet.balance &&
                      _wallet.balance == _availableCoin.minimumTxValue) {
                    return AppLocalizations.instance.translate(
                      'send_amount_below_minimum_unable',
                    );
                  }

                  return null;
                }),
            SizedBox(height: 30),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).disabledColor,
                  onPrimary: Colors.black,
                ),
                label: Text('QR-Code'),
                icon: Icon(Icons.qr_code_scanner_rounded,),
                onPressed: () async {
                  final result = await Navigator.of(context).pushNamed(
                      Routes.QRScan,
                      arguments:
                      AppLocalizations.instance.translate('scan_qr'));
                  if (result != null) parseQrResult(result);
                },
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).accentColor,
                ),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    FocusScope.of(context).unfocus(); //hide keyboard
                    //check for required auth
                    var _appSettings =
                        Provider.of<AppSettings>(context, listen: false);
                    if (_appSettings.authenticationOptions['sendTransaction']) {
                      await Auth.requireAuth(
                          context,
                          _appSettings.biometricsAllowed,
                          () => showTransactionConfirmation(context));
                    } else {
                      showTransactionConfirmation(context);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(AppLocalizations.instance.translate(
                      'send_errors_solve',
                    ))));
                  }
                },
                icon: Icon(Icons.send),
                label: Text(AppLocalizations.instance.translate('send')),
              ),


            ]),
          ],
        ),
      ),
    );
  }
}
