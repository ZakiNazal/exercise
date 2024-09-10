// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exercise/pages/home_page.dart';
import 'package:exercise/pages/login_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>( // Updated to use User? instead of User?>
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return const HomePage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
