import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../tools/app_localizations.dart';
import '../../tools/app_routes.dart';
import '../../widgets/buttons.dart';
import '../../widgets/setup_progress.dart';

class SetupScreen extends StatefulWidget {
  @override
  _SetupScreenState createState() => _SetupScreenState();

  static double calcContainerHeight(BuildContext ctx) {
    var height = MediaQuery.of(ctx).size.height;
    var padding = MediaQuery.of(ctx).padding;
    var correctedHeight = height - padding.top - padding.bottom;

    if (kIsWeb) return correctedHeight;

    return MediaQuery.of(ctx).orientation == Orientation.portrait
        ? correctedHeight
        : MediaQuery.of(ctx).size.height * 1.5;
  }
}

class _SetupScreenState extends State<SetupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: SetupScreen.calcContainerHeight(context),
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
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 20,
                          ),
                          Image.asset(
                            'assets/img/setup-launch.png',
                            height: MediaQuery.of(context).size.height / 5,
                          ),
                          Column(
                            children: [
                              FittedBox(
                                child: Text(
                                  AppLocalizations.instance
                                      .translate('setup_title'),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 46,
                                  ),
                                ),
                              ),
                              Text(
                                AppLocalizations.instance
                                    .translate('setup_subtitle'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 15,
                          ),
                          PeerExplanationText(
                            AppLocalizations.instance.translate('setup_text1'),
                            2,
                          ),
                          PeerButtonSetup(
                            text: AppLocalizations.instance.translate(
                              'setup_import_title',
                            ),
                            action: () => Navigator.of(context)
                                .pushNamed(Routes.SetupImport),
                          ),
                          Text(
                            AppLocalizations.instance.translate('setup_text3'),
                            style: TextStyle(color: Colors.white, fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                          PeerExplanationText(AppLocalizations.instance
                              .translate('setup_text2')),
                          PeerButtonSetup(
                            text: AppLocalizations.instance
                                .translate('setup_save_title'),
                            action: () => Navigator.of(context)
                                .pushNamed(Routes.SetupCreateWallet),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Positioned(
                top: 30,
                right: 25,
                child: IconButton(
                  key: Key('setupLanguageButton'),
                  onPressed: () async {
                    await Navigator.of(context).pushNamed(Routes.SetupLanguage);
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
      ),
    );
  }
}

class PeerExplanationText extends StatelessWidget {
  final String text;
  final int maxLines;
  PeerExplanationText(this.text, [this.maxLines = 1]);

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      maxLines: maxLines,
      maxFontSize: 17,
      style: TextStyle(
        color: Colors.white,
        fontStyle: FontStyle.italic,
      ),
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

//TODO web: material icons are not rendered on firefox / also rendering issues with non latin characters (flutter render engine issue)
//TODO web: find session solution 
//TODO web: layout / sizing for wallet list and wallet home
//TODO web: check camera available
//TODO web: setup pin: don't allow direct access
//TODO web: setup data feeds: don't allow direct access
//TODO web: empty wallet list: show add wallet button