import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart' as frost;
import 'package:peercoin/models/hive/coin_wallet.dart';
import 'package:peercoin/models/hive/roast_wallet.dart';
import 'package:peercoin/models/roast_storage.dart';
import 'package:peercoin/providers/wallet_provider.dart';
import 'package:peercoin/screens/wallet/standard_and_watch_only_wallet_home.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:peercoin/widgets/wallet/roast_group/setup_landing.dart';
import 'package:peercoin/widgets/wallet/roast_group/tabs/completed_keys_tab.dart';
import 'package:peercoin/widgets/wallet/roast_group/tabs/open_request_tab.dart';
import 'package:peercoin/widgets/wallet/roast_group/tabs/request_dkg_tab.dart';
import 'package:peercoin/widgets/wallet/wallet_home/wallet_delete_watch_only_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ROASTWalletHomeScreen extends StatefulWidget {
  const ROASTWalletHomeScreen({super.key});

  @override
  State<ROASTWalletHomeScreen> createState() => _ROASTWalletHomeScreenState();
}

enum ROASTWalletTab {
  rejectedRequests,
  openRequests,
  generatedKeys,
  newDKG,
}

class _ROASTWalletHomeScreenState extends State<ROASTWalletHomeScreen> {
  bool _initial = true;
  bool _walletIsComplete = false;
  DateTime _lastUpdate = DateTime.now();
  ROASTWalletTab _selectedTab = ROASTWalletTab.openRequests;
  late ROASTWallet _roastWallet;
  late CoinWallet _wallet;
  late frost.Client _roastClient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 1,
        title: Text(_wallet.title),
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
                      const SizedBox(height: 30),
                      _calcBody(),
                    ],
                  ),
                )
              : ROASTGroupSetupLanding(
                  roastWallet: _roastWallet,
                ),
    );
  }

  @override
  void didChangeDependencies() async {
    if (_initial) {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map;
      _wallet = arguments['wallet'];

      final walletProvider =
          Provider.of<WalletProvider>(context, listen: false);
      _roastWallet = await walletProvider.getROASTWallet(_wallet.name);

      // only try to login if we have a completed configuration
      if (_roastWallet.isCompleted) {
        await _tryLogin();

        _roastClient.events.listen((event) {
          LoggerWrapper.logInfo(
            'ROASTWalletHomeScreen',
            'eventStream',
            event.toString(),
          );

          setState(() {
            _lastUpdate = DateTime.now();
          });
        });
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
    if (_walletIsComplete) {
      _roastClient.logout();
    }
    super.dispose();
  }

  Widget _calcBody() {
    Widget body;
    switch (_selectedTab) {
      case ROASTWalletTab.rejectedRequests:
        body = const Expanded(
          child: SizedBox(),
        );
        break;
      case ROASTWalletTab.openRequests:
        body = Expanded(
          child: OpenRequestTab(
            roastClient: _roastClient,
            forceRender: () {
              setState(() {
                _lastUpdate = DateTime.now();
              });
            },
          ),
        );
        break;
      case ROASTWalletTab.generatedKeys:
        body = Expanded(
          child: CompletedKeysTab(
            roastClient: _roastClient,
          ),
        );
        break;
      case ROASTWalletTab.newDKG:
        body = Expanded(
          child: RequestDKGTab(
            roastClient: _roastClient,
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
      onTap: (index) {
        _changeTab(ROASTWalletTab.values[index]);
      },
      currentIndex: _selectedTab.index,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.do_not_disturb),
          tooltip: 'Rejected DKGs',
          label: AppLocalizations.instance
              .translate('roast_wallet_bottom_nav_reject'),
          backgroundColor: bgColor,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.list_rounded),
          tooltip: 'Requested DKGs',
          label:
              AppLocalizations.instance.translate('roast_wallet_bottom_open'),
          backgroundColor: bgColor,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.key),
          tooltip: 'Generated Keys',
          label:
              AppLocalizations.instance.translate('roast_wallet_bottom_keys'),
          backgroundColor: bgColor,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.note_add),
          tooltip: 'Request new DKG',
          label: AppLocalizations.instance.translate('roast_wallet_bottom_new'),
          backgroundColor: bgColor,
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
        titleEditDialog(context, _wallet);
        break;
      case 'delete_roast_group':
        _triggerDeleteROASTGroupBottomSheet(
          context: context,
          walletProvider: Provider.of<WalletProvider>(context, listen: false),
          wallet: _wallet,
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
            await walletProvider.deleteROASTWallet(_wallet.name);
            if (context.mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        );
      },
      context: context,
    );
  }

  Future<void> _tryLogin() async {
    final uri = Uri.parse(_roastWallet.serverUrl);

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
      );

      if (!mounted) return;
      LoggerWrapper.logInfo(
        'ROASTGroupLandingConfigured',
        '_tryLogin',
        'Logged in to server',
      );
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
          // TODO unauthorized
          // TODO 404
        }
      }

      // show snack bar
      if (!mounted) return;
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
  }
}
// TODO allow ROAST key export and import, since the key is not derived from the seed
