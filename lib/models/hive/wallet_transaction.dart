import 'package:hive_ce/hive.dart';
part 'wallet_transaction.g.dart';

@HiveType(typeId: 3)
class WalletTransaction extends HiveObject {
  @HiveField(0)
  final String txid;
  @HiveField(1, defaultValue: 0)
  int timestamp;
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
  @HiveField(9, defaultValue: '')
  String opReturn = '';
  @HiveField(10, defaultValue: {})
  Map<String, int> recipients = {};

  WalletTransaction({
    required this.txid,
    required this.timestamp,
    required this.value,
    required this.fee,
    required this.address,
    required this.recipients,
    required this.direction,
    required this.broadCasted,
    required this.broadcastHex,
    required this.confirmations,
    required this.opReturn,
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

  set newOpReturn(String newOpReturn) {
    opReturn = newOpReturn;
  }

  void resetBroadcastHex() {
    broadcastHex = '';
  }
}
