import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';
import 'package:flutter/material.dart';
import 'package:peercoin/widgets/service_container.dart';

import '../../models/hive/wallet_address.dart';
import '../../tools/app_localizations.dart';
import 'addresses_tab.dart';

class AddressesTabWatchOnly extends AddressTab {
  const AddressesTabWatchOnly({
    super.key,
    required super.walletName,
    required super.walletAddresses,
    required super.changeTab,
  });

  @override
  State<AddressesTabWatchOnly> createState() => _AddressesTabWatchOnlyState();
}

class _AddressesTabWatchOnlyState extends State<AddressesTabWatchOnly> {
  bool _initial = true;
  String _searchString = '';
  List<WalletAddress> _filteredWatchOnlyReceivingAddresses = [];

  @override
  void didChangeDependencies() {
    if (_initial == true) {
      updateFilteredList();
      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  void updateFilteredList() {
    setState(() {
      _filteredWatchOnlyReceivingAddresses = widget.walletAddresses
          .where(
            (element) =>
                element.address.contains(_searchString) ||
                element.addressBookName.contains(_searchString),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithSearchSwitch(
        closeOnSubmit: true,
        clearOnClose: true,
        fieldHintText: AppLocalizations.instance.translate('search_address'),
        onChanged: (text) {
          setState(() {
            _searchString = text;
          });
          updateFilteredList();
        },
        onCleared: () => setState(() {
          _searchString = '';
        }),
        appBarBuilder: (context) {
          if (widget.walletAddresses.isEmpty) {
            return AppBar(
              leading: const SizedBox(),
            );
          }
          return AppBar(
            leading: const SizedBox(),
            centerTitle: true,
            title: Text(
              AppLocalizations.instance.translate('search_address'),
            ),
            actions: const [
              AppBarSearchButton(),
            ],
          );
        },
      ),
      body: SingleChildScrollView(
        child: Align(
          child: PeerContainer(
            noSpacers: true,
            child: Column(
              children: [
                for (var address in _filteredWatchOnlyReceivingAddresses)
                  ListTile(
                    title: Text(address.addressBookName),
                    subtitle: Text(address.address),
                    onTap: () {},
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
