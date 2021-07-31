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
      body: Container(
        color: Theme.of(context).primaryColor,
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
                    top: 40,
                    right: 25,
                    child: IconButton(
                      onPressed: () async {
                        await Navigator.of(context)
                            .pushNamed(Routes.SetupLanguage);
                        setState(() {});
                      },
                      icon: Icon(
                        Icons.language_rounded,
                        color: Theme.of(context).backgroundColor,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                        child: SetupProgressIndicator(1),
                      ),
                      Image.asset(
                        'assets/images/90-Start-Up.png',
                        height: MediaQuery.of(context).size.height/3,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          children: [
                            Text(
                              'Welcome',
                              style: TextStyle(color: Colors.white, fontSize: 40),
                            ),
                            Text(
                              'to Peercoin Wallet',
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                    'If you already have a Seed select "Import Seed" otherwise create a new wallet.',
                                style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            PeerButtonBorder(
                              text: 'Create Wallet',
                              action: () => {createWallet(context)},
                            ),
                            PeerButtonBorder(
                              text: 'Import Seed',
                              action: () => Navigator.of(context)
                                  .pushNamed(Routes.SetupImport),
                            ),
                            SizedBox(height: 8,),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
