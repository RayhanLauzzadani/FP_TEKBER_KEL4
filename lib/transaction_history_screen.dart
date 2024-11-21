import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatelessWidget {
  final List<Map<String, String>> transactions;
  final void Function(int) onDeleteTransaction;

  TransactionHistoryScreen({
    required this.transactions,
    required this.onDeleteTransaction,
  });

  // Mapping kategori ke ikon yang sesuai
  final Map<String, IconData> categoryIcons = {
    'Akomodasi': Icons.hotel,
    'Food': Icons.fastfood,
    'Transport': Icons.directions_car,
    'Shopping': Icons.shopping_bag,
  };

  @override
  Widget build(BuildContext context) {
    final NumberFormat _rupiahFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.blue.shade200, // Latar belakang biru muda
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: transactions.isEmpty
            ? const Center(
                child: Text(
                  'No transactions added yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  var transaction = transactions[index];
                  String category = transaction['category']!;
                  IconData? categoryIcon = categoryIcons[category];

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white, // Latar belakang putih pada kartu
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.blue[300]!, // Border biru sesuai theme
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        categoryIcon ?? Icons.category, // Menampilkan ikon yang sesuai
                        color: Colors.blue[300], // Warna ikon biru
                      ),
                      title: Text(
                        category,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        '${_rupiahFormatter.format(int.parse(transaction['amount']!))} - ${transaction['date']}',
                        style: TextStyle(color: Colors.blue[300]), // Warna subtitle biru
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => onDeleteTransaction(index),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}