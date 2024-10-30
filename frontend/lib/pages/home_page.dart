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
  late final SmsService _smsService;
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePageContent(),
    const TransactionPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _smsService = SmsService();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expencify - Home')),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

// Separate HomePageContent to avoid recursion
class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final smsService = SmsService();
          await smsService.requestPermission();
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await smsService.syncMessages(user);
          }
        },
        child: const Text('Sync Messages'),
      ),
    );
  }
}
