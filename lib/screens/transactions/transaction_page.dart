
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/transaction_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/transaction_tile.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return StreamBuilder<List<TransactionModel>>(
      stream: service.getTransactions(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Gagal mengambil transaksi'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final transactions = snapshot.data!;

        if (transactions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 70,
                  color: AppColors.textGrey,
                ),
                SizedBox(height: 15),
                Text(
                  'Belum ada transaksi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Transaksi yang kamu buat akan muncul di sini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textGrey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            return TransactionTile(
              transaction: transactions[index],
            );
          },
        );
      },
    );
  }
}
