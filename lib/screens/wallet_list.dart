import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/models/availablecoins.dart';
import 'package:peercoin/models/coinwallet.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/tools/auth.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/loading_indicator.dart';
import 'package:peercoin/widgets/new_wallet.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class WalletListScreen extends StatefulWidget {
  final bool fromColdStart;

  @override
  _WalletListScreenState createState() => _WalletListScreenState();
  WalletListScreen({this.fromColdStart = false});
}

class _WalletListScreenState extends State<WalletListScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _initial = true;
  late ActiveWallets _activeWallets;
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    animation = Tween(begin: 88.0, end: 92.0).animate(controller);
    controller.repeat(reverse: true);
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    _activeWallets = Provider.of<ActiveWallets>(context);
    var _appSettings = Provider.of<AppSettings>(context, listen: false);
    await _appSettings.init(); //only required in home widget
    await _activeWallets.init();
    if (_initial) {
      if (widget.fromColdStart == false) {
        if (_appSettings.authenticationOptions!['walletList']!) {
          await Auth.requireAuth(context, _appSettings.biometricsAllowed);
        }
      } else {
        //push to default wallet
        final values = await _activeWallets.activeWalletsValues;
        if (values.length == 1) {
          //only one wallet available, pushing to that one
          setState(() {
            _isLoading = true;
            _initial = false;
          });
          await Navigator.of(context).pushNamed(
            Routes.WalletHome,
            arguments: values[0],
          );
          setState(() {
            _isLoading = false;
          });
        } else if (values.length > 1) {
          //find default wallet
          final defaultWallet = values.firstWhereOrNull(
              (elem) => elem.letterCode == _appSettings.defaultWallet);
          if (defaultWallet != null) {
            setState(() {
              _isLoading = true;
              _initial = false;
            });
            await Navigator.of(context).pushNamed(
              Routes.WalletHome,
              arguments: defaultWallet,
            );
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
      setState(() {
        _initial = false;
      });
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () async {
                await Navigator.pushNamed(context, Routes.AppSettings);
                setState(() {});
              },
              icon: Icon(
                Icons.settings_rounded,
                color: Theme.of(context).backgroundColor,
                size: 30,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: animation,
              builder: (ctx, child) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 92,
                  ),
                  child: Container(
                    height: animation.value,
                    width: animation.value,
                    decoration: BoxDecoration(
                      color: Theme.of(context).shadowColor,
                      borderRadius:
                      BorderRadius.all(const Radius.circular(50.0)),
                      border: Border.all(
                        color: Theme.of(context).shadowColor,
                        width: 3,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () => Share.share(
                        Platform.isAndroid
                            ? 'https://play.google.com/store/apps/details?id=com.coinerella.peercoin'
                            : 'https://apps.apple.com/us/app/peercoin-wallet/id1571755170',
                      ),
                      child: Image.asset(
                        'assets/icon/ppc-logo.png',
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 32,),
            Text(
              'Peercoin Wallet',
              style: TextStyle(
                letterSpacing: 1.2,
                fontSize: 28,
                color: Theme.of(context).backgroundColor,
              ),
            ),
            SizedBox(height: 40,),
            FutureBuilder(
              future: _activeWallets.activeWalletsValues,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    _isLoading ||
                    _initial) {
                  return Expanded(
                    child: Center(child: LoadingIndicator()),
                  );
                }
                var listData = snapshot.data! as List;
                if (listData.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        AppLocalizations.instance.translate('wallets_none'),
                        style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).backgroundColor),
                      ),
                    ),
                  );
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: listData.length+1,
                    itemBuilder: (ctx, i) {

                      if (i<listData.length) {
                        CoinWallet _wallet = listData[i];
                        return Card(
                          elevation: 2,
                          shadowColor: Theme.of(context).dividerColor,
                          color: Theme.of(context).backgroundColor,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              InkWell(
                                  onTap: () async {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    await Navigator.of(context).pushNamed(
                                      Routes.WalletHome,
                                      arguments: _wallet,
                                    );
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  },
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 2,horizontal: 24),
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          Theme.of(context).backgroundColor,
                                      child: Image.asset(
                                        AvailableCoins()
                                            .getSpecificCoin(_wallet.name)
                                            .iconPath,
                                        width: 25,
                                      ),
                                    ),
                                    title: Text(
                                      _wallet.title,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                        color: Theme.of(context).dividerColor,
                                      ),
                                    ),
                                    subtitle: Row(
                                      children: [
                                        Text(
                                          (_wallet.balance / 1000000).toString(),
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          _wallet.letterCode,
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Theme.of(context).dividerColor,
                                    ),
                                  )),
                            ],
                          ),
                        );
                      }
                      else if (i==listData.length && listData.length<2){
                        return Card(
                          elevation: 2,
                          shadowColor: Theme.of(context).dividerColor,
                          color: Theme.of(context).backgroundColor,
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              InkWell(
                                  onTap: () {
                                    if (_initial == false) {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return NewWalletDialog();
                                          });
                                    }
                                  },
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.fromLTRB(32, 2, 24, 2),
                                    trailing: CircleAvatar(
                                      backgroundColor: Theme.of(context).backgroundColor,
                                      child: Icon(Icons.add, size: 30,),
                                    ),
                                    title: Text(
                                      'Add wallet',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                        color: Theme.of(context).dividerColor,
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        );
                      }
                      else{
                        return Container();
                      }
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 16,)
          ],
        ),
      ),
    );
  }
}

/*
*Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ElevatedButton(
                  key: Key('newWalletIconButton'),
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).backgroundColor,
                    onPrimary: Theme.of(context).primaryColor,
                    shadowColor: Theme.of(context).dividerColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                    if (_initial == false) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return NewWalletDialog();
                          });
                    }
                  },
                  child: FittedBox(
                    child: Text(
                      'Add',
                      style: TextStyle(
                          letterSpacing: 1.4,
                          fontSize: 16,
                          color: Theme.of(context).dividerColor,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ),
*
* */
