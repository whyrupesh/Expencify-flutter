import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS Inbox Example',
      home: SmsHomePage(),
    );
  }
}

class SmsHomePage extends StatefulWidget {
  @override
  _SmsHomePageState createState() => _SmsHomePageState();
}

class _SmsHomePageState extends State<SmsHomePage> {
  final SmsQuery _query = SmsQuery();
  List<SmsMessage> _messages = [];

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

  // New function to sync messages to Flask
  Future<void> syncMessages() async {
    List<Map<String, String>> smsList = _messages
        .map((msg) => {"address": msg.address ?? '', "body": msg.body ?? ''})
        .toList();

    try {
      final response = await http.post(
        Uri.parse(
            "http://192.168.211.75:5000/parse-sms"), // Replace with your Flask server URL
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"sms_list": smsList}),
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
        title: Text('SMS Inbox Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _requestPermission,
              child: Text('Fetch Last 5 Messages'),
            ),
            ElevatedButton(
              onPressed: syncMessages,
              child: Text('Sync Messages'),
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
