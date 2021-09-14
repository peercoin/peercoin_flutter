import 'package:flutter/material.dart';
import 'package:peercoin/models/coinwallet.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/providers/electrumconnection.dart';
import 'package:peercoin/tools/price_ticker.dart';
import 'package:peercoin/widgets/wallet/wallet_home_connection.dart';
import 'package:provider/provider.dart';

class WalletBalanceHeader extends StatelessWidget {
  final ElectrumConnectionState _connectionState;
  final CoinWallet _wallet;
  WalletBalanceHeader(this._connectionState, this._wallet);

  @override
  Widget build(BuildContext context) {
    var _settings = context.watch<AppSettings>();
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
                Row(
                  children: [
                    Text(
                      '${_wallet.balance / 1000000}',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.grey[100],
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 5,
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
                _settings.selectedCurrency.isNotEmpty &&
                        !_wallet.title.contains('Testnet')
                    ? Text(
                        '${PriceTicker.renderPrice(
                          _wallet.balance / 1000000,
                          _settings.selectedCurrency,
                          _wallet.letterCode,
                          _settings.exchangeRates,
                        ).toStringAsFixed(2)} ${_settings.selectedCurrency}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[200],
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Container(),
                _wallet.unconfirmedBalance > 0
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Icon(
                              Icons.query_builder,
                              size: 12,
                              color: Colors.grey[300],
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              '${_wallet.unconfirmedBalance / 1000000} ${_wallet.letterCode}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
