import 'package:flutter/material.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/widgets/buttons.dart';
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
    var _activeWallets = Provider.of<ActiveWallets>(context, listen: false);
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
          child: _loading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LinearProgressIndicator(
                      backgroundColor: Colors.white,
                    ),
                  ],
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      top: 25,
                      right: 25,
                      child: FloatingActionButton(
                        backgroundColor: Colors.white,
                        onPressed: () async {
                          await Navigator.of(context)
                              .pushNamed(Routes.SetupLanguage);
                          setState(() {});
                        },
                        child: Icon(
                          Icons.language_rounded,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset(
                          'assets/icon/ppc-icon-white-256.png',
                          width: 50,
                        ),
                        Text(
                          AppLocalizations.instance.translate('setup_welcome'),
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 50),
                          child: Text(
                            AppLocalizations.instance
                                .translate('setup_files_for_wallet'),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PeerButtonBorder(
                              text: AppLocalizations.instance
                                  .translate('create_wallet_new_seed'),
                              action: () => {createWallet(context)},
                            ),
                            Text(
                                AppLocalizations.instance.translate(
                                  'create_wallet_or',
                                ),
                                style: TextStyle(color: Colors.white)),
                            PeerButtonBorder(
                              text: AppLocalizations.instance
                                  .translate('create_wallet_existing_seed'),
                              action: () => Navigator.of(context)
                                  .pushNamed(Routes.SetupImport),
                            )
                          ],
                        )
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
