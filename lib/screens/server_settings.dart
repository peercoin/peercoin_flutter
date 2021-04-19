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
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                print("newIndex: $newIndex");
                print(_servers);
                setState(() {
                  final item = _servers.removeAt(oldIndex);
                  _servers.insert(newIndex,
                      item); //TODO doesn't work does not move item that was pushed away
                  //TODO call save priorities to save ALL values, not just the one that was changed
                  // item.setPriority = newIndex;
                });
              },
              children: <Widget>[
                for (int index = 0; index < _servers.length; index++)
                  Card(
                      key: Key('$index'),
                      child: ListTile(
                        leading: Icon(Icons.toc),
                        trailing: IconButton(
                          onPressed: () {
                            setState(() {
                              //toggle connectable
                              _servers[index].setConnectable =
                                  !_servers[index].connectable;
                              //connectable now false ? move to bottom of list
                              if (!_servers[index].connectable) {
                                final item = _servers.removeAt(index);
                                _servers.insert(_servers.length, item);
                                _servers[index].setPriority =
                                    _servers.length - 1;
                              } else {
                                final item = _servers.removeAt(index);
                                _servers.insert(0, item);
                                _servers[index].setPriority = 0;
                              }
                            });
                            //check if still one connectable server is left
                            //show snack bar
                            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            //   content: Text(
                            //     AppLocalizations.instance.translate(
                            //         "authenticate_change_pin_success"),
                            //     textAlign: TextAlign.center,
                            //   ),
                            //   duration: Duration(seconds: 2),
                            // ));

                            //turn tile grey
                          },
                          icon: Icon(_servers[index].connectable
                              ? Icons.offline_bolt
                              : Icons.offline_bolt_outlined),
                        ),
                        tileColor: index.isOdd ? oddItemColor : evenItemColor,
                        title: Text(_servers[index].address),
                      )),
              ],
            ),
    );
  }
}
