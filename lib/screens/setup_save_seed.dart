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
        padding: EdgeInsets.symmetric(horizontal: 30),
        color: Theme.of(context).primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/icon/ppc-icon-white-48.png"),
            SizedBox(height: 30),
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              child: const Text(
                "This is your wallet seed:",
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: SelectableText(
                seed,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    wordSpacing: 10),
              ),
            ),
            SizedBox(height: 30),
            Text(
              "Make sure to keep it safe.\nTreat it like a password.\nThose 12 simple words give full access to your wallet.",
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
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
                    child: const Text(
                      "Continue",
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : TextButton(
                    onPressed: () => shareSeed(seed),
                    child: const Text(
                      "Export now",
                      style: TextStyle(fontSize: 18),
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
