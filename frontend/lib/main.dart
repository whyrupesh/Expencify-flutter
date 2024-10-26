import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter and Flask Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String message = "Press the button to fetch data";

  // Function to fetch data from the Flask API
  Future<void> fetchData() async {
    final url =
        Uri.parse('http://192.168.211.75:5000/print'); // Your Flask endpoint
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Parse the JSON response
      final data = jsonDecode(response.body);
      setState(() {
        message = data['message'];
      });
    } else {
      setState(() {
        message = "Failed to fetch data";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter & Flask Demo"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              message,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchData,
              child: Text("Fetch Data from Flask"),
            ),
          ],
        ),
      ),
    );
  }
}
