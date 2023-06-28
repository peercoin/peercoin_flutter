import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:grpc/grpc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:peercoin/models/available_coins.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../generated/marisma.pbgrpc.dart';
import '../models/app_options.dart';
import '../models/coin_wallet.dart';
import '../models/pending_notifications.dart';
import '../models/server.dart';
import '../models/wallet_address.dart';
import '../models/wallet_transaction.dart';
import '../models/wallet_utxo.dart';
import 'app_localizations.dart';
import 'logger_wrapper.dart';
import 'notification.dart';

class BackgroundSync {
  @pragma('vm:entry-point')
  static void backgroundFetchHeadlessTask(HeadlessTask task) async {
    var taskId = task.taskId;
    var isTimeout = task.timeout;
    if (isTimeout) {
      LoggerWrapper.logWarn(
        'BackgroundSync',
        'backgroundFetchHeadlessTask',
        'Headless task timed-out: $taskId',
      );
      BackgroundFetch.finish(taskId);
      return;
    }
    LoggerWrapper.logInfo(
      'BackgroundSync',
      'backgroundFetchHeadlessTask',
      'Headless event received.',
    );
    await BackgroundSync.executeSync();
    BackgroundFetch.finish(taskId);
  }

  static Future<void> init({
    required int notificationInterval,
    bool needsStart = false,
  }) async {
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
        LoggerWrapper.logInfo(
          'BackgroundSync',
          'init',
          'Event received $taskId',
        );
        await BackgroundSync.executeSync();
        BackgroundFetch.finish(taskId);
      }, (String taskId) async {
        LoggerWrapper.logInfo(
          'BackgroundSync',
          'init',
          'TASK TIMEOUT taskId: $taskId',
        );
        BackgroundFetch.finish(taskId);
      });
      LoggerWrapper.logInfo(
        'BackgroundSync',
        'init',
        'configure success: $status',
      );
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
    if (kIsWeb) return;

    //this static method can't access the providers we already have so we have to re-invent some things here...
    Uint8List encryptionKey;
    var secureStorage = const FlutterSecureStorage();
    var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    //check if key exists or return
    if (await secureStorage.containsKey(key: 'key')) {
      encryptionKey =
          base64Url.decode((await secureStorage.read(key: 'key') as String));
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
    var walletBox = await Hive.openBox<CoinWallet>(
      'wallets',
      encryptionCipher: HiveAesCipher(encryptionKey),
    );

    //open settings box
    var optionsBox = await Hive.openBox(
      'optionsBox',
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
    AppOptionsStore appOptions = optionsBox.get('appOptions');

    //check pending notifications
    var sharedPrefs = await SharedPreferences.getInstance();

    //init app delegate
    await AppLocalizations.delegate.load(
      Locale(sharedPrefs.getString('language_code') ?? 'und'),
    );

    //loop through wallets
    for (var wallet in walletBox.values) {
      //increment identifier for notifications
      if (appOptions.notificationActiveWallets.contains(wallet.name)) {
        //if activated, parse all addresses to a list that will be POSTed to backend later on
        var adressesToQuery = <String, int>{};
        var utxos = wallet.utxos;

        for (var walletAddress in wallet.addresses) {
          var utxoRes = utxos.firstWhereOrNull(
            (element) => element.address == walletAddress.address,
          );

          if (walletAddress.isOurs == true) {
            if (walletAddress.isWatched == true ||
                utxoRes != null && utxoRes.value > 0 ||
                wallet.addresses.indexOf(walletAddress) ==
                    wallet.addresses.length - 1)
            //assumes that last wallet in list is always the unused/change address
            {
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
          }
        }

        LoggerWrapper.logInfo(
          'BackgroundSync',
          'executeSync',
          'addressesToQuery $adressesToQuery',
        );

        var marismaResult = await getNumberOfUtxosFromMarisma(
          walletName: wallet.name,
          addressesToQuery: adressesToQuery,
        );

        var shouldNotify = false;

        LoggerWrapper.logInfo(
          'BackgroundSync',
          'executeSync ${wallet.name}',
          marismaResult.toString(),
        );

        if (marismaResult.isNotEmpty) {
          //loop through addresses in result
          marismaResult.forEach(
            (addr, n) {
              //write tx result from API into coinwallet
              if (n > adressesToQuery[addr]!) {
                wallet.putPendingTransactionNotification(
                  PendingNotification(
                    address: addr,
                    tx: n,
                  ),
                );
                shouldNotify = true;
              } else {
                WalletAddress? walletAddress =
                    wallet.addresses.firstWhereOrNull(
                  (element) => element.address == addr,
                );
                if (walletAddress != null) {
                  walletAddress.newNotificationBackendCount = n;
                }
              }
            },
          );

          if (fromScan == true) {
            //persist backend data
            wallet.clearPendingTransactionNotifications();
          }
        }

        if (shouldNotify == true && fromScan == false) {
          await flutterLocalNotificationsPlugin.show(
            DateTime.now().millisecondsSinceEpoch ~/ 10000,
            AppLocalizations.instance.translate(
              'notification_title',
              {'walletTitle': wallet.title},
            ),
            AppLocalizations.instance.translate('notification_body'),
            LocalNotificationSettings.platformChannelSpecifics,
            payload: wallet.name,
          );
        }
      }
    }
  }

  static MarismaClient getMarismaClient(String walletName) {
    final server =
        AvailableCoins.getSpecificCoin(walletName).marismaServers.first;

    return MarismaClient(
      ClientChannel(
        server.$1,
        port: server.$2,
      ),
    );
  }

  static Future<Map<String, int>> getNumberOfUtxosFromMarisma({
    required String walletName,
    required Map<String, int> addressesToQuery,
    bool fromScan = false,
  }) async {
    var grpcClient = getMarismaClient(walletName);

    Map<String, int> answerMap = {};

    try {
      await grpcClient.getBlockHeight(BlockHeightRequest());
    } catch (e) {
      //client not available
      return answerMap;
    }

    await Future.forEach(
      addressesToQuery.keys,
      (String addr) async {
        int n = addressesToQuery[addr]!;

        var isKnownRes = await grpcClient.getAddressIsKnown(
          AddressRequest(address: addr),
        );
        if (isKnownRes.isKnown == true) {
          var addressNumberOfUtxosReply =
              await grpcClient.getAddressNumberOfUtxos(
            AddressRequest(
              address: addr,
            ),
          );
          if (fromScan == true) {
            answerMap[addr] = addressNumberOfUtxosReply.n;
          } else if (addressNumberOfUtxosReply.n != n) {
            answerMap[addr] = addressNumberOfUtxosReply.n;
          }
        }
      },
    );

    return answerMap;
  }
}
