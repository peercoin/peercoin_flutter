// import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  Future<void> performWIFImport(FlutterDriver driver) async {
    await driver.tap(find.byTooltip('Show menu'));
    await driver.tap(find.text('Import Private Key'));
    await driver.tap(find.byType('TextField'));
    await driver.enterText(
      'cTfaQHvae3MJYrZMWYiB6zWaDAMB23qbfo8vBZP2ZJNaUh3aa1p5',
    );
  }

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
          } catch (error) {
            throw Exception('Driver not connected, ${error.toString()}');
          }
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
          await driver.scrollIntoView(find.text('Deutsch'));
          await driver.tap(find.text('Deutsch'));
          await driver.tap(find.pageBack());
          await driver.scrollIntoView(find.text('Wallet erstellen'));
          //back to english
          await driver.tap(find.byValueKey('setupLanguageButton'));
          await driver.scrollIntoView(find.text('English'));
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
        'Import WIF',
        () async {
          await performWIFImport(driver);
          await driver.tap(find.text('Import'));
          await driver.tap(find.text('Import'));
        },
      );

      test('Check if WIF is in Address book', () async {
        await driver.tap(find.byTooltip('Address Book'));
        await driver.waitFor(find.text('mm5pM9sJzVjsafctQJJrJuhGsw1CTucZ2v'));
      });

      test('Transaction signing, success', () async {
        await driver.tap(find.byTooltip('Transactions'));
        await driver.tap(find.byTooltip('Show menu'));
        await driver.runUnsynchronized(
          () async {
            await driver.tap(find.text('Sign Transaction'));
          },
        );
        await driver.tap(find.text('Select'));
        await driver.tap(find.text('mm5pM9sJzVjsafctQJJrJuhGsw1CTucZ2v'));
        await driver.tap(find.pageBack());
        await driver.tap(find.byValueKey('transactionHexInput'));
        await driver.enterText(
          '0300000001d8af09713b116ecce194add86bd6def0e2dc3abe99c53bfbcd34576061baca9f000000002221022ef8df0bfd68434e2db934e88a7e30b06b88507dac60fa7cc2b732a1b5147ef7ffffffff010a8f9800000000001976a914ff9296d92c5efc397d0e0b9ebe94d95a532270c488ac00000000',
        );
        await driver.tap(find.text('Sign'));
        await driver.waitFor(
          find.text(
            '0300000001d8af09713b116ecce194add86bd6def0e2dc3abe99c53bfbcd34576061baca9f000000006a47304402200455cf81bde046213814387da5bde30e657fe7977c4c35ffe78edd3fe5cada7b0220186524598ac87de9b944f61e819b29c8a9a331c8a52b1694b8559cd9ec3395800121022ef8df0bfd68434e2db934e88a7e30b06b88507dac60fa7cc2b732a1b5147ef7ffffffff010a8f9800000000001976a914ff9296d92c5efc397d0e0b9ebe94d95a532270c488ac00000000',
          ),
        );
        await driver.scrollIntoView(find.text('Broadcast'));
        await driver.tap(find.text('Broadcast'));
        await driver.tap(find.text('Cancel'));
      });

      test('Transaction signing, fail', () async {
        await driver.tap(find.pageBack());
        await driver.tap(find.text('Reset'));
        await driver.tap(find.text('Reset')); //yes, twice to reset
        await driver.tap(find.text('Select'));
        await driver.tap(find.text('mm5pM9sJzVjsafctQJJrJuhGsw1CTucZ2v'));
        await driver.tap(find.pageBack());
        await driver.tap(find.byValueKey('transactionHexInput'));
        await driver.enterText(
          'xxx',
        );
        await driver.tap(find.text('Sign'));
        await driver.waitFor(
          find.byValueKey('signingError'),
        );
      });

      test('Change wallet title', () async {
        await driver.tap(find.pageBack());
        await driver.tap(find.byTooltip('Transactions'));
        await driver.tap(find.byTooltip('Show menu'));
        await driver.tap(find.text('Change Title'));
        await driver.tap(find.byType('TextField'));
        await driver.enterText('Wallet Test');
        await driver.tap(find.text('Okay'));
      });

      test(
        'tap into new peercoin mainnet wallet',
        () async {
          await driver.tap(find.pageBack());
          await Future.delayed(const Duration(seconds: 1));
          await driver.runUnsynchronized(
            () async {
              await driver.tap(find.byValueKey('newWalletIconButton'));
              await driver.tap(find.text('Peercoin'));
              await driver.tap(find.text('Peercoin')); //tap into wallet
              expect(await driver.getText(find.text('connected')), 'connected');
            },
          );
        },
      );

      test('change currency and see if it persists', () async {
        await driver.runUnsynchronized(() async {
          await driver.tap(find.pageBack());
          await driver.tap(find.byValueKey('appSettingsButton'));
        });
        await driver.scrollIntoView(find.text('Price Feed & Currency'));
        await driver.tap(find.text('Price Feed & Currency'));
        await driver.tap(find.byTooltip('Click here to start search'));
        await driver.tap(find.byType('TextField'));
        await driver.enterText('EUR');
        await driver.tap(find.text('Euro'));
        await driver.tap(find.pageBack());
        await driver.tap(find.pageBack());
        await driver.tap(find.pageBack());
        await driver.runUnsynchronized(() async {
          await driver.waitFor(find.text('0.00 EUR'));
        });
      });

      test(
        'find wallet with edited title and try to add an ssl server and see if it persists',
        () async {
          await driver.runUnsynchronized(
            () async {
              await driver.tap(find.byValueKey('appSettingsButton'));
            },
          );
          await driver.tap(find.text('Server Settings'));
          await driver.tap(find.text('Wallet Test'));
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
              await driver.tap(find.text('Wallet Test'));
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
