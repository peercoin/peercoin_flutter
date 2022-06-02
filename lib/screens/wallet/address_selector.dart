import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:peercoin/models/wallet_address.dart';
import 'package:peercoin/tools/app_localizations.dart';

class AddressSelectorScreen extends StatefulWidget {
  const AddressSelectorScreen({Key? key}) : super(key: key);

  @override
  State<AddressSelectorScreen> createState() => _AddressSelectorScreenState();
}

class _AddressSelectorScreenState extends State<AddressSelectorScreen> {
  bool _initial = true;
  late List<WalletAddress> _addresses;
  List<WalletAddress> _filteredAddresses = [];
  String _selectedAddress = '';

  @override
  void didChangeDependencies() {
    if (_initial) {
      final args = ModalRoute.of(context)!.settings.arguments as List;
      _addresses = args[0] as List<WalletAddress>;
      _selectedAddress = args[1] as String;

      applyFilter();
      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  void applyFilter([String? searchedKey]) {
    var _filteredList;
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
        _filteredList = _addresses.where((element) {
          return element.address.contains(searchedKey) ||
              element.addressBookName != null &&
                  element.addressBookName!.contains(searchedKey);
        }).toList();
      } else {
        _filteredList = _addresses;
      }
      setState(() {
        _filteredAddresses = _filteredList;
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
              ),
            ),
            subtitle: Text(
              address.addressBookName ?? '',
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
      SizedBox(
        height: 20,
      ),
      Form(
        key: Key('selectorSearchBar'),
        child: Container(
          padding: const EdgeInsets.only(left: 16),
          child: TextFormField(
            autofocus: true,
            key: Key('selectorSearchKey'),
            textInputAction: TextInputAction.done,
            autocorrect: false,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText:
                  AppLocalizations.instance.translate('addressbook_search'),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (searchKey) => applyFilter(searchKey),
          ),
        ),
      ),
      SizedBox(
        height: 10,
      ),
      ...inkwells,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pop(context, _selectedAddress);
          },
        ),
        title: Text(
          AppLocalizations.instance.translate('address_selector_title'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: generateAddressInkwells()),
      ),
    );
  }
}
