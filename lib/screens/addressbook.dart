import 'package:flutter/material.dart';
import 'package:peercoin/models/walletaddress.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class AddressBookScreen extends StatefulWidget {
  @override
  _AddressBookScreenState createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  bool _initial = true;
  String _walletName;
  String _walletTitle;
  List<WalletAddress> _walletAddresses = [];
  List<WalletAddress> _filteredTx = [];
  int _pageIndex = 0;

  void changeIndex(int i) {
    setState(() {
      _pageIndex = i;
    });
    applyFilter();
  }

  @override
  void didChangeDependencies() async {
    if (_initial) {
      final _args = ModalRoute.of(context).settings.arguments as Map;
      _walletName = _args["name"];
      _walletTitle = _args["title"];
      _walletAddresses =
          await context.watch<ActiveWallets>().getWalletAddresses(_walletName);
      applyFilter();
      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  void applyFilter([String searchedKey]) {
    List<WalletAddress> _filteredList = [];
    if (_pageIndex == 0) {
      _walletAddresses.forEach((e) {
        if (e.isOurs == true || e.isOurs == null) _filteredList.add(e);
      });
    } else if (_pageIndex == 1) {
      _walletAddresses.forEach((e) {
        if (e.isOurs == false) _filteredList.add(e);
      });
    }
    setState(() {
      _filteredTx = _filteredList;
    });
  }

  Future<void> _displayTextInputDialog(
      BuildContext context, WalletAddress address) async {
    TextEditingController _textFieldController = TextEditingController();
    _textFieldController.text = address.addressBookName ?? "";
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.instance
                    .translate('addressbook_edit_dialog_title') +
                " ${address.address}",
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
              child: Text(AppLocalizations.instance
                  .translate('server_settings_alert_cancel')),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(
                AppLocalizations.instance.translate('jail_dialog_button'),
              ),
              onPressed: () {
                context.read<ActiveWallets>().updateLabel(
                    _walletName, address.address, _textFieldController.text);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initial)
      return Scaffold(
          body: Center(
        child: LoadingIndicator(),
      ));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.instance
              .translate('addressbook_title', {"coin": _walletTitle}),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => print("searchin"),
          ), //TODO implement
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        fixedColor: Colors.white,
        onTap: (index) => changeIndex(index),
        currentIndex: _pageIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_left),
            label: AppLocalizations.instance
                .translate('addressbook_bottom_bar_your_addresses'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_right),
            label: AppLocalizations.instance
                .translate('addressbook_bottom_bar_sending_addresses'),
          )
        ],
      ),
      body: _filteredTx.isEmpty
          ? Center(
              child: Text(AppLocalizations.instance
                  .translate('addressbook_no_sending')),
            )
          : ListView.builder(
              itemCount: _filteredTx.length,
              itemBuilder: (ctx, i) {
                return Card(
                  child: InkWell(
                    onTap: () =>
                        _displayTextInputDialog(context, _filteredTx[i]),
                    child: ListTile(
                      title: Center(
                        child: Text(_filteredTx[i].address),
                      ),
                      subtitle: Center(
                        child: Text(
                          _filteredTx[i].addressBookName ??
                              AppLocalizations.instance
                                  .translate('addressbook_no_label'),
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      //TODO add leading icon indicating direciton
                    ),
                  ),
                );
              }),
    );
  }
}

//TODO make addr book list tile slideable (edit/share)
//TODO TX List show label if set
//TODO send tab add label input (optional)
//TODO receive tab add label input (optional)
