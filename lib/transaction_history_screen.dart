import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatelessWidget {
  final List<Map<String, String>> transactions;
  final void Function(int) onDeleteTransaction;

  TransactionHistoryScreen({
    required this.transactions,
    required this.onDeleteTransaction,
  });

  @override
  Widget build(BuildContext context) {
    final NumberFormat _rupiahFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
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
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.category, color: Colors.blueAccent),
                      title: Text(transaction['category']!),
                      subtitle: Text(
                          '${_rupiahFormatter.format(int.parse(transaction['amount']!))} - ${transaction['date']}'),
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
