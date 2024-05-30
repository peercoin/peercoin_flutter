import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_logs/flutter_logs.dart';

import 'package:flutter/material.dart';
import 'package:peercoin/screens/settings/settings_helpers.dart';
import 'package:provider/provider.dart';

import '../../providers/wallet_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../tools/app_localizations.dart';
import '../../tools/auth.dart';
import '../../tools/debug_log_handler.dart';
import '../../tools/share_wrapper.dart';
import '../../widgets/buttons.dart';
import '../../widgets/double_tab_to_clipboard.dart';
import '../../widgets/service_container.dart';
import '../about.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

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

  void revealSeedPhrase(bool biometricsAllowed) async {
    final seed = await context.read<WalletProvider>().seedPhrase;
    if (mounted) {
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
                ),
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
                                withHintText: true,
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
                                ),
                            ],
                          ),
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
                      ),
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
