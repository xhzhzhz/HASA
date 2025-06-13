import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/patient.dart';
import '../models/withdrawal.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => instance;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialize database factory based on platform
    _initializeDatabase();

    _database = await _initDB();
    return _database!;
  }

  void _initializeDatabase() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Initialize FFI for desktop platforms
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    // For mobile platforms (Android/iOS), sqflite is used by default
  }

  Future<Database> _initDB() async {
    try {
      String path;

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // For desktop platforms
        final appDir = await getApplicationDocumentsDirectory();
        path = join(appDir.path, 'app_database.db');
      } else {
        // For mobile platforms
        final dbPath = await getDatabasesPath();
        path = join(dbPath, 'app_database.db');
      }

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      );
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _createDB(Database db, int version) async {
    try {
      // Create patients table
      await db.execute('''
        CREATE TABLE patients (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama TEXT NOT NULL,
          nik INTEGER NOT NULL UNIQUE,
          umur INTEGER NOT NULL,
          alamat TEXT NOT NULL,
          kontak INTEGER NOT NULL,
          tanggal TEXT NOT NULL,
          gejala TEXT NOT NULL,
          risiko TEXT NOT NULL,
          isPemeriksaanSelesai INTEGER DEFAULT 0,
          createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
          updatedAt TEXT DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // Create points table if needed
      await db.execute('''
        CREATE TABLE points (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          points INTEGER DEFAULT 0,
          description TEXT,
          createdAt TEXT DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      await db.execute('''
        CREATE TABLE admins(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE,
          passwordHash TEXT,
          bankAccount TEXT,
          photoPath TEXT
        )
      ''');
      await db.execute('''
    CREATE TABLE withdrawals (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      points INTEGER NOT NULL,
      bankName TEXT NOT NULL,
      accountNumber TEXT NOT NULL,
      accountHolderName TEXT NOT NULL,
      timestamp TEXT NOT NULL
    )
  ''');

      print('Database tables created successfully');
    } catch (e) {
      print('Error creating database tables: $e');
      rethrow;
    }
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here if needed
    if (oldVersion < newVersion) {
      // Add upgrade logic here
      print('Upgrading database from version $oldVersion to $newVersion');
    }
  }

  // Patient operations
  Future<int> insertPatient(Patient patient) async {
    try {
      final db = await database;
      final result = await db.insert(
        'patients',
        patient.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Patient inserted with ID: $result');
      return result;
    } catch (e) {
      print('Error inserting patient: $e');
      rethrow;
    }
  }

  Future<List<Patient>> getAllPatients() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'patients',
        orderBy: 'createdAt DESC',
      );

      return List.generate(maps.length, (i) {
        return Patient.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getting all patients: $e');
      return [];
    }
  }

  Future<Patient?> getPatientById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'patients',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Patient.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting patient by ID: $e');
      return null;
    }
  }

  Future<int> updatePatient(Patient patient) async {
    try {
      final db = await database;
      final result = await db.update(
        'patients',
        patient.toMap(),
        where: 'id = ?',
        whereArgs: [patient.id],
      );
      print('Patient updated: $result rows affected');
      return result;
    } catch (e) {
      print('Error updating patient: $e');
      rethrow;
    }
  }

  Future<int> deletePatient(int id) async {
    try {
      final db = await database;
      final result = await db.delete(
        'patients',
        where: 'id = ?',
        whereArgs: [id],
      );
      print('Patient deleted: $result rows affected');
      return result;
    } catch (e) {
      print('Error deleting patient: $e');
      rethrow;
    }
  }

  // Points operations
  Future<int> insertPoints(int points, String description) async {
    try {
      final db = await database;
      return await db.insert('points', {
        'points': points,
        'description': description,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error inserting points: $e');
      rethrow;
    }
  }

  Future<int> getTotalPoints() async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT SUM(points) as total FROM points',
      );
      return result.first['total'] as int? ?? 0;
    } catch (e) {
      print('Error getting total points: $e');
      return 0;
    }
  }

  Future<int> insertAdmin(Map<String, dynamic> admin) async {
    final db = await database;
    return await db.insert('admins', admin);
  }

  Future<Map<String, dynamic>?> getAdminByUsername(String username) async {
    final db = await database;
    final res = await db.query(
      'admins',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return res.isNotEmpty ? res.first : null;
  }

  Future<int> updateAdmin(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('admins', data, where: 'id = ?', whereArgs: [id]);
  }

  // Fungsi untuk menyimpan data penarikan baru
  Future<void> insertWithdrawal(Withdrawal withdrawal) async {
    final db = await database;
    await db.insert('withdrawals', withdrawal.toMap());
  }

  // Fungsi untuk mengambil semua riwayat penarikan
  Future<List<Withdrawal>> getAllWithdrawals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'withdrawals',
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return Withdrawal.fromMap(maps[i]);
    });
  }

  // Utility methods
  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<void> deleteDatabase() async {
    try {
      String path;
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final appDir = await getApplicationDocumentsDirectory();
        path = join(appDir.path, 'app_database.db');
      } else {
        final dbPath = await getDatabasesPath();
        path = join(dbPath, 'app_database.db');
      }

      await closeDatabase();
      await File(path).delete();
      print('Database deleted successfully');
    } catch (e) {
      print('Error deleting database: $e');
    }
  }
}
