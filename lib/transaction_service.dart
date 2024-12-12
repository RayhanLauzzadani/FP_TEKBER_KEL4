import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionService {
  final CollectionReference _transactionsRef =
      FirebaseFirestore.instance.collection('transactions');

  // Stream untuk mendapatkan semua transaksi, diurutkan berdasarkan tanggal
  Stream<QuerySnapshot> getTransactions({int? limit}) {
    Query query = _transactionsRef.orderBy('date', descending: true);
    if (limit != null) {
      query = query.limit(limit);
    }
    return query.snapshots();
  }

  // Hapus transaksi berdasarkan ID
  Future<void> deleteTransaction(String transactionId) async {
    await _transactionsRef.doc(transactionId).delete();
  }
}
