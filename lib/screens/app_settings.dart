import "package:flutter/material.dart";
import 'package:peercoin/providers/activewallets.dart';
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
