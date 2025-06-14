import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  String? _photoPath;
  bool _isLoading = false;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera);
    if (file != null) setState(() => _photoPath = file.path);
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final registered = await AuthService().register(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      email: _emailController.text,
      photoPath: _photoPath ?? '',
    );

    setState(() => _isLoading = false);

    if (registered) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil. Silakan login.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username mungkin sudah terpakai.')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrasi')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Username tidak boleh kosong';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  } else if (value.length < 8) {
                    return 'Password minimal 8 karakter';
                  } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
                    return 'Password harus mengandung huruf besar';
                  } else if (!RegExp(r'[a-z]').hasMatch(value)) {
                    return 'Password harus mengandung huruf kecil';
                  } else if (!RegExp(r'[0-9]').hasMatch(value)) {
                    return 'Password harus mengandung angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  // Regex sederhana untuk validasi format email
                  const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                  final regex = RegExp(pattern);
                  if (!regex.hasMatch(value.trim())) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickPhoto,
                    child: const Text('Ambil Foto Profil'),
                  ),
                  const SizedBox(width: 10),
                  if (_photoPath != null)
                    Image.file(File(_photoPath!), width: 50, height: 50),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('DAFTAR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
