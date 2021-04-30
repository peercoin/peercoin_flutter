import 'package:flutter/material.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/loading_indicator.dart';

class AddressBookScreen extends StatefulWidget {
  @override
  _AddressBookScreenState createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  bool _initial = true;
  String _walletName;
  String _walletTitle;

  @override
  void didChangeDependencies() {
    if (_initial) {
      setState(() {
        _initial = false;
      });
      final _args = ModalRoute.of(context).settings.arguments as Map;
      _walletName = _args["name"];
      _walletTitle = _args["title"];
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
      ),
    );
  }
}
