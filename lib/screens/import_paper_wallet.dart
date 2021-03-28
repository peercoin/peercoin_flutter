import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peercoin/tools/app_localizations.dart';

class ImportPaperWalletScreen extends StatefulWidget {
  @override
  _ImportPaperWalletScreenState createState() =>
      _ImportPaperWalletScreenState();
}

class _ImportPaperWalletScreenState extends State<ImportPaperWalletScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.instance.translate("wallet_pop_menu_paperwallet"),
        ),
      ),
      body: Column(
        children: [Text("hi")],
      ),
    );
  }
}
