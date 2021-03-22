import "package:flutter/material.dart";
import 'package:peercoin/app_localizations.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/screens/setup_save_seed.dart';
import 'package:peercoin/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class SetupScreen extends StatefulWidget {
  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  bool _loading = false;
  void createWallet(context) async {
    setState(() {
      _loading = true;
    });
    ActiveWallets _activeWallets =
        Provider.of<ActiveWallets>(context, listen: false);
    await _activeWallets.init();
    await _activeWallets.createPhrase();
    await Navigator.of(context).popAndPushNamed(SetupSaveScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/icon/ppc-icon-white-48.png"),
              SizedBox(height: 60),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  AppLocalizations.instance.translate('setup_files_for_wallet',null),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 30),
              TextButton(
                onPressed: () => {createWallet(context)},
                child: _loading
                    ? LoadingIndicator()
                    : Text(
                        AppLocalizations.instance.translate('create_wallet',null),
                        style: TextStyle(fontSize: 18),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
