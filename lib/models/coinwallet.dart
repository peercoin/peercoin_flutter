import 'package:hive/hive.dart';
import 'package:peercoin/models/walletaddress.dart';
import 'package:peercoin/models/wallettransaction.dart';
import 'package:peercoin/models/walletutxo.dart';
part 'coinwallet.g.dart';

@HiveType(typeId: 1)
class CoinWallet extends HiveObject {
  @HiveField(0)
  String _name;

  @HiveField(1)
  String _letterCode;

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

  set balance(int newBalance) {
    _balance = newBalance;
    this.save();
  }

  set unconfirmedBalance(int newBalance) {
    _unconfirmedBalance = newBalance;
    this.save();
  }

  set addNewAddress(WalletAddress newAddress) {
    final res = _addresses.firstWhere(
            (element) => element.address == newAddress.address,
            orElse: () => null) ==
        null;
    if (res == null) {
      _addresses.add(newAddress);
      this.save();
    }
  }

  void putTransaction(WalletTransaction newTx) {
    _transactions.add(newTx);
    this.save();
  }

  void putUtxo(WalletUtxo newUtxo) {
    _utxos.add(newUtxo);
    this.save();
  }

  void clearUtxo(String address) {
    _utxos.removeWhere((element) => element.address == address);
    this.save();
  }

  void removeAddress(WalletAddress walletAddress) {
    _addresses
        .removeWhere((element) => element.address == walletAddress.address);
    this.save();
  }
}
