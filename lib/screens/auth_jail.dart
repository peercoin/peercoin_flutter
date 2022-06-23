import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_settings.dart';
import '../providers/encrypted_box.dart';
import '../tools/app_localizations.dart';
import '../tools/app_routes.dart';
import '../tools/auth.dart';

class AuthJailScreen extends StatefulWidget {
  @override
  _AuthJailState createState() => _AuthJailState();

  final bool jailedFromHome;
  const AuthJailScreen({
    Key? key,
    this.jailedFromHome = false,
  }) : super(key: key);
}

class _AuthJailState extends State<AuthJailScreen> {
  late Timer _timer;
  int _lockCountdown = 0;
  bool _initial = true;
  bool _jailedFromRoute = false;

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (_lockCountdown == 0) {
          setState(() {
            timer.cancel();
            onTimerEnd();
          });
        } else {
          setState(() {
            _lockCountdown--;
          });
        }
      },
    );
  }

  void onTimerEnd() async {
    final appSettings = Provider.of<AppSettings>(context, listen: false);
    await appSettings.init();
    await Auth.requireAuth(
      context: context,
      biometricsAllowed: appSettings.biometricsAllowed,
      callback: () async {
        final encrytpedStorage =
            Provider.of<EncryptedBox>(context, listen: false);
        await encrytpedStorage.setFailedAuths(0);
        if (widget.jailedFromHome == true || _jailedFromRoute == true) {
          await Navigator.of(context).pushReplacementNamed(Routes.WalletList);
        } else {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      canCancel: false,
      jailedFromHome: widget.jailedFromHome,
    );
  }

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      _startTimer();
      final encrytpedStorage =
          Provider.of<EncryptedBox>(context, listen: false);
      final failedAuths = await encrytpedStorage.failedAuths;
      _lockCountdown = 10 + (failedAuths * 10);

      //increase number of failed auths
      await encrytpedStorage.setFailedAuths(failedAuths + 1);

      //check if jailedFromHome came again through route
      if (widget.jailedFromHome == false) {
        final jailedFromRoute =
            ModalRoute.of(context)!.settings.arguments as bool?;
        if (jailedFromRoute == true) _jailedFromRoute = true;
      }

      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          color: Theme.of(context).primaryColor,
          child: Container(
            width: double.infinity,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                Icons.lock,
                color: Colors.white,
                size: 48,
              ),
              SizedBox(height: 20),
              Text(AppLocalizations.instance.translate('jail_heading'),
                  style: TextStyle(fontSize: 24, color: Colors.white)),
              SizedBox(height: 20),
              Text(_lockCountdown.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, color: Colors.white)),
              SizedBox(height: 20),
              Text(AppLocalizations.instance.translate('jail_countdown'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, color: Colors.white)),
              SizedBox(height: 20),
              LinearProgressIndicator(
                backgroundColor: Colors.white,
              )
            ]),
          ),
        ),
      ),
    );
  }
}
