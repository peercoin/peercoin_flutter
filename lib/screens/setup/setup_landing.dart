import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:peercoin/ledger/ledger_interface.dart';

import '../../tools/app_localizations.dart';
import '../../tools/app_routes.dart';
import '../../widgets/buttons.dart';
import '../../widgets/setup_progress.dart';

class SetupLandingScreen extends StatefulWidget {
  const SetupLandingScreen({Key? key}) : super(key: key);

  @override
  State<SetupLandingScreen> createState() => _SetupLandingScreenState();

  static double calcContainerHeight(BuildContext ctx) {
    var height = MediaQuery.of(ctx).size.height;
    var padding = MediaQuery.of(ctx).padding;
    var correctedHeight = height - padding.top - padding.bottom;

    if (MediaQuery.of(ctx).size.height < 600) return 700;
    if (kIsWeb) return correctedHeight;

    return MediaQuery.of(ctx).orientation == Orientation.portrait
        ? correctedHeight
        : MediaQuery.of(ctx).size.height * 1.5;
  }
}

class _SetupLandingScreenState extends State<SetupLandingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: SetupLandingScreen.calcContainerHeight(context),
          color: Theme.of(context).primaryColor,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const PeerProgress(step: 1),
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
                            'assets/icon/ppc-icon-white.png',
                            height: MediaQuery.of(context).size.height / 5,
                          ),
                          Column(
                            children: [
                              FittedBox(
                                child: Text(
                                  AppLocalizations.instance
                                      .translate('setup_title'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 46,
                                  ),
                                ),
                              ),
                              Text(
                                AppLocalizations.instance
                                    .translate('setup_subtitle'),
                                style: const TextStyle(
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
                            text: AppLocalizations.instance
                                .translate('setup_text1'),
                            maxLines: 2,
                          ),
                          PeerButtonSetup(
                            text: AppLocalizations.instance.translate(
                              'setup_import_title',
                            ),
                            action: () => Navigator.of(context)
                                .pushNamed(Routes.setupImport),
                          ),
                          Text(
                            AppLocalizations.instance.translate('setup_text3'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          PeerExplanationText(
                            text: AppLocalizations.instance
                                .translate('setup_text2'),
                          ),
                          PeerButtonSetup(
                            text: AppLocalizations.instance
                                .translate('setup_save_title'),
                            action: () => Navigator.of(context)
                                .pushNamed(Routes.setupCreateWallet),
                          ),
                          if (kIsWeb)
                            Text(
                              AppLocalizations.instance
                                  .translate('setup_text3'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          if (kIsWeb) //only show ledger button on web
                            PeerExplanationText(
                              text: AppLocalizations.instance
                                  .translate('setup_text4'),
                              maxLines: 2,
                            ),
                          if (kIsWeb) //only show ledger button on web
                            PeerButtonSetup(
                              text: AppLocalizations.instance.translate(
                                'setup_ledger_title',
                              ),
                              action: () => Navigator.of(context)
                                  .pushNamed(Routes.setupLedger)
                              // action: () async {
                              //   await LedgerInterface().init();

                              //   for (var i = 0; i < 10; i++) {
                              //     final res = await LedgerInterface()
                              //         .getWalletPublicKey(
                              //       path: "44'/6'/0'/0/$i",
                              //     );
                              //     print(res.address);
                              //   }
                              // },
                              ,
                            ),
                          const SizedBox(
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
                  key: const Key('setupLanguageButton'),
                  onPressed: () async {
                    await Navigator.of(context).pushNamed(Routes.setupLanguage);
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.language_rounded,
                    color: Theme.of(context).colorScheme.background,
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

  const PeerExplanationText({
    Key? key,
    required this.text,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      maxLines: maxLines,
      maxFontSize: 17,
      style: const TextStyle(
        color: Colors.white,
        fontStyle: FontStyle.italic,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class PeerProgress extends StatelessWidget {
  final int step;
  const PeerProgress({
    Key? key,
    required this.step,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: SetupProgressIndicator(step),
    );
  }
}

//TODO web: material icons are not rendered on firefox /
//also rendering issues with non latin characters (flutter render engine issue)
//-> use html renderer instead of canvas for now
