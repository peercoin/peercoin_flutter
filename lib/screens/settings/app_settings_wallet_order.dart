import 'package:flutter/material.dart';
import 'package:peercoin/providers/app_settings.dart';
import 'package:peercoin/providers/wallet_provider.dart';
import 'package:peercoin/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../../widgets/service_container.dart';
import '../../../tools/app_localizations.dart';

class AppSettingsWalletOrderScreen extends StatefulWidget {
  const AppSettingsWalletOrderScreen({Key? key}) : super(key: key);

  @override
  State<AppSettingsWalletOrderScreen> createState() =>
      _AppSettingsWalletOrderScreenState();
}

class _AppSettingsWalletOrderScreenState
    extends State<AppSettingsWalletOrderScreen> {
  bool _initial = true;
  List<String> _walletOrder = [];
  final Map<String, String> _walletTitles = {};
  late AppSettings _appSettings;
  late WalletProvider _walletProvider;

  @override
  void didChangeDependencies() async {
    if (_initial) {
      setState(() {
        _appSettings = context.watch<AppSettings>();
        _walletProvider = context.watch<WalletProvider>();
        _walletOrder = _appSettings.walletOrder;
        _initial = false;
      });

      await _initWalletTitles();
      if (_walletOrder.isEmpty) {
        await _initWalletOrder();
      }
    }

    super.didChangeDependencies();
  }

  Future<void> saveOrder() async {
    _appSettings.setWalletOrder(_walletOrder);
  }

  Future<void> _initWalletTitles() async {
    for (var element in _walletProvider.availableWalletValues) {
      _walletTitles[element.name] = element.title;
    }
  }

  Future<void> _initWalletOrder() async {
    _walletOrder = _walletTitles.keys.toList();
    _appSettings.setWalletOrder(_walletOrder);
  }

  Color _calculateTileColor(int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final oddItemColor = colorScheme.primary.withOpacity(0.10);
    final evenItemColor = colorScheme.primary.withOpacity(0.3);

    if (index.isOdd) {
      return oddItemColor;
    }
    return evenItemColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.instance.translate('app_settings_wallet_order'),
        ),
      ),
      body: _walletOrder.isEmpty
          ? const Center(
              child: LoadingIndicator(),
            )
          : Align(
              child: PeerContainer(
                noSpacers: true,
                child: ReorderableListView.builder(
                  onReorder: (oldIndex, newIndex) async {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }

                    setState(() {
                      final item = _walletOrder.removeAt(oldIndex);
                      _walletOrder.insert(newIndex, item);
                    });

                    await saveOrder();
                  },
                  itemCount: _walletOrder.length,
                  itemBuilder: (ctx, index) {
                    return Card(
                      key: Key(_walletOrder.elementAt(index)),
                      clipBehavior: Clip.antiAlias,
                      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: ListTile(
                        leading: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Icon(Icons.toc)],
                        ),
                        tileColor: _calculateTileColor(
                          index,
                        ),
                        title: Text(
                          _walletTitles[_walletOrder.elementAt(index)]!,
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
