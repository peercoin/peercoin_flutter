import 'package:flutter/material.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:provider/provider.dart';

import '../../../models/hive/coin_wallet.dart';
import '../../../providers/wallet_provider.dart';
import '../../../tools/app_localizations.dart';
import '../../../widgets/service_container.dart';

class AppSettingsServerHome extends StatefulWidget {
  const AppSettingsServerHome({super.key});

  @override
  State<AppSettingsServerHome> createState() => _AppSettingsServerHomeState();
}

class _AppSettingsServerHomeState extends State<AppSettingsServerHome> {
  bool _initial = true;
  List<CoinWallet> _availableWallets = [];
  late WalletProvider _activeWallets;

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      _activeWallets = Provider.of<WalletProvider>(context);
      _availableWallets = _activeWallets.availableWalletValues;

      setState(() {
        _initial = false;
      });
    }

    super.didChangeDependencies();
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

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.instance.translate('wallet_pop_menu_servers'),
        ),
      ),
      body: SingleChildScrollView(
        child: Align(
          child: PeerContainer(
            noSpacers: true,
            child: Column(
              children: _availableWallets.isEmpty
                  ? [
                      Text(
                        AppLocalizations.instance.translate(
                          'wallets_none',
                        ),
                      ),
                    ]
                  : _availableWallets.map(
                      (wallet) {
                        return ListTile(
                          onTap: () => Navigator.of(context).pushNamed(
                            Routes.serverSettingsDetail,
                            arguments: wallet.name,
                          ),
                          title: Text(
                            wallet.title,
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
            ),
          ),
        ),
      ),
    );
  }
}
