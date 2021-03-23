import "package:flutter/material.dart";
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

class AppSettingsScreen extends StatefulWidget {
  static const routeName = "/app-settings";

  @override
  _AppSettingsScreenState createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _initial = true;
  String _seedPhrase = "";
  bool _biometricsAllowed;
  AppSettings _settings;

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      _seedPhrase =
          await Provider.of<ActiveWallets>(context, listen: false).seedPhrase;
      setState(() {
        _initial = false;
      });
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _settings = context.watch<AppSettings>();
    _biometricsAllowed = _settings.biometricsAllowed ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text("App Settings"),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "Authentification",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            SwitchListTile(
                title: Text(
                  AppLocalizations.instance.translate('setup_pin_biometrics'),
                ),
                value: _biometricsAllowed,
                onChanged: (newState) {
                  _settings.setBiometricsAllowed(newState);
                }),
            Divider(),
            SizedBox(height: 10),
            Text(
              "Your seed phrase:\n",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SelectableText(_seedPhrase)
          ],
        ),
      ),
    );
  }
}
