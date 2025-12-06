import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/api_client.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.instance.loadToken();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DataSet Mobile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final isLoggedIn = snapshot.data ?? false;
          return isLoggedIn ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}
