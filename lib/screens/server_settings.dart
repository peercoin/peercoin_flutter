import 'package:flutter/material.dart';
import 'package:peercoin/models/server.dart';
import 'package:peercoin/providers/servers.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:provider/provider.dart';

class ServerSettingsScreen extends StatefulWidget {
  @override
  _ServerSettingsScreenState createState() => _ServerSettingsScreenState();
}

class _ServerSettingsScreenState extends State<ServerSettingsScreen> {
  bool _initial = true;
  String _walletName = "";
  List<Server> _servers = [];

  @override
  void didChangeDependencies() async {
    if (_initial) {
      _walletName = ModalRoute.of(context).settings.arguments;
      _servers =
          await Provider.of<Servers>(context).getServerDetailsList(_walletName);
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
        title: Center(
          child: Text(
            AppLocalizations.instance.translate('server_settings_title'),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: IconButton(
              onPressed: () {
                print("new server dialog");
              },
              icon: Icon(Icons.add),
            ),
          )
        ],
      ),
      body: _servers.isEmpty
          ? Container()
          : ListView.builder(
              itemCount: _servers.length,
              itemBuilder: (ctx, i) {
                print(_servers[i]);
                return Card(
                  child: ListTile(
                    title: Text(_servers[i].address),
                  ),
                );
              }),
    );
  }
}
