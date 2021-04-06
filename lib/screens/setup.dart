import "package:flutter/material.dart";
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/widgets/loading_indicator.dart';
import 'package:peercoin/widgets/setup_progress.dart';
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
    await Navigator.of(context).popAndPushNamed(Routes.SetupScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SetupProgressIndicator(1),
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/icon/ppc-icon-white-256.png",
                width: 50,
              ),
              SizedBox(height: 60),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  AppLocalizations.instance.translate('setup_files_for_wallet'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 30),
              _loading
                  ? LoadingIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => {createWallet(context)},
                          child: Text(
                            AppLocalizations.instance.translate(
                              'create_wallet_new_seed',
                            ),
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        Text(
                            AppLocalizations.instance.translate(
                              'create_wallet_or',
                            ),
                            style: TextStyle(color: Colors.white)),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context)
                              .pushNamed(Routes.SetupImport),
                          child: Text(
                            AppLocalizations.instance
                                .translate('create_wallet_existing_seed'),
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      ],
                    )
            ],
          ),
        ),
      ),
    );
  }
}
