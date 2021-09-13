import 'dart:async';

import 'package:flutter/material.dart';
import 'package:peercoin/providers/unencryptedOptions.dart';
import 'package:peercoin/screens/setup.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/widgets/buttons.dart';
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
            PeerProgress(2),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      AppLocalizations.instance.translate('setup_save_title'),
                      style: TextStyle(color: Colors.white, fontSize: 28),
                    ),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: Theme.of(context).shadowColor,
                          ),
                          child: Column(children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.vpn_key_rounded, color: Theme.of(context).primaryColor, size: 40,),
                                  SizedBox(width: 24,),
                                  Container(
                                    width: MediaQuery.of(context).size.width/1.7,
                                    child: Text(
                                      AppLocalizations.instance
                                          .translate('setup_save_text1'),
                                      style: TextStyle(
                                          color: Theme.of(context).dividerColor, fontSize: 15),
                                      textAlign: TextAlign.left,
                                      maxLines: 5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 220,
                              padding: EdgeInsets.fromLTRB(16, 32, 16, 24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                color: Theme.of(context).backgroundColor,
                                  border: Border.all(
                                      width: 2,
                                      color: Theme.of(context).primaryColor,
                                  ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: getColumn(_seed,0),),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: getColumn(_seed,1),),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: getColumn(_seed,2),),
                                ],),
                            ),
                          ],),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [

                          Slider(
                            activeColor: Colors.white,
                            inactiveColor: Theme.of(context).shadowColor,
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
                            AppLocalizations.instance.translate('setup_seed_slider_label'),
                            style: TextStyle(
                                color: Colors.white, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),

                        ],
                      ),
                    ),
                    if (_sharedYet)
                      PeerButtonSetup(
                        action: () async => await handleContinue(),
                        text: AppLocalizations.instance.translate('continue'),
                      )
                    else
                      PeerButtonSetup(
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

  }

  List<Widget> getColumn(String seed, int pos){
    var list = <Widget>[];
    var se = seed.split(' ');
    var colSize = se.length~/3;

    for(var i=0; i<colSize; i++){
      list.add(
          Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: i * 3 + pos + 1 < 10
            ? Text(
                '  ' + (i * 3 + pos + 1).toString() + '.  ' + se[i * 3 + pos],
                style: TextStyle(color: Theme.of(context).dividerColor),
              )
            : Text(
                (i * 3 + pos + 1).toString() + '.  ' + se[i * 3 + pos],
                style: TextStyle(color: Theme.of(context).dividerColor),
              ),
      ));
    }
    return list;
  }
}
