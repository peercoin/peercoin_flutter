import 'package:flutter/widgets.dart';
import 'package:peercoin/screens/wallet/transaction_confirmation.dart';
import 'package:peercoin/screens/wallet/wallet_verify_message.dart';

import '../screens/settings/app_settings_app_theme.dart';
import '../screens/settings/app_settings_authentication.dart';
import '../screens/settings/app_settings_default_wallet.dart';
import '../screens/settings/app_settings_language.dart';
import '../screens/settings/app_settings_notifications.dart';
import '../screens/settings/app_settings_price_feed.dart';
import '../screens/settings/app_settings_screen.dart';
import '../screens/auth_jail.dart';
import '../screens/changelog.dart';
import '../screens/qrcode_scanner.dart';
import '../screens/server_settings/server_add.dart';
import '../screens/server_settings/server_settings.dart';
import '../screens/setup/setup_create_wallet.dart';
import '../screens/setup/setup_data_feeds.dart';
import '../screens/setup/setup_import_seed.dart';
import '../screens/setup/setup_language.dart';
import '../screens/router_master.dart';
import '../screens/setup/setup_auth.dart';
import '../screens/setup/setup_legal.dart';
import '../screens/wallet/address_selector.dart';
import '../screens/wallet/import_paper_wallet.dart';
import '../screens/wallet/import_wif.dart';
import '../screens/wallet/transaction_details.dart';
import '../screens/wallet/wallet_home.dart';
import '../screens/wallet/wallet_import_scan.dart';
import '../screens/wallet/wallet_list.dart';
import '../screens/wallet/wallet_sign_message.dart';

