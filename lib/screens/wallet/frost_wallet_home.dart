import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:peercoin/models/hive/coin_wallet.dart';

class FrostWalletHomeScreen extends StatefulWidget {
  const FrostWalletHomeScreen({super.key});

  @override
  State<FrostWalletHomeScreen> createState() => _FrostWalletHomeScreenState();
}

class _FrostWalletHomeScreenState extends State<FrostWalletHomeScreen> {
  bool _initial = true;
  late CoinWallet _wallet;

  @override
  void didChangeDependencies() {
    if (_initial) {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map;
      _wallet = arguments['wallet'];

      context.loaderOverlay.hide();
      setState(() {
        _initial = false;
      });
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
        body: Center(
          child: Text('FROST Wallet Home'),
        ));
  }
}
