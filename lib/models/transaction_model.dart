
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type;
  final String note;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.note,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'type': type,
      'note': note,
      'date': Timestamp.fromDate(date),
    };
  }

  factory TransactionModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return TransactionModel(
      id: id,
      title: map['title'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] ?? 'expense',
      note: map['note'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
    );
  }
}
