import "package:flutter/material.dart";
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/models/availablecoins.dart';
import 'package:peercoin/models/coinwallet.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/tools/auth.dart';
import 'package:peercoin/widgets/app_drawer.dart';
import 'package:peercoin/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class WalletListScreen extends StatefulWidget {
  _WalletListScreenState createState() => _WalletListScreenState();
}

class _WalletListScreenState extends State<WalletListScreen> {
  bool _isLoading = false;
  bool _initial = true;
  ActiveWallets _activeWallets;

  @override
  void didChangeDependencies() async {
    if (_initial) {
      _activeWallets = Provider.of<ActiveWallets>(context);
      AppSettings _appSettings =
          Provider.of<AppSettings>(context, listen: false);
      await _appSettings.init(); //only required in home widget
      if (_appSettings.authenticationOptions["walletList"])
        await Auth.requireAuth(context, _appSettings.biometricsAllowed);

      await _activeWallets.init();
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
            child: Text(AppLocalizations.instance.translate('wallets_list'))),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: IconButton(
              onPressed: () {
                if (_initial == false) {
                  Navigator.of(context).pushNamed(Routes.NewWallet);
                }
              },
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
                              .translate('wallets_none')),
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
                                          Routes.WalletHome,
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
