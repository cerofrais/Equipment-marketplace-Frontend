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

  /// Get equipment type by ID including pay structure
  Future<Map<String, dynamic>> getEquipmentTypeById(String equipmentTypeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      // Include query parameter to request pay structure relation
      final uri = Uri.parse('$_baseUrl/api/v1/equipment-types/$equipmentTypeId')
          .replace(queryParameters: {'include_pay_structure': 'true'});

      print('\n╔═══════════════════════════════════════════════════════════════╗');
      print('║ FETCHING EQUIPMENT TYPE BY ID                                 ║');
      print('╠═══════════════════════════════════════════════════════════════╣');
      print('║ URL: $uri');
      print('║ Equipment Type ID: $equipmentTypeId');
      print('║ Has Token: ${token != null}');
      print('╚═══════════════════════════════════════════════════════════════╝\n');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('\n╔═══════════════════════════════════════════════════════════════╗');
      print('║ API RESPONSE                                                  ║');
      print('╠═══════════════════════════════════════════════════════════════╣');
      print('║ Status Code: ${response.statusCode}');
      print('║ Response Body:');
      print('${response.body}');
      print('╚═══════════════════════════════════════════════════════════════╝\n');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch equipment type: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getEquipmentTypeById: $e'); // Debug log
      throw Exception('Error fetching equipment type: $e');
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
