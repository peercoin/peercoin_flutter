import 'dart:async';
import 'dart:convert';

import 'package:coinslib/coinslib.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';

import '../../tools/price_ticker.dart';
import '/../models/wallet_address.dart';
import '/../providers/app_settings.dart';
import '/../screens/wallet/wallet_home.dart';
import '/../tools/app_localizations.dart';
import '/../models/available_coins.dart';
import '/../models/coin.dart';
import '/../models/coin_wallet.dart';
import '/../providers/active_wallets.dart';
import '/../providers/electrum_connection.dart';
import '/../tools/app_routes.dart';
import '/../tools/auth.dart';
import '/../tools/utf8_text_field.dart';
import '/../widgets/buttons.dart';
import '/../widgets/service_container.dart';
import '/../widgets/wallet/wallet_balance_header.dart';
import '../../tools/logger_wrapper.dart';

class SendTab extends StatefulWidget {
  final Function changeIndex;
  final String? address;
  final String? label;
  final ElectrumConnectionState connectionState;
  final CoinWallet wallet;
  const SendTab({
    required this.changeIndex,
    this.address,
    this.label,
    required this.wallet,
    required this.connectionState,
    Key? key,
  }) : super(key: key);

  @override
  State<SendTab> createState() => _SendTabState();
}

class _SendTabState extends State<SendTab> {
  final _formKey = GlobalKey<FormState>();
  final _addressKey = GlobalKey<FormFieldState>();
  final _amountKey = GlobalKey<FormFieldState>();
  final _opReturnKey = GlobalKey<FormFieldState>();
  final _labelKey = GlobalKey<FormFieldState>();
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  final _labelController = TextEditingController();
  final _opReturnController = TextEditingController();
  bool _initial = true;
  late Coin _availableCoin;
  late ActiveWallets _activeWallets;
  int _txFee = 0;
  int _totalValue = 0;
  late List<WalletAddress> _availableAddresses = [];
  bool _expertMode = false;
  late AppSettings _appSettings;
  late final int _decimalProduct;
  bool _fiatEnabled = false;
  bool _fiatInputEnabled = false;
  String _amountInputHelperText = '';
  double _requestedAmountInCoins = 0.0;
  double _coinValue = 0.0;

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      _availableCoin = AvailableCoins.getSpecificCoin(widget.wallet.name);
      _activeWallets = Provider.of<ActiveWallets>(context);
      _appSettings = context.read<AppSettings>();

      _availableAddresses =
          await _activeWallets.getWalletAddresses(widget.wallet.name);
      _decimalProduct = AvailableCoins.getDecimalProduct(
        identifier: widget.wallet.name,
      );
      _fiatEnabled = _appSettings.selectedCurrency.isNotEmpty &&
          !widget.wallet.name.contains('Testnet');
      _calcAmountInputHelperText();

