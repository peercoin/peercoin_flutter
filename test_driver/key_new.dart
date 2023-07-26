// import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Setup',
    () {
      final elevatedButtonFinder = find.byType('ElevatedButton');
      late FlutterDriver driver;

      Future<FlutterDriver> setupAndGetDriver() async {
        var driver = await FlutterDriver.connect(
          timeout: const Duration(minutes: 20),
        );
        var connected = false;
        while (!connected) {
          try {
            await driver.waitUntilFirstFrameRasterized();
            connected = true;
            // ignore: empty_catches
          } catch (error) {}
        }
        return driver;
      }

      setUpAll(() async {
        useMemoryFileSystemForTesting();
        driver = await setupAndGetDriver();
      });

      tearDownAll(() async {
        restoreFileSystem();
        await driver.close();
      });

      test(
        'create new wallet from scratch',
        () async {
          //creates a brand new peercoin testnet wallet from scratch and check if it connects
          await driver.tap(find.byValueKey('setupLanguageButton'));
          await driver.tap(find.text('Deutsch'));
          await driver.tap(find.pageBack());
          await driver.scrollIntoView(find.text('Wallet erstellen'));
          //back to english
          await driver.tap(find.byValueKey('setupLanguageButton'));
          await driver.tap(find.text('English'));
          await driver.tap(find.pageBack());
          await driver.scrollIntoView(find.text('Create Wallet'));
          await driver.tap(find.text('Create Wallet'));
          await driver.scrollIntoView(find.text('Export now'));
          await driver.tap(find.text('Export now'));
          await driver.tap(find.text('Continue'));
          await driver.tap(find.text('Continue'));
          await driver.scrollIntoView(elevatedButtonFinder);
          await driver.tap(elevatedButtonFinder); //pin pad
          for (var i = 1; i <= 12; i++) {
            await driver.tap(find.text('0'));
          }
          await driver
              .scrollIntoView(find.byValueKey('setupApiTickerSwitchKey'));
          await driver.tap(find.byValueKey('setupApiTickerSwitchKey'));
          await driver.tap(find.byValueKey('setupApiBGSwitchKey'));
          await driver.tap(find.text('Continue'));
          // final pixels = await driver.screenshot();
          // final file = File('shot.png');
          // await file.writeAsBytes(pixels);
          await driver.scrollIntoView(find.byValueKey('setupLegalConsentKey'));
          await driver.tap(find.byValueKey('setupLegalConsentKey'));
          await driver.scrollIntoView(find.text('Finish Setup'));
          await driver.tap(find.text('Finish Setup'));
          await driver.tap(find.pageBack());
          await driver.runUnsynchronized(
            () async {
              expect(
                await driver.getText(find.byValueKey('noActiveWallets')),
                'You have no active wallets',
              );
            },
          );
        },
        retry: 2,
        timeout: Timeout.none,
      );

      test(
        'tap into new peercoin testnet wallet',
        () async {
          await driver.runUnsynchronized(
            () async {
              await driver.tap(find.byValueKey('newWalletIconButton'));
              await driver.tap(find.text('Peercoin Testnet'));
              await driver.tap(find.text('Peercoin Testnet')); //tap into wallet
              expect(await driver.getText(find.text('connected')), 'connected');
            },
          );
        },
        retry: 2,
        timeout: const Timeout.factor(2),
      );

      test(
        'try to add an ssl server and see if it persists',
        () async {
          await driver.tap(find.pageBack());
          await driver.runUnsynchronized(
            () async {
              await driver.tap(find.byValueKey('appSettingsButton'));
            },
          );
          await driver.tap(find.text('Server Settings'));
          await driver.tap(find.text('Peercoin Testnet'));
          await driver.tap(find.byValueKey('serverSettingsAddServer'));
          await driver.tap(find.byType('TextFormField'));
          await driver.enterText(
            'ssl://electrum.peercoinexplorer.net:50002',
          ); //main net server for testnet wallet
          await driver.tap(find.byValueKey('saveServerButton'));
          expect(
            await driver.getText(
              find.text(
                'Genesis hash does not match.\nThis server does not support this coin.',
              ),
            ),
            'Genesis hash does not match.\nThis server does not support this coin.',
          );
          await driver.enterText(
            'ssl://testnet-electrum.peercoinexplorer.net:50008',
          ); //testnet server for testnet wallet
          await driver.tap(find.byValueKey('saveServerButton'));
          await driver.tap(find.pageBack());
          await driver.runUnsynchronized(
            () async {
              await driver.tap(find.text('Peercoin Testnet'));
            },
          );
          expect(
            await driver.getText(
              find.text('ssl://testnet-electrum.peercoinexplorer.net:50008'),
            ),
            'ssl://testnet-electrum.peercoinexplorer.net:50008',
          );
        },
        retry: 2,
        timeout: const Timeout.factor(2),
      );
    },
  );
}
