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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.primary.withOpacity(0.15);

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
                print("save dialog");
              },
              icon: Icon(Icons.save),
            ),
          )
        ],
      ),
      body: _servers.isEmpty
          ? Container()
          : ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = _servers.removeAt(oldIndex);
                  _servers.insert(newIndex, item);
                });
              },
              children: <Widget>[
                for (int index = 0; index < _servers.length; index++)
                  Card(
                      key: Key('$index'),
                      child: ListTile(
                        leading: Text("#${index + 1}"),
                        trailing: IconButton(
                          onPressed: () => print("hide"),
                          icon: Icon(Icons.visibility_off),
                        ),
                        tileColor: index.isOdd ? oddItemColor : evenItemColor,
                        title: Text(_servers[index].address),
                      )),
              ],
            ),
    );
  }
}
