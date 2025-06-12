import 'package:flutter/material.dart';
import '../services/point_service.dart';

class RewardPage extends StatelessWidget {
  const RewardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pointService = PointService();

    return Scaffold(
      appBar: AppBar(title: const Text('Reward')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 32),
                        const SizedBox(width: 8),
                        Text(
                          '${pointService.points}',
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
                      'Nilai Penukaran: Rp ${(pointService.points / 10).toStringAsFixed(0)}00',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Ajukan Penarikan'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Apakah Anda yakin ingin mengajukan penarikan poin?',
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        decoration: const InputDecoration(
                                          labelText: 'Nomor Rekening',
                                          prefixIcon: Icon(
                                            Icons.account_balance,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        decoration: const InputDecoration(
                                          labelText: 'Bank',
                                          prefixIcon: Icon(Icons.business),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        decoration: const InputDecoration(
                                          labelText: 'Nama Pemilik Rekening',
                                          prefixIcon: Icon(Icons.person),
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Batal'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Permintaan penarikan berhasil diajukan',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      },
                                      child: const Text('Ajukan'),
                                    ),
                                  ],
                                ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Ajukan Penarikan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Riwayat Pencapaian',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: const ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(0x152AA89B),
                  child: Icon(Icons.add_chart, color: Color(0xFF2AA89B)),
                ),
                title: Text('Mendaftarkan pasien'),
                subtitle: Text('10 poin per pasien'),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: const ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(0x152AA89B),
                  child: Icon(Icons.check_circle, color: Color(0xFF2AA89B)),
                ),
                title: Text('Pemeriksaan pasien'),
                subtitle: Text('10 poin per pemeriksaan'),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: const ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(0x152AA89B),
                  child: Icon(Icons.local_hospital, color: Color(0xFF2AA89B)),
                ),
                title: Text('Rujukan ke Puskesmas'),
                subtitle: Text('20 poin per rujukan'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Informasi Reward',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cara Penukaran Poin',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Kumpulkan minimal 500 poin\n'
                      '2. Ajukan penarikan dengan menekan tombol di atas\n'
                      '3. Isi data rekening bank Anda\n'
                      '4. Penarikan akan diproses dalam 3-5 hari kerja\n'
                      '5. Dana akan ditransfer ke rekening yang Anda daftarkan',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
