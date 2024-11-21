import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'transaction_history_screen.dart';
import 'input_transaction_screen.dart';
import 'stats_screen.dart';
import 'welcome_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<Map<String, String>> _transactions = [];

  void _addTransaction(Map<String, String> transaction) {
    setState(() {
      _transactions.add(transaction);
    });
  }

  void _deleteTransaction(int index) {
    setState(() {
      _transactions.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UI Sederhana',
      debugShowCheckedModeBanner: false,
      initialRoute: '/welcome', // Welcome Page jadi layar awal
      routes: {
        '/welcome': (context) => WelcomePage(),
        '/': (context) => DashboardScreen(transactions: _transactions),
        '/inputTransactions': (context) => InputTransactionScreen(
              onSaveTransaction: _addTransaction,
            ),
        '/history': (context) => TransactionHistoryScreen(
              transactions: _transactions,
              onDeleteTransaction: _deleteTransaction,
            ),
        '/expensesStatistics': (context) =>
            StatsScreen(transactions: _transactions),
      },
    );
  }
}
