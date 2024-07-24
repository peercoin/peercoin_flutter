import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:peercoin/models/hive/coin_wallet.dart';
import 'package:peercoin/models/hive/frost_group.dart';
import 'package:peercoin/providers/wallet_provider.dart';
import 'package:peercoin/widgets/wallet/frost_group/landing_configured.dart';
import 'package:peercoin/widgets/wallet/frost_group/setup_landing.dart';
import 'package:provider/provider.dart';

class FrostWalletHomeScreen extends StatefulWidget {
  const FrostWalletHomeScreen({super.key});

  @override
  State<FrostWalletHomeScreen> createState() => _FrostWalletHomeScreenState();
}

class _FrostWalletHomeScreenState extends State<FrostWalletHomeScreen> {
  bool _initial = true;
  late CoinWallet _wallet;
  late FrostGroup _frostGroup;

  @override
  void didChangeDependencies() async {
    if (_initial) {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map;
      _wallet = arguments['wallet'];

      final walletProvider =
          Provider.of<WalletProvider>(context, listen: false);
      _frostGroup = await walletProvider.getFrostGroup(_wallet.name);

      setState(() {
        _initial = false;
      });

      if (mounted) {
        context.loaderOverlay.hide();
      }
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 1,
        title: Text(_wallet.title),
      ),
      body: _initial
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _frostGroup.isCompleted
              ? const FrostGroupLandingConfigured()
              : FrostGroupSetupLanding(
                  frostGroup: _frostGroup,
                ),
    );
  }
}
