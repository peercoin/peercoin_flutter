// ignore_for_file: prefer_final_fields

import 'package:collection/collection.dart' show IterableExtension;
import 'package:hive/hive.dart';

import 'pending_notifications.dart';
import 'wallet_address.dart';
import 'wallet_transaction.dart';
import 'wallet_utxo.dart';

part 'coin_wallet.g.dart';

@HiveType(typeId: 1)
class CoinWallet extends HiveObject {
  @HiveField(0)
  final String _name;

  @HiveField(1)
  final String _letterCode;

  @HiveField(2)
  List<WalletAddress> _addresses = [];

  @HiveField(3)
  List<WalletTransaction> _transactions = [];

  @HiveField(4)
  List<WalletUtxo> _utxos = [];

  @HiveField(5)
  int _balance = 0;

  @HiveField(6)
  String _title;

  @HiveField(7)
  int _unconfirmedBalance = 0;

  @HiveField(8)
  List<PendingNotification>? _pendingTransactionNotifications = [];

  @HiveField(9, defaultValue: 0)
  int _walletIndex = 0;

  @HiveField(10, defaultValue: false)
  bool _dueForRescan = false;

  @HiveField(11, defaultValue: false)
  bool _watchOnly = false;

  @HiveField(12, defaultValue: false)
  bool _hidden = false;

  CoinWallet(
    this._name,
    this._title,
    this._letterCode,
    this._walletIndex,
    this._dueForRescan,
    this._watchOnly,
  );

  set addNewAddress(WalletAddress newAddress) {
    final res = _addresses
        .firstWhereOrNull((element) => element.address == newAddress.address);
    if (res == null) {
      _addresses.add(newAddress);
      save();
    }
  }

  List<WalletAddress> get addresses {
    return _addresses;
  }

  int get balance {
    return _balance;
  }

  bool get watchOnly {
    return _watchOnly;
  }

  set balance(int newBalance) {
    _balance = newBalance;
    save();
  }

  bool get dueForRescan {
    return _dueForRescan;
  }

  set dueForRescan(bool value) {
    _dueForRescan = value;
    save();
  }

  String get letterCode {
    return _letterCode;
  }

  String get name {
    return _name;
  }

  List<PendingNotification> get pendingTransactionNotifications {
    return _pendingTransactionNotifications ?? [];
  }

  String get title {
    return _title;
  }

  set title(String newTitle) {
    _title = newTitle;
    save();
  }

  List<WalletTransaction> get transactions {
    return _transactions;
  }

  int get unconfirmedBalance {
    return _unconfirmedBalance;
  }

  set unconfirmedBalance(int newBalance) {
    _unconfirmedBalance = newBalance;
    save();
  }

  List<WalletUtxo> get utxos {
    return _utxos;
  }

  int get walletIndex {
    return _walletIndex;
  }

  set walletIndex(int newWalletNumber) {
    _walletIndex = newWalletNumber;
    save();
  }

  void clearPendingTransactionNotifications() {
    if (pendingTransactionNotifications.isNotEmpty) {
      for (var pendingNotifcation in pendingTransactionNotifications) {
        var address = addresses.firstWhere(
          (element) => element.address == pendingNotifcation.address,
        );

        if (pendingNotifcation.tx != address.notificationBackendCount) {
          address.newNotificationBackendCount = pendingNotifcation.tx;
        }
      }
    }
    _pendingTransactionNotifications = [];
    save();
  }

  void clearUtxo(String address) {
    _utxos.removeWhere((element) => element.address == address);
    save();
  }

  void putPendingTransactionNotification(PendingNotification tx) {
    if (_pendingTransactionNotifications == null) {
      _pendingTransactionNotifications = [tx];
    } else {
      var res = pendingTransactionNotifications
          .where(
            (element) => element.address == tx.address,
          )
          .toList();
      if (res.isEmpty) {
        //prevent double write
        _pendingTransactionNotifications!.add(tx);
      } else {
        //replace with new tx
        _pendingTransactionNotifications!
            .removeWhere((element) => element.address == tx.address);
        _pendingTransactionNotifications!.add(tx);
      }
    }
    save();
  }

  void putTransaction(WalletTransaction newTx) {
    _transactions.add(newTx);
    save();
  }

  void removeTransaction(WalletTransaction tx) {
    _transactions.removeWhere((element) => element.txid == tx.txid);
    save();
  }

  void putUtxo(WalletUtxo newUtxo) {
    _utxos.add(newUtxo);
    save();
  }

  void removeAddress(WalletAddress walletAddress) {
    _addresses
        .removeWhere((element) => element.address == walletAddress.address);
    save();
  }

  bool get hidden {
    return _hidden;
  }

  set hidden(bool value) {
    _hidden = value;
    save();
  }
}
