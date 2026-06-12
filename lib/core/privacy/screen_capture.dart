import 'package:flutter/services.dart';

/// Controls Android's FLAG_SECURE. Other platforms simply ignore the request.
class ScreenCapture {
  const ScreenCapture._();

  static const _channel = MethodChannel('net.guilhermegomes.mytokens/privacy');

  static Future<void> setAllowed(bool allowed) async {
    try {
      await _channel.invokeMethod<void>('setScreenCaptureAllowed', allowed);
    } on MissingPluginException {
      // The app is Android-only today; keep tests/other embedders harmless.
    } on PlatformException {
      // Losing this preference must not crash the app.
    }
  }
}
