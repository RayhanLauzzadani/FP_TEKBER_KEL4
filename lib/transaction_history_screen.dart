import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flag/flag.dart';

class TransactionHistoryScreen extends StatelessWidget {
  final VoidCallback onTransactionDeleted;

  TransactionHistoryScreen({required this.onTransactionDeleted});

  final Map<String, Widget> categoryIcons = {
    'Add Balance': Icon(
      PhosphorIcons.wallet(),
      size: 32.0,
      color: Colors.white,
    ),
    'Transport': Icon(
      PhosphorIcons.car(),
      size: 32.0,
      color: Colors.white,
    ),
    'Food': Icon(
      PhosphorIcons.hamburger(),
      size: 32.0,
      color: Colors.white,
    ),
    'Shopping': Icon(
      PhosphorIcons.shoppingBag(),
      size: 32.0,
      color: Colors.white,
    ),
    'Akomodasi': Icon(
      PhosphorIcons.bed(),
      size: 32.0,
      color: Colors.white,
    ),
  };

  final Map<String, NumberFormat> currencyFormatters = {
    'IDR':
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0),
    'USD':
        NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 0),
    'JPY':
        NumberFormat.currency(locale: 'ja_JP', symbol: '¥', decimalDigits: 0),
    'GBP':
        NumberFormat.currency(locale: 'en_GB', symbol: '£', decimalDigits: 0),
    'EUR': NumberFormat.currency(locale: 'eu', symbol: '€', decimalDigits: 0),
  };

  final List<Map<String, String>> countriesWithFlags = [
    {"name": "Indonesia", "code": "ID"},
    {"name": "United States", "code": "US"},
    {"name": "Japan", "code": "JP"},
    {"name": "United Kingdom", "code": "GB"},
    {"name": "European Union", "code": "EU"},
    {"name": "Australia", "code": "AU"},
    {"name": "Singapore", "code": "SG"},
  ];

  final Map<String, String> countryToCurrency = {
    'Indonesia': 'IDR',
    'United States': 'USD',
    'Japan': 'JPY',
    'United Kingdom': 'GBP',
    'European Union': 'EUR',
    'Australia': 'AUD',
    'Singapore': 'SGD',
  };

  String getCurrencySymbol(String currencyCode) {
    switch (currencyCode) {
      case 'IDR':
        return 'Rp';
      case 'USD':
        return '\$';
      case 'JPY':
        return '¥';
      case 'GBP':
        return '£';
      case 'EUR':
        return '€';
      case 'AUD':
        return 'A\$';
      case 'SGD':
        return 'S\$';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(
        child: Text(
          "No user logged in",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4484B7), Color(0xFFFFFFFF)],
          stops: [0.54, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                .collection('users')
                .doc(uid)
                .collection('transactions')
                .orderBy('createdAt', descending: true) // Gunakan 'createdAt'
                .snapshots(),
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
                  final data =
                      transaction.data() as Map<String, dynamic>? ?? {};

                  final String category = data['category'] ?? 'Unknown';
                  final String country = data['country'] ?? 'Unknown';
                  final String currency = data['currency'] ?? 'USD';
                  final double amount =
                      (data['amount'] as num?)?.toDouble() ?? 0.0;
                  final String note = data['notes'] ?? 'No notes available';
                  final DateTime createdAt = data['createdAt'] != null
                      ? (data['createdAt'] is Timestamp
                          ? (data['createdAt'] as Timestamp).toDate()
                          : DateTime.now())
                      : DateTime.now();

                  final String formattedDate =
                      DateFormat('dd MMM yyyy').format(createdAt);

                  final Widget categoryIcon = categoryIcons[category] ??
                      Icon(
                        Icons.category,
                        size: 32.0,
                        color: Colors.white,
                      );

                  final formatter = currencyFormatters[currency] ??
                      NumberFormat.currency(
                          locale: 'en_US', symbol: '\$', decimalDigits: 2);

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.blue[300]!,
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      onTap: () {
                        _showTransactionDetails(
                          context: context,
                          category: category,
                          country: country,
                          amount: amount,
                          createdAt: createdAt,
                          note: note,
                          transactionId:
                              transaction.id, // Menambahkan ID transaksi
                        );
                      },
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF79A4C0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(child: categoryIcon),
                      ),
                      title: Text(
                        category,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        '$country • $formattedDate\n${formatter.format(amount.abs())}',
                        style: TextStyle(color: Colors.blue[300]),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final bool? confirmDelete = await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Delete Transaction'),
                                content: const Text(
                                    'Are you sure you want to delete this transaction?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmDelete == true) {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser?.uid)
                                  .collection('transactions')
                                  .doc(transaction.id)
                                  .delete();

                              onTransactionDeleted();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Transaction deleted successfully'),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Failed to delete transaction: $e'),
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
      ),
    );
  }

  void _showTransactionDetails({
    required BuildContext context,
    required String category,
    required String country,
    required double amount,
    required DateTime createdAt,
    required String note,
    required String transactionId, // Tambahkan ID transaksi
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transaction Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditForm(
                          context: context,
                          transactionId: transactionId,
                          category: category,
                          country: country,
                          amount: amount,
                          createdAt: createdAt,
                          note: note,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Category: $category',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 8),
                Text(
                  'Country: $country',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 8),
                Text(
                  'Amount: \$${amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 8),
                Text(
                  'Date: ${DateFormat('dd MMM yyyy').format(createdAt)}',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 8),
                Text(
                  'Notes: $note',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Close',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditForm({
    required BuildContext context,
    required String transactionId,
    required String category,
    required String country,
    required double amount,
    required DateTime createdAt,
    required String note,
  }) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    final TextEditingController dateController =
        TextEditingController(text: DateFormat('yyyy-MM-dd').format(createdAt));
    final TextEditingController amountController =
        TextEditingController(text: amount.toString());
    final TextEditingController noteController =
        TextEditingController(text: note);

    String selectedCountry = country;
    String currencyCode = countryToCurrency[selectedCountry] ?? 'USD';
    String currencySymbol = getCurrencySymbol(currencyCode);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              backgroundColor: const Color(0xFFA1C1DB),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Edit Transaction',
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                      ),
                      const Text(
                        'Location',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          _showCountrySelectionDialog(context,
                              (String selected) {
                            setState(() {
                              selectedCountry = selected;
                              currencyCode =
                                  countryToCurrency[selectedCountry] ?? 'USD';
                              currencySymbol = getCurrencySymbol(currencyCode);
                            });
                          });
                        },
                        child: Container(
                          height: 55,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFFE7F0F8),
                            border: Border.all(
                                color: const Color(0xFF4383B7), width: 1.5),
                          ),
                          child: Row(
                            children: [
                              if (selectedCountry.isNotEmpty)
                                ClipOval(
                                  child: Flag.fromString(
                                    countriesWithFlags.firstWhere((country) =>
                                        country['name'] ==
                                        selectedCountry)['code']!,
                                    height: 24,
                                    width: 24,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Text(
                                selectedCountry.isNotEmpty
                                    ? selectedCountry
                                    : 'Select Country',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Date',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: createdAt,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              dateController.text =
                                  DateFormat('yyyy-MM-dd').format(selectedDate);
                            });
                          }
                        },
                        child: Container(
                          height: 55,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFFE7F0F8),
                            border: Border.all(
                                color: const Color(0xFF4383B7), width: 1.5),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              dateController.text.isNotEmpty
                                  ? dateController.text
                                  : 'Select Date',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Amount',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 55,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFFE7F0F8),
                          border: Border.all(
                              color: const Color(0xFF4383B7), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Text(
                              currencySymbol,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: amountController,
                                style: const TextStyle(fontSize: 16),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter amount',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Amount cannot be empty';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Notes',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: noteController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFE7F0F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Color(0xFF4383B7), width: 1.5),
                          ),
                          hintText: 'Enter notes',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4383B7),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      double newAmount =
                          double.tryParse(amountController.text) ?? amount;
                      double amountDifference = newAmount - amount;

                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid != null) {
                        final userRef = FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid);

                        await FirebaseFirestore.instance
                            .runTransaction((transaction) async {
                          final snapshot = await transaction.get(userRef);
                          if (snapshot.exists) {
                            transaction.update(userRef, {
                              'balance':
                                  FieldValue.increment(-amountDifference),
                            });
                          }
                        });

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .collection('transactions')
                            .doc(transactionId)
                            .update({
                          'country': selectedCountry,
                          'createdAt': Timestamp.fromDate(
                            DateFormat('yyyy-MM-dd').parse(dateController.text),
                          ),
                          'amount': newAmount,
                          'notes': noteController.text,
                          'currency': currencyCode,
                        });

                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCountrySelectionDialog(
      BuildContext context, Function(String) onSelected) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Select Country'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: countriesWithFlags.length,
              itemBuilder: (context, index) {
                final country = countriesWithFlags[index];
                return ListTile(
                  leading: ClipOval(
                    child: Flag.fromString(
                      country['code']!,
                      height: 24,
                      width: 24,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(country['name']!),
                  onTap: () {
                    onSelected(country['name']!);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
