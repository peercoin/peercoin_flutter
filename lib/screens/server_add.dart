import 'dart:convert';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:peercoin/models/availablecoins.dart';
import 'package:peercoin/models/server.dart';
import 'package:peercoin/providers/electrumconnection.dart';
import 'package:peercoin/providers/servers.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';

class ServerAddScreen extends StatefulWidget {
  @override
  _ServerAddScreenState createState() => _ServerAddScreenState();
}

class _ServerAddScreenState extends State<ServerAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverKey = GlobalKey<FormFieldState>();
  final _serverController = TextEditingController();
  String _walletName = '';
  List<Server> _currentServerList = [];
  bool _initial = true;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    if (_initial) {
      _walletName = ModalRoute.of(context)!.settings.arguments as String;
      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  void tryConnect(String serverUrl) async {
    _currentServerList = await Provider.of<Servers>(context, listen: false)
        .getServerDetailsList(_walletName);

    setState(() {
      _loading = true;
    });

    //check if server already exists
    if (_currentServerList
            .firstWhereOrNull((element) => element.address == serverUrl) !=
        null) {
      //show notification
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          AppLocalizations.instance.translate('server_add_server_exists'),
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 2),
      ));
    } else {
      //continue: try to connect
      FlutterLogs.logInfo('ServerAdd', 'tryConnect', 'trying to connect');

      //close original server connection
      await Provider.of<ElectrumConnection>(context, listen: false)
          .closeConnection();

      //try new connection
      var _connection;
      try {
        _connection = IOWebSocketChannel.connect(
          serverUrl,
        );
      } catch (e) {
        FlutterLogs.logError(
          'ServerAdd',
          'tryConnect',
          e.toString(),
        );
      }

      void sendMessage(String method, String id, [List? params]) {
        if (_connection != null) {
          _connection.sink.add(
            json.encode(
              {
                'id': id,
                'method': method,
                if (params != null) 'params': params
              },
            ),
          );
        }
      }

      void replyHandler(reply) {
        var decoded = json.decode(reply);
        var id = decoded['id'];
        var idString = id.toString();
        var result = decoded['result'];

        if (idString == 'features') {
          if (result['genesis_hash'] ==
              AvailableCoins().getSpecificCoin(_walletName).genesisHash) {
            //gensis hash matches
            //add server to db
            Provider.of<Servers>(context, listen: false)
                .addServer(serverUrl, true);
            //pop screen
            Navigator.of(context).pop(true);
          } else {
            //gensis hash doesn't match
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                AppLocalizations.instance
                    .translate('server_add_server_wrong_genesis'),
                textAlign: TextAlign.center,
              ),
              duration: Duration(seconds: 2),
            ));
          }
        }
        setState(() {
          _loading = false;
        });
      }

      _connection.stream.listen((elem) {
        replyHandler(elem);
      }, onError: (error) {
        FlutterLogs.logError(
          'ServerAdd',
          'tryConnect',
          error.message,
        );
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            AppLocalizations.instance
                .translate('server_add_server_no_connection'),
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 2),
        ));
      });

      sendMessage('server.features', 'features');
    }
  }

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
                _formKey.currentState!.save();
                _formKey.currentState!.validate();
              },
              icon: Icon(Icons.save),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                    textInputAction: TextInputAction.done,
                    key: _serverKey,
                    autocorrect: false,
                    controller: _serverController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.outbond),
                      labelText: AppLocalizations.instance
                          .translate('server_add_input_label'),
                    ),
                    maxLines: null,
                    onFieldSubmitted: (_) => _formKey.currentState!.validate(),
                    inputFormatters: [],
                    validator: (value) {
                      var portRegex = RegExp(':[0-9]');

                      if (value!.isEmpty) {
                        return AppLocalizations.instance
                            .translate('server_add_input_empty');
                      } else if (!value.contains('wss://')) {
                        return AppLocalizations.instance
                            .translate('server_add_no_wss');
                      } else if (!portRegex.hasMatch(value)) {
                        return AppLocalizations.instance
                            .translate('server_add_no_port');
                      }
                      //valid string, try further

                      tryConnect(value);

                      return null;
                    }),
                if (_loading)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: LoadingIndicator(),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
