import 'dart:js_interop';

@JS('chrome.runtime.id')
external JSString? get chromeRuntimeId;

String? getChromeRuntimeId() {
  try {
    final id = chromeRuntimeId;
    return id?.toDart;
  } catch (e) {
    return null;
  }
}
