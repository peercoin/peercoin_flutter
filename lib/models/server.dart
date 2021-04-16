import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'server.g.dart';

@HiveType(typeId: 6)
class Server extends HiveObject {
  @HiveField(0)
  String _label;

  @HiveField(1)
  String address;

  @HiveField(2)
  bool _connectable = true;

  @HiveField(3)
  bool _userGenerated;

  @HiveField(4)
  String _donationAddress;

  @HiveField(5)
  String _serverBanner;

  @HiveField(6)
  DateTime _lastConnection;

  @HiveField(7)
  bool _hidden = false;

  Server({
    @required this.address,
  });

  get getAddress {
    return address;
  }

  get hidden {
    return _hidden;
  }

  get connectable {
    return _connectable;
  }
}
