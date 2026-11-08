
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../models/transaction_model.dart';
import '../../services/firestore_service.dart';

class AddTransactionPage extends StatefulWidget {
  final TransactionModel? transaction;

  const AddTransactionPage({
    super.key,
    this.transaction,
  });

  @override
  State<AddTransactionPage> createState() =>
      _AddTransactionPageState();
}

class _AddTransactionPageState
    extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  final FirestoreService _service = FirestoreService();

  String _type = 'expense';
  DateTime _date = DateTime.now();
  bool _isLoading = false;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();

    final transaction = widget.transaction;

    if (transaction != null) {
      _titleController.text = transaction.title;
      _amountController.text = transaction.amount.toString();
      _noteController.text = transaction.note;
      _type = transaction.type;
      _date = transaction.date;
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final transaction = TransactionModel(
        id: widget.transaction?.id ?? '',
        title: _titleController.text.trim(),
        amount: double.parse(
          _amountController.text.replaceAll(',', '.'),
        ),
        type: _type,
        note: _noteController.text.trim(),
        date: _date,
      );

      if (_isEditing) {
        await _service.updateTransaction(
          widget.transaction!.id,
          transaction,
        );
      } else {
        await _service.addTransaction(transaction);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Transaksi berhasil diperbarui'
                : 'Transaksi berhasil ditambahkan',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan transaksi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      setState(() => _date = selected);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Transaksi' : 'Tambah Transaksi',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Judul Transaksi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Membeli makanan',
                  prefixIcon: Icon(Icons.edit_note),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul transaksi wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Nominal',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: 'Masukkan nominal',
                  prefixText: 'Rp ',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  final amount = double.tryParse(
                    (value ?? '').replaceAll(',', '.'),
                  );

                  if (amount == null || amount <= 0) {
                    return 'Masukkan nominal yang valid';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Jenis Transaksi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'income',
                    child: Text('Pemasukan'),
                  ),
                  DropdownMenuItem(
                    value: 'expense',
                    child: Text('Pengeluaran'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _type = value);
                  }
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Tanggal Transaksi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('dd MMMM yyyy', 'id_ID')
                            .format(_date),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Catatan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Tambahkan catatan (opsional)',
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          _isEditing
                              ? 'Simpan Perubahan'
                              : 'Simpan Transaksi',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
