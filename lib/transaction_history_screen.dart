import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionHistoryScreen extends StatelessWidget {
  final VoidCallback onTransactionDeleted; // Callback untuk memperbarui total balance

  TransactionHistoryScreen({required this.onTransactionDeleted});

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
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('transactions')
              .orderBy('date', descending: true)
              .snapshots(), // Mendengarkan perubahan data secara real-time
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No transactions added yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            final transactions = snapshot.data!.docs;

            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                final category = transaction['category'] ?? 'Unknown';
                final categoryIcon = categoryIcons[category];

                // Menangani parsing amount
                final amount = transaction['amount'] != null
                    ? (transaction['amount'] is num
                        ? transaction['amount'] // Jika sudah angka, gunakan langsung
                        : int.tryParse(transaction['amount'].toString()) ?? 0) // Jika String, parsing ke int
                    : 0;

                // Menangani berbagai tipe data untuk `date`
                final date = transaction['date'] != null
                    ? (transaction['date'] is Timestamp
                        ? (transaction['date'] as Timestamp).toDate() // Jika Timestamp, konversi ke DateTime
                        : DateTime.tryParse(transaction['date']) ?? DateTime.now()) // Jika String, parse ke DateTime
                    : DateTime.now();

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
                      '${_rupiahFormatter.format(amount)} - ${DateFormat('dd MMM yyyy').format(date)}',
                      style: TextStyle(color: Colors.blue[300]), // Warna subtitle biru
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        // Konfirmasi sebelum menghapus
                        final bool? confirmDelete = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Delete Transaction'),
                              content: const Text('Are you sure you want to delete this transaction?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmDelete == true) {
                          try {
                            // Hapus transaksi dari Firestore
                            await FirebaseFirestore.instance
                                .collection('transactions')
                                .doc(transaction.id)
                                .delete();

                            // Callback untuk memperbarui total balance
                            onTransactionDeleted();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Transaction deleted successfully'),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to delete transaction: $e'),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
