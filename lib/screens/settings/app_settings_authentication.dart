import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:peercoin/screens/settings/settings_helpers.dart';
import 'package:provider/provider.dart';

import '../../providers/app_settings.dart';
import '../../tools/app_localizations.dart';
import '../../tools/auth.dart';
import '../../widgets/service_container.dart';
import '../../widgets/settings/settings_auth.dart';

class AppSettingsAuthenticationScreen extends StatefulWidget {
  const AppSettingsAuthenticationScreen({super.key});

  @override
  State<AppSettingsAuthenticationScreen> createState() =>
      _AppSettingsAuthenticationScreenState();
}

class _AppSettingsAuthenticationScreenState
    extends State<AppSettingsAuthenticationScreen> {
  bool _initial = true;
  late AppSettings _settings;
  late bool _biometricsAllowed;
  bool _biometricsAvailable = false;

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      _settings = Provider.of<AppSettings>(context);
      var localAuth = LocalAuthentication();

      _biometricsAvailable =
          kIsWeb ? false : await localAuth.canCheckBiometrics;
      if (_biometricsAvailable == false) {
        _settings.setBiometricsAllowed(false);
      }

      // ignore: use_build_context_synchronously
      await Auth.requireAuth(
        context: context,
        canCancel: false,
        biometricsAllowed: _settings.biometricsAllowed,
        callback: () => setState(
          () {
            _initial = false;
          },
        ),
      );
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (_initial == true) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    _biometricsAllowed = _settings.biometricsAllowed;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.instance.translate('app_settings_auth_header'),
        ),
      ),
      body: SingleChildScrollView(
        child: Align(
          child: PeerContainer(
            noSpacers: true,
            child: SettingsAuth(
              _biometricsAllowed,
              _biometricsAvailable,
              _settings,
              saveSnack,
              _settings.authenticationOptions!,
            ),
          ),
        ),
      ),
    );
  }
}
