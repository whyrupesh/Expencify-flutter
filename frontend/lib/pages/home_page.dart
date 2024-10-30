import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'transaction_page.dart';
import 'profile_page.dart';
import '../services/sms_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePageContent(),
    const TransactionPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  // Fetches the username from Firebase authentication
  void _fetchUserName() {
    setState(() {
// Default to 'User' if null
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expencify'),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

// HomePageContent UI with Welcome and Sync Button
class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName ?? 'User'; // Handle null case

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Welcome Message
          Text(
            'Welcome, $userName!',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          // App Name
          const Text(
            'Expencify',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 30),
          // Sync Button
          ElevatedButton.icon(
            onPressed: () async {
              final smsService = SmsService();
              await smsService.requestPermission();
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await smsService.syncMessages(user);
              }
            },
            icon: const Icon(Icons.sync, size: 24),
            label: const Text('Sync Messages'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(fontSize: 18),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
