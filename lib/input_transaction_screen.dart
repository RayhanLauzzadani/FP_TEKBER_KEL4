import 'package:flutter/material.dart';

class InputTransactionScreen extends StatefulWidget {
  const InputTransactionScreen({super.key});

  @override
  _InputTransactionScreenState createState() => _InputTransactionScreenState();
}

class _InputTransactionScreenState extends State<InputTransactionScreen> {
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();

  void _addTransaction() {
    final category = _categoryController.text;
    final amount = _amountController.text;

    if (category.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields')),
      );
      return;
    }

    // Kirim transaksi kembali ke layar sebelumnya
    Navigator.pop(context, {
      'category': category,
      'amount': amount,
    });

    // Kosongkan field input
    _categoryController.clear();
    _amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addTransaction,
              child: const Text('Add Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
