import 'package:flutter/material.dart';
import 'package:peercoin/providers/encryptedbox.dart';

class Servers with ChangeNotifier {
  EncryptedBox _encryptedBox;

  Servers(this._encryptedBox);
  void init() async {}
}
