import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VendorService {
  final String _baseUrl = dotenv.env['BASE_URL']!;

  Future<Map<String, dynamic>?> getVendorByWhatsapp(String whatsappNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/vendors/search/by-whatsapp/$whatsappNumber'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        // Vendor not found
        return null;
      } else {
        throw Exception('Failed to fetch vendor details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching vendor details: $e');
    }
  }

  Future<Map<String, dynamic>> createVendorProfile({
    required String businessName,
    required String pocName,
    required String pocContactNumber,
    required String whatsappNumber,
    String? gstNumber,
    String? gstRegisteredAddress,
    String? extraDetails,
    required String warehouseZipCode,
    int serviceRadiusKm = 50,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/vendors/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'business_name': businessName,
          'poc_name': pocName,
          'poc_contact_number': pocContactNumber,
          'whatsapp_number': whatsappNumber,
          if (gstNumber != null && gstNumber.isNotEmpty) 'gst_number': gstNumber,
          if (gstRegisteredAddress != null && gstRegisteredAddress.isNotEmpty) 'gst_registered_address': gstRegisteredAddress,
          if (extraDetails != null && extraDetails.isNotEmpty) 'extra_details': extraDetails,
          'warehouse_zip_code': warehouseZipCode,
          'service_radius_km': serviceRadiusKm,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final vendorData = jsonDecode(response.body);
        // Save vendor data in SharedPreferences
        await prefs.setString('vendor_data', jsonEncode(vendorData));
        await prefs.setString('vendor_id', vendorData['id'].toString());
        return vendorData;
      } else {
        throw Exception('Failed to create vendor profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating vendor profile: $e');
    }
  }

  Future<Map<String, dynamic>?> getSavedVendorData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorDataString = prefs.getString('vendor_data');
      if (vendorDataString != null) {
        return jsonDecode(vendorDataString);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getVendorEquipment(String vendorId, {int skip = 0, int limit = 100}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/equipment/vendor/$vendorId?skip=$skip&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch equipment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching equipment: $e');
    }
  }
}
