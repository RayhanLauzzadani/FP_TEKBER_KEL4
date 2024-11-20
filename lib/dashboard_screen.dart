import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl untuk format Rupiah
import 'input_transaction_screen.dart';
import 'transaction_history_screen.dart';
import 'stats_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, String>> transactions = [];

  // Formatter Rupiah
  final NumberFormat _rupiahFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Hitung total saldo
  int _calculateTotalBalance() {
    int total = 5000000; // Awal saldo (contoh Rp 5.000.000)
    for (var transaction in transactions) {
      total -= int.parse(transaction['amount']!); // Kurangi pengeluaran
    }
    return total;
  }

  // Tambahkan transaksi baru
  void _addTransaction(Map<String, String> transaction) {
    setState(() {
      transactions.add(transaction);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Kartu Saldo Total
            Card(
              margin: const EdgeInsets.all(20),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Total Balance',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    Text(
                      _rupiahFormatter.format(_calculateTotalBalance()),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tombol Navigasi
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: const Icon(FontAwesomeIcons.plusCircle, size: 40, color: Colors.white),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InputTransactionScreen(),
                      ),
                    );

                    if (result != null) {
                      _addTransaction(result);
                    }
                  },
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(FontAwesomeIcons.history, size: 40, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TransactionHistoryScreen(transactions: transactions),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(FontAwesomeIcons.chartPie, size: 40, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StatsScreen(transactions: transactions),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
