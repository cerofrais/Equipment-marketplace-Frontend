import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl = dotenv.env['BASE_URL']!;

  Future<void> login(String phoneNumber) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/auth/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone_number': phoneNumber}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send OTP');
    }
    
    // Save phone number temporarily for OTP verification
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone_number', phoneNumber);
  }

  Future<String?> verifyOtp(String phoneNumber, String otp) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone_number': phoneNumber, 'otp': otp}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['access_token']);
      await prefs.setString('refresh_token', data['refresh_token']);
      await prefs.setString('phone_number', phoneNumber);
      await prefs.setBool('is_logged_in', true);
      return null; // Success, no error message
    } else {
      String errorMessage = 'Failed to verify OTP. Status: ${response.statusCode}';
      if (response.body.isNotEmpty) {
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // Ignore if the response body is not valid JSON
        }
      }
      return errorMessage;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    
    // Call logout API if refresh token exists
    if (refreshToken != null) {
      try {
        await http.post(
          Uri.parse('$_baseUrl/api/v1/auth/logout'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refresh_token': refreshToken}),
        );
      } catch (e) {
        // Ignore API errors during logout
      }
    }
    
    // Clear all stored authentication data
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('phone_number');
    await prefs.remove('is_logged_in');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final hasToken = prefs.containsKey('access_token');
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    return hasToken && isLoggedIn;
  }

  Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('phone_number');
  }
}
