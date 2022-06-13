import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Setup',
    () {
      final elevatedButtonFinder = find.byType('ElevatedButton');
      late FlutterDriver driver;

      Future<FlutterDriver> setupAndGetDriver() async {
        var driver = await FlutterDriver.connect();
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
          print('found setupLanguageButton');
          await driver.tap(find.text('English'));
          print('found English');
          await driver.tap(find.pageBack());
          print('found pageBack');
          await driver.tap(find.text('Create Wallet'));
          print('found Create Wallet');
          await driver.tap(find.text('Export now'));
          print('found Export now');
          await driver.tap(find.text('Continue'));
          print('found Continue');
          await driver.tap(find.text('Continue'));
          print('found Continue');
          await driver.tap(elevatedButtonFinder); //pin pad
          for (var i = 1; i <= 12; i++) {
            print('tap 0');
            await driver.tap(find.text('0'));
          }
          await driver.tap(find.byValueKey('setupApiTickerSwitchKey'));
          print('found setupApiTickerSwitchKey');
          await driver.tap(find.byValueKey('setupApiBGSwitchKey'));
          print('found setupApiBGSwitchKey');
          await driver.tap(find.text('Continue'));
          print('found Continue');
          await driver.tap(find.byType('SwitchListTile'));
          print('found SwitchListTile');
          await driver.tap(find.text('Finish Setup'));
          print('found Finish Setup');
          await driver.tap(find.pageBack());
          print('found pageBack');
          await driver.runUnsynchronized(
            () async {
              expect(
                await driver.getText(find.byValueKey('noActiveWallets')),
                'You have no active wallets',
              );
              print('found noActiveWallets');
            },
          );
        },
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
      );
    },
  );
}
