import 'package:flutter/material.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/app_drawer.dart';

class AboutScren extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.instance.translate('about'),
        ),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(children: []),
        ),
      ),
    );
  }
}
