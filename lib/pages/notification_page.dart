import 'package:flutter/material.dart';
import '../services/point_service.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pointService = PointService();

    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: ValueListenableBuilder<List<String>>(
        valueListenable: pointService.notifications,
        builder: (context, notificationList, child) {
          if (notificationList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada notifikasi',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notificationList.length,
            itemBuilder: (context, index) {
              final notification = notificationList[index];

              // Bungkus Card dengan widget Dismissible
              return Dismissible(
                // Key wajib ada dan harus unik untuk setiap item
                key: ValueKey(notification + index.toString()),

                // Arah geser yang diizinkan (dari kanan ke kiri)
                direction: DismissDirection.endToStart,

                // Callback yang dijalankan setelah item berhasil digeser hilang
                onDismissed: (direction) {
                  // Panggil method untuk menghapus notifikasi dari service
                  pointService.removeNotification(index);

                  // Tampilkan SnackBar sebagai konfirmasi
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Notifikasi dihapus'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },

                // Widget yang muncul di belakang item saat digeser
                background: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),

                // Ini adalah widget asli Anda (Card)
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0x152AA89B),
                      child: Icon(Icons.star, color: Color(0xFF2AA89B)),
                    ),
                    title: Text(notification),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
