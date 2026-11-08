
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_colors.dart';
import '../models/transaction_model.dart';
import '../screens/transactions/detail_transaction_page.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionTile({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';

    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(transaction.amount);

    final date = DateFormat(
      'dd MMM yyyy',
      'id_ID',
    ).format(transaction.date);

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 5,
        ),
        leading: CircleAvatar(
          backgroundColor: isIncome
              ? AppColors.lightGreen
              : const Color(0xFFFFEEEE),
          child: Icon(
            isIncome
                ? Icons.arrow_downward
                : Icons.arrow_upward,
            color: isIncome
                ? AppColors.income
                : AppColors.expense,
          ),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkNavy,
          ),
        ),
        subtitle: Text(date),
        trailing: Text(
          '${isIncome ? '+' : '-'}$currency',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isIncome
                ? AppColors.income
                : AppColors.expense,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailTransactionPage(
                transaction: transaction,
              ),
            ),
          );
        },
      ),
    );
  }
}
