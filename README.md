[![Peercoin Donate](https://badgen.net/badge/peercoin/Donate/green?icon=https://raw.githubusercontent.com/peercoin/media/84710cca6c3c8d2d79676e5260cc8d1cd729a427/Peercoin%202020%20Logo%20Files/01.%20Icon%20Only/Inside%20Circle/Transparent/Green%20Icon/peercoin-icon-green-transparent.svg)](https://chainz.cryptoid.info/ppc/address.dws?p77CZFn9jvg9waCzKBzkQfSvBBzPH1nRre)
<a href="https://weblate.ppc.lol/engage/peercoin-flutter/">
<img src="https://weblate.ppc.lol/widgets/peercoin-flutter/-/translations/svg-badge.svg" alt="Übersetzungsstatus" /></a>
[![Codemagic build status](https://api.codemagic.io/apps/61012a37d885ed7a8c3e8b25/61012a37d885ed7a8c3e8b24/status_badge.svg)](https://codemagic.io/apps/61012a37d885ed7a8c3e8b25/61012a37d885ed7a8c3e8b24/latest_build)
[![Analyze & Test](https://github.com/peercoin/peercoin_flutter/actions/workflows/analyze-test.yml/badge.svg)](https://github.com/peercoin/peercoin_flutter/actions/workflows/analyze-test.yml)
[![CodeFactor](https://www.codefactor.io/repository/github/peercoin/peercoin_flutter/badge/main)](https://www.codefactor.io/repository/github/peercoin/peercoin_flutter/overview/main)
# peercoin_flutter
Wallet for Peercoin and Peercoin Testnet using Electrumx as backend.  
**App in constant development**  

**Use at own risk.**  


<p align="center">
     <a href="https://f-droid.org/packages/com.coinerella.peercoin/">
<img src="https://fdroid.gitlab.io/artwork/badge/get-it-on.png"
     alt="Get it on F-Droid"
     height="80"></a>
<a href="https://play.google.com/store/apps/details?id=com.coinerella.peercoin"><img src="https://play.google.com/intl/en_us/badges/images/generic/en-play-badge.png"
     alt="Get it on Google Play" height="80"></a>
</p>
<p align="center">
     <a href="https://apps.apple.com/app/peercoin-wallet/id1571755170?itsct=apps_box_badge&amp;itscg=30200" style="display: inline-block; overflow: hidden; border-radius: 13px; width: 250px; height: 83px;"><img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-us?size=250x83&amp;releaseDate=1626912000&h=8e86ea0b88a4e8559b76592c43b3fe60" alt="Download on the App Store" style="border-radius: 13px; width: 250px; height: 83px;"></a>
</p> 

You can also sign up for our open beta testing here:

* [Android](https://play.google.com/apps/testing/com.coinerella.peercoin)
* [iOS](https://testflight.apple.com/join/iilc4SvQ)

![Screenshot_small](https://user-images.githubusercontent.com/11148913/124509449-470f7c80-ddd2-11eb-9daf-56de7eb83594.png)

## Help Translate
Some of the translations are translated with ChatGPT, so please edit if you find something that's not correct.
<a href="https://weblate.ppc.lol/engage/peercoin-flutter/">
<img src="https://weblate.ppc.lol/widgets/peercoin-flutter/-/translations/multi-auto.svg" alt="Translation status" />
</a>

## Known Limitations
- will not mint

## Development
This repository currently relies on 
[Vesta-wallet/coinslib](https://github.com/Vesta-wallet/coinslib "github.com/Vesta-wallet/coinslib")

**Update icons**  
`dart run flutter_launcher_icons:main`

**Update Hive adapters**  
`dart run build_runner build`

**Update splash screen**  
`dart run flutter_native_splash:create`

**Generate proto files**  
`protoc --dart_out=grpc:lib/generated -Iprotos protos/marisma.proto`

**Build for web**  
`flutter pub global activate peanut`  
`flutter pub global run peanut -b production`  
Web files are now on the production branch and ready to be deployed.  
This will use the html renderer by default. Add *--web-renderer canvas* to peanut if you want to switch to the canvas renderer.

## Basic e2e testing
`flutter drive --target=test_driver/app.dart --driver=test_driver/key_new.dart`  
`flutter drive --target=test_driver/app.dart --driver=test_driver/key_imported.dart`
