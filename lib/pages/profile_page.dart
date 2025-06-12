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
  Map<String, dynamic>? _admin;
  late TextEditingController _bankController;
  String? _photoPath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _bankController = TextEditingController();
    _loadAdmin();
  }

  Future<void> _loadAdmin() async {
    final adm = await AuthService().getCurrentAdmin(widget.username);
    if (adm != null) {
      setState(() {
        _admin = adm;
        _bankController.text = adm['bankAccount'] ?? '';
        _photoPath = adm['photoPath'];
      });
    }
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _photoPath = picked.path;
      });
    }
  }

  @override
  void dispose() {
    _bankController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_admin == null) {
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
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF2AA89B),
                      backgroundImage:
                          _photoPath != null
                              ? FileImage(File(_photoPath!)) as ImageProvider
                              : null,
                      child:
                          _photoPath == null
                              ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              )
                              : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _admin!['username'] ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_admin!['bankAccount'] ?? ''),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showEditDialog(context),
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          'Edit Profil',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2AA89B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.notifications,
                    title: 'Pengaturan Notifikasi',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    context,
                    icon: Icons.help,
                    title: 'Bantuan',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    context,
                    icon: Icons.info,
                    title: 'Tentang Aplikasi',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.onLogout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('HASA Beta', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Profil'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: _admin!['username'],
                  decoration: const InputDecoration(labelText: 'Username'),
                  onChanged: (v) => _admin!['username'] = v,
                ),
                TextFormField(
                  controller: _bankController,
                  decoration: const InputDecoration(labelText: 'No. Rekening'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _pickPhoto,
                      child: const Text('Ganti Foto'),
                    ),
                    const SizedBox(width: 10),
                    if (_photoPath != null)
                      Image.file(File(_photoPath!), width: 50, height: 50),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final success = await AuthService().updateProfile(
                    id: _admin!['id'],
                    username: _admin!['username'],
                    bankAccount: _bankController.text,
                    photoPath: _photoPath,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Profil berhasil diperbarui'
                            : 'Gagal memperbarui profil',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                  if (success) setState(() {});
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }
}
