import 'package:collection/collection.dart' show IterableExtension;
import 'package:hive/hive.dart';
import 'package:peercoin/models/walletaddress.dart';
import 'package:peercoin/models/wallettransaction.dart';
import 'package:peercoin/models/walletutxo.dart';
part 'coinwallet.g.dart';

@HiveType(typeId: 1)
class CoinWallet extends HiveObject {
  @HiveField(0)
  final String _name;

  @HiveField(1)
  final String _letterCode;

  @HiveField(2)
  // ignore: prefer_final_fields
  List<WalletAddress> _addresses = [];

  @HiveField(3)
  // ignore: prefer_final_fields
  List<WalletTransaction> _transactions = [];

  @HiveField(4)
  // ignore: prefer_final_fields
  List<WalletUtxo> _utxos = [];

  @HiveField(5)
  int _balance = 0;

  @HiveField(6)
  final String _title;

  @HiveField(7)
  int _unconfirmedBalance = 0;

  @HiveField(8)
  List<Map<String, int>>? _pendingTransactionNotifications = [];

  CoinWallet(this._name, this._title, this._letterCode);

  String get name {
    return _name;
  }

  String get letterCode {
    return _letterCode;
  }

  List<WalletAddress> get addresses {
    return _addresses;
  }

  List<WalletTransaction> get transactions {
    return _transactions;
  }

  List<WalletUtxo> get utxos {
    return _utxos;
  }

  int get balance {
    return _balance;
  }

  int get unconfirmedBalance {
    return _unconfirmedBalance;
  }

  String get title {
    return _title;
  }

  List<Map<String, int>> get pendingTransactionNotifications {
    return _pendingTransactionNotifications ?? [];
  }

  set balance(int newBalance) {
    _balance = newBalance;
    save();
  }

  set unconfirmedBalance(int newBalance) {
    _unconfirmedBalance = newBalance;
    save();
  }

  set addNewAddress(WalletAddress newAddress) {
    final res = _addresses
        .firstWhereOrNull((element) => element.address == newAddress.address);
    if (res == null) {
      _addresses.add(newAddress);
      save();
    }
  }

  void putTransaction(WalletTransaction newTx) {
    _transactions.add(newTx);
    save();
  }

  void putUtxo(WalletUtxo newUtxo) {
    _utxos.add(newUtxo);
    save();
  }

  void clearUtxo(String address) {
    _utxos.removeWhere((element) => element.address == address);
    save();
  }

  void removeAddress(WalletAddress walletAddress) {
    _addresses
        .removeWhere((element) => element.address == walletAddress.address);
    save();
  }

  void clearPendingTransactionNotifications() {
    _pendingTransactionNotifications = [];
    save();
  }

  void putPendingTransactionNotification(Map<String, int> tx) {
    _pendingTransactionNotifications!.add(tx);
  }
}
