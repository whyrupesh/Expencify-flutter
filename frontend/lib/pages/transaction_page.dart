import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  List<dynamic> _transactions = [];

  Future<void> _fetchTransactions() async {
    try {
      final response =
          await http.get(Uri.parse("http://192.168.211.75:5000/transactions"));
      if (response.statusCode == 200) {
        setState(() {
          _transactions = jsonDecode(response.body);
        });
      } else {
        print("Failed to load transactions: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching transactions: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: ListView.builder(
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final transaction = _transactions[index];
          return ListTile(
            title: Text(transaction['description'] ?? 'No description'),
            subtitle: Text('Amount: ${transaction['amount']}'),
          );
        },
      ),
    );
  }
}
