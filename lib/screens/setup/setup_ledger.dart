import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/active_wallets.dart';
import '../../tools/app_localizations.dart';
import '../../tools/app_routes.dart';
import '../../tools/logger_wrapper.dart';
import '../../widgets/buttons.dart';
import 'setup_landing.dart';

class SetupLedgerScreen extends StatefulWidget {
  const SetupLedgerScreen({Key? key}) : super(key: key);

  @override
  State<SetupLedgerScreen> createState() => _SetupLedgerScreenState();
}

class _SetupLedgerScreenState extends State<SetupLedgerScreen> {
  bool _initial = true;
  bool _ledgerAvailable = false;
  bool _loading = false;

  void createWallet(BuildContext context) async {
    setState(() {
      _loading = true;
    });
    final activeWallets = context.read<ActiveWallets>();
    final navigator = Navigator.of(context);
    try {
      await activeWallets.init();
    } catch (e) {
      LoggerWrapper.logError(
        'SetupLedgerScreen',
        'createWallet',
        e.toString(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.instance.translate('setup_securebox_fail'),
            textAlign: TextAlign.center,
          ),
          duration: const Duration(seconds: 10),
        ),
      );
    }
    await activeWallets.createPhrase(
      'vapor please suffer wood enrich quality position chest quantum fog rival museum',
    ); //Dummy phrase for ledger
    var prefs = await SharedPreferences.getInstance();
    await prefs.setBool('importedSeed', true);
    await prefs.setBool('ledgerMode', true);
    await navigator.pushNamed(Routes.setupAuth);
    setState(() {
      _loading = false;
    });
  }

  @override
  void didChangeDependencies() async {
    if (_initial) {
      //TODO test browser capabilties
      try {} catch (e) {}
    }
    setState(() {
      _initial = false;
    });
    super.didChangeDependencies();
  }

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const PeerProgress(step: 2),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        'assets/img/setup-security.png',
                        height: MediaQuery.of(context).size.height / 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const PeerButtonSetupBack(),
                          AutoSizeText(
                            AppLocalizations.instance.translate(
                              'setup_ledger_title_setup',
                            ),
                            maxFontSize: 28,
                            minFontSize: 25,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            width: 40,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              PeerButtonSetupLoading(
                action: () {
                  if (_ledgerAvailable == false) return;
                  createWallet(context);
                },
                active: _ledgerAvailable,
                text: AppLocalizations.instance.translate(
                  'continue',
                ),
                loading: _loading,
              ),
              const SizedBox(
                height: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
