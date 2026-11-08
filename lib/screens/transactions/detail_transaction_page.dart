
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../models/transaction_model.dart';
import '../../services/firestore_service.dart';
import 'add_transaction_page.dart';

class DetailTransactionPage extends StatelessWidget {
  final TransactionModel transaction;

  const DetailTransactionPage({
    super.key,
    required this.transaction,
  });

  Future<void> _deleteTransaction(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: const Text(
          'Apakah kamu yakin ingin menghapus transaksi ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirestoreService().deleteTransaction(transaction.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil dihapus'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';

    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(transaction.amount);

    final date = DateFormat(
      'dd MMMM yyyy',
      'id_ID',
    ).format(transaction.date);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddTransactionPage(
                    transaction: transaction,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: () => _deleteTransaction(context),
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.expense,
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 25),

            CircleAvatar(
              radius: 38,
              backgroundColor: isIncome
                  ? AppColors.lightGreen
                  : const Color(0xFFFFEEEE),
              child: Icon(
                isIncome
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                size: 35,
                color: isIncome
                    ? AppColors.income
                    : AppColors.expense,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              isIncome ? 'Pemasukan' : 'Pengeluaran',
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              '${isIncome ? '+' : '-'}$currency',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isIncome
                    ? AppColors.income
                    : AppColors.expense,
              ),
            ),

            const SizedBox(height: 35),

            _detailItem('Judul Transaksi', transaction.title),
            _detailItem('Jenis Transaksi', isIncome ? 'Pemasukan' : 'Pengeluaran'),
            _detailItem('Tanggal', date),
            _detailItem(
              'Catatan',
              transaction.note.isEmpty
                  ? 'Tidak ada catatan'
                  : transaction.note,
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.darkNavy,
            ),
          ),
        ],
      ),
    );
  }
}
