import 'package:flutter/widgets.dart';
import 'package:peercoin/screens/addressbook.dart';
import 'package:peercoin/screens/app_settings_screen.dart';
import 'package:peercoin/screens/auth_jail.dart';
import 'package:peercoin/screens/import_paper_wallet.dart';
import 'package:peercoin/screens/qrcodescanner.dart';
import 'package:peercoin/screens/server_add.dart';
import 'package:peercoin/screens/server_settings.dart';
import 'package:peercoin/screens/setup_import_seed.dart';
import 'package:peercoin/screens/setup_pin_code.dart';
import 'package:peercoin/screens/setup_save_seed.dart';
import 'package:peercoin/screens/transaction_details.dart';
import 'package:peercoin/screens/wallet_home.dart';
import 'package:peercoin/screens/wallet_import_scan.dart';
import 'package:peercoin/screens/wallet_list.dart';

class Routes {
  // Route name constants
  static const String WalletList = '/wallet-list';
  static const String AppSettings = '/app-settings';
  static const String QRScan = '/qr-scan';
  static const String SetUpPin = '/setup-pin';
  static const String SetupScreen = '/setup-save-seed';
  static const String SetupImport = '/setup-import-seed';
  static const String Transaction = '/tx-detail';
  static const String WalletHome = '/wallet-home';
  static const String WalletImportScan = '/wallet-import-scan';
  static const String ImportPaperWallet = '/import-paperwallet';
  static const String AuthJail = '/auth-jail';
  static const String ServerSettings = '/server-settings';
  static const String ServerAdd = '/server-add';
  static const String AddressBook = '/addressbook';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      Routes.SetupScreen: (context) => SetupSaveScreen(),
      Routes.SetUpPin: (context) => SetupPinCodeScreen(),
      Routes.WalletList: (context) => WalletListScreen(),
      Routes.WalletHome: (context) => WalletHomeScreen(),
      Routes.QRScan: (context) => QRScanner(),
      Routes.Transaction: (context) => TransactionDetails(),
      Routes.AppSettings: (context) => AppSettingsScreen(),
      Routes.SetupImport: (context) => SetupImportSeedScreen(),
      Routes.WalletImportScan: (context) => WalletImportScanScreen(),
      Routes.ImportPaperWallet: (context) => ImportPaperWalletScreen(),
      Routes.AuthJail: (context) => AuthJailScreen(),
      Routes.ServerSettings: (context) => ServerSettingsScreen(),
      Routes.ServerAdd: (context) => ServerAddScreen(),
      Routes.AddressBook: (context) => AddressBookScreen()
    };
  }
}
