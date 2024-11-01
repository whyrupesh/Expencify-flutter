import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
      backgroundColor: Colors.indigo.shade50, // Light indigo background
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo and Name
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.indigo.shade600,
              child: const Icon(
                Icons.currency_rupee_rounded, // Money icon for expense tracking
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            // App Title
            const Text(
              'Welcome to Expencify',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.indigoAccent, // Primary color for title
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Effortless Expense Tracking',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blueGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Sign-in Button with Google Icon
            ElevatedButton.icon(
              onPressed: () => _signIn(context),
              icon: Image.asset(
                'assets/Googlelogo.png', // Use a local Google logo asset
                height: 24,
              ),
              label: const Text(
                'Sign in with Google',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.indigo.shade800, // Button text color
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                    color: Colors.indigo.shade400), // Button border color
              ),
            ),
            const SizedBox(height: 20),
            // Footer Text with Privacy Assurance
            const Text(
              'Your secure, all-in-one financial manager!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security,
                    color: Colors.indigo.shade600), // Security icon
                const SizedBox(width: 5),
                const Text(
                  'Data Privacy Assured',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
