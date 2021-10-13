import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:peercoin/models/app_options.dart';
import 'package:peercoin/models/server.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/providers/servers.dart';
import 'package:peercoin/screens/auth_jail.dart';
import 'package:peercoin/tools/theme_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_mode_handler/theme_mode_handler.dart';

import './models/coinwallet.dart';
import './models/walletaddress.dart';
import './models/wallettransaction.dart';
import './models/walletutxo.dart';
import './providers/activewallets.dart';
import './providers/electrumconnection.dart';
import './providers/encryptedbox.dart';
import './providers/unencryptedOptions.dart';
import 'screens/setup/setup.dart';
import './screens/wallet/wallet_list.dart';
import './tools/app_localizations.dart';
import './tools/app_routes.dart';
import './tools/app_themes.dart';

late bool setupFinished;
late Widget _homeWidget;
late Locale _locale;

void main() async {
  //init sharedpreferences
  WidgetsFlutterBinding.ensureInitialized();
  var prefs = await SharedPreferences.getInstance();
  setupFinished = prefs.getBool('setupFinished') ?? false;
  _locale = Locale(prefs.getString('language_code') ?? 'und');

  //init hive
  await Hive.initFlutter();
  Hive.registerAdapter(CoinWalletAdapter());
  Hive.registerAdapter(WalletTransactionAdapter());
  Hive.registerAdapter(WalletAddressAdapter());
  Hive.registerAdapter(WalletUtxoAdapter());
  Hive.registerAdapter(AppOptionsStoreAdapter());
  Hive.registerAdapter(ServerAdapter());

  //init notifications
  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

  const initializationSettingsAndroid =
      AndroidInitializationSettings('@drawable/splash');
  final initializationSettingsIOS = IOSInitializationSettings();
  final initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
    if (payload != null) {
      log('notification payload: $payload');
    }
  });

  final notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  //check if app is locked
  final _secureStorage = const FlutterSecureStorage();
  final failedAuths =
      int.parse(await _secureStorage.read(key: 'failedAuths') ?? '0');
  if (setupFinished == false) {
    _homeWidget = SetupScreen();
  } else if (failedAuths > 0) {
    _homeWidget = AuthJailScreen(true);
  } else {
    _homeWidget = WalletListScreen(
      fromColdStart: true,
      walletToOpenDirectly: notificationAppLaunchDetails?.payload ?? '',
    );
  }

  //run
  runApp(PeercoinApp());
}

class PeercoinApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) {
          return UnencryptedOptions();
        }),
        ChangeNotifierProvider.value(value: EncryptedBox()),
        ChangeNotifierProvider(
          create: (context) {
            return ActiveWallets(
              Provider.of<EncryptedBox>(context, listen: false),
            );
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            return AppSettings(
              Provider.of<EncryptedBox>(context, listen: false),
            );
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            return Servers(
              Provider.of<EncryptedBox>(context, listen: false),
            );
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            return ElectrumConnection(
              Provider.of<ActiveWallets>(context, listen: false),
              Provider.of<Servers>(context, listen: false),
            );
          },
        ),
      ],
      child: ThemeModeHandler(
        manager: ThemeManager(),
        builder: (ThemeMode themeMode) {
          return MaterialApp(
            title: 'Peercoin',
            debugShowCheckedModeBanner: false,
            supportedLocales: AppLocalizations.availableLocales.keys
                .map((lang) => Locale(lang)),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            locale: _locale == Locale('und') ? null : _locale,
            themeMode: themeMode,
            theme: MyTheme.getTheme(ThemeMode.light),
            darkTheme: MyTheme.getTheme(ThemeMode.dark),
            home: _homeWidget,
            routes: Routes.getRoutes(),
          );
        },
      ),
    );
  }
}
