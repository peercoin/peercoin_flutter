import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:peercoin/models/coin.dart';

class AvailableCoins {
  Map<String, Coin> _availableCoinList = {
    "peercoin": Coin(
        name: "peercoin",
        displayName: "Peercoin",
        uriCode: "peercoin",
        letterCode: "PPC",
        iconPath: "assets/icon/ppc-icon-48.png",
        iconPathTransparent: "assets/icon/ppc-icon-white-48.png",
        networkType: NetworkType(
            messagePrefix: '\x18Peercoin Signed Message:\n',
            bech32: 'pc',
            bip32: new Bip32Type(public: 0x043587cf, private: 0x04358394),
            pubKeyHash: 0x37,
            scriptHash: 0x75,
            wif: 0xb7),
        fractions: 6,
        minimumTxValue: 10000,
        feePerKb: 0.01),
    "peercoinTestnet": Coin(
        name: "peercoinTestnet",
        displayName: "Peercoin Testnet",
        uriCode: "peercoin",
        letterCode: "tPPC",
        iconPath: "assets/icon/ppc-icon-48.png",
        iconPathTransparent: "assets/icon/ppc-icon-white-48.png",
        networkType: NetworkType(
            messagePrefix: '\x18Peercoin Signed Message:\n',
            bech32: 'tpc',
            bip32: new Bip32Type(public: 0x043587cf, private: 0x04358394),
            pubKeyHash: 0x6f,
            scriptHash: 0xc4,
            wif: 0xef),
        fractions: 6,
        minimumTxValue: 10000,
        feePerKb: 0.01)
  };

  Map<String, Coin> get availableCoins {
    return _availableCoinList;
  }

  Coin getSpecificCoin(identifier) {
    return _availableCoinList[identifier];
  }
}
