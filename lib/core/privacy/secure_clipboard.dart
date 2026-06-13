import 'package:flutter/services.dart';

class SecureClipboard {
  const SecureClipboard._();

  static const _channel = MethodChannel('net.guilhermegomes.mytokens/privacy');

  static Future<void> setText(String text) async {
    try {
      await _channel.invokeMethod<void>('setSensitiveClipboardText', text);
    } on MissingPluginException {
      await Clipboard.setData(ClipboardData(text: text));
    } on PlatformException {
      await Clipboard.setData(ClipboardData(text: text));
    }
  }
}
