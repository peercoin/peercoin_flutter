import "package:flutter/material.dart";
import 'package:peercoin/app_localizations.dart';
import 'package:flutter_screen_lock/functions.dart';
import 'package:local_auth/local_auth.dart';
import 'package:peercoin/models/availablecoins.dart';
import 'package:peercoin/models/coinwallet.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/providers/encryptedbox.dart';
import 'package:peercoin/screens/new_wallet.dart';
import 'package:peercoin/screens/wallet_home.dart';
import 'package:peercoin/widgets/app_drawer.dart';
import 'package:peercoin/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class WalletListScreen extends StatefulWidget {
  static const routeName = "/wallet-list";
  _WalletListScreenState createState() => _WalletListScreenState();
}

class _WalletListScreenState extends State<WalletListScreen> {
  bool _isLoading = false;
  bool _initial = true;
  ActiveWallets _activeWallets;

  Future<void> localAuth(BuildContext context) async {
    final localAuth = LocalAuthentication();
    final didAuthenticate = await localAuth.authenticate(
        biometricOnly: true,
        localizedReason: 'Please authenticate',
        stickyAuth: true);
    if (didAuthenticate) {
      Navigator.pop(context);
    }
  }

  @override
  void didChangeDependencies() async {
    if (_initial) {
      _activeWallets = Provider.of<ActiveWallets>(context);
      await _activeWallets.init();
      await screenLock(
        context: context,
        correctString:
            await Provider.of<EncryptedBox>(context, listen: false).passCode,
        digits: 6,
        canCancel: false,
        customizedButtonChild: Icon(
          Icons.fingerprint,
        ),
        customizedButtonTap: () async {
          await localAuth(context);
        },
        didOpened: () async {
          await localAuth(context);
        },
      );
      setState(() {
        _initial = false;
      });
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Center(
            child: Text(
                AppLocalizations.instance.translate('wallets_list', null))),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: IconButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(NewWalletScreen.routeName),
              icon: Icon(Icons.add),
            ),
          )
        ],
      ),
      body: _isLoading || _initial
          ? Center(
              child: LoadingIndicator(),
            )
          : Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  FutureBuilder(
                    future: _activeWallets.activeWalletsValues,
                    builder: (_, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return Expanded(
                          child: Center(child: LoadingIndicator()),
                        );
                      if (snapshot.data == null || snapshot.data.isEmpty) {
                        return Column(children: [
                          SizedBox(height: 30),
                          Text(AppLocalizations.instance
                              .translate('wallets_none', null)),
                          SizedBox(height: 30)
                        ]);
                      }
                      return Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (ctx, i) {
                            CoinWallet _wallet = snapshot.data[i];
                            return Card(
                              child: Column(
                                children: [
                                  InkWell(
                                      onTap: () async {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        await Navigator.of(context)
                                            .pushReplacementNamed(
                                          WalletHomeScreen.routeName,
                                          arguments: _wallet,
                                        );
                                      },
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          child: Image.asset(
                                              AvailableCoins()
                                                  .getSpecificCoin(_wallet.name)
                                                  .iconPath,
                                              width: 20),
                                        ),
                                        title: Text(_wallet.title),
                                      ))
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
