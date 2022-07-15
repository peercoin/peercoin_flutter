import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/functions.dart';
import 'package:provider/provider.dart';

import '../../providers/app_settings.dart';
import '../../providers/encrypted_box.dart';
import '../../tools/app_localizations.dart';
import '../../tools/auth.dart';
import '../buttons.dart';

class SettingsAuth extends StatelessWidget {
  final bool _biometricsAllowed;
  final bool _biometricsAvailable;
  final AppSettings _settings;
  final Function _saveSnack;
  final Map<String, bool> _authenticationOptions;

  const SettingsAuth(this._biometricsAllowed, this._biometricsAvailable,
      this._settings, this._saveSnack, this._authenticationOptions,
      {Key? key})
      : super(key: key);

  void changePIN(BuildContext context, bool biometricsAllowed) async {
    await Auth.requireAuth(
      context: context,
      biometricsAllowed: biometricsAllowed,
      callback: () async => await screenLock(
        title: Text(
          AppLocalizations.instance.translate('authenticate_title_new'),
          style: const TextStyle(
            fontSize: 24,
          ),
        ),
        confirmTitle: Text(
          AppLocalizations.instance.translate('authenticate_confirm_title_new'),
          style: const TextStyle(
            fontSize: 24,
          ),
        ),
        context: context,
        correctString: '',
        digits: 6,
        confirmation: true,
        didConfirmed: (matchedText) async {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);
          await context.read<EncryptedBox>().setPassCode(matchedText);
          scaffoldMessenger.showSnackBar(SnackBar(
            content: Text(
              AppLocalizations.instance
                  .translate('authenticate_change_pin_success'),
              textAlign: TextAlign.center,
            ),
            duration: const Duration(seconds: 2),
          ));
          navigator.pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
            title: Text(
              AppLocalizations.instance.translate('app_settings_biometrics'),
            ),
            value: _biometricsAllowed,
            onChanged: (newState) {
              if (_biometricsAvailable == false) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    AppLocalizations.instance
                        .translate('setup_pin_no_biometrics'),
                    textAlign: TextAlign.center,
                  ),
                  duration: const Duration(seconds: 5),
                ));
              } else {
                _settings.setBiometricsAllowed(newState);
                _saveSnack(context);
              }
            }),
        SwitchListTile(
            title: Text(
              AppLocalizations.instance.translate('app_settings_walletList'),
            ),
            value: _authenticationOptions['walletList']!,
            onChanged: (newState) {
              _settings.setAuthenticationOptions('walletList', newState);
              _saveSnack(context);
            }),
        SwitchListTile(
            title: Text(
              AppLocalizations.instance.translate('app_settings_walletHome'),
            ),
            value: _authenticationOptions['walletHome']!,
            onChanged: (newState) {
              _settings.setAuthenticationOptions('walletHome', newState);
              _saveSnack(context);
            }),
        SwitchListTile(
            title: Text(
              AppLocalizations.instance
                  .translate('app_settings_sendTransaction'),
            ),
            value: _authenticationOptions['sendTransaction']!,
            onChanged: (newState) {
              _settings.setAuthenticationOptions('sendTransaction', newState);
              _saveSnack(context);
            }),
        SwitchListTile(
            title: Text(
              AppLocalizations.instance.translate('app_settings_newWallet'),
            ),
            value: _authenticationOptions['newWallet']!,
            onChanged: (newState) {
              _settings.setAuthenticationOptions('newWallet', newState);
              _saveSnack(context);
            }),
        PeerButton(
          action: () => changePIN(context, _settings.biometricsAllowed),
          text: AppLocalizations.instance.translate('app_settings_changeCode'),
        )
      ],
    );
  }
}
