// ignore_for_file: avoid_web_libraries_in_flutter, use_build_context_synchronously

import 'dart:js_util';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:peercoin/ledger/ledger_exceptions.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ledger/ledger_interface.dart';
import '../../ledger/ledger_js_binding.dart';
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
  bool _browserSupport = false;
  bool _ledgerAvailable = false;
  bool _screenLoading = false;
  bool _ledgerLoading = false;

  void createWallet(BuildContext context) async {
    setState(() {
      _screenLoading = true;
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
      _screenLoading = false;
    });
  }

  Future<bool> connectLedgerAndTryToGetPubKey() async {
    try {
      await LedgerInterface().performTransaction(
        context: context,
        future: LedgerInterface().init(),
      );
      await LedgerInterface().performTransaction(
        context: context,
        future: LedgerInterface().getWalletPublicKey(
          path: "44'/6'/0'/0/0",
        ),
      );

      return true;
    } catch (e) {
      LoggerWrapper.logError(
        'SetupLedger',
        'connectLedgerAndTryToGetPubKey',
        e.toString(),
      );

      return false;
    }
  }

  Widget renderContainerChild() {
    if (_browserSupport == false) {
      return browserDoesNotSupportWebUSB();
    }
    return activeLedgerStepper();
  }

  Widget activeLedgerStepper() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check),
            const SizedBox(
              width: 20,
            ),
            Text(
              'Your browser supports WebUSB', //TODO i18n
              style: TextStyle(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          'Please unlock your Ledger and open the Peercoin application on your device before clicking "Connect Ledger".', //TODO i18n
          style: TextStyle(
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        PeerButtonSetupLoading(
          loading: _ledgerLoading,
          active: _ledgerAvailable == false,
          action: () async {
            if (_ledgerAvailable) return;
            setState(() {
              _ledgerLoading = true;
            });
            final res = await connectLedgerAndTryToGetPubKey();
            if (res == true) {
              setState(() {
                _ledgerAvailable = true;
                _ledgerLoading = false;
              });
            } else {
              await Future.delayed(const Duration(seconds: 1));
              setState(() {
                _ledgerLoading = false;
              });
            }
          },
          text: _ledgerAvailable
              ? 'Ledger Connected'
              : 'Connect Ledger', //TODO i18n
        ),
        const SizedBox(
          height: 20,
        ),
        if (_ledgerAvailable)
          Text(
            'Ledger connected succesfully. Please continue with the button below.', //TODO i18n
            style: TextStyle(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
        if (_ledgerAvailable)
          const SizedBox(
            height: 20,
          ),
      ],
    );
  }

  Widget browserDoesNotSupportWebUSB() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.close),
            SizedBox(
              width: 20,
            ),
            SizedBox(
              height: 10,
            ),
            AutoSizeText(
              'Your browser does not support WebUSB', //TODO i18n
              maxFontSize: 28,
              minFontSize: 25,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
        const Text('Please consider using Chrome'), //TODO i18n
      ],
    );
  }

  @override
  void didChangeDependencies() async {
    if (_initial) {
      final res = await promiseToFuture(transportWebUSBIsSupported());
      if (res == true) {
        _browserSupport = true;
      }
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
                      Container(
                        padding: const EdgeInsets.all(15),
                        width: MediaQuery.of(context).size.width > 1200
                            ? MediaQuery.of(context).size.width / 2
                            : MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                          color: Theme.of(context).shadowColor,
                        ),
                        child: renderContainerChild(),
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
                loading: _screenLoading,
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