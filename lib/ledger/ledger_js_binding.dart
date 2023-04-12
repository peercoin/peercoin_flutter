@JS()
library ledger_interface;

import 'package:js/js.dart';

// Checks if TransportWebUSB is available (Promise)
@JS('TransportWebUSB.isSupported')
external Object transportWebUSBIsSupported();

// creates a new transport object (Promise)
@JS('TransportWebUSB.create')
external Object transportWebUSBCreate();

// creates a new Btc object (Promise)
@JS('Btc')
class Btc {
  external Btc(Object transport);
  external Object getWalletPublicKey(
    // returns a Promise
    String path,
    Options options,
  );
}

@JS()
@anonymous
class Options {
  external factory Options({bool verify, String format});
}
