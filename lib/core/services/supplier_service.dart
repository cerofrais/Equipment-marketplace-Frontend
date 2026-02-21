import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eqp_rent/core/models/organisation.dart';
import 'package:eqp_rent/core/models/equipment.dart';

class SupplierService {
  final String _baseUrl = dotenv.env['BASE_URL']!;

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Organisation/Supplier Profile Management
  
  /// Create a new supplier organisation
  Future<Organisation> createSupplierOrganisation({
    required String name,
    String? gstin,
    required String city,
    String? address,
    String? phone,
    String? email,
    String? logoUrl,
  }) async {
    final token = await _getAccessToken();
    
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/organisations/'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        if (gstin != null && gstin.isNotEmpty) 'gstin': gstin,
        'type': 'SUPPLIER',
        'city': city,
        if (address != null && address.isNotEmpty) 'address': address,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (email != null && email.isNotEmpty) 'email': email,
        if (logoUrl != null && logoUrl.isNotEmpty) 'logo_url': logoUrl,
        'is_active': true,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final org = Organisation.fromJson(jsonDecode(response.body));
      // Save organisation data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('supplier_org_data', jsonEncode(org.toJson()));
      await prefs.setString('supplier_org_id', org.id ?? '');
      return org;
    } else {
      throw Exception('Failed to create supplier organisation: ${response.body}');
    }
  }

  /// Get the current user's supplier organisation
  Future<Organisation?> getMySupplierOrganisation() async {
    final token = await _getAccessToken();
    
    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/organisations/me?type=SUPPLIER'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final org = Organisation.fromJson(jsonDecode(response.body));
      // Cache locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('supplier_org_data', jsonEncode(org.toJson()));
      await prefs.setString('supplier_org_id', org.id ?? '');
      return org;
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch supplier organisation: ${response.body}');
    }
  }

  /// Get cached supplier organisation data
  Future<Organisation?> getCachedSupplierOrganisation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final orgDataString = prefs.getString('supplier_org_data');
      if (orgDataString != null) {
        return Organisation.fromJson(jsonDecode(orgDataString));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update supplier organisation
  Future<Organisation> updateSupplierOrganisation({
    required String orgId,
    String? name,
    String? gstin,
    String? city,
    String? address,
    String? phone,
    String? email,
    String? logoUrl,
    bool? isActive,
  }) async {
    final token = await _getAccessToken();
    
    final Map<String, dynamic> updateData = {};
    if (name != null) updateData['name'] = name;
    if (gstin != null) updateData['gstin'] = gstin;
    if (city != null) updateData['city'] = city;
    if (address != null) updateData['address'] = address;
    if (phone != null) updateData['phone'] = phone;
    if (email != null) updateData['email'] = email;
    if (logoUrl != null) updateData['logo_url'] = logoUrl;
    if (isActive != null) updateData['is_active'] = isActive;

    final response = await http.put(
      Uri.parse('$_baseUrl/api/v1/organisations/$orgId'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updateData),
    );

    if (response.statusCode == 200) {
      final org = Organisation.fromJson(jsonDecode(response.body));
      // Update cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('supplier_org_data', jsonEncode(org.toJson()));
      return org;
    } else {
      throw Exception('Failed to update supplier organisation: ${response.body}');
    }
  }

  // Equipment Management

  /// Create a new equipment for the supplier
  Future<Equipment> createEquipment({
    required String category,
    String? make,
    String? model,
    int? year,
    required String regNumber,
    String? serialNumber,
    String fuelType = 'DIESEL',
    String? capacityDescription,
    List<String>? attachmentTypes,
    double? meterHours,
    String? baseCity,
    String? baseArea,
    int? deployableRadiusKm,
    String includesOperator = 'OPTIONAL',
    double? ratePerHour,
    double? ratePerDay,
    double? ratePerMonth,
    double? mobilisationCharge,
    int? minRentalDays,
    String? notes,
    String? imageUrl,
    Map<String, dynamic>? payStructure,
  }) async {
    final token = await _getAccessToken();
    
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/equipment/'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'category': category,
        if (make != null) 'make': make,
        if (model != null) 'model': model,
        if (year != null) 'year': year,
        'reg_number': regNumber,
        if (serialNumber != null) 'serial_number': serialNumber,
        'fuel_type': fuelType,
        if (capacityDescription != null) 'capacity_description': capacityDescription,
        if (attachmentTypes != null) 'attachment_types': attachmentTypes,
        if (meterHours != null) 'meter_hours': meterHours,
        if (baseCity != null) 'base_city': baseCity,
        if (baseArea != null) 'base_area': baseArea,
        if (deployableRadiusKm != null) 'deployable_radius_km': deployableRadiusKm,
        'includes_operator': includesOperator,
        if (ratePerHour != null) 'rate_per_hour': ratePerHour,
        if (ratePerDay != null) 'rate_per_day': ratePerDay,
        if (ratePerMonth != null) 'rate_per_month': ratePerMonth,
        if (mobilisationCharge != null) 'mobilisation_charge': mobilisationCharge,
        if (minRentalDays != null) 'min_rental_days': minRentalDays,
        if (notes != null) 'notes': notes,
        if (imageUrl != null) 'image_url': imageUrl,
        if (payStructure != null && payStructure.isNotEmpty) 'pay_structure': payStructure,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Equipment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create equipment: ${response.body}');
    }
  }

  /// Get all equipment for the current supplier organisation
  Future<List<Equipment>> getMyEquipment({
    int skip = 0,
    int limit = 100,
  }) async {
    final token = await _getAccessToken();
    
    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/equipment/my-equipment?skip=$skip&limit=$limit'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Equipment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch equipment: ${response.body}');
    }
  }

  /// Get equipment by ID
  Future<Equipment> getEquipmentById(String equipmentId) async {
    final token = await _getAccessToken();
    
    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/equipment/$equipmentId'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Equipment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch equipment: ${response.body}');
    }
  }

  /// Update equipment
  Future<Equipment> updateEquipment({
    required String equipmentId,
    String? category,
    String? make,
    String? model,
    int? year,
    String? regNumber,
    String? serialNumber,
    String? fuelType,
    String? capacityDescription,
    List<String>? attachmentTypes,
    double? meterHours,
    bool? isAvailable,
    bool? isActive,
    String? baseCity,
    String? baseArea,
    int? deployableRadiusKm,
    String? includesOperator,
    double? ratePerHour,
    double? ratePerDay,
    double? ratePerMonth,
    double? mobilisationCharge,
    int? minRentalDays,
    String? notes,
    String? imageUrl,
  }) async {
    final token = await _getAccessToken();
    
    final Map<String, dynamic> updateData = {};
    if (category != null) updateData['category'] = category;
    if (make != null) updateData['make'] = make;
    if (model != null) updateData['model'] = model;
    if (year != null) updateData['year'] = year;
    if (regNumber != null) updateData['reg_number'] = regNumber;
    if (serialNumber != null) updateData['serial_number'] = serialNumber;
    if (fuelType != null) updateData['fuel_type'] = fuelType;
    if (capacityDescription != null) updateData['capacity_description'] = capacityDescription;
    if (attachmentTypes != null) updateData['attachment_types'] = attachmentTypes;
    if (meterHours != null) updateData['meter_hours'] = meterHours;
    if (isAvailable != null) updateData['is_available'] = isAvailable;
    if (isActive != null) updateData['is_active'] = isActive;
    if (baseCity != null) updateData['base_city'] = baseCity;
    if (baseArea != null) updateData['base_area'] = baseArea;
    if (deployableRadiusKm != null) updateData['deployable_radius_km'] = deployableRadiusKm;
    if (includesOperator != null) updateData['includes_operator'] = includesOperator;
    if (ratePerHour != null) updateData['rate_per_hour'] = ratePerHour;
    if (ratePerDay != null) updateData['rate_per_day'] = ratePerDay;
    if (ratePerMonth != null) updateData['rate_per_month'] = ratePerMonth;
    if (mobilisationCharge != null) updateData['mobilisation_charge'] = mobilisationCharge;
    if (minRentalDays != null) updateData['min_rental_days'] = minRentalDays;
    if (notes != null) updateData['notes'] = notes;
    if (imageUrl != null) updateData['image_url'] = imageUrl;

    final response = await http.put(
      Uri.parse('$_baseUrl/api/v1/equipment/$equipmentId'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updateData),
    );

    if (response.statusCode == 200) {
      return Equipment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update equipment: ${response.body}');
    }
  }

  /// Delete equipment
  Future<void> deleteEquipment(String equipmentId) async {
    final token = await _getAccessToken();
    
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/v1/equipment/$equipmentId'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete equipment: ${response.body}');
    }
  }
}