class Routes {
  // Route name constants
  static const String walletList = '/wallet-list';
  static const String appSettings = '/app-settings';
  static const String appSettingsNotifications = '/app-settings-notifications';
  static const String appSettingsPriceFeed = '/app-settings-price-feed';
  static const String appSettingsLanguage = '/app-settings-language';
  static const String appSettingsDefaultWallet = '/app-settings-default-wallet';
  static const String appSettingsAppTheme = '/app-settings-app-theme';
  static const String appSettingsAuthentication =
      '/app-settings-authentication';
  static const String qrScan = '/qr-scan';
  static const String setupAuth = '/setup-auth';
  static const String setupCreateWallet = '/setup-create-wallet';
  static const String setupImport = '/setup-import-seed';
  static const String setupLanguage = '/setup-language';
  static const String setupDataFeeds = '/setup-feeds';
  static const String setupLegal = '/setup-legal';
  static const String transaction = '/tx-detail';
  static const String walletHome = '/wallet-home';
  static const String walletMessageSigning = '/wallet-message-signing';
  static const String walletMessageVerification =
      '/wallet-message-verification';
  static const String walletImportScan = '/wallet-import-scan';
  static const String importPaperWallet = '/import-paperwallet';
  static const String importWif = '/import-wif';
  static const String authJail = '/auth-jail';
  static const String serverSettings = '/server-settings';
  static const String serverAdd = '/server-add';
  static const String changeLog = '/changelog';
  static const String addressSelector = '/address-selector';
  static const String transactionConfirmation = '/transaction-confirmation';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      Routes.setupCreateWallet: (context) => const RouterMaster(
            widget: SetupCreateWalletScreen(),
            routeType: RouteTypes.setupOnly,
          ),
      Routes.setupAuth: (context) => const RouterMaster(
            widget: SetupAuthScreen(),
            routeType: RouteTypes.setupOnly,
          ),
      Routes.setupLanguage: (context) => const RouterMaster(
            widget: SetupLanguageScreen(),
            routeType: RouteTypes.setupOnly,
          ),
      Routes.walletList: (context) => const RouterMaster(
            widget: WalletListScreen(),
            routeType: RouteTypes.requiresSetupFinished,
          ),
      Routes.walletHome: (context) => const RouterMaster(
            widget: WalletHomeScreen(),
            routeType: RouteTypes.requiresArguments,
          ),
      Routes.qrScan: (context) => const RouterMaster(
            widget: QRScanner(),
            routeType: RouteTypes.requiresArguments,
          ),
      Routes.transaction: (context) => const RouterMaster(
            widget: TransactionDetails(),
            routeType: RouteTypes.requiresArguments,
          ),
      Routes.appSettings: (context) => const RouterMaster(
            widget: AppSettingsScreen(),
            routeType: RouteTypes.requiresSetupFinished,
          ),
      Routes.setupImport: (context) => const RouterMaster(
            widget: SetupImportSeedScreen(),
            routeType: RouteTypes.setupOnly,
          ),
      Routes.walletImportScan: (context) => const RouterMaster(
            widget: WalletImportScanScreen(),
            routeType: RouteTypes.requiresArguments,
          ),
      Routes.walletMessageSigning: (context) => const RouterMaster(
            widget: WalletMessageSigningScreen(),
            routeType: RouteTypes.requiresArguments,
          ),
      Routes.walletMessageVerification: (context) => const RouterMaster(
            widget: WaleltMessagesVerificationScreen(),
            routeType: RouteTypes.requiresArguments,
          ),
      Routes.addressSelector: (context) => const RouterMaster(
            widget: AddressSelectorScreen(),
            routeType: RouteTypes.requiresArguments,
          ),
      Routes.importPaperWallet: (context) => const RouterMaster(
            widget: ImportPaperWalletScreen(),
            routeType: RouteTypes.requiresArguments,
          ),
      Routes.importWif: (context) => const RouterMaster(
            widget: ImportWifScreen(),
            routeType: RouteTypes.requiresArguments,
          ),
      Routes.authJail: (context) => const RouterMaster(
            widget: AuthJailScreen(),
            routeType: RouteTypes.requiresArguments,
          ),
      Routes.serverSettings: (context) => const RouterMaster(
            widget: ServerSettingsScreen(),
            routeType: RouteTypes.requiresArguments,
          ),
      Routes.serverAdd: (context) => const RouterMaster(
            widget: ServerAddScreen(),
            routeType: RouteTypes.requiresArguments,
          ),
      Routes.setupDataFeeds: (context) => const RouterMaster(
            widget: SetupDataFeedsScreen(),
            routeType: RouteTypes.setupOnly,
          ),
      Routes.setupLegal: (context) => const RouterMaster(
            widget: SetupLegalScreen(),
            routeType: RouteTypes.setupOnly,
          ),
      Routes.changeLog: (context) => const RouterMaster(
            widget: ChangeLogScreen(),
            routeType: RouteTypes.requiresSetupFinished,
          ),
      Routes.appSettingsNotifications: (context) => const RouterMaster(
            widget: AppSettingsNotificationsScreen(),
            routeType: RouteTypes.requiresSetupFinished,
          ),
      Routes.transactionConfirmation: (context) => const RouterMaster(
            widget: TransactionConfirmationScreen(),
            routeType: RouteTypes.requiresSetupFinished,
          ),
      Routes.appSettingsLanguage: (context) => const RouterMaster(
            widget: AppSettingsLanguageScreen(),
            routeType: RouteTypes.requiresSetupFinished,
          ),
      Routes.appSettingsDefaultWallet: (context) => const RouterMaster(
            widget: AppSettingsDefaultWalletScreen(),
            routeType: RouteTypes.requiresSetupFinished,
          ),
      Routes.appSettingsAuthentication: (context) => const RouterMaster(
            widget: AppSettingsAuthenticationScreen(),
            routeType: RouteTypes.requiresSetupFinished,
          ),
      Routes.appSettingsPriceFeed: (context) => const RouterMaster(
            widget: AppSettingsPriceFeedScreen(),
            routeType: RouteTypes.requiresSetupFinished,
          ),
      Routes.appSettingsAppTheme: (context) => const RouterMaster(
            widget: AppSettingsAppThemeScreen(),
            routeType: RouteTypes.requiresSetupFinished,
          ),
    };
  }
}
