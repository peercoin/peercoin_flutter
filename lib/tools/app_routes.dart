import 'package:flutter/widgets.dart';

import '../screens/app_settings_notifications.dart';
import '../screens/app_settings_screen.dart';
import '../screens/auth_jail.dart';
import '../screens/changelog.dart';
import '../screens/qrcode_scanner.dart';
import '../screens/server_add.dart';
import '../screens/server_settings.dart';
import '../screens/setup/setup_create_wallet.dart';
import '../screens/setup/setup_data_feeds.dart';
import '../screens/setup/setup_import_seed.dart';
import '../screens/setup/setup_language.dart';
import '../screens/setup/router_master.dart';
import '../screens/setup/setup_pin_code.dart';
import '../screens/wallet/import_paper_wallet.dart';
import '../screens/wallet/import_wif.dart';
import '../screens/wallet/transaction_details.dart';
import '../screens/wallet/wallet_home.dart';
import '../screens/wallet/wallet_import_scan.dart';
import '../screens/wallet/wallet_list.dart';

class Routes {
  // Route name constants
  static const String WalletList = '/wallet-list';
  static const String AppSettings = '/app-settings';
  static const String AppSettingsNotifications = '/app-settings-notifications';
  static const String QRScan = '/qr-scan';
  static const String SetUpPin = '/setup-pin';
  static const String SetupCreateWallet = '/setup-create-wallet';
  static const String SetupImport = '/setup-import-seed';
  static const String SetupLanguage = '/setup-language';
  static const String SetupDataFeeds = '/setup-feeds';
  static const String Transaction = '/tx-detail';
  static const String WalletHome = '/wallet-home';
  static const String WalletImportScan = '/wallet-import-scan';
  static const String ImportPaperWallet = '/import-paperwallet';
  static const String ImportWif = '/import-wif';
  static const String AuthJail = '/auth-jail';
  static const String ServerSettings = '/server-settings';
  static const String ServerAdd = '/server-add';
  static const String ChangeLog = '/changelog';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      Routes.SetupCreateWallet: (context) => RouterMaster(
            widget: SetupCreateWalletScreen(),
            routeType: RouteTypes.setupOnly,
          ),
      Routes.SetUpPin: (context) => RouterMaster(
            widget: SetupPinCodeScreen(),
            routeType: RouteTypes.setupOnly,
          ),
      Routes.SetupLanguage: (context) => RouterMaster(
            widget: SetupLanguageScreen(),
            routeType: RouteTypes.setupOnly,
          ),
      Routes.WalletList: (context) => RouterMaster(
            widget: WalletListScreen(),
            routeType: RouteTypes.requiresSetupFinished,
          ),
      Routes.WalletHome: (context) => RouterMaster(
            widget: WalletHomeScreen(),
            routeType: RouteTypes.requiresArguments,
          ),
      Routes.QRScan: (context) => RouterMaster(
            widget: QRScanner(),
            routeType: RouteTypes.requiresArguments,
          ),
      Routes.Transaction: (context) => RouterMaster(
            widget: TransactionDetails(),
            routeType: RouteTypes.requiresArguments,
          ),
      Routes.AppSettings: (context) => RouterMaster(
            widget: AppSettingsScreen(),
            routeType: RouteTypes.requiresSetupFinished,
          ),
      Routes.SetupImport: (context) => RouterMaster(
            widget: SetupImportSeedScreen(),
            routeType: RouteTypes.setupOnly,
          ),
      Routes.WalletImportScan: (context) => RouterMaster(
            widget: WalletImportScanScreen(),
            routeType: RouteTypes.requiresArguments,
          ),
      Routes.ImportPaperWallet: (context) => RouterMaster(
            widget: ImportPaperWalletScreen(),
            routeType: RouteTypes.requiresArguments,
          ),
      Routes.ImportWif: (context) => RouterMaster(
            widget: ImportWifScreen(),
            routeType: RouteTypes.requiresArguments,
          ),
      Routes.AuthJail: (context) => RouterMaster(
            widget: AuthJailScreen(),
            routeType: RouteTypes.requiresArguments,
          ),
      Routes.ServerSettings: (context) => RouterMaster(
            widget: ServerSettingsScreen(),
            routeType: RouteTypes.requiresArguments,
          ),
      Routes.ServerAdd: (context) => RouterMaster(
            widget: ServerAddScreen(),
            routeType: RouteTypes.requiresArguments,
          ),
      Routes.SetupDataFeeds: (context) => RouterMaster(
            widget: SetupDataFeedsScreen(),
            routeType: RouteTypes.setupOnly,
          ),
      Routes.ChangeLog: (context) => RouterMaster(
            widget: ChangeLogScreen(),
            routeType: RouteTypes.requiresSetupFinished,
          ),
      Routes.AppSettingsNotifications: (context) => RouterMaster(
            widget: AppSettingsNotificationsScreen(),
            routeType: RouteTypes.requiresSetupFinished,
          ),
    };
  }
}
