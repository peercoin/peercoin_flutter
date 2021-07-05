import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/functions.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/providers/encryptedbox.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/auth.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:provider/provider.dart';

class SettingsAuth extends StatelessWidget {
  final bool _biometricsAllowed;
  final bool _biometricsAvailable;
  final AppSettings _settings;
  final Function _saveSnack;
  final Map<String, bool> _authenticationOptions;

  SettingsAuth(
    this._biometricsAllowed,
    this._biometricsAvailable,
    this._settings,
    this._saveSnack,
    this._authenticationOptions,
  );

  void changePIN(BuildContext context, bool biometricsAllowed) async {
    await Auth.requireAuth(
      context,
      biometricsAllowed,
      () async => await screenLock(
        title: Text(
          AppLocalizations.instance.translate('authenticate_title_new'),
          style: TextStyle(
            fontSize: 24,
          ),
        ),
        confirmTitle: Text(
          AppLocalizations.instance.translate('authenticate_confirm_title_new'),
          style: TextStyle(
            fontSize: 24,
          ),
        ),
        context: context,
        correctString: '',
        digits: 6,
        confirmation: true,
        didConfirmed: (matchedText) async {
          await Provider.of<EncryptedBox>(context, listen: false)
              .setPassCode(matchedText);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              AppLocalizations.instance
                  .translate('authenticate_change_pin_success'),
              textAlign: TextAlign.center,
            ),
            duration: Duration(seconds: 2),
          ));
          Navigator.of(context).pop();
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
                  duration: Duration(seconds: 5),
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
