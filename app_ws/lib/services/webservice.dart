import 'package:app_ws/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WebService {
  final String baseUrl = Config.apiBaseUrl;

  WebService();

  Future<List<dynamic>> getIngredienti() async {
    final response = await http.get(Uri.parse('$baseUrl/ingredienti'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load ingredienti');
    }
  }

  Future<List<Map<String, dynamic>>> getCamerieri() async {
    final response = await http.get(Uri.parse('$baseUrl/camerieri'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data.map((cameriere) => {
        'id': cameriere[0],
        'indirizzo': cameriere[1],
        'nome': cameriere[2],
      }));
    } else {
      throw Exception('Failed to load camerieri');
    }
  }

  Future<void> updateIngredienti(List<Map<String, dynamic>> pizze) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ingredienti/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(pizze),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update ingredienti');
    }
  }

  Future<int> register(String indirizzo, String deviceName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/camerieri/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'address': indirizzo, 'name': deviceName}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint('Registered as ${data['id']}');
      return data['id'];
    } else {
      return -1;
    }
  }
}
