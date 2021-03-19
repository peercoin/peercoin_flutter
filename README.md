# peercoin-flutter
Wallet for Peercoin and Peercoin Testnet using Electrumx as backend.
**Early alpha**. 
Basic testing successfull on iOS 14.4 and Android 10. 
**Use at own risk.**

![Screenshot_1616192026](https://user-images.githubusercontent.com/11148913/111847381-fbab8e00-8908-11eb-8c76-4291d3291ac6.png)


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
