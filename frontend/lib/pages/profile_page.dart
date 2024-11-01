import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _signOut(BuildContext context) async {
    await AuthService().signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Profile'),
      //   backgroundColor: Colors.indigo,
      //   centerTitle: true,
      // ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : const AssetImage('assets/default_profile.png')
                      as ImageProvider,
            ),
            const SizedBox(height: 20),
            // User's Display Name
            Text(
              user?.displayName ?? 'User Name',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 5),
            // User's Email
            Text(
              user?.email ?? 'Email not available',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            // Additional User Details
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('User ID'),
              subtitle: Text(user?.uid ?? 'Not available'),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Account Created On'),
              subtitle: Text(
                user?.metadata.creationTime
                        ?.toLocal()
                        .toString()
                        .split(' ')[0] ??
                    'N/A',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('Last Sign-In'),
              subtitle: Text(
                user?.metadata.lastSignInTime
                        ?.toLocal()
                        .toString()
                        .split(' ')[0] ??
                    'N/A',
              ),
            ),
            const SizedBox(height: 30),
            // Sign-Out Button
            ElevatedButton.icon(
              onPressed: () => _signOut(context),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Sign Out',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
