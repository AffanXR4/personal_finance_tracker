
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../models/transaction_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/transaction_tile.dart';

import '../transactions/transaction_page.dart';
import '../transactions/add_transaction_page.dart';
import '../profile/profile_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();

    _pages.addAll([
      _buildDashboard(),
      const TransactionPage(),
      const ProfilePage(),
    ]);
  }

  Widget _buildDashboard() {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<List<TransactionModel>>(
      stream: _firestoreService.getTransactions(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Terjadi kesalahan mengambil data'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final transactions = snapshot.data!;

        double income = 0;
        double expense = 0;

        for (var item in transactions) {
          if (item.type == 'income') {
            income += item.amount;
          } else {
            expense += item.amount;
          }
        }

        final balance = income - expense;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: FutureBuilder(
                      future: _authService.getUserProfile(user!.uid),
                      builder: (context, profileSnapshot) {
                        final name = profileSnapshot.data?.name ??
                            user.displayName ??
                            'Pengguna';

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selamat datang,',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkNavy,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.lightGreen,
                    child: const Icon(
                      Icons.person,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              BalanceCard(
                balance: balance,
                income: income,
                expense: expense,
              ),

              const SizedBox(height: 25),

              const Text(
                'Ringkasan Keuangan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkNavy,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: 'Pemasukan',
                      amount: income,
                      icon: Icons.arrow_downward,
                      color: AppColors.income,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(
                      title: 'Pengeluaran',
                      amount: expense,
                      icon: Icons.arrow_upward,
                      color: AppColors.expense,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      color: AppColors.primary,
                      size: 30,
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Text(
                        'Total Transaksi',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${transactions.length} Transaksi',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transaksi Terbaru',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkNavy,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _currentIndex = 1);
                    },
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              if (transactions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(25),
                    child: Text(
                      'Belum ada transaksi.\nYuk, catat keuangan pertamamu!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                )
              else
                ...transactions.take(5).map(
                  (transaction) => TransactionTile(
                    transaction: transaction,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _openAddTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddTransactionPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      'MyFinance',
      'Riwayat Transaksi',
      'Profil Saya',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_currentIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              onPressed: _openAddTransaction,
              icon: const Icon(
                Icons.add_circle_outline,
                color: AppColors.primary,
                size: 28,
              ),
            ),
        ],
      ),

      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _openAddTransaction,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textGrey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
