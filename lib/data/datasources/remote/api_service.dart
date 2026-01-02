import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  ApiService();

  final _baseUrl = 'https://api.example.com';

  Future<Map<String, dynamic>> get(String path) async {
    final res = await http.get(Uri.parse('$_baseUrl$path'));
    return json.decode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final res = await http.post(
      Uri.parse('$_baseUrl$path'),
      body: json.encode(body),
      headers: {'Content-Type': 'application/json'},
    );
    return json.decode(res.body) as Map<String, dynamic>;
  }
}
