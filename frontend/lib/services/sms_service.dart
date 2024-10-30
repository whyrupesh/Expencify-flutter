import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SmsService {
  final SmsQuery _query = SmsQuery();
  DateTime? _lastSyncTime;

  // Calculate the cutoff date for filtering (3 months back from today)
  DateTime get _cutoffDate {
    return DateTime.now().subtract(const Duration(days: 90));
  }

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

  // Load the last sync timestamp from SharedPreferences
  Future<void> loadLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    String? lastSyncString = prefs.getString('lastSyncTime');
    if (lastSyncString != null) {
      _lastSyncTime = DateTime.parse(lastSyncString);
    } else {
      _lastSyncTime = _cutoffDate; // Default to 3 months back
    }
  }

  // Save the latest sync timestamp to SharedPreferences
  Future<void> saveLastSyncTime(DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastSyncTime', timestamp.toIso8601String());
  }

  // Sync only messages from the last 3 months
  Future<void> syncMessages(User user) async {
    try {
      await loadLastSyncTime(); // Load the last sync time

      // Query all inbox messages
      List<SmsMessage> messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
      );

      // Filter messages from the last 3 months and after the last sync
      List<SmsMessage> recentMessages = messages.where((msg) {
        DateTime messageDate = msg.date ?? DateTime.now();
        return messageDate.isAfter(_cutoffDate) &&
            messageDate.isAfter(_lastSyncTime!);
      }).toList();

      if (recentMessages.isEmpty) {
        print("No new messages to sync from the last 3 months.");
        return; // Exit if there are no new relevant messages
      }

      // Prepare the messages for syncing
      List<Map<String, String>> smsList = recentMessages
          .map((msg) => {
                "address": msg.address ?? '',
                "body": msg.body ?? '',
              })
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

        // Save the latest message's date as the new sync time
        DateTime latestSyncTime = recentMessages.first.date ?? DateTime.now();
        await saveLastSyncTime(latestSyncTime);
      } else {
        print("Failed to sync messages: ${response.statusCode}");
        throw Exception("Failed to sync messages");
      }
    } catch (e) {
      print("Error syncing messages: $e");
    }
  }
}
