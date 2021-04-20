import 'package:flutter/material.dart';
import 'package:peercoin/tools/app_localizations.dart';

class ServerAddScreen extends StatefulWidget {
  @override
  _ServerAddScreenState createState() => _ServerAddScreenState();
}

class _ServerAddScreenState extends State<ServerAddScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            AppLocalizations.instance.translate('server_add_title'),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: IconButton(
              onPressed: () {
                print("save");
              },
              icon: Icon(Icons.save),
            ),
          )
        ],
      ),
    );
  }
}
