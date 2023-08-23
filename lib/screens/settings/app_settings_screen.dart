import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:peercoin/screens/settings/settings_helpers.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/wallet_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../tools/app_localizations.dart';
import '../../tools/auth.dart';
import '../../tools/logger_wrapper.dart';
import '../../tools/share_wrapper.dart';
import '../../widgets/buttons.dart';
import '../../widgets/double_tab_to_clipboard.dart';
import '../../widgets/service_container.dart';
import '../about.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _initial = true;
  String _seedPhrase = '';
  late AppSettingsProvider _settings;
  late WalletProvider _activeWallets;

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      _activeWallets = Provider.of<WalletProvider>(context);
      _settings = Provider.of<AppSettingsProvider>(context);

      await _settings.init(); //only required in home widget
      await _activeWallets.init();

      await initDebugLogHandler();

      setState(() {
        _initial = false;
      });
    }

    super.didChangeDependencies();
  }

  Future<void> initDebugLogHandler() async {
    FlutterLogs.channel.setMethodCallHandler((call) async {
      if (call.method == 'logsExported') {
        var zipName = call.arguments.toString();
        Directory? externalDirectory;

        if (Platform.isIOS) {
          externalDirectory = await getApplicationDocumentsDirectory();
        } else {
          externalDirectory = await getExternalStorageDirectory();
        }

        LoggerWrapper.logInfo(
          'AppSettingsScreen',
          'found',
          'External Storage:$externalDirectory',
        );

        var file = File('${externalDirectory!.path}/$zipName');

        LoggerWrapper.logInfo(
          'AppSettingsScreen',
          'path',
          'Path: \n${file.path}',
        );

        if (file.existsSync()) {
          LoggerWrapper.logInfo(
            'AppSettingsScreen',
            'existsSync',
            'Logs zip found, opening Share overlay',
          );
          await Share.shareXFiles(
            [
              XFile(file.path),
            ],
          );
        } else {
          LoggerWrapper.logError(
            'AppSettingsScreen',
            'existsSync',
            'File not found in storage.',
          );
        }
      }
    });
  }

  void revealSeedPhrase(bool biometricsAllowed) async {
    final seed = await context.read<WalletProvider>().seedPhrase;
    // ignore: use_build_context_synchronously
    await Auth.requireAuth(
      context: context,
      biometricsAllowed: biometricsAllowed,
      callback: () => setState(
        () {
          _seedPhrase = seed;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initial) return Container();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.instance.translate('app_settings_appbar'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: IconButton(
              key: const Key('aboutButton'),
              icon: const Icon(Icons.info_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Align(
          child: PeerContainer(
            noSpacers: true,
            child: Column(
              children: [
                ...availableSettings.keys.map(
                  (key) {
                    return ListTile(
                      onTap: () => Navigator.of(context).pushNamed(
                        availableSettings[key]!,
                      ),
                      title: Text(
                        AppLocalizations.instance.translate(key),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    );
                  },
                ).toList(),
                ExpansionTile(
                  title: Text(
                    AppLocalizations.instance.translate('app_settings_seed'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  childrenPadding: const EdgeInsets.all(10),
                  children: [
                    _seedPhrase == ''
                        ? PeerButton(
                            action: () =>
                                revealSeedPhrase(_settings.biometricsAllowed),
                            text: AppLocalizations.instance
                                .translate('app_settings_revealSeedButton'),
                          )
                        : Column(
                            children: [
                              const SizedBox(height: 20),
                              DoubleTabToClipboard(
                                clipBoardData: _seedPhrase,
                                child: SelectableText(
                                  _seedPhrase,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (!kIsWeb)
                                PeerButton(
                                  action: () => ShareWrapper.share(
                                    context: context,
                                    message: _seedPhrase,
                                  ),
                                  text: AppLocalizations.instance
                                      .translate('app_settings_shareseed'),
                                )
                            ],
                          )
                  ],
                ),
                if (!kIsWeb)
                  ExpansionTile(
                    title: Text(
                      AppLocalizations.instance.translate('app_settings_logs'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    childrenPadding: const EdgeInsets.all(10),
                    children: [
                      Text(
                        AppLocalizations.instance
                            .translate('app_settings_description'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      PeerButton(
                        text: AppLocalizations.instance
                            .translate('app_settings_logs_export'),
                        action: () => FlutterLogs.exportLogs(),
                      )
                    ],
                  ),
                if (!kIsWeb)
                  if (Platform.isIOS)
                    ExpansionTile(
                      title: Text(
                        AppLocalizations.instance
                            .translate('app_settings_delete'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      childrenPadding: const EdgeInsets.all(10),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            AppLocalizations.instance
                                .translate('app_settings_delete_description'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
