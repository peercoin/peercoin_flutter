import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:peercoin/models/app_options.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './models/coinwallet.dart';
import './models/walletaddress.dart';
import './models/wallettransaction.dart';
import './models/walletutxo.dart';
import './providers/activewallets.dart';
import './providers/electrumconnection.dart';
import './providers/encryptedbox.dart';
import 'providers/unencryptedOptions.dart';
import './screens/setup.dart';
import './screens/wallet_list.dart';
import 'tools/app_localizations.dart';
import 'tools/app_routes.dart';
import 'tools/app_themes.dart';

bool setupFinished;

void main() async {
  //init sharedpreferences
  WidgetsFlutterBinding.ensureInitialized();
  var prefs = await SharedPreferences.getInstance();
  setupFinished = prefs.getBool("setupFinished") ?? false;

  //init hive
  await Hive.initFlutter();
  Hive.registerAdapter(CoinWalletAdapter());
  Hive.registerAdapter(WalletTransactionAdapter());
  Hive.registerAdapter(WalletAddressAdapter());
  Hive.registerAdapter(WalletUtxoAdapter());
  Hive.registerAdapter(AppOptionsStoreAdapter());

  //init notifications
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@drawable/splash');
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
  });

  //run
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
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
            return ElectrumConnection(
              Provider.of<ActiveWallets>(context, listen: false),
            );
          },
        )
      ],
      child: MaterialApp(
        title: 'Peercoin',
        supportedLocales: [
          const Locale('en', 'US'), // default
          const Locale('nl', 'NL'),
        ],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
        ],
        themeMode: ThemeMode.system, // Default
        theme: MyTheme.getTheme(ThemeMode.light),
        darkTheme: MyTheme.getTheme(ThemeMode.dark),
        home: setupFinished ? WalletListScreen() : SetupScreen(),
        routes: Routes.getRoutes(),
      ),
    );
  }
}

//TODO: null safety when bitcoin_flutter is null_safe as well (crypto^3.0.0)
