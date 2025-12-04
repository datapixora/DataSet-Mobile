import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  String? _token;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("access_token");
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", token);
    _token = token;
  }

  Map<String, String> _headers({bool auth = false}) => {
        "Content-Type": "application/json",
        if (auth && _token != null) "Authorization": "Bearer $_token",
      };

  Future<http.Response> post(String path, Map body, {bool auth = false}) async {
    final url = Uri.parse("${AppConfig.apiBaseUrl}$path");
    return await http.post(url,
        headers: _headers(auth: auth), body: jsonEncode(body));
  }

  Future<http.Response> get(String path, {bool auth = false}) async {
    final url = Uri.parse("${AppConfig.apiBaseUrl}$path");
    return await http.get(url, headers: _headers(auth: auth));
  }
}
