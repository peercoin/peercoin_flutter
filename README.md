# peercoin-flutter
Wallet for Peercoin and Peercoin Testnet.
**Early alpha**. Basic testing successfull on iOS 14.4 and Android 10. 
**Use at own risk.**


## Development
This repository currently relies on a fork of bitcoin_flutter, which can be found here: 
[github.com/peercoin/bitcoin_flutter](github.com/peercoin/bitcoin_flutter "github.com/peercoin/bitcoin_flutter")

The original library is not compatible, due to transaction timestamp incompability. 

**Update icons**
` flutter pub run flutter_launcher_icons:main`

**Update Hive adapters**
`flutter packages pub run build_runner build`

**Update splash screen**
` flutter pub run flutter_native_splash:create`