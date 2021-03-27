import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/functions.dart';
import 'package:flutter_screen_lock/heading_title.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:peercoin/providers/encryptedbox.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:provider/provider.dart';

class Auth {
  static Future<void> executeCallback(
      BuildContext context, Function callback) async {
    if (callback != null) {
      Navigator.pop(context);
      await callback();
      //TODO having a loading animation here would be nicer
    } else {
      Navigator.pop(context);
    }
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
      [Function callback]) async {
    if (biometricsAllowed) {
      await screenLock(
        context: context,
        correctString:
            await Provider.of<EncryptedBox>(context, listen: false).passCode,
        digits: 6,
        maxRetries: 3,
        canCancel: false,
        title: HeadingTitle(
            text: AppLocalizations.instance.translate("authenticate_title")),
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
      );
    } else {
      await screenLock(
        context: context,
        correctString:
            await Provider.of<EncryptedBox>(context, listen: false).passCode,
        digits: 6,
        maxRetries: 3,
        canCancel: false,
        title: HeadingTitle(
            text: AppLocalizations.instance.translate("authenticate_title")),
        confirmTitle: HeadingTitle(
            text: AppLocalizations.instance
                .translate("authenticate_confirm_title")),
        didUnlocked: () {
          executeCallback(context, callback);
        },
      );
    }
  }
}
