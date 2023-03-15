### **1.1.6** (2023-03-15)
* Update Peercoin Foundation address

### **1.1.5** (2023-02-23)
* Fixed bug which would sometimes push to the wrong wallet after notification
* Address labels are no longer persistent for CSV file imports

### **1.1.4** (2023-02-11)
* Cease loading all wallets into cache on startup

### **1.1.3** (2023-01-01)
* Remove HRK (Croatian Kuna)

### **1.1.2** (2022-12-27)
* Allow verification of signed messages

### **1.1.1** (2022-12-06)
* Address book: allow hiding of sending addresses  
* Send tab: allow fast forwarding or rewiding to addresses

### **1.1.0** (2022-12-03)
* More CSV import fixes

### **1.0.9** (2022-11-21)
* Fix CSV file import

### **1.0.8** (2022-11-17)
* Fix transaction fee rounding issue

### **1.0.7** (2022-11-13)
* New notification API Marisma, also improves scan reliability 

### **1.0.6** (2022-11-12)
* CSV import: allow labels as third column
* Fix transaction building issue when spending full balance

### **1.0.5** (2022-11-10)
* Maintenance and dependency upgrades

### **1.0.4** (2022-11-08)
* Allow re-broadcasting of rejected tx

### **1.0.3** (2022-11-06)
* Send tab: perform form validation after scanning QR-code

### **1.0.2** (2022-10-30)
* Bug fix: reconnect loop that would result in servers banning clients

### **1.0.1** (2022-09-26)
* Even more robust scanning
* Fiat values will no longer be shown in transaction confirmation when price feed is disabled
* iOS devices will now have a "Delete account" notice in App Options

### **1.0.0** (2022-08-17)
* Allow to send to multiple addresses in one transaction
* Allow import of CSV to import addresses for sending
* Stability & performance improvements
* Direct link to foundation donations disabled again for iOS

### **0.9.9** (2022-08-10)
* Dramatically improve import / rescan performance
* About screen: Show licenses used in this app

### **0.9.8** (2022-08-04)
* About screen: Add donation button with direct link to send tab

### **0.9.7** (2022-07-15)
* Price animation for wallet home
* Various stability improvements under the hood

### **0.9.6** (2022-07-06)
* Send tab: Allow sending in FIAT currency
* Wallet list will now show balance in FIAT
* SSL servers are now available (not on web)

### **0.9.5** (2022-06-24)
* Setup legal: fix container heights on smaller screens
* Performance upgrades under the hood

### **0.9.4** (2022-06-20)
* Signing messages is now available for each wallet

### **0.9.3** (2022-06-14)
* Improved error handling for edge case in which secure storage is not accessible on some phones
* Legal notices for setup
* Various dependency updates under the hood

### **0.9.2** (2022-05-13)
* Improved wallet performance:  
From now on the wallet will only watch addresses that it knows to have coins and the unused address (the one displayed in the "Receive" tab).   
You can manually enable watching other addresses in the address book (slide left).   
Background notifications only work for watched addresses.  
Rescans are not affected. 

### **0.9.1** (2022-05-12)
* Price ticker: show latest price update
* Minor localization improvements

### **0.9.0** (2022-04-26)
* Bug fix: Edge case for importing paper wallets

### **0.8.9** (2022-04-14)
* Remove +1 Satoshi extra fee
* Better scanning and notifications 

### **0.8.8** (2022-04-13)
* Add language: Danish
* Add currency: DKK
* Scanning performance improvements
* Bug fix: Sending OP_RETURN/Metadata messages working again
* Bug fix: Edge case for unused addresses

### **0.8.7** (2022-03-29)
* Periodic backup and donation reminders
* Add language: Swedish
* Add currency: AUD, SEK

### **0.8.6** (2022-03-09)
* Add language: Filipino
* Add currencies: PHP

### **0.8.5** (2022-02-18)
* Add language: Arabic
* Add language: Japanese
* Add language: Thai 
* Add currencies: THB, JPY
* Fix for Norwegian
* Fix for importing paper wallets

### **0.8.4** (2022-02-13)
* Add language: Bangla 
* Add language: Farsi
* Add language: Hindi
* Add language: Indonesian
* Add language: Korean
* Add language: Swahili
* Add language: Ukrainian
* Add language: Urdu
* Add language: Turkish
* Add language: Vietnamese
* Fix for Norwegian
* Better transaction building

### **0.8.3** (2022-02-07)
* Fix native crash
* Add currencies: BDT, KRW, TRY

### **0.8.2** (2022-02-04)
* Add Norwegian to available languages
* Completed Portoguese translation
* Add NOK as available currency

### **0.8.1** (2022-02-01)
* Minor bug fixes and improvements under the hood

### **0.8.0** (2022-01-27)
* Address book - Your Addresses: allow to filter for change, empty or used addresses 
* Address book - Your Addresses: allow to switch between addresses balance or label
* App Settings: Allow to manually share debug logs

### **0.7.9** (2022-01-11)
* Allow keys to be exported in address book
* Performance improvements for transaction building for imported keys

### **0.7.8** (2022-01-06)
* Translation fixes
* Fix issue where wallet balance was not updated after TX confirmed
* Fix issue with authentication 

### **0.7.7** (2021-12-30)
* allow import of WIF-format private keys
* add Spanish translation 

### **0.7.6** (2021-12-17)
* fix issue with sending to P2WSH (Segwit Multisig) 

### **0.7.5** (2021-12-16)
* Allow sending to P2WSH (Segwit Multisig) 

### **0.7.4** (2021-12-07)
* Allow sending to P2SH (Multisig) 
* Fix issue where inbound transactions would trigger unnecessary notifications 
* Byte size will now be counted correctly when sending Metadata

### **0.7.3** (2021-12-03)
* Add PLN (Polish Zloty) to price feed
* Add "Empty wallet" button to send tab
* Allow to send 0 outputs when Metadata is present

### **0.7.2** (2021-11-25)
* Transaction Details: incoming and outgoing Metadata is now displayed
* Fix for sending without Metadata (OP_RETURN)

### **0.7.1** (2021-11-18)
* OP_RETURN messages can now be included in the "send" tab of the wallet
* French and Polish translation
* Minor changes under the hood

### **0.7.0** (2021-10-08)
* Background notifications can now be enabled in app settings  
Please perform a wallet scan to avoid unnecessary notifications. 
* Transactions will now be send without timestamp (version 3, 0.11 hard fork)

### **0.6.4** (2021-10-08)
* Fix for older devices
* Fix for price data feed
* Peercoin v0.11 hard fork preperation (Nov 1st 2021) 

### **0.6.3** (2021-09-17)
* New setup screens
* Changelog screen after updates

### **0.6.2** (2021-09-12)
* Address book: enable double tap to clipboard & don't show fee for inbound tx 
* Add fourth setup step: Enable price feed API
* Allow import scan screen to be canceled
