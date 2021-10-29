import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/models/availablecoins.dart';
import 'package:peercoin/models/coinwallet.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/tools/auth.dart';
import 'package:peercoin/tools/backgroundsync.dart';
import 'package:peercoin/tools/price_ticker.dart';
import 'package:peercoin/widgets/loading_indicator.dart';
import 'package:peercoin/widgets/wallet/new_wallet.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class WalletListScreen extends StatefulWidget {
  final bool fromColdStart;
  final String walletToOpenDirectly;

  @override
  _WalletListScreenState createState() => _WalletListScreenState();
  WalletListScreen({
    this.fromColdStart = false,
    this.walletToOpenDirectly = '',
  });
}

class _WalletListScreenState extends State<WalletListScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _initial = true;
  late ActiveWallets _activeWallets;
  late Animation<double> _animation;
  late AnimationController _controller;
  late Timer _priceTimer;
  late AppSettings _appSettings;

  @override
  void initState() {
    //init animation controller
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween(begin: 88.0, end: 92.0).animate(_controller);
    _controller.repeat(reverse: true);
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    _activeWallets = Provider.of<ActiveWallets>(context);
    _appSettings = Provider.of<AppSettings>(context, listen: false);
    await _appSettings.init(); //only required in home widget
    await _activeWallets.init();
    if (_initial) {
      //toggle price ticker update if enabled in settings
      if (_appSettings.selectedCurrency.isNotEmpty) {
        PriceTicker.checkUpdate(_appSettings);
        //start timer to update data hourly
        _priceTimer = Timer.periodic(
          const Duration(hours: 1),
          (_) {
            PriceTicker.checkUpdate(_appSettings);
          },
        );
      }
      //toggle check for "whats new" changelog
      var _packageInfo = await PackageInfo.fromPlatform();
      if (_packageInfo.buildNumber != _appSettings.buildIdentifier) {
        await Navigator.of(context).pushNamed(Routes.ChangeLog);
        _appSettings.setBuildIdentifier(_packageInfo.buildNumber);
      }
      //check if we just finished a scan
      var fromScan = false;
      if (ModalRoute.of(context)?.settings.arguments != null) {
        var map = ModalRoute.of(context)!.settings.arguments as Map;
        fromScan = map['fromScan'] ?? false;
      }
      if (widget.fromColdStart == true &&
          _appSettings.authenticationOptions!['walletList']!) {
        await Auth.requireAuth(context, _appSettings.biometricsAllowed);
      } else if (fromScan == false) {
        //init background tasks
        if (_appSettings.notificationInterval > 0) {
          await BackgroundSync.init(
            notificationInterval: _appSettings.notificationInterval,
          );
        }
        final values = await _activeWallets.activeWalletsValues;
        //find default wallet
        late var defaultWallet;
        //push to wallet directly (from notification) or to default wallet
        if (widget.walletToOpenDirectly.isNotEmpty) {
          defaultWallet = values.firstWhereOrNull(
              (elem) => elem.name == widget.walletToOpenDirectly);
        } else {
          defaultWallet = values.firstWhereOrNull(
              (elem) => elem.letterCode == _appSettings.defaultWallet);
        }
        //push to default wallet
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
    if (_appSettings.selectedCurrency.isNotEmpty) {
      _priceTimer.cancel();
    }
    _controller.dispose();
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
        leading: IconButton(
          icon: Icon(Icons.settings_rounded),
          onPressed: () async {
            await Navigator.pushNamed(context, Routes.AppSettings);
            setState(() {});
          },
        ),
        actions: [
          IconButton(
            key: Key('newWalletIconButton'),
            onPressed: () {
              if (_initial == false) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return NewWalletDialog();
                    });
              }
            },
            icon: Icon(Icons.add_rounded),
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
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (ctx, child) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 92,
                        ),
                        child: Container(
                          height: _animation.value,
                          width: _animation.value,
                          decoration: BoxDecoration(
                            color: Theme.of(context).shadowColor,
                            borderRadius:
                                BorderRadius.all(const Radius.circular(50.0)),
                            border: Border.all(
                              color: Theme.of(context).backgroundColor,
                              width: 2,
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
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Peercoin Wallet',
                      style: TextStyle(
                        letterSpacing: 1.4,
                        fontSize: 24,
                        color: Theme.of(context).backgroundColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  FutureBuilder(
                    future: _activeWallets.activeWalletsValues,
                    builder: (_, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Expanded(
                          child: Center(child: LoadingIndicator()),
                        );
                      }
                      var listData = snapshot.data! as List;
                      if (listData.isEmpty) {
                        return Expanded(
                          child: Center(
                            child: Text(
                              AppLocalizations.instance
                                  .translate('wallets_none'),
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
                          itemCount: listData.length,
                          itemBuilder: (ctx, i) {
                            CoinWallet _wallet = listData[i];
                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              color: Theme.of(context).backgroundColor,
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
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          child: Image.asset(
                                              AvailableCoins()
                                                  .getSpecificCoin(_wallet.name)
                                                  .iconPath,
                                              width: 20),
                                        ),
                                        title: Text(
                                          _wallet.title,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        subtitle: Row(
                                          children: [
                                            Text(
                                              (_wallet.balance / 1000000)
                                                  .toString(),
                                              style: TextStyle(
                                                fontSize: 14,
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      )),
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
