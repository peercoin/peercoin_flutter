import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/functions.dart';
import 'package:flutter_screen_lock/heading_title.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../providers/encrypted_box.dart';
import 'app_localizations.dart';
import 'app_routes.dart';

class Auth {
  static const int maxRetries = 3;
  static int retriesLeft = maxRetries;
  static int failedAuthAttempts = 0;

  static Future<void> executeCallback(
      BuildContext context, Function? callback) async {
    //reset unsuccesful login and attempt counter
    final encryptedBox = context.read<EncryptedBox>();
    final navigator = Navigator.of(context);

    await encryptedBox.setFailedAuths(0);
    await encryptedBox.setFailedAuthAttempts(0);
    retriesLeft = maxRetries;
    failedAuthAttempts = 0;

    if (callback != null) {
      navigator.pop();
      await callback();
      //TODO having a loading animation here would be nicer
    } else {
      navigator.pop();
    }
  }

  static void errorHandler(BuildContext context, int retries) async {
    final encryptedBox = context.read<EncryptedBox>();

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
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  AppLocalizations.instance.translate('jail_dialog_button'),
                ),
              ),
            ],
          );
        },
      );
    }
    failedAuthAttempts = await encryptedBox.failedAuthAttempts;
    await encryptedBox.setFailedAuthAttempts(failedAuthAttempts + 1);
  }

  static Future<void> spawnJail(
      BuildContext context, bool jailedFromHome) async {
    final navigator = Navigator.of(context);
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
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  AppLocalizations.instance.translate('jail_dialog_button'),
                ),
              ),
            ],
          );
        });
    await navigator.pushReplacementNamed(Routes.authJail,
        arguments: jailedFromHome);
  }

  static Future<void> localAuth(BuildContext context,
      [Function? callback]) async {
    final localAuth = LocalAuthentication();
    final authStrings = AndroidAuthMessages(
      signInTitle:
          AppLocalizations.instance.translate('authenticate_biometric_title'),
      biometricHint:
          AppLocalizations.instance.translate('authenticate_biometric_hint'),
    );
    Future<void> executeCB() async => executeCallback(context, callback);
    try {
      final didAuthenticate = await localAuth.authenticate(
          androidAuthStrings: authStrings,
          biometricOnly: true,
          localizedReason: AppLocalizations.instance
              .translate('authenticate_biometric_reason'),
          stickyAuth: true);
      if (didAuthenticate) {
        await executeCB();
      }
    } catch (e) {
      await localAuth.stopAuthentication();
    }
  }

  static Future<void> requireAuth({
    required BuildContext context,
    required bool biometricsAllowed,
    Function? callback,
    bool canCancel = true,
    bool jailedFromHome = false,
  }) async {
    final encryptedBox = Provider.of<EncryptedBox>(context, listen: false);
    failedAuthAttempts = await encryptedBox.failedAuthAttempts;
    retriesLeft = (maxRetries - failedAuthAttempts);
    if (retriesLeft <= 0) retriesLeft = 1;

    await screenLock(
      context: context,
      correctString: await encryptedBox.passCode as String,
      digits: 6,
      maxRetries: retriesLeft,
      canCancel: canCancel,
      title: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: AppLocalizations.instance.translate('authenticate_title'),
          style: const TextStyle(
            fontSize: 24,
          ),
          children: [
            TextSpan(
              text: '\n${AppLocalizations.instance.translate(
                retriesLeft == 1
                    ? 'authenticate_subtitle_singular'
                    : 'authenticate_subtitle_plural',
                {'retriesLeft': retriesLeft.toString()},
              )}',
              style: const TextStyle(fontSize: 14),
            )
          ],
        ),
      ),
      confirmTitle: HeadingTitle(
          text: AppLocalizations.instance
              .translate('authenticate_confirm_title')),
      customizedButtonChild: biometricsAllowed
          ? const Icon(
              Icons.fingerprint,
            )
          : Container(),
      customizedButtonTap: () async {
        if (biometricsAllowed) await localAuth(context, callback);
      },
      didOpened: () async {
        if (biometricsAllowed) await localAuth(context, callback);
      },
      didUnlocked: () {
        executeCallback(context, callback);
      },
      didError: (retries) => errorHandler(context, retries),
      didMaxRetries: (_) async {
        await spawnJail(context, jailedFromHome);
      },
    );
  }
}
