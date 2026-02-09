// Mobile-specific file operations
import 'package:gal/gal.dart';
import 'dart:typed_data';

/// Download image bytes to gallery (mobile only)
Future<void> savePlatformFile(List<int> bytes, String filename) async {
  await Gal.putImageBytes(
    Uint8List.fromList(bytes),
    album: 'EquipVerse',
  );
}
