import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();

    // Timer untuk berpindah ke Dashboard setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Warna latar belakang
      body: Center(
        child: Image.asset(
          'assets/images/logo.png', // Path ke logo
          width: 800, // Ukuran logo dikembalikan seperti semula
          height: 800,
        ),
      ),
    );
  }
}
