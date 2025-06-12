import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'pages/auth_gate.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'services/db_helper.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database factory for desktop platforms only
  // Skip platform check for web
  if (!kIsWeb) {
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
    } catch (e) {
      print('Platform detection error: $e');
    }
  }

  // Initialize database
  try {
    final dbHelper = DatabaseHelper();
    await dbHelper
        .database; // This will create the database if it doesn't exist
    print('Database initialized successfully');
  } catch (e) {
    print('Error initializing database: $e');
  }

  runApp(const HASAApp()); // Changed from MyApp() to HASAApp()
}

class HASAApp extends StatelessWidget {
  const HASAApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HASA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2AA89B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2AA89B),
          primary: const Color(0xFF2AA89B),
          secondary: const Color(0xFF26857A),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2AA89B),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF2AA89B),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: const AuthGate(),
    );
  }
}