      setState(() {
        _addressController.text = widget.address ?? '';
        _labelController.text = widget.label ?? '';
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  Future<Map> _buildTx() async {
    return await _activeWallets.buildTransaction(
      identifier: widget.wallet.name,
      address: _addressKey.currentState!.value.trim(),
      amount: _requestedAmountInCoins,
      fee: 0,
      opReturn: _opReturnKey.currentState?.value ?? '',
    );
  }

  void _parseQrResult(String code) {
    var parsed = Uri.parse(code);
    parsed.queryParameters.forEach((key, value) {
      if (key == 'amount') {
        _amountController.text = value;
      } else if (key == 'label') {
        _labelController.text = value;
      }
    });
    _addressController.text = parsed.path;
  }

  RegExp _getValidator(int fractions) {
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

  void _showTransactionConfirmation(context) async {
    var firstPress = true;
    var buildResult = await _buildTx();

    int destroyedChange = buildResult['destroyedChange'];
    var correctedDust = 0;
    _txFee = buildResult['fee'];
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        String? displayValue = _requestedAmountInCoins.toString();
        _totalValue = (_requestedAmountInCoins * _decimalProduct).toInt();
        if (_totalValue == widget.wallet.balance) {
          var newValue = _requestedAmountInCoins - (_txFee / _decimalProduct);
          displayValue = newValue.toStringAsFixed(_availableCoin.fractions);
        } else {
          _totalValue = _totalValue + _txFee;
        }
        if (destroyedChange > 0) {
          var newValue = (_requestedAmountInCoins - (_txFee / _decimalProduct));
          displayValue = newValue.toString();

          if (_amountKey.currentState!.value == '0') {
            displayValue = '0';
            correctedDust = destroyedChange - _txFee;
          } else {
            correctedDust = destroyedChange;
          }
          _totalValue =
              (_requestedAmountInCoins * _decimalProduct + destroyedChange)
                  .toInt();
        }
        return SimpleDialog(
          title: Text(
              AppLocalizations.instance.translate('send_confirm_transaction')),
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
                          text: '$displayValue ${widget.wallet.letterCode}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: AppLocalizations.instance.translate('send_to'),
                        ),
                        TextSpan(
                          text: _addressKey.currentState!.value,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.instance.translate(
                      'send_fee',
                      {
                        'amount': '${_txFee / _decimalProduct}',
                        'letter_code': widget.wallet.letterCode
                      },
                    ),
                  ),
                  if (correctedDust > 0)
                    Text(
                      AppLocalizations.instance.translate(
                        'send_dust',
                        {
                          'amount': '${correctedDust / _decimalProduct}',
                          'letter_code': widget.wallet.letterCode
                        },
                      ),
                      style: TextStyle(color: Theme.of(context).errorColor),
                    ),
                  Text(
                    AppLocalizations.instance.translate(
                      'send_total',
                      {
                        'amount': '${_totalValue / _decimalProduct}',
                        'letter_code': widget.wallet.letterCode
                      },
                    ),
                    style: _fiatInputEnabled
                        ? const TextStyle()
                        : const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (_fiatInputEnabled)
                    Text(
                      AppLocalizations.instance.translate(
                        'send_total',
                        {
                          'amount':
                              ((_totalValue / _decimalProduct) * _coinValue)
                                  .toStringAsFixed(4),
                          'letter_code': _appSettings.selectedCurrency
                        },
                      ),
                      style: _fiatInputEnabled
                          ? const TextStyle(fontWeight: FontWeight.bold)
                          : const TextStyle(),
                    ),
                  const SizedBox(height: 20),
                  PeerButton(
                    text: AppLocalizations.instance.translate(
                      'send_confirm_send',
                    ),
                    action: () async {
                      if (firstPress == false) return; //prevent double tap
                      final electrumConnection =
                          context.read<ElectrumConnection>();
                      final navigator = Navigator.of(context);
                      try {
                        firstPress = false;
                        //write tx to history
                        await _activeWallets.putOutgoingTx(
                          widget.wallet.name,
                          _addressKey.currentState!.value,
                          {
                            'txid': buildResult['id'],
                            'hex': buildResult['hex'],
                            'outValue': _totalValue - _txFee,
                            'outFees': _txFee + destroyedChange,
                            'opReturn': buildResult['opReturn'],
                          },
                          buildResult['neededChange'],
                        );
                        //broadcast
                        electrumConnection.broadcastTransaction(
                          buildResult['hex'],
                          buildResult['id'],
                        );
                        //store label if exists
                        if (_labelKey.currentState!.value != '') {
                          _activeWallets.updateLabel(
                            widget.wallet.name,
                            _addressKey.currentState!.value,
                            _labelKey.currentState!.value,
                          );
                        }
                        //pop message
                        navigator.pop();
                        //navigate back to tx list
                        widget.changeIndex(Tabs.transactions);
                      } catch (e) {
                        LoggerWrapper.logError(
                          'SendTab',
                          'showTransactionConfirmation',
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
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Iterable> _getSuggestions(String pattern) async {
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

  String? _amountValidator(String value) {
    if (value.isEmpty) {
      return AppLocalizations.instance.translate('send_enter_amount');
    }
    String convertedValue = _fiatInputEnabled
        ? _requestedAmountInCoins.toString()
        : value.replaceAll(',', '.');

    if (_fiatInputEnabled == false) {
      _amountController.text = convertedValue;
    }

    var txValueInSatoshis =
        (double.parse(convertedValue) * _decimalProduct).toInt();
    LoggerWrapper.logInfo(
      'SendTab',
      'send_amount',
      'req value $txValueInSatoshis - ${widget.wallet.balance}',
    );
    if (convertedValue.contains('.') &&
        convertedValue.split('.')[1].length > _availableCoin.fractions) {
      return AppLocalizations.instance.translate('send_amount_small');
    }
    if (txValueInSatoshis > widget.wallet.balance ||
        txValueInSatoshis == 0 && widget.wallet.balance == 0) {
      return AppLocalizations.instance.translate('send_amount_exceeds');
    }
    if (txValueInSatoshis < _availableCoin.minimumTxValue &&
        _opReturnController.text.isEmpty) {
      return AppLocalizations.instance.translate('send_amount_below_minimum',
          {'amount': '${_availableCoin.minimumTxValue / _decimalProduct}'});
    }
    if (txValueInSatoshis == widget.wallet.balance &&
        widget.wallet.balance == _availableCoin.minimumTxValue) {
      return AppLocalizations.instance.translate(
        'send_amount_below_minimum_unable',
        {'amount': '${_availableCoin.minimumTxValue / _decimalProduct}'},
      );
    }
    return null;
  }

  void _calcAmountInputHelperText() {
    final inputAmount = _amountController.text == ''
        ? 1.0
        : double.tryParse(
              _amountController.text.replaceAll(',', '.'),
            ) ??
            0;

    if (_fiatEnabled == false) {
      setState(() {
        _requestedAmountInCoins = inputAmount;
      });
      return;
    }

    final fiatPrice = PriceTicker.renderPrice(
      1,
      _appSettings.selectedCurrency,
      widget.wallet.letterCode,
      _appSettings.exchangeRates,
    );

    String priceInCoins =
        (_fiatInputEnabled ? inputAmount * (1 / _coinValue) : inputAmount)
            .toStringAsFixed(_availableCoin.fractions);

    String result = '';
    if (_fiatInputEnabled) {
      result =
          '$inputAmount ${_appSettings.selectedCurrency} = $priceInCoins ${widget.wallet.letterCode}';
    } else {
      result =
          '$inputAmount ${widget.wallet.letterCode} = ${(inputAmount * fiatPrice).toStringAsFixed(2)} ${_appSettings.selectedCurrency}';
    }

    setState(() {
      _amountInputHelperText = result;
      _requestedAmountInCoins = double.parse(priceInCoins);
      _coinValue = fiatPrice;
    });
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
                    Theme.of(context).bottomAppBarColor,
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
                    children: [
                      PeerServiceTitle(
                        title: AppLocalizations.instance
                            .translate('wallet_bottom_nav_send'),
                      ),
                      TypeAheadFormField(
                        hideOnEmpty: true,
                        key: _addressKey,
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: _addressController,
                          autocorrect: false,
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.shuffle,
                              color: Theme.of(context).primaryColor,
                            ),
                            labelText: AppLocalizations.instance
                                .translate('tx_address'),
                            suffixIcon: IconButton(
                              onPressed: () async {
                                var data =
                                    await Clipboard.getData('text/plain');
                                _addressController.text = data!.text!.trim();
                              },
                              icon: Icon(
                                Icons.paste_rounded,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                        suggestionsCallback: (pattern) {
                          return _getSuggestions(pattern);
                        },
                        itemBuilder: (context, dynamic suggestion) {
                          return ListTile(
                            title: Text(suggestion.addressBookName ?? ''),
                            subtitle: Text(suggestion.address),
                          );
                        },
                        transitionBuilder:
                            (context, suggestionsBox, controller) {
                          return suggestionsBox;
                        },
                        onSuggestionSelected: (dynamic suggestion) {
                          _addressController.text = suggestion.address;
                          _labelController.text = suggestion.addressBookName;
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
                        controller: _labelController,
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
                        controller: _amountController,
                        autocorrect: false,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            _getValidator(_availableCoin.fractions),
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
                              .translate('send_amount'),
                          suffix: Text(
                            _fiatInputEnabled
                                ? _appSettings.selectedCurrency
                                : widget.wallet.letterCode,
                          ),
                          helperText: _amountInputHelperText,
                        ),
                        onChanged: (value) {
                          _calcAmountInputHelperText();
                          if (_amountKey.currentState!.hasError) {
                            _amountKey.currentState!.validate();
                            //position cursor correctly
                            _amountController.selection =
                                TextSelection.fromPosition(
                              TextPosition(
                                offset: _amountController.text.length,
                              ),
                            );
                          }
                        },
                        validator: (value) {
                          return _amountValidator(value!);
                        },
                      ),
                      if (_expertMode)
                        TextFormField(
                          textInputAction: TextInputAction.done,
                          key: _opReturnKey,
                          controller: _opReturnController,
                          autocorrect: false,
                          maxLength: _availableCoin.networkType.opreturnSize,
                          minLines: 1,
                          maxLines: 5,
                          buildCounter: (
                            context, {
                            required currentLength,
                            required isFocused,
                            maxLength,
                          }) {
                            var utf8Length =
                                utf8.encode(_opReturnController.text).length;
                            return Text(
                              '$utf8Length/$maxLength',
                              style: Theme.of(context).textTheme.caption,
                            );
                          },
                          inputFormatters: [
                            Utf8LengthLimitingTextInputFormatter(
                              _availableCoin.networkType.opreturnSize,
                            ),
                          ],
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () async {
                                var data =
                                    await Clipboard.getData('text/plain');
                                _opReturnController.text = data!.text!.trim();
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
                                .translate('send_op_return'),
                          ),
                        ),
                      if (_fiatEnabled)
                        SwitchListTile(
                          value: _fiatInputEnabled,
                          onChanged: (_) => setState(() {
                            _fiatInputEnabled = _;
                            _amountController.text = '';
                            _amountController.selection =
                                TextSelection.fromPosition(
                              TextPosition(
                                offset: _amountController.text.length,
                              ),
                            );
                            _calcAmountInputHelperText();
                          }),
                          title: Text(
                            AppLocalizations.instance.translate(
                              'send_fiat_switch',
                              {
                                'currency': _appSettings.selectedCurrency,
                              },
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ),
                      SwitchListTile(
                        value: _expertMode,
                        onChanged: (_) => setState(() {
                          _expertMode = _;
                          _opReturnController.text = '';
                        }),
                        title: Text(
                          AppLocalizations.instance.translate(
                            'send_add_metadata',
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      PeerButtonBorder(
                        text: AppLocalizations.instance.translate(
                          'send_empty',
                        ),
                        action: () async {
                          setState(() {
                            _fiatInputEnabled = false;
                          });
                          _amountController.text =
                              (widget.wallet.balance / _decimalProduct)
                                  .toString();
                          _calcAmountInputHelperText();
                        },
                      ),
                      const SizedBox(height: 10),
                      if (_appSettings.camerasAvailble)
                        PeerButtonBorder(
                          text: AppLocalizations.instance.translate(
                            'scan_qr',
                          ),
                          action: () async {
                            final result =
                                await Navigator.of(context).pushNamed(
                              Routes.qrScan,
                              arguments: AppLocalizations.instance
                                  .translate('scan_qr'),
                            );
                            if (result != null) {
                              _parseQrResult(result as String);
                            }
                          },
                        ),
                      const SizedBox(height: 8),
                      PeerButton(
                        text: AppLocalizations.instance.translate('send'),
                        action: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            FocusScope.of(context).unfocus(); //hide keyboard
                            //check for required auth
                            if (_appSettings
                                .authenticationOptions!['sendTransaction']!) {
                              await Auth.requireAuth(
                                context: context,
                                biometricsAllowed:
                                    _appSettings.biometricsAllowed,
                                callback: () =>
                                    _showTransactionConfirmation(context),
                              );
                            } else {
                              _showTransactionConfirmation(context);
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.instance.translate(
                                    'send_errors_solve',
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      if (!kIsWeb) const SizedBox(height: 10),
                      if (!kIsWeb)
                        Text(
                          AppLocalizations.instance.translate(
                            'wallet__send_label_hint',
                          ),
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
          ],
        ),
      ],
    );
  }
}
