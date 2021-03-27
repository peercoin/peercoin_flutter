import 'package:flutter/widgets.dart';
import 'package:peercoin/screens/app_settings_screen.dart';
import 'package:peercoin/screens/new_wallet.dart';
import 'package:peercoin/screens/qrcodescanner.dart';
import 'package:peercoin/screens/setup_import_seed.dart';
import 'package:peercoin/screens/setup_pin_code.dart';
import 'package:peercoin/screens/setup_save_seed.dart';
import 'package:peercoin/screens/transaction_details.dart';
import 'package:peercoin/screens/wallet_home.dart';
import 'package:peercoin/screens/wallet_list.dart';

class Routes {
  // Route name constants
  static const String WalletList = "/wallet-list";
  static const String AppSettings = "/app-settings";
  static const String NewWallet = "/new-wallet";
  static const String QRScan = "/qr-scan";
  static const String SetUpPin = "/setup-pin";
  static const String SetupScreen = "/setup-save-seed";
  static const String SetupImport = "/setup-import-seed";
  static const String Transaction = "/tx-detail";
  static const String WalletHome = "/wallet-home";

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      Routes.SetupScreen: (context) => SetupSaveScreen(),
      Routes.SetUpPin: (context) => SetupPinCodeScreen(),
      Routes.WalletList: (context) => WalletListScreen(),
      Routes.WalletHome: (context) => WalletHomeScreen(),
      Routes.NewWallet: (context) => NewWalletScreen(),
      Routes.QRScan: (context) => QRScanner(),
      Routes.Transaction: (context) => TransactionDetails(),
      Routes.AppSettings: (context) => AppSettingsScreen(),
      Routes.SetupImport: (context) => SetupImportSeed()
    };
  }
}
