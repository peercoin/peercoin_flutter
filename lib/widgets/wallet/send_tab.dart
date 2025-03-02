import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:fast_csv/fast_csv.dart' as fast_csv;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:peercoin/exceptions/exceptions.dart';
import 'package:peercoin/models/buildresult.dart';
import 'package:peercoin/tools/validators.dart';
import 'package:peercoin/widgets/wallet/send_tab_management.dart';
import 'package:peercoin/widgets/wallet/send_tab_navigator.dart';
import 'package:provider/provider.dart';

import '/../models/available_coins.dart';
import '/../models/coin.dart';
import '/../models/hive/coin_wallet.dart';
import '/../models/hive/wallet_address.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/connection_provider.dart';
import '../../screens/wallet/standard_and_watch_only_wallet_home.dart';
import '/../tools/app_localizations.dart';
import '/../tools/app_routes.dart';
import '/../tools/auth.dart';
import '/../tools/utf8_text_field.dart';
import '/../widgets/buttons.dart';
import '/../widgets/service_container.dart';
import '/../widgets/wallet/wallet_balance_header.dart';
import '../../screens/wallet/transaction_confirmation.dart';
import '../../tools/logger_wrapper.dart';
import '../../tools/price_ticker.dart';

class SendTab extends StatefulWidget {
  final Function changeTab;
  final String? address;
  final String? label;
  final BackendConnectionState connectionState;
  final CoinWallet wallet;
  const SendTab({
    required this.changeTab,
    this.address,
    this.label,
    required this.wallet,
    required this.connectionState,
    super.key,
  });

  @override
  State<SendTab> createState() => _SendTabState();
}

