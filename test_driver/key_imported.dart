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
        'create wallet from imported seed',
        () async {
          //creates a peercoin testnet wallet from an imported seed and checks if it connects
          await driver.tap(find.byValueKey('setupLanguageButton'));
          await driver.tap(find.text('English'));
          await driver.tap(find.pageBack());
          await driver.tap(find.text('Import Seed'));
          await driver.tap(find.byValueKey('importTextField'));
          await driver.enterText(
            'vapor please suffer wood enrich quality position chest quantum fog rival museum',
          );
          await driver.tap(find.text('Import'));

          await driver.tap(elevatedButtonFinder); //pin pad
          for (var i = 1; i <= 12; i++) {
            await driver.tap(find.text('0'));
          }
          await driver.tap(find.byValueKey('setupApiTickerSwitchKey'));
          await driver.tap(find.byValueKey('setupApiBGSwitchKey'));
          await driver.tap(find.text('Continue'));
          await driver.tap(find.byValueKey('setupLegalConsentKey'));
          await driver.tap(find.text('Finish Setup'));
          await driver.tap(find.pageBack());
          await driver.runUnsynchronized(
            () async {
              expect(
                await driver.getText(find.byValueKey('noActiveWallets')),
                'You have no active wallets',
              );
            },
            timeout: Duration(
              minutes: 15,
            ),
          );
        },
        timeout: Timeout.none,
      );

      test(
        'tap into imported peercoin testnet wallet',
        () async {
          await driver.runUnsynchronized(
            () async {
              await driver.tap(find.byValueKey('newWalletIconButton'));
              await driver.tap(find.text('Peercoin Testnet'));
              await driver.tap(
                find.text('Okay'),
                timeout: Duration(minutes: 15),
              );
              await driver.tap(
                find.text('Peercoin Testnet'),
                timeout: Duration(minutes: 15),
              ); //tap into wallet
              expect(await driver.getText(find.text('connected')), 'connected');
            },
            timeout: Duration(
              minutes: 15,
            ),
          );
        },
        retry: 2,
      );
    },
  );
}
//TODO: Add message signing