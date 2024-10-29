import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS Inbox Example',
      home: SmsHomePage(),
    );
  }
}

class SmsHomePage extends StatefulWidget {
  const SmsHomePage({super.key});

  @override
  _SmsHomePageState createState() => _SmsHomePageState();
}

class _SmsHomePageState extends State<SmsHomePage> {
  final SmsQuery _query = SmsQuery();
  final AuthService _authService = AuthService();
  List<SmsMessage> _messages = [];
  User? _user; // Track the authenticated user

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth
        .instance.currentUser; // Get current user if already signed in
  }

  // Function to sign in with Google
  Future<void> _signIn() async {
    User? user = await _authService.signInWithGoogle();
    setState(() {
      _user = user;
    });

    if (_user != null) {
      print("User signed in: ${_user!.displayName}, UID: ${_user!.uid}");
    }
  }

  // Function to sign out
  Future<void> _signOut() async {
    await _authService.signOut();
    setState(() {
      _user = null;
    });
    print("User signed out");
  }

  Future<void> _requestPermission() async {
    if (await Permission.sms.request().isGranted) {
      _getLastFiveMessages();
    } else {
      print('SMS Permission denied');
    }
  }

  Future<void> _getLastFiveMessages() async {
    List<SmsMessage> messages = await _query.querySms(
      kinds: [SmsQueryKind.inbox],
    );

    setState(() {
      _messages = messages.take(5).toList();
    });

    for (var message in _messages) {
      print('From: ${message.address}, Body: ${message.body}');
    }
  }

  // Updated syncMessages function to include user ID
  Future<void> syncMessages() async {
    if (_user == null) {
      print("User not signed in. Please sign in first.");
      return;
    }

    List<Map<String, String>> smsList = _messages
        .map((msg) => {"address": msg.address ?? '', "body": msg.body ?? ''})
        .toList();

    try {
      final response = await http.post(
        Uri.parse(
            "http://192.168.211.75:5000/parse-sms"), // Replace with your Flask server URL
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": _user!.uid, // Include user ID in the payload
          "sms_list": smsList
        }),
      );

      if (response.statusCode == 200) {
        print("Messages synced successfully: ${response.body}");
      } else {
        print("Failed to sync messages: ${response.statusCode}");
      }
    } catch (e) {
      print("Error syncing messages: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Inbox Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Sign in/out buttons
            if (_user == null)
              ElevatedButton(
                onPressed: _signIn,
                child: const Text('Sign in with Google'),
              )
            else
              Column(
                children: [
                  Text('Hello, ${_user!.displayName}'),
                  ElevatedButton(
                    onPressed: _signOut,
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestPermission,
              child: const Text('Fetch Last 5 Messages'),
            ),
            ElevatedButton(
              onPressed: syncMessages,
              child: const Text('Sync Messages'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  SmsMessage message = _messages[index];
                  return ListTile(
                    title: Text(message.body ?? 'No content'),
                    subtitle: Text('From: ${message.address}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
