import 'package:flutter/material.dart';
import '../services/point_service.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pointService = PointService();

    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body:
          pointService.notifications.isEmpty
              ? Center(
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
              )
              : ListView.builder(
                itemCount: pointService.notifications.length,
                itemBuilder: (context, index) {
                  final notification = pointService.notifications[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0x152AA89B),
                        child: Icon(
                          Icons.check_circle,
                          color: Color(0xFF2AA89B),
                        ),
                      ),
                      title: Text(notification),
                      subtitle: Text(
                        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                },
              ),
    );
  }
}
