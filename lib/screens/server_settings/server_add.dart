// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:peercoin/widgets/service_container.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../models/available_coins.dart';
import '../../models/server.dart';
import '../../providers/electrum_connection.dart';
import '../../providers/servers.dart';
import '../../tools/app_localizations.dart';
import '../../tools/logger_wrapper.dart';
import '../../widgets/loading_indicator.dart';

class ServerAddScreen extends StatefulWidget {
  const ServerAddScreen({Key? key}) : super(key: key);

  @override
  _ServerAddScreenState createState() => _ServerAddScreenState();
}

class _ServerAddScreenState extends State<ServerAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverKey = GlobalKey<FormFieldState>();
  final _serverController = TextEditingController();
  String _walletName = '';
  late ElectrumServerType _serverType;
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

  void tryConnect(String _serverUrl) async {
    _currentServerList = await Provider.of<Servers>(context, listen: false)
        .getServerDetailsList(_walletName);

    setState(() {
      _loading = true;
    });

    //check if server already exists
    if (_currentServerList
            .firstWhereOrNull((element) => element.address == _serverUrl) !=
        null) {
      //show notification
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          AppLocalizations.instance.translate('server_add_server_exists'),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 2),
      ));
    } else {
      //continue: try to connect
      LoggerWrapper.logInfo('ServerAdd', 'tryConnect', 'trying to connect');

      //close original server connection
      await Provider.of<ElectrumConnection>(context, listen: false)
          .closeConnection();

      //try new connection
      var _connection;
      try {
        if (_serverUrl.contains('wss://')) {
          _serverType = ElectrumServerType.wss;
          _connection = WebSocketChannel.connect(
            Uri.parse(_serverUrl),
          );
        } else if (_serverUrl.contains('ssl://') && kIsWeb == false) {
          _serverType = ElectrumServerType.ssl;

          final split = _serverUrl.split(':');
          final host = split[1].replaceAll('//', '');
          final port = int.parse(split[2]);
          _connection = await SecureSocket.connect(
            host,
            port,
            timeout: const Duration(seconds: 10),
          );
        }
      } catch (e) {
        displayError(e);
        LoggerWrapper.logError(
          'ServerAdd',
          'tryConnect',
          e.toString(),
        );
      }

      void sendMessage(String method, String? id, [List? params]) {
        final String _encodedMessage = json.encode(
          {'id': id, 'method': method, if (params != null) 'params': params},
        );
        if (_connection != null) {
          if (_serverType == ElectrumServerType.ssl) {
            _connection.add(_encodedMessage.codeUnits);
            _connection.add('\n'.codeUnits);
          } else if (_serverType == ElectrumServerType.wss) {
            _connection!.sink.add(_encodedMessage);
          }
        }
      }

      void replyHandler(reply) {
        String parsedReply;
        if (reply is Uint8List) {
          parsedReply = String.fromCharCodes(reply);
        } else {
          parsedReply = reply;
        }

        var decoded = json.decode(parsedReply);
        var id = decoded['id'];
        var idString = id.toString();
        var result = decoded['result'];

        if (idString == 'features') {
          if (result['genesis_hash'] ==
              AvailableCoins().getSpecificCoin(_walletName).genesisHash) {
            //gensis hash matches
            //add server to db
            Provider.of<Servers>(context, listen: false).addServer(
              _serverUrl,
              true,
            );
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
              duration: const Duration(seconds: 2),
            ));
          }
        }
        setState(() {
          _loading = false;
        });
      }

      var stream;
      if (_serverType == ElectrumServerType.ssl) {
        stream = _connection;
      } else if (_serverType == ElectrumServerType.wss) {
        stream = _connection!.stream;
      }

      if (stream == null) return;

      stream.listen((elem) {
        replyHandler(elem);
      }, onError: (error) {
        displayError(error);
      });

      sendMessage('server.features', 'features');
    }
  }

  void displayError(dynamic error) {
    LoggerWrapper.logError(
      'ServerAdd',
      'tryConnect',
      error.message,
    );
    setState(() {
      _loading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.instance
              .translate('server_add_server_no_connection'),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
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
              icon: const Icon(Icons.save),
            ),
          )
        ],
      ),
      body: Align(
        child: PeerContainer(
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
                        icon: const Icon(Icons.outbond),
                        labelText: AppLocalizations.instance
                            .translate('server_add_input_label'),
                      ),
                      maxLines: null,
                      onFieldSubmitted: (_) =>
                          _formKey.currentState!.validate(),
                      validator: (value) {
                        var portRegex = RegExp(':[0-9]');

                        if (value!.isEmpty) {
                          return AppLocalizations.instance
                              .translate('server_add_input_empty');
                        } else if (kIsWeb && !value.contains('wss://')) {
                          return AppLocalizations.instance
                              .translate('server_add_no_wss');
                        } else if (!kIsWeb &&
                            !value.contains('wss://') &&
                            !value.contains('ssl://')) {
                          return AppLocalizations.instance
                              .translate('server_add_no_wss_or_ssl');
                        } else if (!portRegex.hasMatch(value)) {
                          return AppLocalizations.instance
                              .translate('server_add_no_port');
                        }
                        //valid string, try further

                        tryConnect(value);

                        return null;
                      }),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: LoadingIndicator(),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
