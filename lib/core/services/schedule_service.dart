import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:equip_verse/core/models/schedule.dart';
import 'package:equip_verse/core/services/vendor_service.dart';

class ScheduleService {
  final String _baseUrl = dotenv.env['BASE_URL']!;
  final _vendorService = VendorService();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<String?> _getVendorId() async {
    try {
      final vendorData = await _vendorService.getSavedVendorData();
      return vendorData?['id'];
    } catch (e) {
      return null;
    }
  }

  /// Check if equipment is available for the given time range
  Future<AvailabilityCheck> checkAvailability({
    required String equipmentId,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/schedules/check-availability'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'equipment_id': equipmentId,
          'start_time': startTime,
          'end_time': endTime,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AvailabilityCheck.fromJson(data);
      } else {
        throw Exception('Failed to check availability: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error checking availability: $e');
    }
  }

  /// Create a new schedule
  Future<Schedule> createSchedule({
    required String equipmentId,
    required String startTime,
    required String endTime,
    required String customerContactName,
    required String customerContactNumber,
    double? price,
  }) async {
    try {
      final token = await _getToken();
      final vendorId = await _getVendorId();
      
      if (vendorId == null) {
        throw Exception('Vendor ID not found. Please ensure you have a vendor profile.');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/schedules/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'vendor_id': vendorId,
          'equipment_id': equipmentId,
          'start_time': startTime,
          'end_time': endTime,
          'name': customerContactName,
          'contact': customerContactNumber,
          if (price != null) 'price': price,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Schedule.fromJson(data);
      } else {
        throw Exception('Failed to create schedule: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating schedule: $e');
    }
  }

  /// Get all schedules
  Future<List<Schedule>> getAllSchedules() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/schedules/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Schedule.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch schedules: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching schedules: $e');
    }
  }

  /// Get schedules by equipment ID
  Future<List<Schedule>> getSchedulesByEquipment(String equipmentId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/schedules/equipment/$equipmentId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Schedule.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch schedules: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching schedules: $e');
    }
  }

  /// Get a specific schedule by ID
  Future<Schedule> getSchedule(String scheduleId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/schedules/$scheduleId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Schedule.fromJson(data);
      } else {
        throw Exception('Failed to fetch schedule: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching schedule: $e');
    }
  }

  /// Update a schedule
  Future<Schedule> updateSchedule({
    required String scheduleId,
    String? startTime,
    String? endTime,
    String? customerContactName,
    String? customerContactNumber,
    double? price,
    String? status,
  }) async {
    try {
      final token = await _getToken();
      final Map<String, dynamic> body = {};
      
      if (startTime != null) body['start_time'] = startTime;
      if (endTime != null) body['end_time'] = endTime;
      if (customerContactName != null) body['customer_contact_name'] = customerContactName;
      if (customerContactNumber != null) body['customer_contact_number'] = customerContactNumber;
      if (price != null) body['price'] = price;
      if (status != null) body['status'] = status;

      final response = await http.put(
        Uri.parse('$_baseUrl/api/v1/schedules/$scheduleId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Schedule.fromJson(data);
      } else {
        throw Exception('Failed to update schedule: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating schedule: $e');
    }
  }

  /// Delete a schedule
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      final token = await _getToken();
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/v1/schedules/$scheduleId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete schedule: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting schedule: $e');
    }
  }
}
