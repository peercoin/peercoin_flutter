### **1.4.2** (2025-05-29)

- Fix DKG threshold not respected in requests
- Various translation and wording updates for ROAST
- Fixes for Dark Mode to make a specific set of users extra happy

### **1.4.1** (2025-05-26)

- Add support for ROAST on more devices

### **1.4.0** (2025-05-17)

- Add experimental feature: ROAST
- A lot of tiny upgrades under the hood to ensure forward compatibility

### **1.3.5** (2025-03-08)

- Fix for transaction list misbehaviour caused by sending addresses

### **1.3.4** (2025-03-02)

- Fix for some devices that experienced problems with message signing
- reenable CSV file selection for import

### **1.3.3** (2025-02-28)

- Fixes for badges in address book

### **1.3.2** (2025-02-27)

- Fixes for private key export

### **1.3.1** (2025-02-26)

- Watch only wallets are now considered stable and removed from experimental features

### **1.3.0** (2024-06-09)

- Show transaction confirmation: fix bug where some outputs were not displayed correctly
- Allow hiding of wallets in wallet list
- Allow watch-only wallets to be deleted

### **1.2.9** (2024-05-30)

- Show transaction id for finalized transactions in transaction signing flow
- Improve user experience for double tab to clipboard with hint texts

### **1.2.8** (2024-05-27)

- Allow broadcast of signed transactions if all inputs are signed

### **1.2.7** (2024-05-24)

- Various bug fixes and improvements related to flutter upgrade
- Improved flow for transaction signing, now with confirmation and more feedback

### **1.2.6** (2024-04-20)

- Improved transaction signing handling and error messages

### **1.2.5** (2024-04-08)

- Address public keys can now be exported during transaction signing

### **1.2.4** (2024-04-05)

- Add transaction signing from wallet home
- Fix for some devices not being able to see the wallet receive tab
- Dependency upgrades, e. g. now using coinlib 2.0.0

### **1.2.3** (2023-11-30)

- Experimental features are now available in Settings
- "Watch only" wallets are the first available feature that can be enabled. These wallets can only monitor the balance of an address and cannot spend coins.
- App now uses Material 3 design language

### **1.2.2** (2023-09-27)

- Change the options for purchasing Peercoin on some devices

### **1.2.1** (2023-09-24)

- Minor improvements and bug hunting

### **1.2.0** (2023-09-12)

- This app now uses coinlib to deal with the hard stuff behind the scenes.

### **1.1.9** (2023-08-23)

- You may now add multiple wallets of the same type
- Complete redesign of rescan process, check "Wallet Scan" in app settings and "Reset" in the respective wallet
- A multitude of currencies is now available and losely corresponds with the languages added in 1.1.8
- Items in "Language" and "Price Feed & Currency" settings can now be searched
- Fixed a bug where some devices would have issues when setting up an app that was locked before
- Changelog will no longer be displayed on first startup for new wallets

### **1.1.8** (2023-08-02)

- Server Settings have been moved from inside the wallets to application settings
- Wallet titles may now be edited from within the wallet
- Fixed a bug where some devices could not create a new seed and where stuck in setup
- Add language: Afrikaans
- Add language: Albanian
- Add language: Amharic
- Add language: Armenian
- Add language: Assamese
- Add language: Azerbaijani
- Add language: Basque
- Add language: Belarusian
- Add language: Bosnian
- Add language: Bulgarian
- Add language: Burmese
- Add language: Catalan
- Add language: Czech
- Add language: Estonian
- Add language: Finnish
- Add language: Galician
- Add language: Georgian
- Add language: Gujarati
- Add language: Hebrew
- Add language: Hungarian / Magyar
- Add language: Icelandic
- Add language: Kazakh
- Add language: Kirghiz / Kyrgyz
- Add language: Kannada
- Add language: Khmer
- Add language: Latvian
- Add language: Lithuanian
- Add language: Lao
- Add language: Macedonian
- Add language: Malay
- Add language: Malayalam
- Add language: Marathi
- Add language: Modern Greek
- Add language: Mongolian
- Add language: Nepali
- Add language: Oriya
- Add language: Panjabi / Punjabi
- Add language: Pushto Pashto
- Add language: Serbian
- Add language: Sinhala / Sinhalese
- Add language: Slovak
- Add language: Slovenian
- Add language: Swiss German Alemannic Alsatian
- Add language: Tagalog
- Add language: Tamil
- Add language: Telugu
- Add language: Traditional Chinese
- Add language: Uzbek
- Add language: Welsh
- Add language: Zulu

### **1.1.7** (2023-06-16)

- Minor updates under the hood

### **1.1.6** (2023-03-15)

- Update Peercoin Foundation address

### **1.1.5** (2023-02-23)

- Fixed bug which would sometimes push to the wrong wallet after notification
- Address labels are no longer persistent for CSV file imports

### **1.1.4** (2023-02-11)

- Cease loading all wallets into cache on startup

### **1.1.3** (2023-01-01)

- Remove HRK (Croatian Kuna)

### **1.1.2** (2022-12-27)

- Allow verification of signed messages

### **1.1.1** (2022-12-06)

- Address book: allow hiding of sending addresses
- Send tab: allow fast forwarding or rewiding to addresses

### **1.1.0** (2022-12-03)

- More CSV import fixes

### **1.0.9** (2022-11-21)

- Fix CSV file import

### **1.0.8** (2022-11-17)

- Fix transaction fee rounding issue

### **1.0.7** (2022-11-13)

- New notification API Marisma, also improves scan reliability

### **1.0.6** (2022-11-12)

- CSV import: allow labels as third column
- Fix transaction building issue when spending full balance

### **1.0.5** (2022-11-10)

- Maintenance and dependency upgrades

