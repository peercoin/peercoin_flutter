import 'dart:async';

import 'package:flutter/material.dart';
import 'package:peercoin/providers/unencryptedOptions.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/double_tab_to_clipboard.dart';
import 'package:peercoin/widgets/setup_progress.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class SetupSaveScreen extends StatefulWidget {
  @override
  _SetupSaveScreenState createState() => _SetupSaveScreenState();
}

class _SetupSaveScreenState extends State<SetupSaveScreen> {
  bool _sharedYet = false;
  bool _initial = true;
  String _seed = '';
  double _currentSliderValue = 12;
  late ActiveWallets _activeWallets;

  Future<void> shareSeed(seed) async {
    await Share.share(seed);
    Timer(
      Duration(seconds: 1),
      () => setState(() {
        _sharedYet = true;
      }),
    );
  }

  @override
  void didChangeDependencies() async {
    if (_initial) {
      _activeWallets = Provider.of<ActiveWallets>(context);
      _seed = await _activeWallets.seedPhrase;

      setState(() {
        _initial = false;
      });
    }

    super.didChangeDependencies();
  }

  void recreatePhrase(double sliderValue) async {
    var _entropy = 128;
    var _intValue = sliderValue.toInt();

    switch (_intValue) {
      case 16:
        _entropy = 160;
        break;
      case 20:
        _entropy = 192;
        break;
      case 24:
        _entropy = 256;
        break;
      default:
        _entropy = 128;
    }

    await _activeWallets.createPhrase(null, _entropy);
    _seed = await _activeWallets.seedPhrase;

    setState(() {
      _sharedYet = false;
    });
  }

  Future<void> handleContinue() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.instance.translate('setup_continue_alert_title'),
            textAlign: TextAlign.center,
          ),
          content: Text(
            AppLocalizations.instance.translate('setup_continue_alert_content'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.instance
                    .translate('server_settings_alert_cancel'),
              ),
            ),
            TextButton(
              onPressed: () async {
                var prefs = await Provider.of<UnencryptedOptions>(context,
                        listen: false)
                    .prefs;
                await prefs.setBool('importedSeed', false);
                await Navigator.popAndPushNamed(context, Routes.SetUpPin);
              },
              child: Text(
                AppLocalizations.instance.translate('continue'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: SetupProgressIndicator(2),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Your Seed',
                      style: TextStyle(color: Colors.white, fontSize: 32),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Double tap the list to copy on the clipboard.',
                            style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context).backgroundColor,
                          ),
                          child: DoubleTabToClipboard(
                            clipBoardData: _seed,
                            child: SelectableText(
                              _seed,
                              minLines: 5,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.bold,
                                wordSpacing: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'Slide to change the number of words.',
                          style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                        Slider(
                          activeColor: Colors.white,
                          inactiveColor: Theme.of(context).disabledColor,
                          value: _currentSliderValue,
                          min: 12,
                          max: 24,
                          divisions: 3,
                          label: _currentSliderValue.round().toString(),
                          onChanged: (value) {
                            setState(() {
                              _currentSliderValue = value;
                            });
                            if (value % 4 == 0) {
                              recreatePhrase(value);
                            }
                          },
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'This list of words is used to generate your private key and gives full access to your wallet. Keep it safe !',
                        style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    if (_sharedYet)
                      PeerButtonBorder(
                        action: () async => await handleContinue(),
                        text: AppLocalizations.instance.translate('continue'),
                      )
                    else
                      PeerButtonBorder(
                        action: () async => await shareSeed(_seed),
                        text: AppLocalizations.instance.translate('export_now'),
                      ),
                    SizedBox(height: 8,),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );




    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 30),
                height: MediaQuery.of(context).size.height,
                color: Theme.of(context).primaryColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset(
                      'assets/icon/ppc-icon-white-256.png',
                      width: 50,
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      child: Text(
                        AppLocalizations.instance
                            .translate('label_wallet_seed'),
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                    DoubleTabToClipboard(
                      clipBoardData: _seed,
                      child: SelectableText(
                        _seed,
                        minLines: 4,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          wordSpacing: 10,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Slider(
                          activeColor: Colors.white,
                          inactiveColor: Theme.of(context).accentColor,
                          value: _currentSliderValue,
                          min: 12,
                          max: 24,
                          divisions: 3,
                          label: _currentSliderValue.round().toString(),
                          onChanged: (value) {
                            setState(() {
                              _currentSliderValue = value;
                            });
                            if (value % 4 == 0) {
                              recreatePhrase(value);
                            }
                          },
                        ),
                        Text(
                          AppLocalizations.instance
                              .translate('setup_seed_slider_label'),
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                    Text(
                      AppLocalizations.instance.translate(
                          'label_keep_seed_safe', {
                        'numberOfWords': _currentSliderValue.round().toString()
                      }),
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: _sharedYet
                          ? PeerButtonBorder(
                              action: () async => await handleContinue(),
                              text: AppLocalizations.instance
                                  .translate('continue'),
                            )
                          : PeerButtonBorder(
                              action: () async => await shareSeed(_seed),
                              text: AppLocalizations.instance
                                  .translate('export_now'),
                            ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
