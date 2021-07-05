import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Setup', () {
    final elevatedButtonFinder = find.byType('ElevatedButton');
    late FlutterDriver driver;

    setUpAll(() async {
      useMemoryFileSystemForTesting();
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      restoreFileSystem();
      await driver.close();
    });

    test('create wallet from imported seed', () async {
      //creates a peercoin testnet wallet from an imported seed and checks if it connects
      await driver.tap(find.text('Import existing seed'));
      await driver.tap(find.byValueKey('importTextField'));
      await driver.enterText(
        'vapor please suffer wood enrich quality position chest quantum fog rival museum',
      );
      await driver.tap(find.text('Import seed'));

      await driver.tap(elevatedButtonFinder); //pin pad
      for (var i = 1; i <= 12; i++) {
        await driver.tap(find.text('0'));
      }
      await driver.tap(find.byValueKey('newWalletIconButton'));
      await driver.tap(find.text('Peercoin Testnet'));
      await driver.tap(find.text('Peercoin Testnet')); //tap into wallet
      await driver.tap(
        find.text('Peercoin Testnet'),
        timeout: Duration(minutes: 1),
      ); //tap into wallet
      expect(await driver.getText(find.text('connected')), 'connected');
    });
  });
}
