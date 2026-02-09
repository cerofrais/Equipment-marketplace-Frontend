import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'package:image_picker/image_picker.dart';

class FileService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Upload equipment image
  /// Returns the file path from the server
  Future<String> uploadEquipmentImage(XFile imageFile) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/api/v1/files/upload_equipment_image');

      var request = http.MultipartRequest('POST', uri);
      
      // Add auth token if available
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add file from bytes (works on all platforms)
      final bytes = await imageFile.readAsBytes();
      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: imageFile.name,
      );
      request.files.add(multipartFile);

      developer.log('Uploading image to: $uri', name: 'FileService');

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      developer.log('Upload response: ${response.statusCode} - ${response.body}', name: 'FileService');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['file_path'] != null) {
          return data['file_path'];
        }
        throw Exception('Invalid response format: ${response.body}');
      } else {
        throw Exception('Failed to upload image: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      developer.log('Error uploading image: $e', name: 'FileService');
      rethrow;
    }
  }

  /// Get the full URL for downloading an image
  String getImageUrl(String filePath) {
    // URL encode the file path
    final encodedPath = Uri.encodeComponent(filePath);
    return '$baseUrl/api/v1/files/download/$encodedPath';
  }

  /// Download image and return as bytes
  Future<List<int>> downloadImage(String filePath) async {
    try {
      final url = getImageUrl(filePath);
      developer.log('Downloading image from: $url', name: 'FileService');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error downloading image: $e', name: 'FileService');
      rethrow;
    }
  }
}
