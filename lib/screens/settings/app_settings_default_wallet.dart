import 'package:flutter/material.dart';
import 'package:peercoin/screens/settings/settings_helpers.dart';
import 'package:provider/provider.dart';

import '../../models/hive/coin_wallet.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../tools/app_localizations.dart';
import '../../widgets/service_container.dart';

class AppSettingsDefaultWalletScreen extends StatefulWidget {
  const AppSettingsDefaultWalletScreen({super.key});

  @override
  State<AppSettingsDefaultWalletScreen> createState() =>
      _AppSettingsDefaultWalletScreenState();
}

class _AppSettingsDefaultWalletScreenState
    extends State<AppSettingsDefaultWalletScreen> {
  bool _initial = true;
  String _defaultWallet = '';
  List<CoinWallet> _availableWallets = [];
  late WalletProvider _activeWallets;

  late AppSettingsProvider _settings;

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      _activeWallets = Provider.of<WalletProvider>(context);
      _settings = Provider.of<AppSettingsProvider>(context);
      _availableWallets = _activeWallets.availableWalletValues;

      setState(() {
        _initial = false;
      });
    }

    super.didChangeDependencies();
  }

  void saveDefaultWallet(String wallet) async {
    _settings.setDefaultWallet(
      wallet == _settings.defaultWallet ? '' : wallet,
    );
    saveSnack(context);
  }

  List<Widget> generateDefaultWallets() {
    final inkwells = _availableWallets.map((wallet) {
      return InkWell(
        onTap: () => saveDefaultWallet(wallet.letterCode),
        child: ListTile(
          title: Text(wallet.title),
          leading: Radio(
            value: wallet.letterCode,
            groupValue: _defaultWallet,
            onChanged: (dynamic _) => saveDefaultWallet(wallet.letterCode),
          ),
        ),
      );
    }).toList();

    return [
      ...inkwells,
      Text(
        AppLocalizations.instance.translate(
          'app_settings_default_description',
        ),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.secondary,
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_initial == true) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    _defaultWallet = _settings.defaultWallet;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.instance.translate('app_settings_default_wallet'),
        ),
      ),
      body: SingleChildScrollView(
        child: Align(
          child: PeerContainer(
            noSpacers: true,
            child: Column(
              children: generateDefaultWallets(),
            ),
          ),
        ),
      ),
    );
  }
}
