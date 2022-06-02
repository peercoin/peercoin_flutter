import 'package:flutter/material.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:provider/provider.dart';
// import 'package:provider/provider.dart';

// import '../../providers/active_wallets.dart';
import '../../providers/active_wallets.dart';
import '../../tools/app_localizations.dart';
import '../../widgets/buttons.dart';
import '../../widgets/loading_indicator.dart';

class WalletSigningScreen extends StatefulWidget {
  const WalletSigningScreen({Key? key}) : super(key: key);

  @override
  State<WalletSigningScreen> createState() => _WalletSigningScreenState();
}

class _WalletSigningScreenState extends State<WalletSigningScreen> {
  late String _walletName;
  late ActiveWallets _activeWallets;
  bool _initial = true;
  int _currentStep = 1;
  bool _signingInProgress = false;
  String _signature = '';
  String _signingAddress = '';

  @override
  void didChangeDependencies() {
    if (_initial == true) {
      setState(() {
        _walletName = ModalRoute.of(context)!.settings.arguments as String;
        _activeWallets = Provider.of<ActiveWallets>(context);
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  void saveSnack(context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.instance.translate(
            'sign_snack_text',
            {'address': _signingAddress},
          ),
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _showAddressSelector() async {
    final _oldAddr = _signingAddress;
    var result = await Navigator.of(context).pushNamed(
      Routes.AddressSelector,
      arguments: [
        await _activeWallets.getWalletAddresses(_walletName),
        _signingAddress
      ],
    );
    setState(() {
      _signingAddress = result as String;
    });
    if (result != '' && result != _oldAddr) {
      saveSnack(context);
    }
  }

  void handlePress(int step) async {
    if (step == _currentStep) {
      switch (step) {
        case 1:
          await _showAddressSelector();
          break;
        case 2:
          // createQrScanner('priv');
          break;
        case 3:
          // requestUtxos();
          break;
        case 4:
          // emptyWallet();
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.instance.translate('wallet_pop_menu_signing'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.instance
                                  .translate('sign_step_1'),
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            _signingAddress == ''
                                ? AppLocalizations.instance
                                    .translate('sign_step_1_description')
                                : _signingAddress,
                          ),
                        ),
                        PeerButton(
                          action: () => handlePress(1),
                          text: AppLocalizations.instance.translate(
                            _signingAddress == ''
                                ? 'sign_step_1_button'
                                : 'sign_step_1_button_alt',
                          ),
                          small: true,
                          active: _currentStep == 1,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.instance.translate('sign_step_2'),
                            style: Theme.of(context).textTheme.headline6),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.instance.translate('sign_step_3'),
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    PeerButton(
                      action: () => handlePress(3),
                      text: AppLocalizations.instance
                          .translate('sign_step_3_button'),
                      small: true,
                      active: _currentStep == 3,
                    ),
                    Container(
                      height: 30,
                      child: _signingInProgress == true
                          ? LoadingIndicator()
                          : Text(_signature),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

//TODO Message form
//TODO fire sign