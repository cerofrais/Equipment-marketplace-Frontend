import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EquipmentService {
  final String _baseUrl = dotenv.env['BASE_URL']!;

  Future<Map<String, dynamic>> createEquipment({
    required String assetCategory,
    required String manufacturer,
    required String model,
    required int yearOfPurchase,
    required String registrationNumber,
    String? serialNumber,
    String? photoFront,
    String? photoSide,
    String? photoPlate,
    String? additionalPhotos,
    String? conditionNotes,
    required String location,
    double? rentalRatePerDay,
    double? rentalRatePerWeek,
    bool isAvailable = true,
    required String vendorId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/equipment/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'asset_category': assetCategory,
          'manufacturer': manufacturer,
          'model': model,
          'year_of_purchase': yearOfPurchase,
          'registration_number': registrationNumber,
          if (serialNumber != null && serialNumber.isNotEmpty) 'serial_number': serialNumber,
          if (photoFront != null && photoFront.isNotEmpty) 'photo_front': photoFront,
          if (photoSide != null && photoSide.isNotEmpty) 'photo_side': photoSide,
          if (photoPlate != null && photoPlate.isNotEmpty) 'photo_plate': photoPlate,
          if (additionalPhotos != null && additionalPhotos.isNotEmpty) 'additional_photos': additionalPhotos,
          if (conditionNotes != null && conditionNotes.isNotEmpty) 'condition_notes': conditionNotes,
          'location': location,
          if (rentalRatePerDay != null) 'rental_rate_per_day': rentalRatePerDay,
          if (rentalRatePerWeek != null) 'rental_rate_per_week': rentalRatePerWeek,
          'is_available': isAvailable,
          'vendor_id': vendorId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create equipment: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating equipment: $e');
    }
  }
}
