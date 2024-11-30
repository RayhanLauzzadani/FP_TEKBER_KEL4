import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dashboard_screen.dart';
import 'transaction_history_screen.dart';
import 'input_transaction_screen.dart';
import 'stats_screen.dart';
import 'welcome_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyBjMDNMKQFz5Clw8BK343WWe4QwsrTqSs4",
        authDomain: "fp-tekber-c-kel4.firebaseapp.com",
        projectId: "fp-tekber-c-kel4",
        storageBucket: "fp-tekber-c-kel4.appspot.com",
        messagingSenderId: "353816920464",
        appId: "1:353816920464:web:a3f3a2924a77c09537b315",
        measurementId: "G-0WBKLX7PJV",
      ),
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
        '/': (context) => DashboardScreen(), // Constructor tanpa parameter
        '/inputTransactions': (context) => InputTransactionScreen(
              onTransactionAdded: () {}, // Callback kosong
            ),
        '/history': (context) => TransactionHistoryScreen(
              onTransactionDeleted: () {}, // Callback kosong
            ),
        '/expensesStatistics': (context) => StatsScreen(),
      },
    );
  }
}