class _SendTabState extends State<SendTab> {
  final _formKey = GlobalKey<FormState>();
  final _addressKeyList = [GlobalKey<FormFieldState>()];
  final _amountKeyList = [GlobalKey<FormFieldState>()];
  final _labelKeyList = [GlobalKey<FormFieldState>()];
  final _opReturnKey = GlobalKey<FormFieldState>();
  final _addressControllerList = [TextEditingController()];
  final _amountControllerList = [TextEditingController()];
  final _labelControllerList = [TextEditingController()];
  final _opReturnController = TextEditingController();
  bool _initial = true;
  late Coin _availableCoin;
  late WalletProvider _walletProvider;
  late List<WalletAddress> _availableAddresses = [];
  bool _expertMode = false;
  late AppSettingsProvider _appSettings;
  late final int _decimalProduct;
  bool _fiatEnabled = false;
  bool _fiatInputEnabled = false;
  final Map<int, String> _amountInputHelperTextList = {};
  final Map<int, double> _requestedAmountInCoinsList = {};
  double _totalAmountRequestedInCoins = 0.0;
  double _coinValue = 0.0;
  int _numberOfRecipients = 1;
  int _currentAddressIndex = 0;

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
                    children: [
                      PeerServiceTitle(
                        title: AppLocalizations.instance.translate(
                          'wallet_bottom_nav_send',
                        ),
                      ),
                      _numberOfRecipients > 1
                          ? SendTabNavigator(
                              currentIndex: _currentAddressIndex + 1,
                              numberOfRecipients: _numberOfRecipients,
                              raiseNewindex: (int newIndex) => setState(
                                () {
                                  if (triggerFormValidation()) {
                                    _currentAddressIndex = newIndex - 1;
                                  }
                                },
                              ),
                            )
                          : const SizedBox(),
                      TypeAheadFormField(
                        hideOnEmpty: true,
                        key: _addressKeyList[_currentAddressIndex],
                        textFieldConfiguration: TextFieldConfiguration(
                          controller:
                              _addressControllerList[_currentAddressIndex],
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
                                _addressControllerList[_currentAddressIndex]
                                    .text = data!.text!.trim();
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
                          _addressControllerList[_currentAddressIndex].text =
                              suggestion.address;
                          _labelControllerList[_currentAddressIndex].text =
                              suggestion.addressBookName;
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return AppLocalizations.instance
                                .translate('send_enter_address');
                          }
                          if (_addressControllerList
                                  .where((element) => element.text == value)
                                  .length >
                              1) {
                            return AppLocalizations.instance
                                .translate('send_address_already_exists');
                          }
                          var sanitized = value.trim();
                          if (validateAddress(
                                sanitized,
                                _availableCoin.networkType,
                              ) ==
                              false) {
                            return AppLocalizations.instance
                                .translate('send_invalid_address');
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        textInputAction: TextInputAction.done,
                        key: _labelKeyList[_currentAddressIndex],
                        controller: _labelControllerList[_currentAddressIndex],
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
                        key: _amountKeyList[_currentAddressIndex],
                        controller: _amountControllerList[_currentAddressIndex],
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
                          helperText:
                              _amountInputHelperTextList[_currentAddressIndex],
                        ),
                        onChanged: (value) {
                          _calcAmountInputHelperText(_currentAddressIndex);
                          if (_amountKeyList[_currentAddressIndex]
                              .currentState!
                              .hasError) {
                            _amountKeyList[_currentAddressIndex]
                                .currentState!
                                .validate();
                            //position cursor correctly
                            _amountControllerList[_currentAddressIndex]
                                .selection = TextSelection.fromPosition(
                              TextPosition(
                                offset:
                                    _amountControllerList[_currentAddressIndex]
                                        .text
                                        .length,
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
                          maxLength: _availableCoin.opreturnSize,
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
                              style: Theme.of(context).textTheme.bodySmall,
                            );
                          },
                          inputFormatters: [
                            Utf8LengthLimitingTextInputFormatter(
                              _availableCoin.opreturnSize,
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
                      if (_expertMode)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            AppLocalizations.instance.translate(
                              'wallet_send_label_hint_metadata',
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      SendTabAddressManagement(
                        onAdd: () {
                          if (_addNewAddress()) {
                            setState(
                              () {
                                _numberOfRecipients++;
                              },
                            );
                          }
                        },
                        onDelete: () {
                          _removeAddress(_currentAddressIndex);
                        },
                        numberOfRecipients: _numberOfRecipients,
                      ),
                      if (_fiatEnabled && _currentAddressIndex == 0)
                        SwitchListTile(
                          value: _fiatInputEnabled,
                          onChanged: (newState) => setState(
                            () {
                              _fiatInputEnabled = newState;
                              _amountControllerList[_currentAddressIndex].text =
                                  '';
                              _amountControllerList[_currentAddressIndex]
                                  .selection = TextSelection.fromPosition(
                                TextPosition(
                                  offset: _amountControllerList[
                                          _currentAddressIndex]
                                      .text
                                      .length,
                                ),
                              );
                              _amountControllerList.asMap().forEach(
                                (index, _) {
                                  _amountControllerList[index].text = '';
                                  _calcAmountInputHelperText(index);
                                },
                              );
                            },
                          ),
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
                      _currentAddressIndex == 0
                          ? SwitchListTile(
                              value: _expertMode,
                              onChanged: (newState) => setState(() {
                                _expertMode = newState;
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
                            )
                          : const SizedBox(),
                      const SizedBox(height: 10),
                      PeerButton(
                        text: AppLocalizations.instance.translate('send'),
                        action: () async {
                          if (triggerFormValidation()) {
                            _formKey.currentState!.save();
                            FocusScope.of(context).unfocus(); //hide keyboard
                            _amountControllerList.asMap().forEach(
                              (index, _) {
                                _calcAmountInputHelperText(index);
                              },
                            );
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
                      if (_appSettings.camerasAvailble)
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
                      const SizedBox(height: 10),
                      PeerButtonBorder(
                        text: AppLocalizations.instance.translate(
                          'send_empty',
                        ),
                        action: () async {
                          setState(() {
                            _fiatInputEnabled = false;
                          });
                          _amountControllerList[_currentAddressIndex].text =
                              (widget.wallet.balance / _decimalProduct)
                                  .toString();
                          _calcAmountInputHelperText(_currentAddressIndex);
                        },
                      ),
                      const SizedBox(height: 10),
                      PeerButtonBorder(
                        text: AppLocalizations.instance.translate(
                          'send_import_csv',
                        ),
                        action: () async {
                          await importCsv();
                        },
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

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      _availableCoin = AvailableCoins.getSpecificCoin(widget.wallet.name);
      _walletProvider = Provider.of<WalletProvider>(context);
      _appSettings = context.read<AppSettingsProvider>();

      _availableAddresses =
          await _walletProvider.getWalletAddresses(widget.wallet.name);
      _decimalProduct = AvailableCoins.getDecimalProduct(
        identifier: widget.wallet.name,
      );
      _fiatEnabled = _appSettings.selectedCurrency.isNotEmpty &&
          !widget.wallet.name.contains('Testnet');
      _calcAmountInputHelperText(_currentAddressIndex);

      setState(() {
        _addressControllerList[0].text = widget.address ?? '';
        _labelControllerList[0].text = widget.label ?? '';
        _initial = false;
      });
    }

    super.didChangeDependencies();
  }

  bool triggerFormValidation() {
    return _formKey.currentState!.validate();
  }

  bool _addNewAddress({
    String address = '',
    double amount = 0.0,
    String label = '',
    bool fromImport = false,
  }) {
    if (triggerFormValidation() || fromImport == true) {
      _labelControllerList.add(TextEditingController(text: label));
      _addressControllerList.add(TextEditingController(text: address));
      _amountControllerList.add(TextEditingController(text: amount.toString()));
      _labelKeyList.add(GlobalKey<FormFieldState>());
      _addressKeyList.add(GlobalKey<FormFieldState>());
      _amountKeyList.add(GlobalKey<FormFieldState>());
      _amountInputHelperTextList[_numberOfRecipients] = '';
      _requestedAmountInCoinsList[_numberOfRecipients] = amount;
      if (fromImport == false) {
        _formKey.currentState!.save();
        setState(() {
          _currentAddressIndex = _numberOfRecipients;
        });
      }
      return true;
    }
    return false;
  }

  String? _amountValidator(String value) {
    if (value.isEmpty) {
      return AppLocalizations.instance.translate('send_enter_amount');
    }
    String sanitizedValue = _fiatInputEnabled
        ? _requestedAmountInCoinsList[_currentAddressIndex].toString()
        : value.replaceAll(',', '.');

    if (_fiatInputEnabled == false) {
      _amountControllerList[_currentAddressIndex].text = sanitizedValue;
    }
    _buildRecipientMap();

    var txValueInSatoshis = double.parse(
      (_totalAmountRequestedInCoins * _decimalProduct)
          .toStringAsFixed(_availableCoin.fractions),
    );
    LoggerWrapper.logInfo(
      'SendTab',
      'send_amount',
      'req value $txValueInSatoshis - wallet balance ${widget.wallet.balance}',
    );
    if (sanitizedValue.contains('.') &&
        sanitizedValue.split('.')[1].length > _availableCoin.fractions) {
      return AppLocalizations.instance.translate('send_amount_small');
    }
    if (txValueInSatoshis > widget.wallet.balance ||
        txValueInSatoshis == 0 && widget.wallet.balance == 0) {
      return AppLocalizations.instance.translate('send_amount_exceeds');
    }
    if (txValueInSatoshis < _availableCoin.minimumTxValue &&
        _opReturnController.text.isEmpty) {
      return AppLocalizations.instance.translate(
        'send_amount_below_minimum',
        {'amount': '${_availableCoin.minimumTxValue / _decimalProduct}'},
      );
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

  Map<String, int> _buildRecipientMap() {
    Map<String, int> recipients = {};
    double totalCoins = 0;
    _amountControllerList.asMap().forEach((key, value) {
      var coins = Decimal.parse(_requestedAmountInCoinsList[key].toString());
      var decimalProduct = Decimal.parse(_decimalProduct.toString());
      recipients[_addressControllerList[key].text.trim()] =
          int.parse((coins * decimalProduct).toString());
      totalCoins += coins.toDouble();
    });

    setState(() {
      _totalAmountRequestedInCoins = totalCoins;
    });
    return recipients;
  }

  Future<BuildResult?> _buildTx() async {
    try {
      return await _walletProvider.buildTransaction(
        identifier: widget.wallet.name,
        recipients: _buildRecipientMap(),
        fee: 0,
        opReturn: _opReturnKey.currentState?.value ?? '',
      );
    } catch (e) {
      LoggerWrapper.logError(
        'SendTab',
        'buildTx',
        'error building tx: ${e.toString()}',
      );
      if (e.runtimeType == CantPayForFeesException) {
        final exception = e as CantPayForFeesException;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.instance.translate(
                'send_errors_cant_pay_fees',
                {
                  'feesMissing':
                      (exception.feesMissing / _decimalProduct).toString(),
                  'letter_code': widget.wallet.letterCode,
                },
              ),
            ),
            duration: const Duration(seconds: 7),
          ),
        );
      }
    }
    return null;
  }

  void _calcAmountInputHelperText(int index) {
    final inputAmount = _amountControllerList[index].text == ''
        ? 1.0
        : double.tryParse(
              _amountControllerList[index].text.replaceAll(',', '.'),
            ) ??
            0;

    if (_fiatEnabled == false) {
      setState(() {
        _requestedAmountInCoinsList[index] = inputAmount;
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
      _amountInputHelperTextList[index] = result;
      _requestedAmountInCoinsList[index] = double.parse(priceInCoins);
      _coinValue = fiatPrice;
    });
  }

  Future<Iterable> _getSuggestions(String pattern) async {
    return _availableAddresses.where((element) {
      if (element.isOurs == false && element.address.contains(pattern)) {
        return true;
      } else if (element.isOurs == false &&
          element.addressBookName.contains(pattern)) {
        return true;
      }
      return false;
    });
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

  void _parseQrResult(String code) {
    var parsed = Uri.parse(code);
    parsed.queryParameters.forEach((key, value) {
      if (key == 'amount') {
        _amountControllerList[_currentAddressIndex].text = value;
      } else if (key == 'label') {
        _labelControllerList[_currentAddressIndex].text = value;
      }
    });

    _addressControllerList[_currentAddressIndex].text = parsed.path;
    triggerFormValidation();
  }

  _removeAddress(int index) {
    _labelControllerList.removeAt(index);
    _addressControllerList.removeAt(index);
    _amountControllerList.removeAt(index);
    _labelKeyList.removeAt(index);
    _addressKeyList.removeAt(index);
    _amountKeyList.removeAt(index);
    _amountInputHelperTextList.remove(index);
    _requestedAmountInCoinsList.remove(index);

    setState(() {
      _numberOfRecipients--;
      if (_currentAddressIndex - 1 > 0) {
        _currentAddressIndex--;
      } else {
        _currentAddressIndex = 0;
      }
    });
  }

  void _showTransactionConfirmation(context) async {
    var buildResult = await _buildTx();
    if (buildResult != null) {
      await Navigator.of(context).pushNamed(
        Routes.transactionConfirmation,
        arguments: TransactionConfirmationArguments(
          buildResult: buildResult,
          decimalProduct: _decimalProduct,
          coinLetterCode: widget.wallet.letterCode,
          coinIdentifier: widget.wallet.name,
          callBackAfterSend: () => widget.changeTab(WalletTab.transactions),
          fiatPricePerCoin: _coinValue,
          fiatCode: _appSettings.selectedCurrency,
        ),
      );

      //persist labels
      _labelControllerList.asMap().forEach(
        (index, controller) {
          if (controller.text != '') {
            _walletProvider.updateOrCreateAddressLabel(
              identifier: widget.wallet.name,
              address: _addressControllerList[index].text,
              label: controller.text,
            );
          }
        },
      );
    }
  }

  Future<void> importCsv() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    String csv;
    if (result != null) {
      if (kIsWeb) {
        csv = String.fromCharCodes(
          result.files.single.bytes!,
        );
      } else {
        csv = await File(result.files.single.path!).readAsString();
      }
      final parsed = fast_csv.parse(csv);
      var i = 0;
      for (final row in parsed) {
        final address = row[0];
        final amount = double.parse(
          row[1].replaceAll(',', '.'),
        );
        if (i == 0) {
          _addressControllerList[0].text = address;
          _amountControllerList[0].text = amount.toString();
          _requestedAmountInCoinsList[0] = amount;
        } else {
          _addNewAddress(
            address: address,
            amount: amount,
            label: '',
            fromImport: true,
          );
          setState(() {
            _numberOfRecipients++;
          });
        }
        i++;
      }
    }
  }
}
