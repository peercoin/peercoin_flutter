import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/available_coins.dart';
import '../../models/hive/coin_wallet.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../tools/app_localizations.dart';
import '../../tools/app_routes.dart';
import '../../tools/auth.dart';
import '../../tools/background_sync.dart';
import '../../tools/debug_log_handler.dart';
import '../../tools/periodic_reminders.dart';
import '../../tools/price_ticker.dart';
import '../../tools/share_wrapper.dart';
import '../../widgets/spinning_peercoin_icon.dart';
import '../../widgets/wallet/new_wallet.dart';
import '../../tools/session_checker.dart';
import '../../widgets/buttons.dart';
import '../../widgets/logout_dialog_dummy.dart'
    if (dart.library.html) '../../widgets/logout_dialog.dart';

class WalletListScreen extends StatefulWidget {
  final bool fromColdStart;
  final String walletToOpenDirectly;

  @override
  State<WalletListScreen> createState() => _WalletListScreenState();

  const WalletListScreen({
    Key? key,
    this.fromColdStart = false,
    this.walletToOpenDirectly = '',
  }) : super(key: key);
}

class _WalletListScreenState extends State<WalletListScreen>
    with SingleTickerProviderStateMixin {
  bool _initial = true;
  late bool _importedSeed;
  late WalletProvider _walletProvider;
  late Animation<double> _animation;
  late AnimationController _controller;
  late Timer _priceTimer;
  late Timer _sessionTimer;
  late AppSettingsProvider _appSettings;
  late List<CoinWallet> _activeWalletsOrdered;

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

  Future<void> _orderWallets() async {
    final values = _walletProvider.availableWalletValues;
    final order = _appSettings.walletOrder;
    values.sort(
      (a, b) => order.indexOf(a.name).compareTo(
            order.indexOf(b.name),
          ),
    );
    _activeWalletsOrdered = values;
  }

  void _triggerChangeLogCheck(
    NavigatorState navigator,
    String identifierInSettings,
  ) async {
    var packageInfo = await PackageInfo.fromPlatform();
    if (packageInfo.buildNumber != identifierInSettings) {
      await navigator.pushNamed(Routes.changeLog);
      _appSettings.setBuildIdentifier(packageInfo.buildNumber);
    }
  }

  Future<bool> checkReminder() async {
    return await PeriodicReminders.checkReminder(
      _appSettings,
      context,
    );
  }

  Future<void> handleInitError(Object e) async {
    LoggerWrapper.logError(
      'WalletListScreen',
      'didChangeDependencies',
      e.toString(),
    );

    //automatically toggle exportLogs for this event, since it is very likely app settings can not be accessed
    await initDebugLogHandler();
    FlutterLogs.exportLogs();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.instance.translate(
              'secure_storage_app_bar_title',
            ),
            textAlign: TextAlign.center,
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  void didChangeDependencies() async {
    if (_initial) {
      _appSettings = Provider.of<AppSettingsProvider>(context);
      _walletProvider = Provider.of<WalletProvider>(context);
      final navigator = Navigator.of(context);
      final modalRoute = ModalRoute.of(context);

      try {
        await _appSettings.init(); //only required in home widget
        await _walletProvider.init();
        await _orderWallets();
        final prefs = await SharedPreferences.getInstance();
        _importedSeed = prefs.getBool('importedSeed') == true;
      } catch (e) {
        await handleInitError(e);
      } finally {
        setState(() {
          _initial = false;
        });
      }

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
        _triggerChangeLogCheck(
          navigator,
          _appSettings.buildIdentifier,
        );

        //toggle periodic reminders
        if (_activeWalletsOrdered.isNotEmpty) {
          //don't show for users with no wallets
          if (await checkReminder() == true) {
            return; //don't execute code below this line if checkReminder returned true
          }
        }
      } else {
        //start session checker timer on web
        _sessionTimer = Timer.periodic(
          const Duration(minutes: 10),
          (timer) async {
            if (await checkSessionExpired()) {
              if (mounted) {
                Navigator.of(context).pop();
              }
              LogoutDialog.reloadWindow();
            }
          },
        );
      }

      //check if we just finished a scan
      var fromScan = false;
      if (modalRoute?.settings.arguments != null) {
        var map = modalRoute!.settings.arguments as Map;
        fromScan = map['fromScan'] ?? false;
      }
      if (widget.fromColdStart == true &&
          _appSettings.authenticationOptions!['walletList']!) {
        if (mounted) {
          await Auth.requireAuth(
            context: context,
            biometricsAllowed: _appSettings.biometricsAllowed,
            canCancel: false,
          );
        }
      } else if (fromScan == false) {
        //init background tasks
        if (_appSettings.notificationInterval > 0) {
          await BackgroundSync.init(
            notificationInterval: _appSettings.notificationInterval,
          );
        }
        //find default wallet

        CoinWallet? defaultWallet;
        //push to wallet directly (from notification) or to default wallet
        if (widget.walletToOpenDirectly.isNotEmpty) {
          defaultWallet = _activeWalletsOrdered.firstWhereOrNull(
            (elem) => elem.name == widget.walletToOpenDirectly,
          );
        } else {
          defaultWallet = _activeWalletsOrdered.firstWhereOrNull(
            (elem) => elem.letterCode == _appSettings.defaultWallet,
          );
        }
        //push to default wallet
        if (_activeWalletsOrdered.length == 1 &&
            widget.walletToOpenDirectly.isEmpty) {
          //only one wallet available, pushing to that one (no walletToOpenDirectly set)
          if (!kIsWeb) {
            if (mounted) {
              context.loaderOverlay.show();
            }
            await navigator.pushNamed(
              Routes.walletHome,
              arguments: {
                'wallet': _activeWalletsOrdered.first,
              },
            );
          }
        } else if (_activeWalletsOrdered.length > 1 ||
            widget.walletToOpenDirectly.isNotEmpty) {
          if (defaultWallet != null) {
            if (mounted) {
              context.loaderOverlay.show();
            }
            if (!kIsWeb) {
              await navigator.pushNamed(
                Routes.walletHome,
                arguments: {'wallet': defaultWallet},
              );
            }
          }
        }
      }
    }

    //always on didChangeDependencies
    await _orderWallets();

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
          key: const Key('appSettingsButton'),
          icon: const Icon(Icons.settings_rounded),
          onPressed: () async {
            await Navigator.pushNamed(context, Routes.appSettings);
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
            ),
        ],
      ),
      body: _initial
          ? const Center(
              child: SpinningPeercoinIcon(),
            )
          : Container(
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
                              color: Theme.of(context).colorScheme.background,
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
                        color: Theme.of(context).colorScheme.background,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  _activeWalletsOrdered.isEmpty
                      ? Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.instance.translate(
                                  'wallets_none',
                                ),
                                key: const Key('noActiveWallets'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color:
                                      Theme.of(context).colorScheme.background,
                                ),
                              ),
                              if (_importedSeed)
                                const SizedBox(
                                  height: 20,
                                ),
                              if (_importedSeed)
                                PeerButtonBorder(
                                  key: const Key('scanForWalletsButton'),
                                  text: AppLocalizations.instance.translate(
                                    'scan_for_wallets',
                                  ),
                                  action: () => Navigator.of(context).pushNamed(
                                    Routes.appSettingsWalletScanner,
                                  ),
                                ),
                              const SizedBox(
                                height: 20,
                              ),
                              PeerButtonBorder(
                                text: AppLocalizations.instance.translate(
                                  'add_new_wallet',
                                ),
                                action: () => showWalletDialog(context),
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width > 1200
                                ? MediaQuery.of(context).size.width / 2
                                : MediaQuery.of(context).size.width,
                            child: ListView.builder(
                              itemCount: _activeWalletsOrdered.length,
                              itemBuilder: (ctx, i) {
                                CoinWallet wallet = _activeWalletsOrdered[i];
                                String balance = (wallet.balance /
                                        AvailableCoins.getDecimalProduct(
                                          identifier: wallet.name,
                                        ))
                                    .toString();
                                bool showFiat = wallet.letterCode != 'tPPC' &&
                                    _appSettings.selectedCurrency.isNotEmpty;
                                return Card(
                                  elevation: 0,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 16,
                                  ),
                                  color:
                                      Theme.of(context).colorScheme.background,
                                  child: Column(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          context.loaderOverlay.show();
                                          await Navigator.of(context).pushNamed(
                                            Routes.walletHome,
                                            arguments: {
                                              'wallet': wallet,
                                            },
                                          );
                                        },
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.white,
                                            child: Image.asset(
                                              AvailableCoins.getSpecificCoin(
                                                wallet.name,
                                              ).iconPath,
                                              width: 20,
                                            ),
                                          ),
                                          title: Text(
                                            wallet.title,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          subtitle: Row(
                                            children: [
                                              Flexible(
                                                flex: 2,
                                                child: Text(
                                                  '$balance ${wallet.letterCode}',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                  overflow:
                                                      TextOverflow.visible,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 4,
                                              ),
                                              if (showFiat) const Text('|'),
                                              const SizedBox(
                                                width: 4,
                                              ),
                                              if (showFiat)
                                                Flexible(
                                                  child: Text(
                                                    '${PriceTicker.renderPrice(
                                                      double.parse(balance),
                                                      _appSettings
                                                          .selectedCurrency,
                                                      wallet.letterCode,
                                                      _appSettings
                                                          .exchangeRates,
                                                    ).toStringAsFixed(2)} ${_appSettings.selectedCurrency}',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
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
