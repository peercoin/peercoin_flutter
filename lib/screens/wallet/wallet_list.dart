import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../models/available_coins.dart';
import '../../models/coin_wallet.dart';
import '../../providers/active_wallets.dart';
import '../../providers/app_settings.dart';
import '../../tools/app_localizations.dart';
import '../../tools/app_routes.dart';
import '../../tools/auth.dart';
import '../../tools/background_sync.dart';
import '../../tools/periodic_reminders.dart';
import '../../tools/price_ticker.dart';
import '../../tools/share_wrapper.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/wallet/new_wallet.dart';
import '../../tools/session_checker.dart';
import '../../widgets/buttons.dart';
import '../../widgets/logout_dialog_dummy.dart'
    if (dart.library.html) '../../widgets/logout_dialog.dart';

class WalletListScreen extends StatefulWidget {
  final bool fromColdStart;
  final String walletToOpenDirectly;

  @override
  _WalletListScreenState createState() => _WalletListScreenState();
  const WalletListScreen({
    Key? key,
    this.fromColdStart = false,
    this.walletToOpenDirectly = '',
  }) : super(key: key);
}

class _WalletListScreenState extends State<WalletListScreen>
    with SingleTickerProviderStateMixin {
  bool _initial = true;
  late ActiveWallets _activeWallets;
  late Animation<double> _animation;
  late AnimationController _controller;
  late Timer _priceTimer;
  late Timer _sessionTimer;
  late AppSettings _appSettings;

  @override
  void initState() {
    //init animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
    if (_initial) {
      await _appSettings.init(); //only required in home widget
      await _activeWallets.init();
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

      if (!kIsWeb) {
        //toggle check for "whats new" changelog
        var _packageInfo = await PackageInfo.fromPlatform();
        if (_packageInfo.buildNumber != _appSettings.buildIdentifier) {
          await Navigator.of(context).pushNamed(Routes.changeLog);
          _appSettings.setBuildIdentifier(_packageInfo.buildNumber);
        }

        //toggle periodic reminders
        var _walletValues = await _activeWallets.activeWalletsValues;
        if (_walletValues.isNotEmpty) {
          //don't show for users with no wallets
          await PeriodicReminders.checkReminder(_appSettings, context);
        }
      } else {
        //start session checker timer on web
        _sessionTimer = Timer.periodic(
          const Duration(minutes: 10),
          (timer) async {
            if (await checkSessionExpired()) {
              Navigator.of(context).pop();
              LogoutDialog.reloadWindow();
            }
          },
        );
      }

      //check if we just finished a scan
      var fromScan = false;
      if (ModalRoute.of(context)?.settings.arguments != null) {
        var map = ModalRoute.of(context)!.settings.arguments as Map;
        fromScan = map['fromScan'] ?? false;
      }
      if (widget.fromColdStart == true &&
          _appSettings.authenticationOptions!['walletList']!) {
        await Auth.requireAuth(
          context: context,
          biometricsAllowed: _appSettings.biometricsAllowed,
          canCancel: false,
        );
      } else if (fromScan == false) {
        //init background tasks
        if (_appSettings.notificationInterval > 0) {
          await BackgroundSync.init(
            notificationInterval: _appSettings.notificationInterval,
          );
        }
        final values = await _activeWallets.activeWalletsValues;
        //find default wallet

        CoinWallet? defaultWallet;
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
            _initial = false;
          });
          if (!kIsWeb) {
            await Navigator.of(context).pushNamed(
              Routes.walletHome,
              arguments: values[0],
            );
          }
        } else if (values.length > 1) {
          if (defaultWallet != null) {
            setState(() {
              _initial = false;
            });
            if (!kIsWeb) {
              await Navigator.of(context).pushNamed(
                Routes.walletHome,
                arguments: defaultWallet,
              );
            }
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
    if (kIsWeb) {
      _sessionTimer.cancel();
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
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.settings_rounded),
          onPressed: () async {
            await Navigator.pushNamed(context, Routes.appSettings);
            setState(() {});
          },
        ),
        actions: [
          IconButton(
            key: const Key('newWalletIconButton'),
            onPressed: () {
              showWalletDialog(context);
            },
            icon: const Icon(Icons.add_rounded),
          ),
          if (kIsWeb)
            IconButton(
              key: const Key('logoutButton'),
              onPressed: () async {
                if (_initial == false) {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const LogoutDialog();
                    },
                  );
                }
              },
              icon: const Icon(Icons.logout_rounded),
            )
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (ctx, child) {
                return ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 92,
                  ),
                  child: Container(
                    height: _animation.value,
                    width: _animation.value,
                    decoration: BoxDecoration(
                      color: Theme.of(context).shadowColor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(50.0)),
                      border: Border.all(
                        color: Theme.of(context).backgroundColor,
                        width: 2,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        if (!kIsWeb) {
                          ShareWrapper.share(
                            context: context,
                            message: Platform.isAndroid
                                ? 'https://play.google.com/store/apps/details?id=com.coinerella.peercoin'
                                : 'https://apps.apple.com/app/peercoin-wallet/id1571755170',
                          );
                        }
                      },
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
            const SizedBox(
              height: 40,
            ),
            FutureBuilder(
              future: _activeWallets.activeWalletsValues,
              builder: (_, snapshot) {
                if (snapshot.data == null) {
                  return const Expanded(
                    child: Center(
                      child: LoadingIndicator(),
                    ),
                  );
                }
                var listData = snapshot.data! as List;
                if (listData.isEmpty) {
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.instance.translate('wallets_none'),
                          key: const Key('noActiveWallets'),
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).backgroundColor,
                          ),
                        ),
                        if (kIsWeb)
                          const SizedBox(
                            height: 20,
                          ),
                        if (kIsWeb)
                          PeerButton(
                            text: AppLocalizations.instance
                                .translate('add_new_wallet'),
                            action: () => showWalletDialog(context),
                          )
                      ],
                    ),
                  );
                }
                return Expanded(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width > 1200
                        ? MediaQuery.of(context).size.width / 2
                        : MediaQuery.of(context).size.width,
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
                                  await Navigator.of(context).pushNamed(
                                    Routes.walletHome,
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
                                  title: Text(
                                    _wallet.title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Text(
                                        (_wallet.balance / 1000000).toString(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        _wallet.letterCode,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void showWalletDialog(BuildContext context) {
    if (_initial == false) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const NewWalletDialog();
        },
      );
    }
  }
}
