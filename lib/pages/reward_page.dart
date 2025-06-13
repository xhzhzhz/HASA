import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/withdrawal.dart';
import '../services/notification_service.dart';
import '../services/point_service.dart';

class RewardPage extends StatefulWidget {
  const RewardPage({Key? key}) : super(key: key);

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  final pointService = PointService();
  final _formKey = GlobalKey<FormState>();
  final _rekeningController = TextEditingController();
  final _bankController = TextEditingController();
  final _namaController = TextEditingController();

  @override
  void dispose() {
    _rekeningController.dispose();
    _bankController.dispose();
    _namaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reward')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPointsCard(),
            const SizedBox(height: 24),
            const Text(
              'Riwayat Penarikan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildWithdrawalHistory(),
            const SizedBox(height: 24),
            const Text(
              'Cara Mendapatkan Poin',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildAchievementInfo(
              icon: Icons.add_chart,
              title: 'Mendaftarkan pasien',
              subtitle: '100 poin per pasien',
            ),
            _buildAchievementInfo(
              icon: Icons.check_circle,
              title: 'Pemeriksaan pasien',
              subtitle: '100 poin per pemeriksaan',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Poin Terkumpul',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<int>(
              valueListenable: pointService.points,
              builder: (context, currentPoints, child) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 32),
                        const SizedBox(width: 8),
                        Text(
                          '$currentPoints',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2AA89B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nilai Penukaran: Rp ${(currentPoints / 10).toStringAsFixed(0)}0000',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showWithdrawalDialog,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Ajukan Penarikan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalHistory() {
    return ValueListenableBuilder<List<Withdrawal>>(
      valueListenable: pointService.withdrawalHistory,
      builder: (context, historyList, child) {
        if (historyList.isEmpty) {
          return const Card(
            child: ListTile(title: Text('Belum ada riwayat penarikan.')),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: historyList.length,
          itemBuilder: (context, index) {
            final item = historyList[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0x152AA89B),
                  child: Icon(Icons.arrow_upward, color: Color(0xFF2AA89B)),
                ),
                title: Text(
                  'Penarikan ${item.amountInRupiah}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${item.bankName} - ${item.accountNumber}\n${DateFormat('d MMMM yyyy, HH:mm').format(item.timestamp)}',
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAchievementInfo({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0x152AA89B),
          child: Icon(icon, color: const Color(0xFF2AA89B)),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }

  void _showWithdrawalDialog() {
    if (pointService.points.value < 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Poin tidak mencukupi untuk penarikan (minimal 500 poin).',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _rekeningController.clear();
    _bankController.clear();
    _namaController.clear();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Ajukan Penarikan'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Anda akan menarik ${pointService.points.value} poin.'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _rekeningController,
                    decoration: const InputDecoration(
                      labelText: 'Nomor Rekening',
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                    keyboardType: TextInputType.number,
                    validator:
                        (v) =>
                            v == null || v.isEmpty
                                ? 'Nomor rekening wajib diisi'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bankController,
                    decoration: const InputDecoration(
                      labelText: 'Bank',
                      prefixIcon: Icon(Icons.business),
                    ),
                    validator:
                        (v) =>
                            v == null || v.isEmpty
                                ? 'Nama bank wajib diisi'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Pemilik Rekening',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator:
                        (v) =>
                            v == null || v.isEmpty
                                ? 'Nama pemilik wajib diisi'
                                : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final newWithdrawal = Withdrawal(
                      points: pointService.points.value,
                      bankName: _bankController.text,
                      accountNumber: _rekeningController.text,
                      accountHolderName: _namaController.text,
                      timestamp: DateTime.now(),
                    );

                    await pointService.submitWithdrawal(newWithdrawal);

                    if (mounted) Navigator.pop(context);

                    NotificationService().showNotification(
                      DateTime.now().millisecondsSinceEpoch.remainder(100000),
                      'Penarikan Berhasil Diajukan',
                      'Permintaan penarikan ${newWithdrawal.amountInRupiah} sedang diproses.',
                    );
                  }
                },
                child: const Text('Ajukan'),
              ),
            ],
          ),
    );
  }
}
