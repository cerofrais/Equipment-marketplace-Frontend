import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EquipmentTypesService {
  final String _baseUrl = dotenv.env['BASE_URL']!;

  Future<List<Map<String, dynamic>>> getEquipmentTypes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/equipment-types'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch equipment types: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching equipment types: $e');
    }
  }

  Future<Map<String, dynamic>> createEquipmentType({
    required String name,
    required String category,
    String? description,
    String? imagePath,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/equipment-types/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'category': category,
          'description': description ?? '',
          'image_path': imagePath ?? '',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create equipment type: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating equipment type: $e');
    }
  }
}
