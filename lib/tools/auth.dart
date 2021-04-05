import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/functions.dart';
import 'package:flutter_screen_lock/heading_title.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:peercoin/providers/encryptedbox.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:provider/provider.dart';

class Auth {
  static const int maxRetries = 3;
  static const int retriesLeft = 3;
  //TODO count retries left in secure storage

  static Future<void> executeCallback(
      BuildContext context, Function callback) async {
    //reset unsuccesful login counter
    await Provider.of<EncryptedBox>(context, listen: false).setFailedAuths(0);

    if (callback != null) {
      Navigator.pop(context);
      await callback();
      //TODO having a loading animation here would be nicer
    } else {
      Navigator.pop(context);
    }
  }

  static void errorHandler(BuildContext context, int retries) async {
    if (retries == retriesLeft - 1) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              AppLocalizations.instance
                  .translate('authenticate_retry_warning_title'),
              textAlign: TextAlign.center,
            ),
            content: Text(
              AppLocalizations.instance
                  .translate('authenticate_retry_warning_text'),
            ),
            actions: [
              TextButton(
                child: Text(
                  AppLocalizations.instance.translate('jail_dialog_button'),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  static Future<void> spawnJail(
      BuildContext context, bool jailedFromHome) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              AppLocalizations.instance.translate('jail_dialog_title'),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                child: Text(
                  AppLocalizations.instance.translate('jail_dialog_button'),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
    Navigator.of(context)
        .pushReplacementNamed(Routes.AuthJail, arguments: jailedFromHome);
  }

  static Future<void> localAuth(BuildContext context,
      [Function callback]) async {
    final localAuth = LocalAuthentication();
    final authStrings = AndroidAuthMessages(
      signInTitle:
          AppLocalizations.instance.translate('authenticate_biometric_title'),
      biometricHint:
          AppLocalizations.instance.translate('authenticate_biometric_hint'),
    );
    try {
      final didAuthenticate = await localAuth.authenticate(
          androidAuthStrings: authStrings,
          biometricOnly: true,
          localizedReason: AppLocalizations.instance
              .translate('authenticate_biometric_reason'),
          stickyAuth: true);
      if (didAuthenticate) {
        executeCallback(context, callback);
      }
    } catch (e) {
      localAuth.stopAuthentication();
    }
  }

  static Future<void> requireAuth(BuildContext context, bool biometricsAllowed,
      [Function callback,
      bool canCancel = true,
      bool jailedFromHome = false]) async {
    if (biometricsAllowed) {
      await screenLock(
        context: context,
        correctString:
            await Provider.of<EncryptedBox>(context, listen: false).passCode,
        digits: 6,
        maxRetries: retriesLeft,
        canCancel: canCancel,
        title: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: AppLocalizations.instance.translate("authenticate_title"),
                style: TextStyle(
                  fontSize: 24,
                ),
                children: [
                  TextSpan(
                    text: AppLocalizations.instance.translate(
                      retriesLeft > 1
                          ? "authenticate_subtitle_plural"
                          : "authenticate_subtitle_singular",
                      {"retriesLeft": retriesLeft.toString()},
                    ),
                    style: TextStyle(fontSize: 14),
                  )
                ])),
        confirmTitle: HeadingTitle(
            text: AppLocalizations.instance
                .translate("authenticate_confirm_title")),
        customizedButtonChild: Icon(
          Icons.fingerprint,
        ),
        customizedButtonTap: () async {
          await localAuth(context, callback);
        },
        didOpened: () async {
          await localAuth(context, callback);
        },
        didUnlocked: () {
          executeCallback(context, callback);
        },
        didError: (retries) => errorHandler(context, retries),
        didMaxRetries: (_) async {
          spawnJail(context, jailedFromHome);
        },
      );
    } else {
      await screenLock(
        context: context,
        correctString:
            await Provider.of<EncryptedBox>(context, listen: false).passCode,
        digits: 6,
        maxRetries: retriesLeft,
        canCancel: canCancel,
        title: HeadingTitle(
            text: AppLocalizations.instance.translate(
          "authenticate_title",
          {
            "retriesLeft": retriesLeft.toString(),
          },
        )),
        confirmTitle: HeadingTitle(
            text: AppLocalizations.instance
                .translate("authenticate_confirm_title")),
        didUnlocked: () {
          executeCallback(context, callback);
        },
        didError: (retries) => errorHandler(context, retries),
        didMaxRetries: (_) async {
          spawnJail(context, jailedFromHome);
        },
      );
    }
  }
}
