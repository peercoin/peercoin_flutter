import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:peercoin/models/availablecoins.dart';
import 'package:peercoin/models/coin.dart';
import 'package:peercoin/models/walletaddress.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/loading_indicator.dart';
import 'package:peercoin/widgets/wallet_home_qr.dart';
import 'package:provider/provider.dart';

class AddressBookScreen extends StatefulWidget {
  @override
  _AddressBookScreenState createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  bool _initial = true;
  late String _walletName;
  late String _walletTitle;
  List<WalletAddress>? _walletAddresses = [];
  List<WalletAddress> _filteredAddr = [];
  int _pageIndex = 0;
  late SearchBar searchBar;
  late Coin _availableCoin;

  _AddressBookScreenState() {
    searchBar = SearchBar(
      inBar: false,
      setState: setState,
      onClosed: clearFilter,
      onSubmitted: clearFilter,
      onCleared: clearFilter,
      buildDefaultAppBar: buildAppBar,
      onChanged: applyFilter,
      hintText: AppLocalizations.instance.translate('search'),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Center(
        child: FittedBox(
          child: Text(
            AppLocalizations.instance
                .translate('addressbook_title', {'coin': _walletTitle}),
          ),
        ),
      ),
      actions: [
        searchBar.getSearchAction(context),
        if (_pageIndex == 1)
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addressAddDialog(context),
          ),
      ],
    );
  }

  void changeIndex(int i) {
    setState(() {
      _pageIndex = i;
    });
    applyFilter();
  }

  @override
  void didChangeDependencies() async {
    if (_initial) {
      final _args = ModalRoute.of(context)!.settings.arguments as Map;
      _walletName = _args['name'];
      _walletTitle = _args['title'];
      _walletAddresses =
          await context.watch<ActiveWallets>().getWalletAddresses(_walletName);
      applyFilter();
      _availableCoin = AvailableCoins().getSpecificCoin(_walletName);

      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  void clearFilter([String? _]) {
    applyFilter();
  }

  void applyFilter([String? searchedKey]) {
    var _filteredList = <WalletAddress>[];
    if (_pageIndex == 0) {
      _walletAddresses!.forEach((e) {
        if (e.isOurs == true || e.isOurs == null) _filteredList.add(e);
      });
    } else if (_pageIndex == 1) {
      _walletAddresses!.forEach((e) {
        if (e.isOurs == false) _filteredList.add(e);
      });
    }

    if (searchedKey != null) {
      _filteredList = _filteredList.where((element) {
        return element.address.contains(searchedKey) ||
            element.addressBookName != null &&
                element.addressBookName!.contains(searchedKey);
      }).toList();
    }

    setState(() {
      _filteredAddr = _filteredList;
    });
  }

  Future<void> _addressEditDialog(
      BuildContext context, WalletAddress address) async {
    var _textFieldController = TextEditingController();
    _textFieldController.text = address.addressBookName ?? '';
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.instance
                    .translate('addressbook_edit_dialog_title') +
                ' ${address.address}',
            textAlign: TextAlign.center,
          ),
          content: TextField(
            controller: _textFieldController,
            maxLength: 32,
            decoration: InputDecoration(
                hintText: AppLocalizations.instance
                    .translate('addressbook_edit_dialog_input')),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.instance
                  .translate('server_settings_alert_cancel')),
            ),
            TextButton(
              onPressed: () {
                context.read<ActiveWallets>().updateLabel(
                    _walletName, address.address, _textFieldController.text);
                Navigator.pop(context);
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

  Future<void> _addressAddDialog(BuildContext context) async {
    var _labelController = TextEditingController();
    var _addressController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.instance.translate('addressbook_add_new'),
            textAlign: TextAlign.center,
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _addressController,
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
                    if (Address.validateAddress(
                            sanitized, _availableCoin.networkType) ==
                        false) {
                      return AppLocalizations.instance
                          .translate('send_invalid_address');
                    }
                    //check if already exists
                    if (_walletAddresses!.firstWhereOrNull(
                            (elem) => elem.address == value) !=
                        null) {
                      return 'Address already exists';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _labelController,
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
              child: Text(AppLocalizations.instance
                  .translate('server_settings_alert_cancel')),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  context.read<ActiveWallets>().updateLabel(
                        _walletName,
                        _addressController.text,
                        _labelController.text == ''
                            ? ''
                            : _labelController.text,
                      );
                  applyFilter();
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
    if (_initial) {
      return Scaffold(
          body: Center(
        child: LoadingIndicator(),
      ));
    }
    return Scaffold(
      appBar: searchBar.build(context),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        fixedColor: Colors.white,
        unselectedLabelStyle: TextStyle(
          letterSpacing: 1.4,
        ),
        onTap: (index) => changeIndex(index),
        currentIndex: _pageIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.download_sharp),
            label: AppLocalizations.instance
                .translate('addressbook_bottom_bar_your_addresses'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_sharp),
            label: AppLocalizations.instance
                .translate('addressbook_bottom_bar_sending_addresses'),
          )
        ],
      ),
      body: _filteredAddr.isEmpty
          ? Center(
              child: Text(AppLocalizations.instance
                  .translate('addressbook_no_sending')),
            )
          : ListView.builder(
              itemCount: _filteredAddr.length,
              itemBuilder: (ctx, i) {
                return Card(
                  child: Slidable(
                    key: Key(_filteredAddr[i].address),
                    actionPane: SlidableScrollActionPane(),
                    secondaryActions: <Widget>[
                      IconSlideAction(
                        caption: AppLocalizations.instance
                            .translate('addressbook_swipe_edit'),
                        color: Theme.of(context).primaryColor,
                        icon: Icons.edit,
                        onTap: () =>
                            _addressEditDialog(context, _filteredAddr[i]),
                      ),
                      IconSlideAction(
                        caption: AppLocalizations.instance
                            .translate('addressbook_swipe_share'),
                        color: Theme.of(context).accentColor,
                        iconWidget: Icon(Icons.share, color: Colors.white),
                        onTap: () => WalletHomeQr.showQrDialog(
                            context, _filteredAddr[i].address),
                      ),
                      if (_pageIndex == 1)
                        IconSlideAction(
                          caption: AppLocalizations.instance
                              .translate('addressbook_swipe_send'),
                          color: Colors.white,
                          iconWidget: Icon(Icons.send, color: Colors.grey),
                          onTap: () =>
                              Navigator.of(context).pop(_filteredAddr[i]),
                        ),
                      if (_pageIndex == 1)
                        IconSlideAction(
                            caption: AppLocalizations.instance
                                .translate('addressbook_swipe_delete'),
                            color: Colors.red,
                            iconWidget: Icon(Icons.delete, color: Colors.white),
                            onTap: () async {
                              await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text(AppLocalizations.instance
                                      .translate(
                                          'addressbook_dialog_remove_title')),
                                  content: Text(_filteredAddr[i].address),
                                  actions: <Widget>[
                                    TextButton.icon(
                                        label: Text(AppLocalizations.instance
                                            .translate(
                                                'server_settings_alert_cancel')),
                                        icon: Icon(Icons.cancel),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        }),
                                    TextButton.icon(
                                      label: Text(AppLocalizations.instance
                                          .translate('jail_dialog_button')),
                                      icon: Icon(Icons.check),
                                      onPressed: () {
                                        context
                                            .read<ActiveWallets>()
                                            .removeAddress(
                                                _walletName, _filteredAddr[i]);
                                        applyFilter();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                            AppLocalizations.instance.translate(
                                                'addressbook_dialog_remove_snack'),
                                            textAlign: TextAlign.center,
                                          ),
                                          duration: Duration(seconds: 5),
                                        ));
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            })
                    ],
                    actionExtentRatio: 0.25,
                    child: ListTile(
                      subtitle: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Center(
                          child: Text(_filteredAddr[i].address),
                        ),
                      ),
                      title: Center(
                        child: Text(
                          _filteredAddr[i].addressBookName == ''
                              ? '-'
                              : _filteredAddr[i].addressBookName!,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
