import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:peercoin/models/app_options.dart';
import 'package:peercoin/models/availablecoins.dart';
import 'package:peercoin/models/coinwallet.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:peercoin/models/server.dart';
import 'package:peercoin/models/walletaddress.dart';
import 'package:peercoin/models/wallettransaction.dart';
import 'package:peercoin/models/walletutxo.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundSync {
  static Future<void> executeSync() async {
    //this static method can't access the providers we already have so we have to re-invent some things here...
    Uint8List _encryptionKey;
    var _secureStorage = const FlutterSecureStorage();
    var _shouldNotify = false;
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
    var _pendingNotifications =
        _sharedPrefs.getStringList('pendingNotifications') ?? [];
    //loop through wallets
    var i = 0;
    _walletBox.values.forEach(
      (wallet) async {
        //increment identifier for notifications
        i++;
        if (_appOptions.notificationActiveWallets.contains(wallet.letterCode)) {
          wallet.addresses.forEach(
            (walletAddress) async {
              print(walletAddress.address);

              var response = await http.read(
                Uri.parse(
                  AvailableCoins().getSpecificCoin(wallet.name).explorerUrl +
                      '/api/address/' +
                      walletAddress.address,
                ),
              );
              var jsonResponse = jsonDecode(response) as Map;
              if (jsonResponse.containsKey('txApperances')) {
                //txApperances in reply, continue

                var numberOfTx = wallet.transactions
                    .where(
                      (element) => element.address == walletAddress.address,
                    )
                    .length;
                print(walletAddress.address + ' ' + numberOfTx.toString());
                print(
                    "in explorer: confirmed ${jsonResponse['txApperances']} - unconfirmed ${jsonResponse['unconfirmedTxApperances']}");

                if (jsonResponse['txApperances'] > numberOfTx) {
                  //number greater than what we have in the data base -> new confirmed tx
                  _shouldNotify = true;
                } else if (jsonResponse
                    .containsKey('unconfirmedTxApperances')) {
                  if (jsonResponse['unconfirmedTxApperances'] +
                          jsonResponse['txApperances'] >
                      numberOfTx) {
                    //new unconfirmed tx
                    _shouldNotify = true;
                  }
                }
              }
              if (_shouldNotify == true &&
                  !_pendingNotifications.contains(
                    wallet.letterCode,
                  )) {
                await flutterLocalNotificationsPlugin.show(
                  i,
                  AppLocalizations.instance.translate(
                      'notification_title', {'walletTitle': wallet.title}),
                  AppLocalizations.instance.translate('notification_body'),
                  LocalNotificationSettings.platformChannelSpecifics,
                  payload: wallet.name,
                );
                //write to pending notificatons
                _pendingNotifications.add(wallet.letterCode);
                await _sharedPrefs.setStringList(
                    'pendingNotifications', _pendingNotifications);
              }
            },
          );
        }
      },
    );
  }
}
