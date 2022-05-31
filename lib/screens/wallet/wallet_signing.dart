import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../providers/active_wallets.dart';
import '../../tools/app_localizations.dart';

class WalletSigningScreen extends StatefulWidget {
  const WalletSigningScreen({Key? key}) : super(key: key);

  @override
  State<WalletSigningScreen> createState() => _WalletSigningScreenState();
}

class _WalletSigningScreenState extends State<WalletSigningScreen> {
  // late String _walletName;
  bool _initial = true;
  // late ActiveWallets _activeWallets;

  @override
  void didChangeDependencies() {
    if (_initial == true) {
      setState(() {
        // _walletName = ModalRoute.of(context)!.settings.arguments as String;
        // _activeWallets = Provider.of<ActiveWallets>(context);
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.instance.translate('wallet_pop_menu_performance'),
        ),
      ),
    );
  }
}
