import 'package:hive/hive.dart';
part 'wallettransaction.g.dart';

@HiveType(typeId: 3)
class WalletTransaction extends HiveObject {
  @HiveField(0)
  final String txid;
  @HiveField(1)
  int? timestamp; //nullable for backward compatability
  @HiveField(2)
  final int value;
  @HiveField(3)
  final int fee;
  @HiveField(4)
  final String address;
  @HiveField(5)
  final String direction;
  @HiveField(6)
  int confirmations = 0;
  @HiveField(7)
  bool broadCasted = true;
  @HiveField(8)
  String broadcastHex = '';

  WalletTransaction({
    required this.txid,
    required this.timestamp,
    required this.value,
    required this.fee,
    required this.address,
    required this.direction,
    required this.broadCasted,
    required this.broadcastHex,
    required this.confirmations,
  });

  set newTimestamp(int newTime) {
    timestamp = newTime;
  }

  set newConfirmations(int newConfirmations) {
    confirmations = newConfirmations;
  }

  set newBroadcasted(bool newBroadcasted) {
    broadCasted = newBroadcasted;
  }

  void resetBroadcastHex() {
    broadcastHex = '';
  }
}
