import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login_page.dart';
import 'welcome_page.dart';
import 'dashboard_screen.dart';
import 'transaction_history_screen.dart';
import 'input_transaction_screen.dart';
import 'stats_screen.dart';
import 'trip_planning_screen.dart';
import 'conversion_calculator_screen.dart';
import 'screens/verify_screen.dart';
import 'screens/newpassword_screen.dart';
import 'screens/register_page.dart';
import 'screens/logout_page.dart'; // Import LogoutPage
import 'package:phosphor_flutter/phosphor_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    await Firebase.initializeApp();
    runApp(MyApp());
  } catch (e) {
    runApp(ErrorApp(message: e.toString()));
  }
}

class ErrorApp extends StatelessWidget {
  final String message;

  const ErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Error: $message',
            style: const TextStyle(color: Colors.red, fontSize: 18),
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
      title: 'Navigation Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthWrapper(), // Ganti initialRoute dengan AuthWrapper
      routes: {
        '/welcome': (context) => WelcomePage(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/verify': (context) => VerifyEmailScreen(),
        '/newPassword': (context) => NewPasswordScreen(),
        '/dashboard': (context) => NavigationHome(),
        '/inputTransactions': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
          return InputTransactionScreen(
            onTransactionAdded: () {},
            exchangeRates: args['exchangeRates'] ?? {},
          );
        },
        '/history': (context) => TransactionHistoryScreen(onTransactionDeleted: () {}),
        '/expensesStatistics': (context) => StatsScreen(),
        '/tripPlanning': (context) => TripPlanningScreen(),
        '/conversionCalculator': (context) => ConversionCalculatorScreen(),
        '/logout': (context) => const LogoutScreen(), // Route untuk LogoutPage
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Stream status autentikasi Firebase
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Tampilkan layar loading saat memeriksa status login
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          // Jika pengguna sudah login, arahkan ke Dashboard
          return NavigationHome();
        } else {
          // Jika belum login, arahkan ke halaman WelcomePage atau LoginPage
          return WelcomePage();
        }
      },
    );
  }
}

class NavigationHome extends StatefulWidget {
  @override
  State<NavigationHome> createState() => _NavigationHomeState();
}

class _NavigationHomeState extends State<NavigationHome> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DashboardScreen(),
    TripPlanningScreen(),
    StatsScreen(),
    const LogoutScreen(), // Ganti Settings dengan LogoutPage
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Color(0xFF7AAACE),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                PhosphorIcons.house(),
                size: 32.0,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                PhosphorIcons.island(),
                size: 32.0,
              ),
              label: 'Trip',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                PhosphorIcons.chartDonut(),
                size: 32.0,
              ),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                PhosphorIcons.gearSix(),
                size: 32.0,
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
