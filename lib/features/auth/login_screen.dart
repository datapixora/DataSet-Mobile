import 'package:flutter/material.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool loading = false;
  String? error;

  final auth = AuthService();

  login() async {
    setState(() => loading = true);
    bool ok = await auth.login(email.text, pass.text);
    setState(() => loading = false);

    if (!ok) return setState(() => error = "Login failed");
    // 🔜 بعد از لاگین → برو CampaignList (Step 4)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: email, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: pass, obscureText: true, decoration: InputDecoration(labelText: "Password")),
            SizedBox(height: 20),
            if (error != null) Text(error!, style: TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: loading ? null : login,
              child: loading ? CircularProgressIndicator() : Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
