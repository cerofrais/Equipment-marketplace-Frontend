import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:equip_verse/core/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final String _baseUrl = dotenv.env['BASE_URL']!;

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<String?> _getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('phone_number');
  }

  Future<User> getCurrentUser() async {
    final token = await _getAccessToken();
    final phoneNumber = await _getPhoneNumber();
    
    if (phoneNumber == null) {
      throw Exception('Phone number not found');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/users/by-phone/$phoneNumber'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  Future<User> updateUser(String userId, Map<String, dynamic> updates) async {
    final token = await _getAccessToken();
    final response = await http.put(
      Uri.parse('$_baseUrl/api/v1/users/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update user profile');
    }
  }
}
