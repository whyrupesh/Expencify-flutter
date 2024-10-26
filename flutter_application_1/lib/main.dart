import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

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

  // Request SMS permissions
  Future<void> _requestPermission() async {
    if (await Permission.sms.request().isGranted) {
      _getLastFiveMessages();
    } else {
      print('SMS Permission denied');
    }
  }

  // Fetch the last 5 messages
  Future<void> _getLastFiveMessages() async {
    List<SmsMessage> messages = await _query.querySms(
      kinds: [SmsQueryKind.inbox],
    );

    setState(() {
      _messages = messages.take(100).toList(); // Keep only the last 5 messages
    });

    // Print to terminal
    for (var message in _messages) {
      print('From: ${message.address}, Body: ${message.body}');
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
