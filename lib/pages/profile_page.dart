import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback onLogout;
  final String username;

  const ProfilePage({Key? key, required this.onLogout, required this.username})
    : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // State untuk membedakan antara 'sedang memuat' dan 'gagal memuat'
  bool _isLoading = true;
  Map<String, dynamic>? _admin;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadAdmin();
  }

  /// Mengambil data admin dari database dan memperbarui state
  Future<void> _loadAdmin() async {
    // Jika tidak sedang loading, set ke true untuk menampilkan indicator saat refresh
    if (mounted && !_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    final adm = await AuthService().getCurrentAdmin(widget.username);

    if (mounted) {
      setState(() {
        _admin = adm;
        _isLoading = false; // Matikan loading setelah proses selesai
      });
    }
  }

  // Method build utama, sekarang lebih rapi
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil Akun')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Akun')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileCard(),
            const SizedBox(height: 24),
            _buildMenuItems(),
            const SizedBox(height: 24),
            _buildLogoutButton(),
            const SizedBox(height: 24),
            const Text('HASA Beta v1.0', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  /// Method untuk membangun kartu profil utama
  Widget _buildProfileCard() {
    final photoPath = _admin!['photoPath'];
    final imageExists =
        photoPath != null &&
        photoPath.isNotEmpty &&
        File(photoPath).existsSync();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF2AA89B),
              backgroundImage: imageExists ? FileImage(File(photoPath!)) : null,
              child:
                  !imageExists
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
            ),
            const SizedBox(height: 16),
            Text(
              _admin!['username'] ?? 'Nama Pengguna',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_admin!['bankAccount'] ?? 'email belum diatur'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showEditDialog,
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profil'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Method untuk membangun menu-menu di bawah profil
  Widget _buildMenuItems() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.notifications,
            title: 'Pengaturan Notifikasi',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildMenuItem(icon: Icons.help, title: 'Bantuan', onTap: () {}),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildMenuItem(
            icon: Icons.info,
            title: 'Tentang Aplikasi',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  /// Method untuk membangun tombol logout
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: widget.onLogout,
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  /// Method untuk membangun satu item menu
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    // ... (kode ini tidak berubah dan sudah benar)
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF2AA89B)),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// Method untuk menampilkan dialog edit profil
  void _showEditDialog() {
    final usernameCtrl = TextEditingController(text: _admin!['username']);
    final bankCtrl = TextEditingController(text: _admin!['bankAccount']);
    String? tempPhotoPath = _admin!['photoPath'];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Profil'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: usernameCtrl,
                      decoration: const InputDecoration(labelText: 'Username'),
                    ),
                    TextFormField(
                      controller: bankCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final picked = await _picker.pickImage(
                              source: ImageSource.camera,
                              maxWidth: 600,
                              imageQuality: 70,
                            );
                            if (picked != null) {
                              setDialogState(() => tempPhotoPath = picked.path);
                            }
                          },
                          child: const Text('Ganti Foto'),
                        ),
                        const SizedBox(width: 10),
                        if (tempPhotoPath != null &&
                            File(tempPhotoPath!).existsSync())
                          Image.file(
                            File(tempPhotoPath!),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        else
                          const Icon(Icons.photo, size: 50, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newUsername = usernameCtrl.text;
                    final isUsernameChanged =
                        newUsername != _admin!['username'];

                    final success = await AuthService().updateProfile(
                      id: _admin!['id'],
                      username: newUsername,
                      bankAccount: bankCtrl.text,
                      photoPath: tempPhotoPath,
                    );

                    if (!mounted) return;
                    Navigator.pop(dialogContext);

                    if (success) {
                      if (isUsernameChanged) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Username diubah, silakan login kembali.',
                            ),
                            backgroundColor: Colors.blue,
                          ),
                        );
                        widget.onLogout();
                      } else {
                        await _loadAdmin();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profil berhasil diperbarui'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gagal memperbarui profil'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
