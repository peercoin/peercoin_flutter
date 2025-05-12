import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart' as frost;
import 'package:peercoin/generated/marisma.pbgrpc.dart';
import 'package:peercoin/models/hive/coin_wallet.dart';
import 'package:peercoin/models/hive/roast_wallet.dart';
import 'package:peercoin/models/roast_storage.dart';
import 'package:peercoin/providers/wallet_provider.dart';
import 'package:peercoin/screens/wallet/standard_and_watch_only_wallet_home.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:peercoin/tools/marisma_client.dart';
import 'package:peercoin/tools/taproot_transaction_final_assembly.dart';
import 'package:peercoin/widgets/wallet/roast_group/login_status.dart';
import 'package:peercoin/widgets/wallet/roast_group/setup_landing.dart';
import 'package:peercoin/widgets/wallet/roast_group/tabs/completed_keys_tab.dart';
import 'package:peercoin/widgets/wallet/roast_group/tabs/open_request_tab.dart';
import 'package:peercoin/widgets/wallet/roast_group/tabs/request_dkg_tab.dart';
import 'package:peercoin/widgets/wallet/roast_group/tabs/request_signature_tab.dart';
import 'package:peercoin/widgets/wallet/wallet_home/wallet_delete_watch_only_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class RoastWalletHomeScreenArguments {
  CoinWallet coinWallet;

  RoastWalletHomeScreenArguments({
    required this.coinWallet,
  });
}

class ROASTWalletHomeScreen extends StatefulWidget {
  const ROASTWalletHomeScreen({super.key});

  @override
  State<ROASTWalletHomeScreen> createState() => _ROASTWalletHomeScreenState();
}

enum ROASTWalletTab { openRequests, generatedKeys, newDKG, newSignature }

enum ROASTLoginStatus {
  loggedIn,
  loggedOut,
  noServer,
}

