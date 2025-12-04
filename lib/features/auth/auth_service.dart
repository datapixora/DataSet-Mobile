import 'dart:convert';
import '../../core/api_client.dart';

class AuthService {
  final api = ApiClient.instance;

  Future<bool> signup(String email, String password, String fullname) async {
    final res = await api.post("/auth/signup", {
      "email": email,
      "password": password,
      "fullName": fullname,
    });

    return res.statusCode == 200 || res.statusCode == 201;
  }

  Future<bool> login(String email, String password) async {
    final res = await api.post("/auth/login", {
      "email": email,
      "password": password,
    });

    if (res.statusCode != 200) return false;

    final data = jsonDecode(res.body);
    final token = data["data"]["accessToken"]; // اگر متفاوت بود بعداً اصلاح می‌کنیم
    await api.saveToken(token);

    return true;
  }
}
