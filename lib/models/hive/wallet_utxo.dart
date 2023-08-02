import 'package:hive/hive.dart';
part 'wallet_utxo.g.dart';

@HiveType(typeId: 4)
class WalletUtxo extends HiveObject {
  @HiveField(0)
  final String hash;
  @HiveField(1)
  final int txPos;
  @HiveField(2)
  int height;
  @HiveField(3)
  int value;
  @HiveField(4)
  final String address;

  WalletUtxo({
    required this.hash,
    required this.txPos,
    required this.height,
    required this.value,
    required this.address,
  });

  set newValue(int newValue) {
    value = newValue;
  }

  set newHeight(int newHeight) {
    height = newHeight;
  }
}
