import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frost_noosphere/frost_noosphere.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:peercoin/models/hive/frost_group.dart';
import 'package:peercoin/models/hive/hive_frost_client_config_hive_adapter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_mode_handler/theme_mode_handler.dart';

import 'models/hive/app_options.dart';
import 'models/hive/pending_notifications.dart';
import 'models/hive/server.dart';
import 'providers/app_settings_provider.dart';
import 'providers/server_provider.dart';
import 'screens/auth_jail.dart';
import 'screens/secure_storage_error_screen.dart';
import 'tools/logger_wrapper.dart';
import 'tools/theme_manager.dart';
import 'models/hive/coin_wallet.dart';
import 'models/hive/wallet_address.dart';
import 'models/hive/wallet_transaction.dart';
import 'models/hive/wallet_utxo.dart';
import 'providers/wallet_provider.dart';
import 'providers/connection_provider.dart';
import 'providers/encrypted_box_provider.dart';
import 'screens/setup/setup_landing.dart';
import 'screens/wallet/wallet_list.dart';
import 'tools/app_localizations.dart';
import 'tools/app_routes.dart';
import 'tools/app_themes.dart';
import 'tools/session_checker.dart';
import 'widgets/spinning_peercoin_icon.dart';

late bool setupFinished;
late Widget _homeWidget;
late Locale _locale;

void main() async {
  //init sharedpreferences
  WidgetsFlutterBinding.ensureInitialized();
  var prefs = await SharedPreferences.getInstance();
  setupFinished = prefs.getBool('setupFinished') ?? false;
  _locale = Locale(prefs.getString('language_code') ?? 'und');

  //clear storage if setup is not finished
  if (!setupFinished) {
    await prefs.clear();
    LoggerWrapper.logInfo(
      'main',
      'SharedPreferences',
      'SharedPreferences flushed',
    );
  }

  //init hive
  await Hive.initFlutter();
  Hive.registerAdapter(CoinWalletAdapter());
  Hive.registerAdapter(WalletTransactionAdapter());
  Hive.registerAdapter(WalletAddressAdapter());
  Hive.registerAdapter(WalletUtxoAdapter());
  Hive.registerAdapter(AppOptionsStoreAdapter());
  Hive.registerAdapter(ServerAdapter());
  Hive.registerAdapter(PendingNotificationAdapter());
  Hive.registerAdapter(FrostGroupAdapter());
  Hive.registerAdapter(HiveFrostClientConfigAdapter());

  //init coinlib
  await loadCoinlib();

  //init frost
  await loadFrosty();

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
  const initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: DarwinInitializationSettings(),
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (
      NotificationResponse notificationResponse,
    ) async {
      if (notificationResponse.payload != null) {
        LoggerWrapper.logInfo(
          'notification',
          'payload',
          notificationResponse.payload!,
        );
      }
    },
  );

  final notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  //check if app is locked
  var secureStorageError = false;
  var failedAuths = 0;
  var sessionExpired = await checkSessionExpired();

  try {
    const secureStorage = FlutterSecureStorage();
    //clear secureStorage if setup is not finished
    if (!setupFinished) {
      await secureStorage.deleteAll();
      LoggerWrapper.logInfo(
        'main',
        'secureStorage',
        'secureStorage flushed',
      );
    }

    failedAuths =
        int.parse(await secureStorage.read(key: 'failedAuths') ?? '0');
  } catch (e) {
    secureStorageError = true;
    LoggerWrapper.logError('Main', 'secureStorage', e.toString());
  }

  if (secureStorageError == true) {
    _homeWidget = const SecureStorageFailedScreen();
  } else {
    //check web session expired

    if (setupFinished == false || sessionExpired == true) {
      _homeWidget = const SetupLandingScreen();
    } else if (failedAuths > 0) {
      _homeWidget = const AuthJailScreen(
        jailedFromHome: true,
      );
    } else {
      _homeWidget = WalletListScreen(
        fromColdStart: true,
        walletToOpenDirectly:
            notificationAppLaunchDetails?.notificationResponse?.payload ?? '',
      );
    }
  }

  if (!kIsWeb) {
    //init logger
    await FlutterLogs.initLogs(
      logLevelsEnabled: [
        LogLevel.INFO,
        LogLevel.WARNING,
        LogLevel.ERROR,
        LogLevel.SEVERE,
      ],
      timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
      directoryStructure: DirectoryStructure.FOR_DATE,
      logFileExtension: LogFileExtension.LOG,
      logsWriteDirectoryName: 'MyLogs',
      logsExportDirectoryName: 'MyLogs/Exported',
      debugFileOperations: true,
      isDebuggable: true,
    );

    LoggerWrapper.logInfo('main', 'initLogs', 'Init logs..');

    var packageInfo = await PackageInfo.fromPlatform();
    LoggerWrapper.logInfo(
      'main',
      'initLogs',
      'Version ${packageInfo.version} Build ${packageInfo.buildNumber}',
    );
  }

  //run
  runApp(const PeercoinApp());
}

class PeercoinApp extends StatelessWidget {
  const PeercoinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: EncryptedBoxProvider()),
        ChangeNotifierProvider(
          create: (context) {
            return WalletProvider(
              Provider.of<EncryptedBoxProvider>(context, listen: false),
            );
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            return AppSettingsProvider(
              Provider.of<EncryptedBoxProvider>(context, listen: false),
            );
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            return ServerProvider(
              Provider.of<EncryptedBoxProvider>(context, listen: false),
            );
          },
        ),
        ChangeNotifierProvider.value(value: ConnectionProvider()),
      ],
      child: ThemeModeHandler(
        manager: ThemeManager(),
        builder: (ThemeMode themeMode) {
          return GlobalLoaderOverlay(
            useDefaultLoading: false,
            overlayColor: Colors.grey.withOpacity(0.6),
            overlayWidget: const Center(
              child: SpinningPeercoinIcon(),
            ),
            child: MaterialApp(
              title: 'Peercoin',
              debugShowCheckedModeBanner: false,
              supportedLocales: AppLocalizations.availableLocales.values.map(
                (e) {
                  var (locale, _) = e;
                  return locale;
                },
              ),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              locale: _locale == const Locale('und') ? null : _locale,
              themeMode: themeMode,
              theme: MyTheme.getTheme(ThemeMode.light),
              darkTheme: MyTheme.getTheme(ThemeMode.dark),
              home: _homeWidget,
              routes: Routes.getRoutes(),
            ),
          );
        },
      ),
    );
  }
}
