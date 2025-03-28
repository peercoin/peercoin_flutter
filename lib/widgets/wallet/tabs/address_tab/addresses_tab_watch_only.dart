import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/available_coins.dart';
import '../../../../models/coin.dart';
import '../../../../models/hive/wallet_address.dart';
import '../../../../providers/wallet_provider.dart';
import '../../../../tools/app_localizations.dart';
import '../../../../tools/validators.dart';
import 'addresses_tab.dart';
import 'addresses_tab_expandable.dart';

class AddressesTabWatchOnly extends AddressTab {
  final String searchString;

  const AddressesTabWatchOnly({
    super.key,
    required super.walletName,
    required super.walletAddresses,
    required super.changeTab,
    required this.searchString,
  });

  @override
  State<AddressesTabWatchOnly> createState() => _AddressesTabWatchOnlyState();
}

class _AddressesTabWatchOnlyState extends State<AddressesTabWatchOnly> {
  bool _initial = true;
  List<WalletAddress> _filteredWatchOnlyReceivingAddresses = [];
  late Coin _availableCoin;
  late WalletProvider _walletProvider;
  final Map _addressBalanceMap = {};
  late int _decimalProduct;

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      _availableCoin = AvailableCoins.getSpecificCoin(widget.walletName);
      _walletProvider = Provider.of<WalletProvider>(context);

      await _fillAddressBalanceMap();

      _decimalProduct = AvailableCoins.getDecimalProduct(
        identifier: widget.walletName,
      );

      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  Future<void> _fillAddressBalanceMap() async {
    final utxos = await _walletProvider.getWalletUtxos(widget.walletName);
    if (_addressBalanceMap.isNotEmpty) {
      _addressBalanceMap.clear();
    }
    for (var tx in utxos) {
      if (tx.value > 0) {
        if (_addressBalanceMap[tx.address] != null) {
          _addressBalanceMap[tx.address] += tx.value;
        } else {
          _addressBalanceMap[tx.address] = tx.value;
        }
      }
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredWatchOnlyReceivingAddresses = widget.walletAddresses
          .where(
            (element) =>
                element.address.contains(widget.searchString) ||
                element.addressBookName.contains(widget.searchString),
          )
          .toList();
    });
  }

  Future<void> _addressAddDialog(BuildContext context) async {
    var labelController = TextEditingController();
    var addressController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.instance.translate('addressbook_add_new'),
            textAlign: TextAlign.center,
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.instance.translate('send_address'),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return AppLocalizations.instance
                          .translate('send_enter_address');
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
                    //check if already exists
                    if (widget.walletAddresses
                        .any((element) => element.address == value)) {
                      return 'Address already exists';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: labelController,
                  maxLength: 32,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.instance.translate('send_label'),
                  ),
                ),
              ],
            ),
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
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  context.read<WalletProvider>().createWatchOnlyAddres(
                        identifier: widget.walletName,
                        address: addressController.text.trim(),
                        label: labelController.text == ''
                            ? ''
                            : labelController.text,
                      );
                  _applyFilter();
                  Navigator.pop(context);
                }
              },
              child: Text(
                AppLocalizations.instance.translate('jail_dialog_button'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _applyFilter();
    _fillAddressBalanceMap();

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SingleChildScrollView(
        child: Align(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.surface,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        fixedSize: Size(
                          MediaQuery.of(context).size.width > 1200
                              ? MediaQuery.of(context).size.width / 5
                              : MediaQuery.of(context).size.width / 3,
                          40,
                        ),
                        shape: RoundedRectangleBorder(
                          //to set border radius to button
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            width: 2,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        _addressAddDialog(context);
                      },
                      child: Text(
                        AppLocalizations.instance
                            .translate('addressbook_new_button'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.4,
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_filteredWatchOnlyReceivingAddresses.isEmpty)
                Column(
                  children: [
                    Image.asset(
                      'assets/img/list-empty.png',
                      height: MediaQuery.of(context).size.height / 4,
                    ),
                    Center(
                      child: Text(
                        AppLocalizations.instance.translate('addresses_none'),
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                    ),
                  ],
                ),
              for (var addr in _filteredWatchOnlyReceivingAddresses)
                AddressTabExpandable(
                  walletAddress: addr,
                  walletName: widget.walletName,
                  type: AddressTabSlideableType.watchOnly,
                  applyFilterCallback: _applyFilter,
                  balance: _addressBalanceMap.containsKey(addr.address)
                      ? _addressBalanceMap[addr.address] / _decimalProduct
                      : 0,
                  balanceUnit: _availableCoin.letterCode,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
