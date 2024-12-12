import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TransactionHistoryWidget extends StatelessWidget {
  final int limit;
  final bool allowDelete;

  TransactionHistoryWidget({this.limit = 5, this.allowDelete = false});

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
    'IDR': NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0),
    'USD': NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 0),
    'JPY': NumberFormat.currency(locale: 'ja_JP', symbol: '¥', decimalDigits: 0),
    'GBP': NumberFormat.currency(locale: 'en_GB', symbol: '£', decimalDigits: 0),
    'EUR': NumberFormat.currency(locale: 'eu', symbol: '€', decimalDigits: 0),
  };

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

    return StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('transactions')
      .orderBy('createdAt', descending: true) // Gunakan 'createdAt'
      .limit(limit)
      .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Center(
        child: Text("No transaction history available"),
      );
    }

    final transactions = snapshot.data!.docs;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final data = transaction.data() as Map<String, dynamic>?;

        final String category = data?['category'] ?? 'Unknown';
        final String country = data?['country'] ?? 'Unknown';
        final String currency = data?['currency'] ?? 'USD';
        final double amount = (data?['amount'] as num?)?.toDouble() ?? 0.0;
        final double convertedAmount =
            (data?['convertedAmount'] as num?)?.toDouble() ?? 0.0;

        final DateTime createdAt = data?['createdAt'] != null
            ? (data?['createdAt'] is Timestamp
                ? (data?['createdAt'] as Timestamp).toDate()
                : DateTime.now())
            : DateTime.now();

        final String formattedDate = DateFormat('dd MMM yyyy').format(createdAt);

        final formatter = currencyFormatters[currency] ??
            NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);
        final usdFormatter = currencyFormatters['USD'] ??
            NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);

        final Widget categoryIcon = categoryIcons[category] ??
            Icon(
              Icons.category,
              size: 32.0,
              color: Colors.white,
            );

        final String prefix = category == 'Add Balance' ? '+' : '-';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF79A4C0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: categoryIcon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$country • $formattedDate',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$prefix${formatter.format(amount.abs())}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '≈ ${usdFormatter.format(convertedAmount.abs())}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  },
);
  }
}
