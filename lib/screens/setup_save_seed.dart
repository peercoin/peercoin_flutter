import 'dart:async';

import 'package:flutter/material.dart';
import 'package:peercoin/providers/unencryptedOptions.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/tools/app_routes.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SetupProgressIndicator(2),
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
                            .translate('label_wallet_seed')!,
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                    SelectableText(
                      _seed,
                      minLines: 4,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          wordSpacing: 10),
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
                              .translate('setup_seed_slider_label')!,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                    Text(
                      AppLocalizations.instance.translate(
                          'label_keep_seed_safe', {
                        'numberOfWords': _currentSliderValue.round().toString()
                      })!,
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: _sharedYet
                          ? ElevatedButton(
                              key: Key('continue'),
                              onPressed: () async {
                                var prefs =
                                    await Provider.of<UnencryptedOptions>(
                                            context,
                                            listen: false)
                                        .prefs;
                                await prefs.setBool('importedSeed', false);
                                await Navigator.popAndPushNamed(
                                    context, Routes.SetUpPin);
                              },
                              child: Text(
                                AppLocalizations.instance
                                    .translate('continue')!,
                                style: TextStyle(fontSize: 18),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () async => await shareSeed(_seed),
                              child: Text(
                                AppLocalizations.instance
                                    .translate('export_now')!,
                                style: TextStyle(fontSize: 18),
                              ),
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
