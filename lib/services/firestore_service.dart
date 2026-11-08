
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/transaction_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _transactions {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('transactions');
  }

  // Mengambil transaksi secara real-time
  Stream<List<TransactionModel>> getTransactions() {
    return _transactions
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TransactionModel.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }

  // Menambahkan transaksi
  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactions.add(transaction.toMap());
  }

  // Mengubah transaksi
  Future<void> updateTransaction(
    String id,
    TransactionModel transaction,
  ) async {
    await _transactions.doc(id).update(transaction.toMap());
  }

  // Menghapus transaksi
  Future<void> deleteTransaction(String id) async {
    await _transactions.doc(id).delete();
  }
}