### **1.0.4** (2022-11-08)

- Allow re-broadcasting of rejected tx

### **1.0.3** (2022-11-06)

- Send tab: perform form validation after scanning QR-code

### **1.0.2** (2022-10-30)

- Bug fix: reconnect loop that would result in servers banning clients

### **1.0.1** (2022-09-26)

- Even more robust scanning
- Fiat values will no longer be shown in transaction confirmation when price feed is disabled
- iOS devices will now have a "Delete account" notice in App Options

### **1.0.0** (2022-08-17)

- Allow to send to multiple addresses in one transaction
- Allow import of CSV to import addresses for sending
- Stability & performance improvements
- Direct link to foundation donations disabled again for iOS

### **0.9.9** (2022-08-10)

- Dramatically improve import / rescan performance
- About screen: Show licenses used in this app

### **0.9.8** (2022-08-04)

- About screen: Add donation button with direct link to send tab

### **0.9.7** (2022-07-15)

- Price animation for wallet home
- Various stability improvements under the hood

### **0.9.6** (2022-07-06)

- Send tab: Allow sending in FIAT currency
- Wallet list will now show balance in FIAT
- SSL servers are now available (not on web)

### **0.9.5** (2022-06-24)

- Setup legal: fix container heights on smaller screens
- Performance upgrades under the hood

### **0.9.4** (2022-06-20)

- Signing messages is now available for each wallet

### **0.9.3** (2022-06-14)

- Improved error handling for edge case in which secure storage is not accessible on some phones
- Legal notices for setup
- Various dependency updates under the hood

### **0.9.2** (2022-05-13)

- Improved wallet performance:  
  From now on the wallet will only watch addresses that it knows to have coins and the unused address (the one displayed in the "Receive" tab).  
  You can manually enable watching other addresses in the address book (slide left).  
  Background notifications only work for watched addresses.  
  Rescans are not affected.

### **0.9.1** (2022-05-12)

- Price ticker: show latest price update
- Minor localization improvements

### **0.9.0** (2022-04-26)

- Bug fix: Edge case for importing paper wallets

### **0.8.9** (2022-04-14)

- Remove +1 Satoshi extra fee
- Better scanning and notifications

### **0.8.8** (2022-04-13)

- Add language: Danish
- Add currency: DKK
- Scanning performance improvements
- Bug fix: Sending OP_RETURN/Metadata messages working again
- Bug fix: Edge case for unused addresses

### **0.8.7** (2022-03-29)

- Periodic backup and donation reminders
- Add language: Swedish
- Add currency: AUD, SEK

### **0.8.6** (2022-03-09)

- Add language: Filipino
- Add currencies: PHP

### **0.8.5** (2022-02-18)

- Add language: Arabic
- Add language: Japanese
- Add language: Thai
- Add currencies: THB, JPY
- Fix for Norwegian
- Fix for importing paper wallets

### **0.8.4** (2022-02-13)

- Add language: Bangla
- Add language: Farsi
- Add language: Hindi
- Add language: Indonesian
- Add language: Korean
- Add language: Swahili
- Add language: Ukrainian
- Add language: Urdu
- Add language: Turkish
- Add language: Vietnamese
- Fix for Norwegian
- Better transaction building

### **0.8.3** (2022-02-07)

- Fix native crash
- Add currencies: BDT, KRW, TRY

### **0.8.2** (2022-02-04)

- Add Norwegian to available languages
- Completed Portoguese translation
- Add NOK as available currency

### **0.8.1** (2022-02-01)

- Minor bug fixes and improvements under the hood

### **0.8.0** (2022-01-27)

- Address book - Your Addresses: allow to filter for change, empty or used addresses
- Address book - Your Addresses: allow to switch between addresses balance or label
- App Settings: Allow to manually share debug logs

### **0.7.9** (2022-01-11)

- Allow keys to be exported in address book
- Performance improvements for transaction building for imported keys

### **0.7.8** (2022-01-06)

- Translation fixes
- Fix issue where wallet balance was not updated after TX confirmed
- Fix issue with authentication

### **0.7.7** (2021-12-30)

- allow import of WIF-format private keys
- add Spanish translation

### **0.7.6** (2021-12-17)

- fix issue with sending to P2WSH (Segwit Multisig)

### **0.7.5** (2021-12-16)

- Allow sending to P2WSH (Segwit Multisig)

### **0.7.4** (2021-12-07)

- Allow sending to P2SH (Multisig)
- Fix issue where inbound transactions would trigger unnecessary notifications
- Byte size will now be counted correctly when sending Metadata

### **0.7.3** (2021-12-03)

- Add PLN (Polish Zloty) to price feed
- Add "Empty wallet" button to send tab
- Allow to send 0 outputs when Metadata is present

### **0.7.2** (2021-11-25)

- Transaction Details: incoming and outgoing Metadata is now displayed
- Fix for sending without Metadata (OP_RETURN)

### **0.7.1** (2021-11-18)

- OP_RETURN messages can now be included in the "send" tab of the wallet
- French and Polish translation
- Minor changes under the hood

### **0.7.0** (2021-10-08)

- Background notifications can now be enabled in app settings  
  Please perform a wallet scan to avoid unnecessary notifications.
- Transactions will now be send without timestamp (version 3, 0.11 hard fork)

### **0.6.4** (2021-10-08)

- Fix for older devices
- Fix for price data feed
- Peercoin v0.11 hard fork preperation (Nov 1st 2021)

### **0.6.3** (2021-09-17)

- New setup screens
- Changelog screen after updates

### **0.6.2** (2021-09-12)

- Address book: enable double tap to clipboard & don't show fee for inbound tx
- Add fourth setup step: Enable price feed API
- Allow import scan screen to be canceled
