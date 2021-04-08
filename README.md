# peercoin-flutter
Wallet for Peercoin and Peercoin Testnet using Electrumx as backend.  
**Early alpha**  
Basic testing successfull on iOS 14.4 and Android 10.  
**Use at own risk.**  

![screenshot](https://user-images.githubusercontent.com/11148913/113717529-feb9c300-96eb-11eb-92b7-d5199ec0460f.jpg)

## Development
This repository currently relies on a fork of bitcoin_flutter, which can be found here: 
[peercoin/bitcoin_flutter](https://github.com/peercoin/bitcoin_flutter "github.com/peercoin/bitcoin_flutter")

The original library is not compatible, due to transaction timestamp incompability. 

**Update icons**  
`flutter pub run flutter_launcher_icons:main`

**Update Hive adapters**  
`flutter packages pub run build_runner build`

**Update splash screen**  
`flutter pub run flutter_native_splash:create`
