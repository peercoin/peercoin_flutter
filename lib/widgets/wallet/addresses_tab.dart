import 'package:coinslib/coinslib.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:peercoin/models/availablecoins.dart';
import 'package:peercoin/models/coin.dart';
import 'package:peercoin/models/walletaddress.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/screens/wallet/wallet_home.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/auth.dart';
import 'package:peercoin/widgets/wallet/wallet_home_qr.dart';
import 'package:provider/provider.dart';

import '../double_tab_to_clipboard.dart';

class AddressTab extends StatefulWidget {
  final String name;
  final String title;
  final List<WalletAddress>? _walletAddresses;
  final Function changeIndex;
  AddressTab(this.name, this.title, this._walletAddresses, this.changeIndex);
  @override
  _AddressTabState createState() => _AddressTabState();
}

class _AddressTabState extends State<AddressTab> {
  bool _initial = true;
  List<WalletAddress> _filteredSend = [];
  List<WalletAddress> _filteredReceive = [];
  late Coin _availableCoin;
  final _formKey = GlobalKey<FormState>();
  final _searchKey = GlobalKey<FormFieldState>();
  final searchController = TextEditingController();
  bool _search = false;
  bool _showChangeAddresses = true;
  bool _showLabel = true;
  Map _addressBalanceMap = {};

