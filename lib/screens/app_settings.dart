import "package:flutter/material.dart";
import 'package:peercoin/app_localizations.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/providers/options.dart';
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
  bool _showMetadata = false;

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      _seedPhrase =
          await Provider.of<ActiveWallets>(context, listen: false).seedPhrase;
      _showMetadata = await Provider.of<Options>(context, listen: false).allowMetaData;
      setState(() {
        _initial = false;
      });
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.instance.translate('setting_title', null)),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              AppLocalizations.instance.translate('setting_seed', null),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SelectableText(_seedPhrase),
            CheckboxListTile(
              value: _showMetadata,
              onChanged: (value) {
                setState(() {
                  _showMetadata = value;
                  Provider.of<Options>(context, listen: false).setAllowMetaData(value);
                });
              },
              title: Text(AppLocalizations.instance.translate('setting_metadata', null)),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10
              ),
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
