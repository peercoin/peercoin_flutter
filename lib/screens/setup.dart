import "package:flutter/material.dart";
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/screens/setup_save_seed.dart';
import 'package:peercoin/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class SetupScreen extends StatefulWidget {
  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  bool _loading = false;
  void createWallet(context) async {
    setState(() {
      _loading = true;
    });
    ActiveWallets _activeWallets =
        Provider.of<ActiveWallets>(context, listen: false);
    await _activeWallets.init();
    await _activeWallets.createPhrase();
    await Navigator.of(context).popAndPushNamed(SetupSaveScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              child: const Text(
                "Setup",
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () => {createWallet(context)},
              child: _loading ? LoadingIndicator() : Text("Create Wallet"),
            )
          ],
        ),
      ),
    );
  }
}