  @override
  void didChangeDependencies() async {
    if (_initial) {
      applyFilter();
      fillAddressBalanceMap();
      _availableCoin = AvailableCoins().getSpecificCoin(widget.name);
      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  void fillAddressBalanceMap() {}

  void applyFilter([String? searchedKey]) {
    var _filteredListR = <WalletAddress>[];
    var _filteredListS = <WalletAddress>[];

    widget._walletAddresses!.forEach((e) {
      if (e.isOurs == true || e.isOurs == null) {
        if (_showChangeAddresses == false) {
          if (e.isChangeAddr == false) {
            _filteredListR.add(e);
          }
        } else {
          _filteredListR.add(e);
        }
      } else {
        _filteredListS.add(e);
      }
    });

    if (searchedKey != null) {
      _filteredListR = _filteredListR.where((element) {
        return element.address.contains(searchedKey) ||
            element.addressBookName != null &&
                element.addressBookName!.contains(searchedKey);
      }).toList();
      _filteredListS = _filteredListS.where((element) {
        return element.address.contains(searchedKey) ||
            element.addressBookName != null &&
                element.addressBookName!.contains(searchedKey);
      }).toList();
    }

    setState(() {
      _filteredReceive = _filteredListR;
      _filteredSend = _filteredListS;
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
                    widget.name, address.address, _textFieldController.text);
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

  Future<void> _showAddressExportDialog(
      BuildContext context, WalletAddress address) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.instance
                .translate('addressbook_export_dialog_title'),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.instance
                    .translate('addressbook_export_dialog_description'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).errorColor,
                ),
              ),
            ],
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
              onPressed: () async {
                var _wif;
                if (address.wif!.isEmpty || address.wif == null) {
                  _wif = await context.read<ActiveWallets>().getWif(
                        _availableCoin.name,
                        address.address,
                      );
                } else {
                  _wif = address.wif;
                }
                Navigator.of(context).pop();
                WalletHomeQr.showQrDialog(context, _wif);
              },
              child: Text(
                AppLocalizations.instance
                    .translate('addressbook_export_dialog_button'),
              ),
            )
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
                    if (widget._walletAddresses!
                        .any((element) => element.address == value)) {
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
                        widget.name,
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
    var listReceive = <Widget>[];
    var listSend = <Widget>[];
    for (var addr in _filteredSend) {
      listSend.add(
        DoubleTabToClipboard(
          clipBoardData: addr.address,
          child: Card(
            elevation: 0,
            child: ClipRect(
              child: Slidable(
                key: Key(addr.address),
                actionPane: SlidableScrollActionPane(),
                secondaryActions: <Widget>[
                  IconSlideAction(
                    caption: AppLocalizations.instance
                        .translate('addressbook_swipe_edit'),
                    color: Theme.of(context).primaryColor,
                    icon: Icons.edit,
                    onTap: () => _addressEditDialog(context, addr),
                  ),
                  IconSlideAction(
                    caption: AppLocalizations.instance
                        .translate('addressbook_swipe_share'),
                    color: Theme.of(context).backgroundColor,
                    iconWidget: Icon(
                      Icons.share,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    onTap: () =>
                        WalletHomeQr.showQrDialog(context, addr.address),
                  ),
                  IconSlideAction(
                    caption: AppLocalizations.instance
                        .translate('addressbook_swipe_send'),
                    color: Theme.of(context).colorScheme.secondary,
                    iconWidget: Icon(
                      Icons.send,
                      color: Theme.of(context).backgroundColor,
                    ),
                    onTap: () => widget.changeIndex(
                        Tabs.send, addr.address, addr.addressBookName),
                  ),
                  IconSlideAction(
                      caption: AppLocalizations.instance
                          .translate('addressbook_swipe_delete'),
                      color: Theme.of(context).errorColor,
                      iconWidget: Icon(Icons.delete, color: Colors.white),
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(AppLocalizations.instance
                                .translate('addressbook_dialog_remove_title')),
                            content: Text(addr.address),
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
                                      .removeAddress(widget.name, addr);
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
                      child: Text(addr.address),
                    ),
                  ),
                  title: Center(
                    child: Text(
                      addr.addressBookName ?? '-',
                      style: TextStyle(
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
      );
    }
    for (var addr in _filteredReceive) {
      listReceive.add(
        DoubleTabToClipboard(
          clipBoardData: addr.address,
          child: Card(
            elevation: 0,
            child: ClipRect(
              child: Slidable(
                key: Key(addr.address),
                actionPane: SlidableScrollActionPane(),
                secondaryActions: <Widget>[
                  IconSlideAction(
                    caption: AppLocalizations.instance
                        .translate('addressbook_swipe_edit'),
                    color: Theme.of(context).primaryColor,
                    icon: Icons.edit,
                    onTap: () => _addressEditDialog(context, addr),
                  ),
                  IconSlideAction(
                    caption: AppLocalizations.instance
                        .translate('addressbook_swipe_share'),
                    color: Theme.of(context).backgroundColor,
                    iconWidget: Icon(
                      Icons.share,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    onTap: () => WalletHomeQr.showQrDialog(
                      context,
                      addr.address,
                    ),
                  ),
                  IconSlideAction(
                    caption: AppLocalizations.instance
                        .translate('addressbook_swipe_export'),
                    color: Theme.of(context).backgroundColor,
                    iconWidget: Icon(
                      Icons.vpn_key,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    onTap: () => Auth.requireAuth(
                      context: context,
                      biometricsAllowed:
                          context.read<AppSettings>().biometricsAllowed,
                      callback: () => _showAddressExportDialog(context, addr),
                    ),
                  ),
                ],
                actionExtentRatio: 0.25,
                child: ListTile(
                  subtitle: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Center(
                      child: Text(addr.address),
                    ),
                  ),
                  title: Center(
                    child: Text(
                      _showLabel
                          ? addr.addressBookName ?? '-'
                          : _addressBalanceMap[addr.address] ?? '0.0',
                      style: TextStyle(
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
      );
    }

    return Column(
      children: [
        Expanded(
            child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              floating: true,
              backgroundColor: _search
                  ? Theme.of(context).backgroundColor
                  : Theme.of(context).primaryColor,
              title: Container(
                margin: const EdgeInsets.only(top: 8),
                child: _search
                    ? Form(
                        key: _formKey,
                        child: Container(
                          padding: const EdgeInsets.only(left: 16),
                          child: TextFormField(
                            autofocus: true,
                            key: _searchKey,
                            textInputAction: TextInputAction.done,
                            autocorrect: false,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: AppLocalizations.instance
                                  .translate('addressbook_search'),
                              suffixIcon: IconButton(
                                icon: Center(child: Icon(Icons.clear)),
                                iconSize: 24,
                                onPressed: () {
                                  _search = false;
                                  applyFilter();
                                },
                              ),
                            ),
                            onChanged: applyFilter,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Theme.of(context).backgroundColor,
                              onPrimary: Theme.of(context).backgroundColor,
                              fixedSize: Size(
                                  MediaQuery.of(context).size.width / 3, 40),
                              shape: RoundedRectangleBorder(
                                //to set border radius to button
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                    width: 2,
                                    color: Theme.of(context).primaryColor),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              if (widget._walletAddresses!.isNotEmpty) {
                                setState(() {
                                  _search = true;
                                });
                              }
                            },
                            child: Text(
                              AppLocalizations.instance.translate('search'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.4,
                                fontSize: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Theme.of(context).backgroundColor,
                              onPrimary: Theme.of(context).backgroundColor,
                              fixedSize: Size(
                                  MediaQuery.of(context).size.width / 3, 40),
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
                        ],
                      ),
              ),
            ),
            SliverAppBar(
              automaticallyImplyLeading: false,
              title: Text(
                AppLocalizations.instance
                    .translate('addressbook_bottom_bar_sending_addresses'),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(listSend),
            ),
            SliverAppBar(
              automaticallyImplyLeading: false,
              title: Text(
                AppLocalizations.instance
                    .translate('addressbook_bottom_bar_your_addresses'),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ChoiceChip(
                        backgroundColor: Theme.of(context).backgroundColor,
                        selectedColor: Theme.of(context).shadowColor,
                        visualDensity:
                            VisualDensity(horizontal: 0.0, vertical: -4),
                        label: Container(
                          child: Text(
                            AppLocalizations.instance
                                .translate('addressbook_hide_change'),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        selected: _showChangeAddresses,
                        onSelected: (_) {
                          setState(() {
                            _showChangeAddresses = _;
                          });
                          applyFilter();
                        }),
                    ChoiceChip(
                      backgroundColor: Theme.of(context).backgroundColor,
                      selectedColor: Theme.of(context).shadowColor,
                      visualDensity:
                          VisualDensity(horizontal: 0.0, vertical: -4),
                      label: Container(
                        child: Text(
                          _showLabel
                              ? AppLocalizations.instance
                                  .translate('addressbook_show_balance')
                              : AppLocalizations.instance
                                  .translate('addressbook_show_label'),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                      selected: _showLabel,
                      onSelected: (_) {
                        setState(() {
                          _showLabel = _;
                        });
                        applyFilter();
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 10),
            ),
            SliverList(
              delegate: SliverChildListDelegate(listReceive),
            ),
          ],
        )),
      ],
    );
  }
  //TODO allow change addresses to be hidden in the list
  //TODO toggle switch: hide change addresses
  //TODO toggle switch: label / balance
}
