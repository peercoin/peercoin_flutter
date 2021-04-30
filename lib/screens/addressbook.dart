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

  @override
  void didChangeDependencies() async {
    if (_initial) {
      final _args = ModalRoute.of(context).settings.arguments as Map;
      _walletName = _args["name"];
      _walletTitle = _args["title"];
      _walletAddresses =
          await context.watch<ActiveWallets>().getWalletAddresses(_walletName);
      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
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
      body: _walletAddresses.isEmpty
          ? Center(child: LoadingIndicator())
          : ListView.builder(
              //TODO add selection chips for incoming / outgoing
              itemCount: _walletAddresses.length,
              itemBuilder: (ctx, i) {
                return Card(
                  child: InkWell(
                    onTap: () => print("this is how I win"),
                    child: ListTile(
                      title: Center(
                        child: Text(_walletAddresses[i].address),
                      ),
                      subtitle: Center(
                        child: Text(
                          _walletAddresses[i].addressBookName ??
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

//TODO walletaddress needs a field to distinguish incoming/outgoing tx
//TODO TX List show label if set
//TODO send tab add label input (optional)
//TODO receive tab add label input (optional)
