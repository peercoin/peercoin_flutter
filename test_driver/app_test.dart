// Imports the Flutter Driver API.
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Setup', () {
    // First, define the Finders and use them to locate widgets from the
    // test suite. Note: the Strings provided to the `byValueKey` method must
    // be the same as the Strings we used for the Keys in step 1.
    final newSeedButtonFinder = find.byValueKey('newseed');
    final importButtonFinder = find.byValueKey('import');
    final continueFinder = find.byType('ElevatedButton');

    late FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      useMemoryFileSystemForTesting();
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      restoreFileSystem();
      await driver.close();
    });

    test('create new walet', () async {
      await driver.tap(newSeedButtonFinder);
      await driver.tap(continueFinder);
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
