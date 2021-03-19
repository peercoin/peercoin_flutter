import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:peercoin/models/coinwallet.dart';
import 'package:peercoin/models/walletaddress.dart';
import 'package:peercoin/models/wallettransaction.dart';
import 'package:peercoin/models/walletutxo.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/providers/electrumconnection.dart';
import 'package:peercoin/screens/new_wallet.dart';
import 'package:peercoin/screens/qrcodescanner.dart';
import 'package:peercoin/screens/wallet_home.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './providers/encryptedbox.dart';
import './providers/options.dart';
import './screens/setup_save_seed.dart';
import 'screens/setup.dart';
import 'screens/wallet_list.dart';

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
  //

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Options()),
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
            return ElectrumConnection(
              Provider.of<ActiveWallets>(context, listen: false),
            );
          },
        )
      ],
      child: MaterialApp(
        title: 'Peercoin Testnet Wallet',
        theme: ThemeData(
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
          WalletListScreen.routeName: (ctx) => WalletListScreen(),
          WalletHomeScreen.routeName: (ctx) => WalletHomeScreen(),
          NewWalletScreen.routeName: (ctx) => NewWalletScreen(),
          QRScanner.routeName: (ctx) => QRScanner()
        },
      ),
    );
  }
}

//TODO: Setup LocalAuth
//TODO: null safety when bitcoin_flutter is null_safe as well (crypto^3.0.0)
