import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/functions.dart';
import 'package:flutter_screen_lock/heading_title.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:peercoin/providers/encryptedbox.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:provider/provider.dart';

class Auth {
  static Future<void> localAuth(BuildContext context) async {
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
        Navigator.pop(context);
      }
    } catch (e) {
      localAuth.stopAuthentication();
    }
  }

  static Future<bool> requireAuth(
      BuildContext context, bool biometricsAllowed) async {
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
          await localAuth(context);
        },
        didOpened: () async {
          await localAuth(context);
        },
        didUnlocked: () {
          Navigator.pop(context);
          return true;
        },
        didMaxRetries: (_) {
          return false;
        },
      );
      return false;
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
          Navigator.pop(context);
          return true;
        },
        didMaxRetries: (_) {
          return false;
        },
      );
      return false;
    }
  }
}
