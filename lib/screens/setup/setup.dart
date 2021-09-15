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
    await Navigator.of(context).pushNamed(Routes.SetupScreen);
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Stack(
                fit: StackFit.expand,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      PeerProgress(1),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height/20,),
                              Image.asset(
                                'assets/img/setup-launch.png',
                                height: MediaQuery.of(context).size.height/5,
                              ),
                              Column(
                                children: [
                                  Text(
                                    AppLocalizations.instance.translate('setup_title'),
                                    style: TextStyle(color: Colors.white, fontSize: 46),
                                  ),
                                  Text(
                                    AppLocalizations.instance.translate('setup_subtitle'),
                                    style: TextStyle(color: Colors.white, fontSize: 24),
                                  ),
                                ],
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height/15,),
                              PeerExplanationText(AppLocalizations.instance.translate('setup_text1')),
                              PeerButtonSetup(
                                text: AppLocalizations.instance.translate(
                                  'setup_import_title',
                                ),
                                action: () => Navigator.of(context)
                                    .pushNamed(Routes.SetupImport),
                              ),
                              Text(
                                AppLocalizations.instance.translate('setup_text3'),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                              PeerExplanationText(AppLocalizations.instance.translate('setup_text2')),
                              PeerButtonSetupLoading(
                                text: AppLocalizations.instance.translate('setup_save_title'),
                                action: () => {createWallet(context)},
                                loading: _loading,
                              ),
                              SizedBox(height: 8,),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height/8,
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
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class PeerExplanationText extends StatelessWidget {
  final String text;
  PeerExplanationText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          color: Colors.white, fontStyle: FontStyle.italic, fontSize: 17),
      textAlign: TextAlign.center,
    );
  }
}

class PeerProgress extends StatelessWidget {
  final int num;
  PeerProgress(this.num);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: SetupProgressIndicator(num),
    );
  }
}

