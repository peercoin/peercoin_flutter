import 'package:flutter_driver/driver_extension.dart';
import 'package:peercoin/main.dart' as app;
import 'package:flutter_driver/flutter_driver.dart';

void main() {
  // This line enables the extension.
  useMemoryFileSystemForTesting();
  enableFlutterDriverExtension();

  // Call the `main()` function of the app, or call `runApp` with
  // any widget you are interested in testing.
  app.main();
}
