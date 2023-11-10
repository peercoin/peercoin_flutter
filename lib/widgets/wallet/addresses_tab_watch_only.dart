import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:peercoin/widgets/service_container.dart';
import 'package:peercoin/widgets/wallet/wallet_home_qr.dart';
import 'package:provider/provider.dart';

import '../../models/available_coins.dart';
import '../../models/coin.dart';
import '../../models/hive/wallet_address.dart';
import '../../providers/wallet_provider.dart';
import '../../tools/app_localizations.dart';
import '../../tools/validators.dart';
import '../double_tab_to_clipboard.dart';
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
  late Coin _availableCoin;

  @override
  void didChangeDependencies() {
    if (_initial == true) {
      _availableCoin = AvailableCoins.getSpecificCoin(widget.walletName);

      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  void _updateFilteredList() {
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

  void _applyFilter() {}
  void _addressEditDialog(BuildContext ctx, dynamic _) {}
  String _renderLabel(dynamic _) {
    return '';
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
                        address: addressController.text,
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
    _updateFilteredList();

    return Scaffold(
      body: SingleChildScrollView(
        child: Align(
          child: PeerContainer(
            noSpacers: true,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.background,
                      backgroundColor: Theme.of(context).colorScheme.background,
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
                for (var addr in _filteredWatchOnlyReceivingAddresses)
                  Align(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width > 1200
                          ? MediaQuery.of(context).size.width / 3
                          : MediaQuery.of(context).size.width,
                      child: DoubleTabToClipboard(
                        clipBoardData: addr.address,
                        child: Card(
                          elevation: 0,
                          child: ClipRect(
                            child: Slidable(
                              key: Key(addr.address),
                              actionPane: const SlidableScrollActionPane(),
                              secondaryActions: <Widget>[
                                IconSlideAction(
                                  caption: AppLocalizations.instance
                                      .translate('addressbook_swipe_edit'),
                                  color: Theme.of(context).primaryColor,
                                  icon: Icons.edit,
                                  onTap: () =>
                                      _addressEditDialog(context, addr),
                                ),
                                IconSlideAction(
                                  caption: AppLocalizations.instance
                                      .translate('addressbook_swipe_share'),
                                  color:
                                      Theme.of(context).colorScheme.background,
                                  iconWidget: Icon(
                                    Icons.share,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  onTap: () => WalletHomeQr.showQrDialog(
                                    context,
                                    addr.address,
                                  ),
                                ),
                                IconSlideAction(
                                  caption: AppLocalizations.instance
                                      .translate('addressbook_swipe_delete'),
                                  color: Theme.of(context).colorScheme.error,
                                  iconWidget: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  onTap: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text(
                                          AppLocalizations.instance.translate(
                                            'addressbook_dialog_remove_title',
                                          ),
                                        ),
                                        content: Text(addr.address),
                                        actions: <Widget>[
                                          TextButton.icon(
                                            label: Text(
                                              AppLocalizations.instance
                                                  .translate(
                                                'server_settings_alert_cancel',
                                              ),
                                            ),
                                            icon: const Icon(Icons.cancel),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton.icon(
                                            label: Text(
                                              AppLocalizations.instance
                                                  .translate(
                                                'jail_dialog_button',
                                              ),
                                            ),
                                            icon: const Icon(Icons.check),
                                            onPressed: () {
                                              context
                                                  .read<WalletProvider>()
                                                  .removeAddress(
                                                    widget.walletName,
                                                    addr,
                                                  );
                                              _applyFilter();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    AppLocalizations.instance
                                                        .translate(
                                                      'addressbook_dialog_remove_snack',
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  duration: const Duration(
                                                    seconds: 5,
                                                  ),
                                                ),
                                              );
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                              actionExtentRatio: 0.25,
                              child: ListTile(
                                leading: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.swipe_left),
                                  ],
                                ),
                                subtitle: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Center(
                                    child: Text(addr.address),
                                  ),
                                ),
                                title: Center(
                                  child: Text(
                                    _renderLabel(addr),
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
