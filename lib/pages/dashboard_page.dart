import 'package:flutter/material.dart';
import 'home_page.dart';
import 'patient_page.dart';
import 'notification_page.dart';
import 'reward_page.dart';
import 'profile_page.dart';
import '../services/point_service.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback onLogout;
  final String username;

  const DashboardPage({
    Key? key,
    required this.onLogout,
    required this.username,
  }) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  late List<Widget> _pages;
  final pointService = PointService();

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const PatientPage(),
      const NotificationPage(),
      const RewardPage(),
      ProfilePage(onLogout: widget.onLogout, username: widget.username),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Pasien',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Reward',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
