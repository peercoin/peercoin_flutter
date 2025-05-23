import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/hive/server.dart';
import '../../../providers/connection_provider.dart';
import '../../../widgets/service_container.dart';
import '../../../providers/server_provider.dart';
import '../../../tools/app_localizations.dart';
import '../../../tools/app_routes.dart';

class ServerSettingsScreen extends StatefulWidget {
  const ServerSettingsScreen({super.key});

  @override
  State<ServerSettingsScreen> createState() => _ServerSettingsScreenState();
}

class _ServerSettingsScreenState extends State<ServerSettingsScreen> {
  bool _initial = true;
  String _walletName = '';
  List<Server> _servers = [];
  final Map _indexCache = {};
  late ServerProvider _serversProvider;

  @override
  void didChangeDependencies() async {
    if (_initial) {
      _walletName = ModalRoute.of(context)!.settings.arguments as String;
      _serversProvider = Provider.of<ServerProvider>(context);
      await _serversProvider.init(_walletName);
      await loadServers();
      setState(() {
        _initial = false;
      });
    }

    super.didChangeDependencies();
  }

  Future<void> loadServers() async {
    final result = await _serversProvider.getServerDetailsList(_walletName);
    setState(() {
      _servers = result;
    });
  }

  Future<void> savePriorities(String? serverUrl, int newIndex) async {
    if (_indexCache[serverUrl] != null) {
      await context.read<ConnectionProvider>().closeConnection();
    }
    if (newIndex != _indexCache[serverUrl]) {
      _indexCache[serverUrl] = newIndex;
      _servers[newIndex].setPriority = newIndex;
    }
  }

  Color calculateTileColor(int index, bool connectable) {
    final colorScheme = Theme.of(context).colorScheme;
    final oddItemColor = colorScheme.primary.withValues(alpha: 0.10);
    final evenItemColor = colorScheme.primary.withValues(alpha: 0.3);

    if (!connectable) {
      return Theme.of(context).colorScheme.secondary;
    } else if (index.isOdd) {
      return oddItemColor;
    }
    return evenItemColor;
  }

  @override
  void deactivate() {
    Provider.of<ConnectionProvider>(context).init(
      _walletName,
      fromConnectivityChangeOrLifeCycle: true,
    );
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Center(
          child: Text(
            AppLocalizations.instance.translate('server_settings_title'),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: IconButton(
              key: const Key('serverSettingsAddServer'),
              onPressed: () async {
                var result = await Navigator.of(context)
                    .pushNamed(Routes.serverAdd, arguments: _walletName);
                if (result == true) {
                  await loadServers();
                }
              },
              icon: const Icon(Icons.add),
            ),
          ),
        ],
      ),
      body: Align(
        child: PeerContainer(
          noSpacers: true,
          child: _servers.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ReorderableListView.builder(
                  onReorder: (oldIndex, newIndex) {
                    if (_servers[oldIndex].connectable == false) return;
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    setState(() {
                      final item = _servers.removeAt(oldIndex);
                      _servers.insert(newIndex, item);
                    });
                  },
                  itemCount: _servers.length,
                  itemBuilder: (ctx, index) {
                    savePriorities(_servers[index].address, index);
                    return Dismissible(
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) async {
                        if (_servers[index].userGenerated == true) {
                          return await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(
                                AppLocalizations.instance.translate(
                                  'server_settings_alert_generated_title',
                                ),
                              ),
                              content: Text(_servers[index].address),
                              actions: <Widget>[
                                TextButton.icon(
                                  label: Text(
                                    AppLocalizations.instance.translate(
                                      'server_settings_alert_cancel',
                                    ),
                                  ),
                                  icon: const Icon(Icons.cancel),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                                TextButton.icon(
                                  label: Text(
                                    AppLocalizations.instance
                                        .translate('jail_dialog_button'),
                                  ),
                                  icon: const Icon(Icons.check),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            ),
                          );
                        } else {
                          return await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(
                                AppLocalizations.instance.translate(
                                  'server_settings_alert_hardcoded_title',
                                ),
                              ),
                              content: Text(
                                AppLocalizations.instance.translate(
                                  'server_settings_alert_hardcoded_content',
                                ),
                              ),
                              actions: <Widget>[
                                TextButton.icon(
                                  label: Text(
                                    AppLocalizations.instance
                                        .translate('jail_dialog_button'),
                                  ),
                                  icon: const Icon(Icons.check),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      onDismissed: (_) {
                        _serversProvider.removeServer(_servers[index]);
                        setState(() {
                          _servers.remove(_servers[index]);
                        });
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 10),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 4,
                        ),
                        color: Theme.of(context).colorScheme.error,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      key: Key(_servers[index].address),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.toc),
                              if (!_servers[index].userGenerated)
                                const Icon(Icons.delete_forever),
                            ],
                          ),
                          trailing: IconButton(
                            onPressed: () async {
                              final oldItem = _servers[index];
                              setState(() {
                                //toggle connectable
                                _servers[index].setConnectable =
                                    !_servers[index].connectable;
                              });
                              //check if still one connectable server is left
                              if (_servers.firstWhereOrNull(
                                    (element) => element.connectable == true,
                                  ) ==
                                  null) {
                                //show snack bar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.instance.translate(
                                        'server_settings_error_no_server_left',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );

                                //reset connectable
                                oldItem.setConnectable = true;
                              }
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
                            },
                            icon: Icon(
                              _servers[index].connectable
                                  ? Icons.offline_bolt
                                  : Icons.offline_bolt_outlined,
                            ),
                          ),
                          tileColor: calculateTileColor(
                            index,
                            _servers[index].connectable,
                          ),
                          title: Text(
                            _servers[index].address,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
