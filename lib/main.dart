// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:exercise/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:exercise/pages/login_page.dart';
import 'package:exercise/pages/home_page.dart';
import 'package:exercise/util/auth_page.dart';
import 'package:exercise/util/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Exercise App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xff1565c0),
      ),
      home: const SplashToAuthWrapper(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}

class SplashToAuthWrapper extends StatefulWidget {
  const SplashToAuthWrapper({super.key});

  @override
  _SplashToAuthWrapperState createState() => _SplashToAuthWrapperState();
}

class _SplashToAuthWrapperState extends State<SplashToAuthWrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _navigateToAuthPage();
  }

  Future<void> _navigateToAuthPage() async {
    await Future.delayed(const Duration(seconds: 3)); // Adjust this duration as needed
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _showSplash ? const SplashScreen() : const AuthPage();
  }
}
