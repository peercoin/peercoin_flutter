import 'dart:math';

import 'package:coinslib/coinslib.dart';
import 'coin.dart';

class AvailableCoins {
  static final Map<String, Coin> _availableCoinList = {
    'peercoin': Coin(
      name: 'peercoin',
      displayName: 'Peercoin',
      uriCode: 'peercoin',
      letterCode: 'PPC',
      iconPath: 'assets/icon/ppc-icon-48.png',
      iconPathTransparent: 'assets/icon/ppc-icon-white-48.png',
      networkType: NetworkType(
        messagePrefix: 'Peercoin Signed Message:\n',
        bech32: 'pc',
        bip32: Bip32Type(public: 0x043587cf, private: 0x04358394),
        pubKeyHash: 0x37,
        scriptHash: 0x75,
        wif: 0xb7,
        opreturnSize: 256,
      ),
      fractions: 6,
      minimumTxValue: 10000,
      fixedFee: true,
      fixedFeePerKb: 0.01,
      explorerUrl: 'https://blockbook.peercoin.net',
      genesisHash:
          '0000000032fe677166d54963b62a4677d8957e87c508eaa4fd7eb1c880cd27e3',
      txVersion: 3,
      electrumRequiredProtocol: 1.4,
      electrumServers: [
        'wss://electrum.peercoinexplorer.net:50004',
        'wss://allingas.peercoinexplorer.net:50004',
      ],
    ),
    'peercoinTestnet': Coin(
      name: 'peercoinTestnet',
      displayName: 'Peercoin Testnet',
      uriCode: 'peercoin',
      letterCode: 'tPPC',
      iconPath: 'assets/icon/ppc-icon-48.png',
      iconPathTransparent: 'assets/icon/ppc-icon-white-48.png',
      networkType: NetworkType(
        messagePrefix: 'Peercoin Signed Message:\n',
        bech32: 'tpc',
        bip32: Bip32Type(public: 0x043587cf, private: 0x04358394),
        pubKeyHash: 0x6f,
        scriptHash: 0xc4,
        wif: 0xef,
        opreturnSize: 256,
      ),
      fixedFee: true,
      fractions: 6,
      minimumTxValue: 10000,
      fixedFeePerKb: 0.01,
      explorerUrl: 'https://tblockbook.peercoin.net',
      genesisHash:
          '00000001f757bb737f6596503e17cd17b0658ce630cc727c0cca81aec47c9f06',
      txVersion: 3,
      electrumRequiredProtocol: 1.4,
      electrumServers: [
        'wss://testnet-electrum.peercoinexplorer.net:50009',
        'wss://allingas.peercoinexplorer.net:50009',
      ],
    ),
  };

  static Map<String, Coin> get availableCoins {
    return _availableCoinList;
  }

  static Coin getSpecificCoin(String identifier) {
    return _availableCoinList[identifier]!;
  }

  static int getDecimalProduct({required String identifier}) {
    return pow(
      10,
      getSpecificCoin(identifier).fractions,
    ).toInt();
  }
}
