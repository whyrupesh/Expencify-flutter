import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  // Future<void> _signIn(BuildContext context) async {
  //   final user = await AuthService().signInWithGoogle();
  //   if (user != null) {
  //     Navigator.pushReplacementNamed(context, '/home');
  //   } else {
  //     print("Sign-in failed.");
  //   }
  // }

  Future<void> _signIn(BuildContext context) async {
    print("Attempting to sign in...");
    final user = await AuthService().signInWithGoogle();

    if (context.mounted && user != null) {
      print("User signed in: ${user.displayName}");
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      print("Sign-in failed.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expencify')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _signIn(context),
          child: const Text('Sign in with Google'),
        ),
      ),
    );
  }
}
