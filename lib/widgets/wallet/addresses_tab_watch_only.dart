import 'package:flutter/material.dart';
import 'package:peercoin/widgets/service_container.dart';

import '../../models/hive/wallet_address.dart';
import 'addresses_tab.dart';

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

  @override
  void didChangeDependencies() {
    if (_initial == true) {
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
                element.address.contains(widget.searchString) ||
                element.addressBookName.contains(widget.searchString),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    updateFilteredList();

    return Scaffold(
      body: SingleChildScrollView(
        child: Align(
          child: PeerContainer(
            noSpacers: true,
            child: Column(
              children: [
                Text('Add Button'),
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
