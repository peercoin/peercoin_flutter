import 'package:flutter/material.dart';
import 'package:peercoin/models/coinwallet.dart';
import 'package:peercoin/providers/electrumconnection.dart';
import 'package:peercoin/widgets/wallet_home_connection.dart';

class WalletBalanceHeader extends StatelessWidget {
  final ElectrumConnectionState _connectionState;
  final CoinWallet _wallet;
  WalletBalanceHeader(this._connectionState, this._wallet);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 32,
        ),
        WalletHomeConnection(_connectionState),
        SizedBox(
          height: 16,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  (_wallet.balance / 1000000).toString(),
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey[100],
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _wallet.unconfirmedBalance > 0
                    ? Text(
                        (_wallet.unconfirmedBalance / 1000000).toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[200],
                        ),
                      )
                    : Container(),
              ],
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              _wallet.letterCode,
              style: TextStyle(
                fontSize: 24,
                color: Colors.grey[100],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
