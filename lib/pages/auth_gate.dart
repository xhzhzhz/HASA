import 'package:flutter/material.dart';
import 'sign_in_page.dart';
import 'dashboard_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _signedIn = false;

  @override
  Widget build(BuildContext context) {
    return _signedIn
        ? DashboardPage(onLogout: _logout)
        : SignInPage(onSignIn: _login); // Tampilkan halaman login
  }

  void _login() {
    setState(() {
      _signedIn = true; // Simulasikan login
    });
  }

  void _logout() {
    setState(() {
      _signedIn = false; // Simulasikan logout
    });
  }
}
