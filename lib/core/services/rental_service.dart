import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:equip_verse/core/models/rental_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RentalService {
  final String _baseUrl = dotenv.env['BASE_URL']!;

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<RentalRequest> createRentalRequest(
      String equipmentTypeId,
      String zipCode,
      DateTime startDate,
      DateTime endDate,
      {String? details,
      double? desiredPrice,
      String? reason}) async {
    final token = await _getAccessToken();
    
    final Map<String, dynamic> requestBody = {
      'equipment_type_id': equipmentTypeId,
      'zip_code': zipCode,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
    
    if (details != null) requestBody['details'] = details;
    if (desiredPrice != null) requestBody['desired_price'] = desiredPrice;
    if (reason != null) requestBody['reason'] = reason;
    
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/rental-requests'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 201) {
      return RentalRequest.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create rental request');
    }
  }

  Future<List<RentalRequest>> getMyRentalRequests() async {
    final token = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/rental-requests/my-requests'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => RentalRequest.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load rental requests');
    }
  }

  Future<List<RentalRequest>> getRentalRequestsByUserId(String userId) async {
    final token = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/rental-requests/by-user/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => RentalRequest.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load rental requests');
    }
  }
}
