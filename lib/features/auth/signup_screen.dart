// lib/features/auth/signup_screen.dart
import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../campaigns/campaign_list_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final fullName = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  bool loading = false;
  String? error;

  final auth = AuthService();

  Future<void> _signup() async {
    setState(() {
      loading = true;
      error = null;
    });

    final ok = await auth.signup(
      email.text.trim(),
      pass.text.trim(),
      fullName.text.trim(),
    );

    setState(() {
      loading = false;
    });

    if (!ok) {
      setState(() {
        error = 'Signup failed';
      });
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const CampaignListScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: fullName,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: pass,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            if (error != null)
              Text(
                error!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: loading ? null : _signup,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}
