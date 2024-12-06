import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dashboard_screen.dart';
import 'transaction_history_screen.dart';
import 'input_transaction_screen.dart';
import 'stats_screen.dart';
import 'welcome_page.dart';
import 'trip_planning_screen.dart';
import 'conversion_calculator_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
    );
    runApp(MyApp());
  } catch (e) {
    print("Error initializing Firebase: $e");
    runApp(ErrorApp(message: e.toString())); // Tampilkan error jika gagal
  }
}

class ErrorApp extends StatelessWidget {
  final String message;

  ErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Error: $message',
            style: TextStyle(color: Colors.red, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => WelcomePage(),
        '/': (context) => DashboardScreen(),
        '/inputTransactions': (context) => InputTransactionScreen(
              onTransactionAdded: () {},
            ),
        '/history': (context) => TransactionHistoryScreen(
              onTransactionDeleted: () {},
            ),
        '/expensesStatistics': (context) => StatsScreen(),
        '/tripPlanning': (context) => TripPlanningScreen(),
        '/conversionCalculator': (context) => ConversionCalculatorScreen(), // Rute baru
      },
    );
  }
}
