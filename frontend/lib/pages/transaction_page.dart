import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  List<dynamic> transactions = [];
  double totalDebit = 0.0;
  double totalCredit = 0.0;
  bool isLoading = true; // Track loading state
  String? errorMessage; // Store any error message

  @override
  void initState() {
    super.initState();
    fetchUserTransactions();
  }

  final String apiUrl =
      'http://13.233.104.228:5001/user/${FirebaseAuth.instance.currentUser?.uid}/transactions';
  // 'http://192.168.211.75:5000/user/${FirebaseAuth.instance.currentUser?.uid}/transactions';

  Future<void> fetchUserTransactions() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          transactions = data;
          calculateTotals(data);
          isLoading = false; // Data loaded successfully
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load transactions: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching transactions: $e';
        isLoading = false;
      });
    }
  }

  void calculateTotals(List<dynamic> transactions) {
    double debitSum = 0.0;
    double creditSum = 0.0;

    for (var transaction in transactions) {
      double amount = parseAmount(transaction['Amount'] ?? '0.0');
      String type = transaction['Transaction Type']?.toLowerCase() ?? 'unknown';

      if (type == 'debit') {
        debitSum += amount;
      } else if (type == 'credit') {
        creditSum += amount;
      }
    }

    setState(() {
      totalDebit = debitSum;
      totalCredit = creditSum;
    });
  }

  double parseAmount(String amount) {
    String cleanedAmount = amount.replaceAll(RegExp(r'[^\d.]'), '');

    if (cleanedAmount.split('.').length > 2) {
      cleanedAmount =
          cleanedAmount.substring(0, cleanedAmount.lastIndexOf('.'));
    }

    return double.tryParse(cleanedAmount) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Transaction Page'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator()) // Show loader
            : errorMessage != null
                ? Center(child: Text(errorMessage!)) // Show error message
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transaction Summary',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryCard(
                              'Total Debit', totalDebit, Colors.red),
                          _buildSummaryCard(
                              'Total Credit', totalCredit, Colors.green),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Transactions',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            return _buildTransactionCard(transaction);
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, double amount, Color textColor) {
    return Card(
      elevation: 4, // Adds shadow for depth
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      color: Colors.white, // Set the background color to white
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Increased padding
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align text to the start
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor, // Text color can remain colored for contrast
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24, // Slightly larger font size for the amount
                fontWeight: FontWeight.bold,
                color: textColor, // Text color for the amount
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    bool isDebit =
        (transaction['Transaction Type'] ?? '').toLowerCase() == 'debit';
    Color typeColor = isDebit ? Colors.red : Colors.green;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: typeColor.withOpacity(0.2),
          child: Icon(
            isDebit ? Icons.arrow_downward : Icons.arrow_upward,
            color: typeColor,
          ),
        ),
        title: Text(
          '₹${transaction['Amount'] ?? '0.0'}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Category: ${transaction['Category'] ?? 'N/A'}'),
            Text('Date: ${transaction['Date'] ?? 'N/A'}'),
            Text('Time: ${transaction['Time'] ?? 'N/A'}'),
          ],
        ),
        trailing: Text(
          isDebit ? 'Debit' : 'Credit',
          style: TextStyle(color: typeColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
