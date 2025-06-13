import 'package:flutter/foundation.dart';
import 'db_helper.dart';
import '../models/withdrawal.dart'; // Import model dari file baru

class PointService {
  // --- BAGIAN SINGLETON ---
  // 1. Buat constructor privat untuk mencegah instance baru dibuat dari luar.
  PointService._internal();

  // 2. Buat satu instance statis di dalam class itu sendiri.
  static final PointService _instance = PointService._internal();

  // 3. Buat factory constructor yang akan selalu mengembalikan instance yang sama.
  factory PointService() {
    return _instance;
  }
  // --- AKHIR BAGIAN SINGLETON ---

  /// ValueNotifier untuk poin. UI akan "mendengarkan" perubahan pada `.value`.
  final ValueNotifier<int> points = ValueNotifier(0);

  /// ValueNotifier untuk daftar notifikasi.
  final ValueNotifier<List<String>> notifications = ValueNotifier([]);
  final ValueNotifier<List<Withdrawal>> withdrawalHistory = ValueNotifier([]);

  // Muat data dari DB saat aplikasi dimulai
  Future<void> loadDataFromDb() async {
    withdrawalHistory.value = await DatabaseHelper().getAllWithdrawals();
  }

  /// Method untuk menambah poin.

  /// Ini juga akan secara otomatis memicu pembaruan pada UI yang mendengarkannya.
  void addPoints(int amount, String reason) {
    // Tambahkan poin ke nilai saat ini.
    points.value += amount;

    // Buat list baru dari notifikasi yang ada untuk memicu pembaruan.
    final currentNotifications = List<String>.from(notifications.value);

    // Tambahkan notifikasi baru di posisi paling atas (index 0).
    currentNotifications.insert(0, '$reason (+$amount poin)');

    // Perbarui ValueNotifier dengan list yang baru.
    notifications.value = currentNotifications;
  }

  // METHOD DIPERBARUI: Untuk memproses penarikan
  Future<void> submitWithdrawal(Withdrawal withdrawal) async {
    // 1. Simpan ke Database
    await DatabaseHelper().insertWithdrawal(withdrawal);

    // 2. Muat ulang riwayat dari database untuk memperbarui UI
    await loadDataFromDb();

    // 3. Tambahkan notifikasi umum & reset poin
    addPoints(0, 'Penarikan ${withdrawal.amountInRupiah} diajukan');
    points.value = 0;
  }

  void removeNotification(int index) {
    // Buat salinan dari list saat ini
    final currentNotifications = List<String>.from(notifications.value);

    // Hapus item pada index yang ditentukan
    currentNotifications.removeAt(index);

    // Perbarui ValueNotifier dengan list yang baru untuk memicu update UI
    notifications.value = currentNotifications;
  }
}
