import 'dart:io';

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

    test('create new wallet from scratch', () async {
      //creates a brand new peercoin testnet wallet from scratch and check if it connects
      await driver.tap(find.byValueKey('newseed'));
      await driver.tap(elevatedButtonFinder);
      await Process.run(
        'adb',
        <String>['shell', 'input', 'keyevent', 'KEYCODE_BACK'],
        runInShell: true,
      ); //TODO removes "share" overlay - does not work on iphone
      await driver.tap(find.byValueKey('continue'));
      await driver.tap(elevatedButtonFinder); //pin pad
      for (var i = 1; i <= 12; i++) {
        await driver.tap(find.text('0'));
      }
      await driver.tap(find.byValueKey('newWalletIconButton'));
      await driver.tap(find.text('Peercoin Testnet'));
      await driver.tap(find.text('Peercoin Testnet')); //tap into wallet
      expect(await driver.getText(find.text('connected')), 'connected');
    });
  });
}
