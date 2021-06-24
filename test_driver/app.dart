import 'package:flutter_driver/driver_extension.dart';
import 'package:peercoin/main.dart' as app;
import 'package:flutter_driver/flutter_driver.dart';

void main() {
  useMemoryFileSystemForTesting();
  enableFlutterDriverExtension();

  app.main();
}
