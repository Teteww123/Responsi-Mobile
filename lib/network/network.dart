import 'dart:convert';
import 'package:http/http.dart' as http;

class Network {
  static const String _baseUrl = 'https://resp-api-three.vercel.app';

  static Future<List<dynamic>> getPhones() async {
    final response = await http.get(Uri.parse('$_baseUrl/phones'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Failed to load phones');
    }
  }

  static Future<Map<String, dynamic>> getPhoneDetail(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/phone/$id'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? {};
    } else {
      throw Exception('Failed to load phone detail');
    }
  }

  static Future<void> createPhone(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/phone'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create phone');
    }
  }

  static Future<void> updatePhone(int id, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/phone/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update phone');
    }
  }

  static Future<void> deletePhone(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/phone/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete phone');
    }
  }
}


