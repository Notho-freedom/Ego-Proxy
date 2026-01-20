import 'dart:convert';
import 'dart:typed_data';
import 'dart:js_util' as js_util;

Future<String?> recognizeWebOcr(Uint8List bytes) async {
  final dataUrl = 'data:image/png;base64,${base64Encode(bytes)}';
  final tesseract = js_util.getProperty(js_util.globalThis, 'Tesseract');
  if (tesseract == null) {
    return null;
  }
  final promise = js_util.callMethod(tesseract, 'recognize', [dataUrl, 'eng+fra']);
  final result = await js_util.promiseToFuture(promise);
  final data = js_util.getProperty(result, 'data');
  final text = js_util.getProperty(data, 'text');
  return text is String ? text : text?.toString();
}
