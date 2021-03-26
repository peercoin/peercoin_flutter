import 'package:flutter/material.dart';

class SetupImportSeed extends StatefulWidget {
  @override
  _SetupImportSeedState createState() => _SetupImportSeedState();
}

class _SetupImportSeedState extends State<SetupImportSeed> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Container(
        width: double.infinity,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(
            "assets/icon/ppc-icon-white-256.png",
            width: 50,
          ),
          SizedBox(height: 60),
        ]),
      ),
    );
  }
}
