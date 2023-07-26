import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  const seedPhrase =
      'vapor please suffer wood enrich quality position chest quantum fog rival museum';

  group(
    'Setup, Signing and Settings',
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
        'Setup, create wallet from imported seed',
        () async {
          //creates a peercoin testnet wallet from an imported seed and checks if it connects
          await driver.tap(find.byValueKey('setupLanguageButton'));
          await driver.tap(find.text('English'));
          await driver.tap(find.pageBack());
          await driver.scrollIntoView(find.text('Import Seed'));
          await driver.tap(find.text('Import Seed'));
          await driver.scrollIntoView(find.byValueKey('importTextField'));
          await driver.tap(find.byValueKey('importTextField'));
          await driver.enterText(seedPhrase);
          await driver.tap(find.text('Import'));
          await driver.scrollIntoView(elevatedButtonFinder);
          await driver.tap(find.byValueKey('setupAllowBiometrics'));
          await driver.tap(elevatedButtonFinder); //pin pad
          await driver.runUnsynchronized(
            () async {
              for (var i = 1; i <= 12; i++) {
                await driver.tap(find.text('0'));
              }
            },
          );
          await driver
              .scrollIntoView(find.byValueKey('setupApiTickerSwitchKey'));
          await driver.tap(find.byValueKey('setupApiTickerSwitchKey'));
          await driver.tap(find.byValueKey('setupApiBGSwitchKey'));
          await driver.tap(find.text('Continue'));
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
            timeout: const Duration(
              minutes: 15,
            ),
          );
        },
        timeout: Timeout.none,
      );

      test(
        'Setup, tap into imported peercoin testnet wallet',
        () async {
          await driver.runUnsynchronized(
            () async {
              await driver.tap(find.byValueKey('newWalletIconButton'));
              await driver.tap(find.text('Peercoin Testnet'));
              await driver.tap(
                find.text('Okay'),
                timeout: const Duration(minutes: 15),
              );
              await driver.tap(
                find.text('Peercoin Testnet'),
                timeout: const Duration(minutes: 15),
              ); //tap into wallet
              expect(await driver.getText(find.text('connected')), 'connected');
            },
            timeout: const Duration(
              minutes: 15,
            ),
          );
        },
        retry: 2,
        timeout: const Timeout.factor(2),
      );

      test(
          'Message signing, tap into sign message, select address and sign message',
          () async {
        await driver.tap(find.byTooltip('Show menu'));
        await driver.runUnsynchronized(
          () async {
            await driver.tap(find.text('Sign Messages'));
          },
        );
        await driver.tap(find.text('Select'));
        await driver.tap(find.text('mfdKHgpEzyMVHugqzttiEbhNvWjSGPy5fb'));
        await driver.tap(find.pageBack());
        await driver.tap(find.byValueKey('signMessageInput'));
        await driver.enterText(
          'sign message',
        );
        await driver.tap(find.text('Sign'));
        await driver.waitFor(
          find.text(
            'Hyd9cBXuT9CMgE8sK7YNeLQF1qaLxjQCMQv3pwKXCGdpOurIceSiuHfgXCnEtAhExq6iP/+vMn6sYC5OfpSBhRc=',
          ),
        );
      });

      test('Message verification, tap into verify message and verify',
          () async {
        await driver.tap(find.pageBack());
        await driver.tap(find.byTooltip('Show menu'));
        await driver.runUnsynchronized(
          () async {
            await driver.tap(find.text('Verify Messages'));
          },
        );
        await driver.tap(find.byValueKey('verifyAddressInput'));
        await driver.enterText(
          'mfdKHgpEzyMVHugqzttiEbhNvWjSGPy5fb',
        );
        await driver.tap(find.byValueKey('verifyMessageInput'));
        await driver.enterText(
          'sign message',
        );
        await driver.tap(find.byValueKey('verifSignatureInput'));
        await driver.enterText(
          'Hyd9cBXuT9CMgE8sK7YNeLQF1qaLxjQCMQv3pwKXCGdpOurIceSiuHfgXCnEtAhExq6iP/+vMn6sYC5OfpSBhRc=',
        );
        await driver.tap(find.text('Verify'));
        await driver.waitFor(
          find.text(
            'Message verified.',
          ),
        );

        //restart
        await driver.tap(find.byValueKey('verifyRestart'));
        expect(await driver.getText(find.byValueKey('verifyAddressInput')), '');
        expect(await driver.getText(find.byValueKey('verifyMessageInput')), '');
        expect(
          await driver.getText(find.byValueKey('verifSignatureInput')),
          '',
        );

        await driver.tap(find.byValueKey('verifyAddressInput'));
        await driver.enterText(
          'mfdKHgpEzyMVHugqzttiEbhNvWjSGPy5fb',
        );
        await driver.tap(find.byValueKey('verifyMessageInput'));
        await driver.enterText(
          'sign message',
        );
        await driver.tap(find.byValueKey('verifSignatureInput'));
        await driver.enterText(
          'yd9cBXuT9CMgE8sK7YNeLQF1qaLxjQCMQv3pwKXCGdpOurIceSiuHfgXCnEtAhExq6iP/+vMn6sYC5OfpSBhRc=',
        );
        await driver.tap(find.text('Verify'));
        await driver.waitFor(
          find.text(
            'Message could not be verified.',
          ),
        );
      });

      test('Settings, test lock into auth jail', () async {
        await driver.tap(find.pageBack());
        await driver.runUnsynchronized(
          () async {
            await driver.tap(find.pageBack());
            await driver.tap(find.byValueKey('appSettingsButton'));
          },
        );
        await driver.tap(find.text('Seed Phrase'));
        await driver.tap(find.text('Reveal seed phrase'));

        //tap wrong code two times
        for (var i = 1; i <= 12; i++) {
          await driver.tap(find.text('1'));
        }
        //tap okay for warning to go away
        await driver.tap(find.text('Okay'));
        await driver.runUnsynchronized(
          () async {
            for (var i = 1; i <= 6; i++) {
              await driver.tap(find.text('1'));
            }
          },
        );
        await driver.tap(find.text('Okay'));
        //auth jail open now
        await driver.runUnsynchronized(
          () async {
            await driver.waitFor(
              find.text('App locked for'),
            );
          },
        );
      });

      test('Settings, test unlock and show seed phrase', () async {
        await Future.delayed(const Duration(seconds: 12));
        await driver.runUnsynchronized(
          () async {
            for (var i = 1; i <= 6; i++) {
              await driver.tap(find.text('0'));
            }
            await driver.tap(find.byValueKey('appSettingsButton'));
          },
        );
        await driver.tap(find.text('Seed Phrase'));
        await driver.tap(find.text('Reveal seed phrase'));
        await driver.runUnsynchronized(
          () async {
            for (var i = 1; i <= 6; i++) {
              await driver.tap(find.text('0'));
            }
          },
        );
        await driver.waitFor(find.text(seedPhrase));
      });

      test(
        'Settings, change pin',
        () async {
          await driver.tap(find.text('Authentication'));
          await driver.runUnsynchronized(
            () async {
              for (var i = 1; i <= 6; i++) {
                await driver.tap(find.text('0'));
              }
            },
          );
          await driver.tap(find.text('Change PIN'));
          for (var i = 1; i <= 6; i++) {
            await driver.tap(find.text('0'));
          }
          for (var i = 1; i <= 12; i++) {
            await driver.tap(find.text('1'));
          }
          // final pixels = await driver.screenshot();
          // final file = File('shot.png');
          // await file.writeAsBytes(pixels);
          await driver.runUnsynchronized(() async {
            await driver.tap(find.pageBack());
            await driver.tap(find.pageBack());
            await driver.tap(find.byValueKey('appSettingsButton'));
          });
          await driver.tap(find.text('Seed Phrase'));
          await driver.tap(find.text('Reveal seed phrase'));
          for (var i = 1; i <= 6; i++) {
            await driver.tap(find.text('1'));
          }
        },
        timeout: const Timeout.factor(2),
      );

      test('Settings, change language', () async {
        //creates a peercoin testnet wallet from an imported seed and checks if it connects
        await driver.tap(find.text('Language'));
        await driver.tap(find.text('Deutsch'));
        await driver.scrollIntoView(find.text('Sprachen'));
      });
    },
  );
}
