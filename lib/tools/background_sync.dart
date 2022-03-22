import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:peercoin/models/app_options.dart';
import 'package:peercoin/models/coin_wallet.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:peercoin/models/pending_notifications.dart';
import 'package:peercoin/models/server.dart';
import 'package:peercoin/models/wallet_address.dart';
import 'package:peercoin/models/wallet_transaction.dart';
import 'package:peercoin/models/wallet_utxo.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundSync {
  static void backgroundFetchHeadlessTask(HeadlessTask task) async {
    var taskId = task.taskId;
    var isTimeout = task.timeout;
    if (isTimeout) {
      FlutterLogs.logWarn(
        'BackgroundSync',
        'backgroundFetchHeadlessTask',
        'Headless task timed-out: $taskId',
      );
      BackgroundFetch.finish(taskId);
      return;
    }
    FlutterLogs.logInfo(
      'BackgroundSync',
      'backgroundFetchHeadlessTask',
      'Headless event received.',
    );
    await BackgroundSync.executeSync();
    BackgroundFetch.finish(taskId);
  }

  static Future<void> init(
      {required int notificationInterval, bool needsStart = false}) async {
    Future<void> initPlatformState() async {
      var status = await BackgroundFetch.configure(
          BackgroundFetchConfig(
            minimumFetchInterval: notificationInterval,
            startOnBoot: true,
            stopOnTerminate: false,
            enableHeadless: Platform.isAndroid ? true : false,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.ANY,
          ), (String taskId) async {
        FlutterLogs.logInfo('BackgroundSync', 'init', 'Event received $taskId');
        await BackgroundSync.executeSync();
        BackgroundFetch.finish(taskId);
      }, (String taskId) async {
        FlutterLogs.logInfo(
            'BackgroundSync', 'init', 'TASK TIMEOUT taskId: $taskId');
        BackgroundFetch.finish(taskId);
      });
      FlutterLogs.logInfo(
          'BackgroundSync', 'init', 'configure success: $status');
    }

    await initPlatformState();
    if (Platform.isAndroid) {
      await BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
    }
    if (needsStart == true) {
      await BackgroundFetch.start();
    }
  }

  static Future<void> executeSync({bool fromScan = false}) async {
    //this static method can't access the providers we already have so we have to re-invent some things here...
    Uint8List _encryptionKey;
    var _secureStorage = const FlutterSecureStorage();
    var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    //check if key exists or return
    if (await _secureStorage.containsKey(key: 'key')) {
      _encryptionKey =
          base64Url.decode((await _secureStorage.read(key: 'key') as String));
    } else {
      return;
    }

    //init hive - sadly we have to register all of them here
    if (!Hive.isAdapterRegistered(1)) {
      await Hive.initFlutter();
      Hive.registerAdapter(CoinWalletAdapter());
      Hive.registerAdapter(WalletTransactionAdapter());
      Hive.registerAdapter(WalletAddressAdapter());
      Hive.registerAdapter(WalletUtxoAdapter());
      Hive.registerAdapter(AppOptionsStoreAdapter());
      Hive.registerAdapter(ServerAdapter());
      Hive.registerAdapter(PendingNotificationAdapter());
    }

    //open wallet box
    var _walletBox = await Hive.openBox<CoinWallet>(
      'wallets',
      encryptionCipher: HiveAesCipher(_encryptionKey),
    );

    //open settings box
    var _optionsBox = await Hive.openBox(
      'optionsBox',
      encryptionCipher: HiveAesCipher(_encryptionKey),
    );
    AppOptionsStore _appOptions = _optionsBox.get('appOptions');

    //check pending notifications
    var _sharedPrefs = await SharedPreferences.getInstance();

    //init app delegate
    await AppLocalizations.delegate.load(
      Locale(_sharedPrefs.getString('language_code') ?? 'und'),
    );

    //loop through wallets
    _walletBox.values.forEach(
      (wallet) async {
        //increment identifier for notifications
        if (_appOptions.notificationActiveWallets.contains(wallet.letterCode)) {
          //if activated, parse all addresses to a list that will be POSTed to backend later on
          var adressesToQuery = <String, int>{};
          wallet.addresses.forEach((walletAddress) async {
            if (walletAddress.isOurs == true) {
              //check if that address already has a pending notification
              var res = wallet.pendingTransactionNotifications
                  .where(
                    (element) => element.address == walletAddress.address,
                  )
                  .toList();
              if (res.isNotEmpty) {
                //addr does have a pending notification
                adressesToQuery[walletAddress.address] = res[0].tx;
              } else {
                //addr does not have a pending notification
                adressesToQuery[walletAddress.address] =
                    walletAddress.notificationBackendCount;
              }
            }
          });

          FlutterLogs.logInfo(
            'BackgroundSync',
            'executeSync',
            'addressesToQuery $adressesToQuery',
          );

          var result = await http.post(
            Uri.parse('https://peercoinexplorer.net/address-status'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({
              'coin': wallet.name,
              'addresses': [adressesToQuery]
            }),
          );

          var _shouldNotify = false;
          var _foundDifference;
          if (result.body.contains('foundDifference')) {
            //valid answer
            var bodyDecoded = jsonDecode(result.body);
            FlutterLogs.logInfo(
              'BackgroundSync',
              'executeSync ${wallet.name}',
              bodyDecoded.toString(),
            );
            _foundDifference = bodyDecoded['foundDifference'];
            if (_foundDifference == true) {
              //loop through addresses in result
              var addresses = bodyDecoded['addresses'];
              addresses.forEach((element) {
                //write tx result from API into coinwallet
                wallet.putPendingTransactionNotification(PendingNotification(
                    address: element['address'], tx: element['tx']));
              });

              if (fromScan == true) {
                //persist backend data
                wallet.clearPendingTransactionNotifications();
              } else {
                _shouldNotify = true;
              }
            }
          }

          if (_shouldNotify == true) {
            await flutterLocalNotificationsPlugin.show(
              DateTime.now().millisecondsSinceEpoch ~/ 10000,
              AppLocalizations.instance.translate(
                  'notification_title', {'walletTitle': wallet.title}),
              AppLocalizations.instance.translate('notification_body'),
              LocalNotificationSettings.platformChannelSpecifics,
              payload: wallet.name,
            );
          }
        }
      },
    );
  }
}
