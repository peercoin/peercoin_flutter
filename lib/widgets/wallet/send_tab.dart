import 'dart:async';
import 'dart:developer';

import 'package:coinslib/coinslib.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:peercoin/models/walletaddress.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/screens/wallet/wallet_home.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/models/availablecoins.dart';
import 'package:peercoin/models/coin.dart';
import 'package:peercoin/models/coinwallet.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/providers/electrumconnection.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/tools/auth.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/service_container.dart';
import 'package:peercoin/widgets/wallet/wallet_balance_header.dart';
import 'package:provider/provider.dart';

class SendTab extends StatefulWidget {
  final Function _changeIndex;
  final String? _address;
  final String? _label;
  final _connectionState;
  SendTab(this._changeIndex, this._address, this._label, this._connectionState);

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
  late CoinWallet _wallet;
  late Coin _availableCoin;
  late ActiveWallets _activeWallets;
  int _txFee = 0;
  int _totalValue = 0;
  WalletAddress? _transferedAddress;
  late List<WalletAddress> _availableAddresses = [];

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      _wallet = ModalRoute.of(context)!.settings.arguments as CoinWallet;
      _availableCoin = AvailableCoins().getSpecificCoin(_wallet.name);
      _activeWallets = Provider.of<ActiveWallets>(context);
      _availableAddresses =
          await _activeWallets.getWalletAddresses(_wallet.name);
      setState(() {
        addressController.text = widget._address ?? '';
        labelController.text = widget._label ?? '';
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  Future<Map> buildTx(bool dryrun, [int fee = 0]) async {
    return await _activeWallets.buildTransaction(
      _wallet.name,
      _addressKey.currentState!.value.trim(),
      _amountKey.currentState!.value,
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

    int? _destroyedChange = _buildResult['destroyedChange'];
    _txFee = _buildResult['fee'];
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          String? _displayValue = _amountKey.currentState!.value;
          _totalValue =
              (double.parse(_amountKey.currentState!.value) * 1000000).toInt();
          if (_totalValue == _wallet.balance) {
            var newValue = double.parse(_amountKey.currentState!.value) -
                (_txFee / 1000000);
            _displayValue = newValue.toStringAsFixed(_availableCoin.fractions);
          } else {
            _totalValue = _totalValue + _txFee;
          }
          if (_destroyedChange! > 0) {
            var newValue = (double.parse(_amountKey.currentState!.value) -
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
                              text: _addressKey.currentState!.value,
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
                    PeerButton(
                      text: AppLocalizations.instance
                          .translate('send_confirm_send'),
                      action: () async {
                        if (_firstPress == false) return; //prevent double tap
                        try {
                          _firstPress = false;
                          var _buildResult = await buildTx(false, _txFee);
                          //write tx to history
                          await _activeWallets.putOutgoingTx(
                              _wallet.name, _addressKey.currentState!.value, {
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
                          if (_labelKey.currentState!.value != '') {
                            _activeWallets.updateLabel(
                              _wallet.name,
                              _addressKey.currentState!.value,
                              _labelKey.currentState!.value,
                            );
                          }
                          //pop message
                          Navigator.of(context).pop();
                          //navigate back to tx list
                          widget._changeIndex(Tabs.transactions);
                        } catch (e) {
                          log('error $e');
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
          element.addressBookName!.contains(pattern)) {
        return true;
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _transferedAddress = _activeWallets.transferedAddress;
    if (_transferedAddress != null &&
        _transferedAddress!.address != addressController.text) {
      addressController.text = _transferedAddress!.address;
      labelController.text = _transferedAddress!.addressBookName ?? '';
      _activeWallets.transferedAddress = null; //reset transfer
    }

    return Stack(
      children: [
        WalletBalanceHeader(widget._connectionState, _wallet),
        ListView(
          children: [
            SizedBox(
              height: _wallet.unconfirmedBalance > 0 ? 125 : 110,
            ),
            Container(
              height: 30,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Theme.of(context).bottomAppBarColor,
                  Theme.of(context).primaryColor,
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              ),
            ),
            PeerContainer(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    PeerServiceTitle(
                        title: AppLocalizations.instance
                            .translate('wallet_bottom_nav_send')),
                    TypeAheadFormField(
                      hideOnEmpty: true,
                      key: _addressKey,
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: addressController,
                        autocorrect: false,
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.shuffle,
                            color: Theme.of(context).primaryColor,
                          ),
                          labelText:
                              AppLocalizations.instance.translate('tx_address'),
                          suffixIcon: IconButton(
                            onPressed: () async {
                              var data = await Clipboard.getData('text/plain');
                              addressController.text = data!.text!;
                            },
                            icon: Icon(
                              Icons.paste_rounded,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                      suggestionsCallback: (pattern) {
                        return getSuggestions(pattern);
                      },
                      itemBuilder: (context, dynamic suggestion) {
                        return ListTile(
                          title: Text(suggestion.addressBookName ?? ''),
                          subtitle: Text(suggestion.address),
                        );
                      },
                      transitionBuilder: (context, suggestionsBox, controller) {
                        return suggestionsBox;
                      },
                      onSuggestionSelected: (dynamic suggestion) {
                        addressController.text = suggestion.address;
                        labelController.text = suggestion.addressBookName;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
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
                        autocorrect: false,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              getValidator(_availableCoin.fractions)),
                        ],
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.money,
                            color: Theme.of(context).primaryColor,
                          ),
                          labelText: AppLocalizations.instance
                              .translate('send_amount'),
                          suffix: Text(_wallet.letterCode),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return AppLocalizations.instance
                                .translate('send_enter_amount');
                          }
                          final convertedValue = value.replaceAll(',', '.');
                          amountController.text = convertedValue;
                          var txValueInSatoshis =
                              (double.parse(convertedValue) * 1000000).toInt();
                          log('req value $txValueInSatoshis - ${_wallet.balance}');
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
                          if (txValueInSatoshis <
                              _availableCoin.minimumTxValue) {
                            return AppLocalizations.instance.translate(
                                'send_amount_below_minimum', {
                              'amount':
                                  '${_availableCoin.minimumTxValue / 1000000}'
                            });
                          }
                          if (txValueInSatoshis == _wallet.balance &&
                              _wallet.balance ==
                                  _availableCoin.minimumTxValue) {
                            return AppLocalizations.instance.translate(
                              'send_amount_below_minimum_unable',
                            );
                          }

                          return null;
                        }),
                    SizedBox(height: 30),
                    PeerButtonBorder(
                      text: AppLocalizations.instance.translate(
                        'send_qr',
                      ),
                      action: () async {
                        final result = await Navigator.of(context).pushNamed(
                            Routes.QRScan,
                            arguments:
                                AppLocalizations.instance.translate('scan_qr'));
                        if (result != null) parseQrResult(result as String);
                      },
                    ),
                    SizedBox(height: 8),
                    PeerButton(
                      text: AppLocalizations.instance.translate('send'),
                      action: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          FocusScope.of(context).unfocus(); //hide keyboard
                          //check for required auth
                          var _appSettings =
                              Provider.of<AppSettings>(context, listen: false);
                          if (_appSettings
                              .authenticationOptions!['sendTransaction']!) {
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
                    ),
                    SizedBox(height: 10),
                    Text(
                        AppLocalizations.instance.translate(
                          'wallet__send_label_hint',
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        )),
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