class _ROASTWalletHomeScreenState extends State<ROASTWalletHomeScreen> {
  bool _initial = true;
  bool _walletIsComplete = false;
  ROASTLoginStatus _loginStatus = ROASTLoginStatus.loggedOut;
  DateTime _lastUpdate = DateTime.now();
  ROASTWalletTab _selectedTab = ROASTWalletTab.openRequests;
  int _numberOfOnlineParticipants = 0;
  late ROASTWallet _roastWallet;
  late CoinWallet _coinWallet;
  late frost.Client _roastClient;
  late MarismaClient _marismaClient;
  late Future<void> Function() _shutdownMarismaClient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 1,
        title: Text(_coinWallet.title),
        actions: _calcPopupMenuItems(context),
      ),
      bottomNavigationBar:
          _walletIsComplete ? _calcBottomNavBar(context) : null,
      body: _initial
          ? const SizedBox()
          : _walletIsComplete
              ? Container(
                  key: Key(_lastUpdate.toString()),
                  color: Theme.of(context).primaryColor,
                  child: Column(
                    children: [
                      _loginStatus == ROASTLoginStatus.loggedIn
                          ? Column(
                              children: [
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.people,
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      AppLocalizations.instance.translate(
                                          _numberOfOnlineParticipants > 1
                                              ? 'roast_wallet_number_of_participants_plural'
                                              : 'roast_wallet_number_of_participants_singular',
                                          {
                                            'n': _numberOfOnlineParticipants
                                                .toString(),
                                          }),
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : const SizedBox(),
                      const SizedBox(height: 30),
                      _calcBody(),
                    ],
                  ),
                )
              : ROASTGroupSetupLanding(
                  roastWallet: _roastWallet,
                  coinWallet: _coinWallet,
                ),
    );
  }

  @override
  void didChangeDependencies() async {
    if (_initial) {
      final arguments = ModalRoute.of(context)!.settings.arguments!
          as RoastWalletHomeScreenArguments;
      _coinWallet = arguments.coinWallet;

      final walletProvider =
          Provider.of<WalletProvider>(context, listen: false);
      _roastWallet = await walletProvider.getROASTWallet(_coinWallet.name);

      // only try to login if we have a completed configuration
      if (_roastWallet.isCompleted) {
        final logginResult = await _tryLogin();
        if (logginResult) {
          // listen to events
          _roastClient.events.listen(
            (event) async {
              LoggerWrapper.logInfo(
                'ROASTWalletHomeScreen',
                'eventStream',
                event.toString(),
              );

              // check for SignaturesCompleteClientEvent and broadcast
              if (event is frost.SignaturesCompleteClientEvent) {
                try {
                  final builtTx = await taprootTransactionFinalAssembly(
                    event,
                  );
                  LoggerWrapper.logInfo(
                    'ROASTWalletHomeScreen',
                    'eventStream',
                    'Broadcasting transaction: ${builtTx.toHex()}',
                  );
                  await _marismaClient.broadCastTransaction(
                    BroadCastTransactionRequest(hex: builtTx.toHex()),
                  );
                } catch (e) {
                  LoggerWrapper.logError(
                    'ROASTWalletHomeScreen',
                    'eventStream',
                    'Failed to broadcast transaction: $e',
                  );
                }
              }

              setState(() {
                _lastUpdate = DateTime.now();
                _numberOfOnlineParticipants =
                    _roastClient.onlineParticipants.length + 1;
              });
            },
          );
        }
      }

      setState(() {
        _initial = false;
        _walletIsComplete = _roastWallet.isCompleted;
      });

      if (mounted) {
        context.loaderOverlay.hide();
      }
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (_walletIsComplete && _loginStatus == ROASTLoginStatus.loggedIn) {
      _roastClient.logout();
      _shutdownMarismaClient();
    }
    super.dispose();
  }

  void _deriveNewAddress(ECPublicKey key, int index) {
    final currentDerivedKeys = _roastWallet.derivedKeys;
    final existingIndices = currentDerivedKeys[key] ?? <int>{};
    final updatedDerivedKeys =
        Map<ECPublicKey, Set<int>>.from(currentDerivedKeys);

    updatedDerivedKeys[key] = {...existingIndices, index};

    _roastWallet.derivedKeys = updatedDerivedKeys;
    _roastWallet.save();
  }

  List<String> _getUsedDKGNames() {
    final usedDKGNames = <String>[];
    for (final request in _roastClient.dkgRequests) {
      usedDKGNames.add(request.details.name);
    }

    for (final key in _roastClient.acceptedDkgs) {
      usedDKGNames.add(key.details.name);
    }

    for (final key in _roastWallet.keys.values) {
      usedDKGNames.add(key.name);
    }

    return usedDKGNames;
  }

  void _forceRender() {
    setState(() {
      _lastUpdate = DateTime.now();
    });
  }

  Widget _calcBody() {
    Widget body;
    if (_loginStatus == ROASTLoginStatus.loggedOut ||
        _loginStatus == ROASTLoginStatus.noServer) {
      return Expanded(
        child: ROASTWalletLoginStatus(
          status: _loginStatus,
          retry: () async {
            await _tryLogin();
          },
          openServerEditDialog: () {
            _serverURLEditDialog();
          },
          shareConfiguration: () {
            _exportConfiguration();
          },
        ),
      );
    }

    final isTestnet = _coinWallet.letterCode == 'tPPC';

    switch (_selectedTab) {
      case ROASTWalletTab.openRequests:
        body = Expanded(
          child: OpenRequestTab(
            key: Key('$_lastUpdate-openrequests'),
            roastClient: _roastClient,
            forceRender: _forceRender,
            participantNames: _roastWallet.participantNames,
          ),
        );
        break;
      case ROASTWalletTab.generatedKeys:
        body = Expanded(
          child: CompletedKeysTab(
            key: Key('$_lastUpdate-completedkeys'),
            roastClient: _roastClient,
            derivedKeys: _roastWallet.derivedKeys,
            deriveNewAddress: _deriveNewAddress,
            isTestnet: isTestnet,
          ),
        );
        break;
      case ROASTWalletTab.newDKG:
        body = Expanded(
          child: RequestDkgTab(
            roastClient: _roastClient,
            groupSize: _roastWallet.clientConfig!.group.participants.length,
            usedDKGNames: _getUsedDKGNames(),
            forceRender: _forceRender,
          ),
        );
        break;
      case ROASTWalletTab.newSignature:
        body = Expanded(
          child: RequestSignatureTab(
            roastClient: _roastClient,
            threshold: _roastWallet.clientConfig!.group.participants.length,
            derivedKeys: _roastWallet.derivedKeys,
            forceRender: _forceRender,
            isTestnet: isTestnet,
            walletName: _coinWallet.name,
            marismaClient: _marismaClient,
          ),
        );
        break;
    }

    return body;
  }

  BottomNavigationBar _calcBottomNavBar(BuildContext context) {
    final bgColor = Theme.of(context).primaryColor;
    return BottomNavigationBar(
      unselectedItemColor: Theme.of(context).disabledColor,
      selectedItemColor: Colors.white,
      backgroundColor: bgColor,
      onTap: (index) {
        _changeTab(ROASTWalletTab.values[index]);
      },
      currentIndex: _selectedTab.index,
      items: [
        BottomNavigationBarItem(
          backgroundColor: bgColor,
          icon: const Icon(Icons.list_rounded),
          tooltip: AppLocalizations.instance
              .translate('roast_wallet_bototm_open_tooltip'),
          label:
              AppLocalizations.instance.translate('roast_wallet_bottom_open'),
        ),
        BottomNavigationBarItem(
          backgroundColor: bgColor,
          icon: const Icon(Icons.key),
          tooltip: AppLocalizations.instance
              .translate('roast_wallet_bototm_keys_tooltip'),
          label:
              AppLocalizations.instance.translate('roast_wallet_bottom_keys'),
        ),
        BottomNavigationBarItem(
          backgroundColor: bgColor,
          icon: const Icon(Icons.note_add),
          tooltip: AppLocalizations.instance
              .translate('roast_wallet_bototm_new_dkg_tooltip'),
          label: AppLocalizations.instance
              .translate('roast_wallet_bottom_new_dkg'),
        ),
        BottomNavigationBarItem(
          backgroundColor: bgColor,
          icon: const Icon(Icons.drive_file_rename_outline),
          tooltip: AppLocalizations.instance
              .translate('roast_wallet_bototm_new_signature_tooltip'),
          label: AppLocalizations.instance
              .translate('roast_wallet_bottom_new_signature'),
        ),
      ],
    );
  }

  List<Widget> _calcPopupMenuItems(BuildContext context) {
    return [
      PopupMenuButton(
        onSelected: (dynamic value) => _selectPopUpMenuItem(value),
        itemBuilder: (_) {
          return [
            PopupMenuItem(
              value: 'change_title',
              child: ListTile(
                leading: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: Text(
                  AppLocalizations.instance.translate(
                    'wallet_pop_menu_change_title',
                  ),
                ),
              ),
            ),
            PopupMenuItem(
              value: 'export_roast_group',
              child: ListTile(
                leading: Icon(
                  Icons.share,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: Text(
                  AppLocalizations.instance.translate(
                    'roast_wallet_share_group_config',
                  ),
                ),
              ),
            ),
            PopupMenuItem(
              value: 'change_server_url',
              child: ListTile(
                leading: Icon(
                  Icons.dns,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: Text(
                  AppLocalizations.instance.translate(
                    'roast_landing_configured_edit_server_url_title',
                  ),
                ),
              ),
            ),
            PopupMenuItem(
              value: 'delete_roast_group',
              child: ListTile(
                leading: Icon(
                  Icons.delete_forever,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: Text(
                  AppLocalizations.instance.translate(
                    'delete_wallet',
                  ),
                ),
              ),
            ),
          ];
        },
      ),
    ];
  }

  void _changeTab(ROASTWalletTab t) {
    setState(() {
      _selectedTab = t;
    });
  }

  void _exportConfiguration() {
    LoggerWrapper.logInfo(
      'ROASTGroupLandingConfigured',
      '_exportConfiguration',
      'Exporting server configuration',
    );

    if (_roastWallet.clientConfig == null ||
        _roastWallet.clientConfig?.group == null) {
      return;
    }

    Share.share(
      _roastWallet.clientConfig!.group.yaml,
    );
  }

  void _selectPopUpMenuItem(String value) {
    switch (value) {
      case 'change_title':
        titleEditDialog(context, _coinWallet);
        break;
      case 'delete_roast_group':
        _triggerDeleteROASTGroupBottomSheet(
          context: context,
          walletProvider: Provider.of<WalletProvider>(context, listen: false),
          wallet: _coinWallet,
        );
        break;
      case 'export_roast_group':
        _exportConfiguration();
        break;
      case 'change_server_url':
        _serverURLEditDialog();
        break;
      default:
    }
  }

  Future<void> _serverURLEditDialog() async {
    final textFieldController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    textFieldController.text = _roastWallet.serverUrl;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.instance.translate(
              'roast_landing_configured_edit_server_url_title',
            ),
            textAlign: TextAlign.center,
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: textFieldController,
              decoration: InputDecoration(
                hintText: AppLocalizations.instance.translate(
                  'roast_landing_configured_edit_server_url_placeholder',
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.instance.translate(
                    'roast_landing_configured_edit_server_url_empty',
                  );
                }
                if (Uri.tryParse(value) == null ||
                    !value.startsWith('https://')) {
                  return AppLocalizations.instance.translate(
                    'roast_landing_configured_edit_server_url_error',
                  );
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.instance
                    .translate('server_settings_alert_cancel'),
              ),
            ),
            TextButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                _roastWallet.setServerUrl = textFieldController.text;
                Navigator.pop(context);
                _tryLogin();
              },
              child: Text(
                AppLocalizations.instance.translate('jail_dialog_button'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _triggerDeleteROASTGroupBottomSheet({
    required BuildContext context,
    required WalletProvider walletProvider,
    required CoinWallet wallet,
  }) async {
    await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return WalletDeleteWatchOnlyBottomSheet(
          action: () async {
            await walletProvider.deleteROASTWallet(_coinWallet.name);
            if (context.mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        );
      },
      context: context,
    );
  }

  Future<bool> _tryLogin() async {
    final uri = Uri.parse(_roastWallet.serverUrl);

    if (uri.host.isEmpty) {
      setState(() {
        _loginStatus = ROASTLoginStatus.noServer;
      });
      return false;
    }

    try {
      _roastClient = await frost.Client.login(
        config: _roastWallet.clientConfig!,
        api: frost.GrpcClientApi(
          ClientChannel(
            uri.host.trim(),
            port: uri.port,
            options: const ChannelOptions(
              credentials: ChannelCredentials.secure(),
            ),
          ),
        ),
        store: ROASTStorage(_roastWallet),
        getPrivateKey: (_) async =>
            _roastWallet.ourKey, // TODO request interface for key
        onDisconnect: () {
          LoggerWrapper.logInfo(
            'ROASTGroupLandingConfigured',
            '_tryLogin',
            'Disconnected from server',
          );
          setState(() {
            _loginStatus = ROASTLoginStatus.loggedOut;
          });
        },
      );

      LoggerWrapper.logInfo(
        'ROASTGroupLandingConfigured',
        '_tryLogin',
        'Logged in to server',
      );

      // init marisma client
      final (cli, shutdown) = getMarismaClient(
        _coinWallet.name,
      );
      _marismaClient = cli;
      _shutdownMarismaClient = shutdown;

      setState(() {
        _loginStatus = ROASTLoginStatus.loggedIn;
        _lastUpdate = DateTime.now();
        _numberOfOnlineParticipants =
            _roastClient.onlineParticipants.length + 1;
      });

      return true;
    } catch (e) {
      LoggerWrapper.logError(
        'ROASTGroupLandingConfigured',
        '_tryLogin',
        'Failed to login to server: $e',
      );

      String errorMessageTranslationKey =
          'roast_landing_configured_login_failed_snack_fallback';

      if (e is GrpcError) {
        switch (e.code) {
          case 14:
            errorMessageTranslationKey =
                'roast_landing_configured_login_failed_snack_14';
            break;
          default:
            errorMessageTranslationKey =
                'roast_landing_configured_login_failed_snack_fallback';
        }
      } else if (e is frost.InvalidRequest) {
        errorMessageTranslationKey =
            'roast_landing_configured_login_failed_snack_fingerprint_mismatch';
      }

      // show snack bar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.instance.translate(errorMessageTranslationKey),
              textAlign: TextAlign.center,
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return false;
    }
  }
}

// TODO marisma consent?
// TODO allow ROAST key export and import, since the key is not derived from the seed
// TODO background notification for new DKG requests
// TODO expiries for all requests default to 1 day and should be configurable
