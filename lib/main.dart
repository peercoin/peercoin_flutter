import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:peercoin/models/app_options.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/screens/setup_pin_code.dart';
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
import './screens/new_wallet.dart';
import './screens/qrcodescanner.dart';
import './screens/transaction_details.dart';
import './screens/wallet_home.dart';
import './screens/setup_save_seed.dart';
import './screens/setup.dart';
import './screens/wallet_list.dart';
import 'screens/app_settings_screen.dart';
import 'tools/app_localizations.dart';

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
          //GlobalWidgetsLocalizations.delegate,
        ],
        theme: ThemeData(
          textTheme: Theme.of(context).textTheme.apply(
                fontSizeFactor: 1.1,
                fontSizeDelta: 2.0,
              ),
          primaryColor: Color.fromRGBO(60, 176, 84, 1),
          accentColor: Colors.grey,
          errorColor: Colors.red,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(primary: Colors.white),
          ),
        ),
        home: setupFinished ? WalletListScreen() : SetupScreen(),
        routes: {
          SetupSaveScreen.routeName: (ctx) => SetupSaveScreen(),
          SetupPinCodeScreen.routeName: (ctx) => SetupPinCodeScreen(),
          WalletListScreen.routeName: (ctx) => WalletListScreen(),
          WalletHomeScreen.routeName: (ctx) => WalletHomeScreen(),
          NewWalletScreen.routeName: (ctx) => NewWalletScreen(),
          QRScanner.routeName: (ctx) => QRScanner(),
          TransactionDetails.routeName: (ctx) => TransactionDetails(),
          AppSettingsScreen.routeName: (ctx) => AppSettingsScreen(),
        },
      ),
    );
  }
}

//TODO: null safety when bitcoin_flutter is null_safe as well (crypto^3.0.0)
