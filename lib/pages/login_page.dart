// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages, avoid_print, use_build_context_synchronously

import 'package:exercise/util/square_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  void signUserIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    if (emailController.text.trim().isEmpty || passwordController.text.isEmpty) {
      showErrorMessage('Please enter both email and password');
      return;
    }

    // Show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(), // Add .trim() here
        password: passwordController.text,
      );
      // Pop the loading circle
      Navigator.pop(context);
      // Navigate to home page
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      // Pop the loading circle
      Navigator.pop(context);
      // Show error message
      showErrorMessage(e.message ?? 'An error occurred');
    } catch (e) {
      // Handle other potential errors
      Navigator.pop(context);
      showErrorMessage('An unexpected error occurred');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1565c0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Icon(
                  Icons.lock,
                  size: 50,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Rubik',
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                const Text('Welcome Back You\'ve Been Missed!',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Rubik',
                      color: Colors.white60,
                    )),
                const SizedBox(height: 30),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Rubik',
                    ),
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Rubik',
                    ),
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 27),
                ElevatedButton(
                  onPressed: _isLoading ? null : signUserIn,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xff1565c0),
                    backgroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                    ? const CircularProgressIndicator(color: Color(0xff1565c0))
                    : const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Rubik',
                        ),
                      ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterPage()),
                    );
                  },
                  child: const Text.rich(
                    TextSpan(
                      text: 'Don\'t Have An Account? ',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Rubik',
                        color: Colors.white,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Register',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                              decorationThickness: 1.5,
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Rubik',
                              color: Colors.white70),
                        ),
                      ),
                      const Expanded(
                          child: Divider(
                        thickness: 0.5,
                        color: Colors.white70,
                      ))
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // google button
                    SquareTile(imagePath: 'asset/images/google.png'),
          
                    SizedBox(width: 20),
                    // apple button
                    SquareTile(imagePath: 'asset/images/apple.png')
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Add dispose method to clean up controllers
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
