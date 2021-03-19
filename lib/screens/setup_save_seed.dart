import 'dart:async';

import 'package:flutter/material.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/providers/options.dart';
import 'package:peercoin/screens/wallet_list.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class SetupSaveScreen extends StatefulWidget {
  static const routeName = "/setup-save-seed";

  @override
  _SetupSaveScreenState createState() => _SetupSaveScreenState();
}

class _SetupSaveScreenState extends State<SetupSaveScreen> {
  bool sharedYet = false;
  String seed = "";

  Future<void> shareSeed(seed) async {
    await Share.share(seed);
    Timer(
      Duration(seconds: 2),
      () => setState(() {
        sharedYet = true;
      }),
    );
  }

  @override
  void didChangeDependencies() async {
    var thisSeed = await Provider.of<ActiveWallets>(context).seedPhrase;
    setState(() {
      seed = thisSeed;
    });
    super.didChangeDependencies();
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
                "Save your seed",
                style: TextStyle(color: Colors.white),
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.all(50),
                child: SelectableText(
                  seed,
                  style: TextStyle(color: Colors.white70, wordSpacing: 10),
                ),
              ),
            ),
            sharedYet
                ? TextButton(
                    onPressed: () async {
                      var prefs =
                          await Provider.of<Options>(context, listen: false)
                              .prefs;
                      await prefs.setBool("setupFinished", true);
                      Navigator.popAndPushNamed(
                          context, WalletListScreen.routeName);
                    },
                    child: const Text("Continue"),
                  )
                : TextButton(
                    onPressed: () => shareSeed(seed),
                    child: const Text("Export"),
                  )
          ],
        ),
      ),
    );
  }
}
