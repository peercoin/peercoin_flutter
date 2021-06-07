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

    test('create new walet', () async {
      await driver.tap(find.byValueKey('newseed'));
      await driver.tap(elevatedButtonFinder);

      await driver.runUnsynchronized(() async {
        await Process.run(
          'adb',
          <String>['shell', 'input', 'keyevent', 'KEYCODE_BACK'],
          runInShell: true,
        ); //TODO does not work on iphone
        await driver.tap(find.byValueKey('continue'));
      });
      await driver.tap(elevatedButtonFinder); //pin pad
      for (var i = 1; i <= 12; i++) {
        await driver.tap(find.text('0'));
      }
    });

    // test('starts at 0', () async {
    //   // Use the `driver.getText` method to verify the counter starts at 0.
    //   expect(await driver.getText(counterTextFinder), "0");
    // });

    // test('increments the counter', () async {
    //   // First, tap the button.
    //   await driver.tap(buttonFinder);

    //   // Then, verify the counter text is incremented by 1.
    //   expect(await driver.getText(counterTextFinder), "1");
    // });

    // test('increments the counter during animation', () async {
    //   await driver.runUnsynchronized(() async {
    //     // First, tap the button.
    //     await driver.tap(buttonFinder);

    //     // Then, verify the counter text is incremented by 1.
    //     expect(await driver.getText(counterTextFinder), "1");
    //   });
    // });
  });
}
