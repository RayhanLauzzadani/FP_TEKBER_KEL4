import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.blue[300],
      appBar: AppBar(
        automaticallyImplyLeading: false, // Menghilangkan tombol Back
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('balances').doc('totalBalance').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text(
                  'Balance not found',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              );
            }

            // Ambil saldo terbaru dari Firestore
            final double totalBalance = snapshot.data!['balance']?.toDouble() ?? 0.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Welcome, User!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Total Balance",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Colors.white),
                ),
                const SizedBox(height: 5),
                Text(
                  formatter.format(totalBalance),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // Tampilkan pop-up untuk memasukkan nominal
                    showDialog(
                      context: context,
                      builder: (context) {
                        final TextEditingController amountController = TextEditingController();

                        return AlertDialog(
                          title: const Text("Add Balance"),
                          content: TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: "Enter amount",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Tutup dialog
                              },
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                // Ambil nominal dari teks input
                                final amount = double.tryParse(amountController.text) ?? 0;

                                if (amount > 0) {
                                  await FirebaseFirestore.instance
                                      .collection('balances')
                                      .doc('totalBalance')
                                      .update({'balance': FieldValue.increment(amount)});
                                }

                                Navigator.of(context).pop(); // Tutup dialog
                              },
                              child: const Text("Add"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('Add Balance'),
                ),
                const SizedBox(height: 40),
                _buildMenuButton(context, "Input Transactions", Icons.edit, '/inputTransactions'),
                _buildMenuButton(context, "History", Icons.history, '/history'),
                _buildMenuButton(context, "Expenses Statistics", Icons.bar_chart, '/expensesStatistics'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          shadowColor: Colors.black45,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
        onPressed: () => Navigator.pushNamed(context, route),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blue[300]),
            const SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[300]),
            ),
          ],
        ),
      ),
    );
  }
}
