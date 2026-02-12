import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:eqp_rent/core/models/equipment.dart';

class ApiService {
  final String _baseUrl = dotenv.env['BASE_URL']!;

  Future<List<Equipment>> getEquipmentTypes() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/v1/equipment-types'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Equipment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load equipment types');
    }
  }
}
