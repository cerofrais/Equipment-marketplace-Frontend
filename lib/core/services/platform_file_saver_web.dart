// Web-specific file operations
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'dart:typed_data';

/// Download image bytes to user's downloads folder (web only)
Future<void> savePlatformFile(List<int> bytes, String filename) async {
  final uint8list = Uint8List.fromList(bytes);
  final blob = web.Blob([uint8list.toJS].toJS);
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = filename;
  anchor.style.display = 'none';
  
  web.document.body?.appendChild(anchor);
  anchor.click();
  
  web.document.body?.removeChild(anchor);
  web.URL.revokeObjectURL(url);
}
