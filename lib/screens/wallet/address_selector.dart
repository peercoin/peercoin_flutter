import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../models/hive/wallet_address.dart';
import '../../tools/app_localizations.dart';

class AddressSelectorScreen extends StatefulWidget {
  const AddressSelectorScreen({Key? key}) : super(key: key);

  @override
  State<AddressSelectorScreen> createState() => _AddressSelectorScreenState();
}

class _AddressSelectorScreenState extends State<AddressSelectorScreen> {
  bool _initial = true;
  bool _searchActive = false;
  late List<WalletAddress> _addresses;
  List<WalletAddress> _filteredAddresses = [];
  String _selectedAddress = '';

  @override
  void didChangeDependencies() {
    if (_initial) {
      final args = ModalRoute.of(context)!.settings.arguments as Map;
      _addresses = args['addresses'] as List<WalletAddress>;
      _selectedAddress = args['selectedAddress'] as String;

      applyFilter();
      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  void applyFilter([String? searchedKey]) {
    List<WalletAddress> filteredList;
    if (_initial) {
      setState(
        () {
          _addresses =
              _addresses.where((element) => element.isOurs == true).toList();
          _filteredAddresses = _addresses;
        },
      );
    } else {
      //filter search keys
      if (searchedKey != null && searchedKey.isNotEmpty) {
        filteredList = _addresses.where((element) {
          return element.address.contains(searchedKey) ||
              element.addressBookName.contains(searchedKey);
        }).toList();
      } else {
        filteredList = _addresses;
      }
      setState(() {
        _filteredAddresses = filteredList;
      });
    }
  }

  List<Widget> generateAddressInkwells() {
    final inkwells = _filteredAddresses.map(
      (address) {
        return InkWell(
          key: Key(address.address),
          onTap: () => setState(
            () {
              _selectedAddress = address.address;
            },
          ),
          child: ListTile(
            title: Container(
              height: 25,
              alignment: Alignment.center,
              child: AutoSizeText(
                address.address,
                maxFontSize: 14,
              ),
            ),
            subtitle: Text(
              address.addressBookName,
              textAlign: TextAlign.center,
            ),
            leading: Radio(
              value: address.address,
              groupValue: _selectedAddress,
              onChanged: (_) => setState(
                () {
                  _selectedAddress = address.address;
                },
              ),
            ),
          ),
        );
      },
    ).toList();

    return [
      const SizedBox(
        height: 10,
      ),
      ...inkwells,
    ];
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context, _selectedAddress);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back',
            onPressed: () {
              Navigator.pop(context, _selectedAddress);
            },
          ),
          title: _searchActive == false
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.instance
                          .translate('address_selector_title'),
                    ),
                    IconButton(
                      onPressed: () => setState(() {
                        _searchActive = true;
                      }),
                      icon: const Icon(Icons.search),
                    )
                  ],
                )
              : Form(
                  key: const Key('selectorSearchBar'),
                  child: TextFormField(
                    autofocus: true,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.background,
                    ),
                    key: const Key('selectorSearchKey'),
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.instance
                          .translate('addressbook_search'),
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.background,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() {
                          _searchActive = false;
                        }),
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(context).colorScheme.background,
                        ),
                      ),
                    ),
                    onChanged: (searchKey) => applyFilter(searchKey),
                  ),
                ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: generateAddressInkwells(),
            ),
          ),
        ),
      ),
    );
  }
}
