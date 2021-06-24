[![Peercoin Donate](https://badgen.net/badge/peercoin/Donate/green?icon=https://raw.githubusercontent.com/peercoin/media/84710cca6c3c8d2d79676e5260cc8d1cd729a427/Peercoin%202020%20Logo%20Files/01.%20Icon%20Only/Inside%20Circle/Transparent/Green%20Icon/peercoin-icon-green-transparent.svg)](https://chainz.cryptoid.info/ppc/address.dws?PPXMXETHJE3E8k6s8vmpDC18b7y5eKAudS)
<a href="https://weblate.ppc.lol/engage/peercoin-flutter/">
<img src="https://weblate.ppc.lol/widgets/peercoin-flutter/-/translations/svg-badge.svg" alt="Übersetzungsstatus" />
</a>
# peercoin_flutter
Wallet for Peercoin and Peercoin Testnet using Electrumx as backend.  
**App in constant development**  
Basic testing successfull on iOS 14.4 and Android 10.  
**Use at own risk.**  

![git](https://user-images.githubusercontent.com/11148913/117579330-ac0c6600-b0f2-11eb-99f8-97443d892d36.png)

## Help Translate
<a href="https://weblate.ppc.lol/engage/peercoin-flutter/">
<img src="https://weblate.ppc.lol/widgets/peercoin-flutter/-/translations/multi-auto.svg" alt="Übersetzungsstatus" />
</a>

## Known Limitations
- can't send to Multisig addresses
- adds 1 Satoshi extra fee due to sporadic internal rounding errors 

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

## Basic e2e testing
`flutter drive --target=test_driver/app.dart --driver=test_driver/key_new.dart`
`flutter drive --target=test_driver/app.dart --driver=test_driver/key_imported.dart`