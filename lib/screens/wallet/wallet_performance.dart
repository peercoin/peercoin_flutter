import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../providers/active_wallets.dart';
import '../../tools/app_localizations.dart';

class WalletPerformanceScreen extends StatefulWidget {
  const WalletPerformanceScreen({Key? key}) : super(key: key);

  @override
  State<WalletPerformanceScreen> createState() =>
      _WalletPerformanceScreenState();
}

class _WalletPerformanceScreenState extends State<WalletPerformanceScreen> {
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

//TODO Hint: rescan not affected
//TODO Hint: disabling generation of change addresses will result in lack of privacy
//TODO Hint: Addresses can be watched manually by enabling them in the address book
//TODO Receive tab: allow manual generation of unused address if change address generation is disabled 
