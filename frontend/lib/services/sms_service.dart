import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SmsService {
  final SmsQuery _query = SmsQuery();

  // Request SMS permission if not already granted
  Future<void> requestPermission() async {
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      status = await Permission.sms.request();
    }

    if (status.isGranted) {
      print("SMS Permission granted");
    } else {
      print("SMS Permission denied");
      throw Exception("SMS Permission denied");
    }
  }

  // Fetch and sync the last 5 messages
  Future<void> syncMessages(User user) async {
    try {
      List<SmsMessage> messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
      );

      List<Map<String, String>> smsList = messages
          .take(5)
          .map((msg) => {"address": msg.address ?? '', "body": msg.body ?? ''})
          .toList();

      final response = await http.post(
        Uri.parse("http://192.168.211.75:5000/parse-sms"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": user.uid,
          "sms_list": smsList,
        }),
      );

      if (response.statusCode == 200) {
        print("Messages synced successfully: ${response.body}");
      } else {
        print(
            "Failed to sync messages with status code: ${response.statusCode}");
        throw Exception("Failed to sync messages: ${response.statusCode}");
      }
    } catch (e) {
      print("Error syncing messages: $e");
    }
  }
}
