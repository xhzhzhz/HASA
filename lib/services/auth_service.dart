import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'db_helper.dart';

class AuthService {
  final _db = DatabaseHelper.instance;

  Future<bool> register({
    required String username,
    required String password,
    required String email,
    required String photoPath,
  }) async {
    final existing = await _db.getAdminByUsername(username);
    if (existing != null) {
      // Username sudah dipakai
      return false;
    }
    final hash = sha256.convert(utf8.encode(password)).toString();
    try {
      await _db.insertAdmin({
        'username': username,
        'passwordHash': hash,
        'email': email,
        'photoPath': photoPath,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final adm = await _db.getAdminByUsername(username);
    if (adm == null) return false;
    final hash = sha256.convert(utf8.encode(password)).toString();
    return hash == adm['passwordHash'];
  }

  Future<Map<String, dynamic>?> getCurrentAdmin(String username) async {
    return await _db.getAdminByUsername(username);
  }

  Future<bool> updateProfile({
    required int id,
    String? username,
    String? email,
    String? photoPath,
  }) async {
    final data = <String, dynamic>{};
    if (username != null) data['username'] = username;
    if (email != null) data['email'] = email;
    if (photoPath != null) data['photoPath'] = photoPath;
    return await _db.updateAdmin(id, data) > 0;
  }

  Future<bool> sendPasswordReset({required String email}) async {
    // username == email
    final adm = await _db.getAdminByUsername(email);
    if (adm == null) {
      // User/email tidak ditemukan
      return false;
    }
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}
