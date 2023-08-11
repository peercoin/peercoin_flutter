import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/available_coins.dart';
import '/../models/hive/coin_wallet.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/connection_provider.dart';
import '/../tools/price_ticker.dart';
import '/../widgets/wallet/wallet_home_connection.dart';
import 'wallet_balance_price.dart';

class WalletBalanceHeader extends StatelessWidget {
  final BackendConnectionState _connectionState;
  final CoinWallet _wallet;
  const WalletBalanceHeader(this._connectionState, this._wallet, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var settings = context.watch<AppSettingsProvider>();
    final decimalProduct = AvailableCoins.getDecimalProduct(
      identifier: _wallet.name,
    );

    return Column(
      children: [
        const SizedBox(
          height: 32,
        ),
        WalletHomeConnection(_connectionState),
        const SizedBox(
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
                      '${_wallet.balance / decimalProduct}',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.grey[100],
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
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
                settings.selectedCurrency.isNotEmpty &&
                        _wallet.letterCode != 'tPPC'
                    ? WalletBalancePrice(
                        valueInFiat: Text(
                          '${PriceTicker.renderPrice(
                            _wallet.balance / decimalProduct,
                            settings.selectedCurrency,
                            _wallet.letterCode,
                            settings.exchangeRates,
                          ).toStringAsFixed(2)} ${settings.selectedCurrency}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[200],
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        fiatCoinValue: Text(
                          '1 ${_wallet.letterCode} = ${(PriceTicker.renderPrice(
                            1,
                            settings.selectedCurrency,
                            _wallet.letterCode,
                            settings.exchangeRates,
                          )).toStringAsFixed(2)} ${settings.selectedCurrency}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[200],
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : const SizedBox(),
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
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              '${_wallet.unconfirmedBalance / decimalProduct} ${_wallet.letterCode}',
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
