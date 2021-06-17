import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:peercoin/models/availablecoins.dart';
import 'package:peercoin/models/coin.dart';
import 'package:peercoin/models/walletaddress.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class AddressTab extends StatefulWidget {
  final String name;
  final String title;
  final List<WalletAddress> _walletAddresses;
  AddressTab(this.name,this.title,this._walletAddresses);
  @override
  _AddressTabState createState() => _AddressTabState();
}

class _AddressTabState extends State<AddressTab> {
  bool _initial = true;
  List<WalletAddress> _filteredAddr = [];
  Coin _availableCoin;
  bool _ourAddresses = false;
  final _formKey = GlobalKey<FormState>();
  final _searchKey = GlobalKey<FormFieldState>();
  final searchController = TextEditingController();

  @override
  void didChangeDependencies() async {
    if (_initial) {
      applyFilter(ours: _ourAddresses);
      _availableCoin = AvailableCoins().getSpecificCoin(widget.name);

      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  void clearFilter([String _]) {
    applyFilter(ours: _ourAddresses);
  }

  void applyFilter({bool ours, String searchedKey}) {
    var _filteredList = <WalletAddress>[];

    if (ours!=null) {
      if (ours) {
        widget._walletAddresses.forEach((e) {
          if (e.isOurs == true || e.isOurs == null) _filteredList.add(e);
        });
        _ourAddresses = ours;
      } else {
        widget._walletAddresses.forEach((e) {
          if (e.isOurs == false) _filteredList.add(e);
        });
        _ourAddresses = ours;
      }
    }

    if (searchedKey!=null) {
      _filteredList = _filteredList.where((element) {
        return element.address.contains(searchedKey) ||
            element.addressBookName != null &&
                element.addressBookName.contains(searchedKey);
      }).toList();
    }

    setState(() { _filteredAddr = _filteredList; });
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
                    if (value.isEmpty) {
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
                    if (widget._walletAddresses.firstWhere(
                            (elem) => elem.address == value,
                        orElse: () => null) !=
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
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  context.read<ActiveWallets>().updateLabel(
                    widget.name,
                    _addressController.text,
                    _labelController.text == ''
                        ? null
                        : _labelController.text,
                  );
                  //applyFilter();
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


    return Column(
      children: [
        if (widget._walletAddresses.isNotEmpty)
        Wrap(
              spacing: 8.0,
              children: <Widget>[
                ChoiceChip(
                  backgroundColor: Theme.of(context).unselectedWidgetColor,
                  selectedColor: Theme.of(context).backgroundColor,
                  visualDensity: VisualDensity(horizontal: 0.0, vertical: -4),
                  label: Container(
                      child: Text('Send',
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                    ),
                  )),
                  selected: !_ourAddresses,
                  onSelected: (_) => applyFilter(ours: false),
                ),
                ChoiceChip(
                  backgroundColor: Theme.of(context).unselectedWidgetColor,
                  selectedColor: Theme.of(context).backgroundColor,
                  visualDensity: VisualDensity(horizontal: 0.0, vertical: -4),
                  label:
                      Text('Your',
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                          )),
                  selected: _ourAddresses,
                  onSelected: (_) => applyFilter(ours: true),
                ),
              ],
            ),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredAddr.length,
            itemBuilder: (ctx, i) {
              return Card(
                child: ClipRect(
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
                        onTap: () => Share.share(_filteredAddr[i].address),
                      ),
                      if (_ourAddresses)
                        IconSlideAction(
                          caption: AppLocalizations.instance
                              .translate('addressbook_swipe_send'),
                          color: Colors.white,
                          iconWidget: Icon(Icons.send, color: Colors.grey),
                          onTap: () =>
                              Navigator.of(context).pop(_filteredAddr[i]),
                        ),
                      if (_ourAddresses)
                        IconSlideAction(
                            caption: AppLocalizations.instance
                                .translate('addressbook_swipe_delete'),
                            color: Colors.red,
                            iconWidget: Icon(Icons.delete, color: Colors.white),
                            onTap: () async {
                              await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text(AppLocalizations.instance.translate(
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
                                                widget.name, _filteredAddr[i]);
                                        //applyFilter();
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
                          _filteredAddr[i].addressBookName ?? '-',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/*
final InputBorder formBorders = OutlineInputBorder(
      //borderRadius: const BorderRadius.all(Radius.circular(36)),
      borderSide: const BorderSide(
        width: 2,
        color: Colors.transparent,
      ),
    );

* Container(
          margin: const EdgeInsets.all(8),
          child: Form(
            key: _formKey,
            child: TextFormField(
              key: _searchKey,
              onChanged: (String text){applyFilter(searchedKey: text);},
              controller: searchController,
              style: TextStyle(color: Colors.white,),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                hintStyle: TextStyle(color: Colors.white,),
                hintText: 'Address',
                //floatingLabelBehavior: FloatingLabelBehavior.never,
                suffixIcon: IconButton(
                  icon: Center(child: Icon(CupertinoIcons.xmark_circle_fill)),
                  iconSize: 25,
                  color: Colors.white,
                  onPressed: (){setState(() { searchController.clear(); });},
                ),
                filled: true,
                border: formBorders,
                disabledBorder: formBorders,
                errorBorder: formBorders,
                enabledBorder: formBorders,
                focusedBorder: formBorders,
                focusedErrorBorder: formBorders,
              ),
            ),

          ),
        ),*/
