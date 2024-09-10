// ignore_for_file: use_key_in_widget_constructors

import 'package:exercise/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:exercise/pages/login_page.dart';
import 'package:exercise/pages/home_page.dart';
import 'package:exercise/util/auth_page.dart';

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
      home: const AuthPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
