// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, use_super_parameters, deprecated_member_use

import 'package:exercise/pages/edit_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> userData = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (user != null) {
        final docRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
        final docSnapshot = await docRef.get();

        if (!mounted) return;

        if (docSnapshot.exists) {
          setState(() {
            userData = docSnapshot.data()!;
            _isLoading = false;
          });
        } else {
          // Create a new user document with default values
          final defaultUserData = {
            'name': user!.displayName ?? 'New User',
            'email': user!.email,
            'photoUrl': user!.photoURL,
            'exercisesCompleted': 0,
            'points': 0,
            'streak': 0,
          };

          await docRef.set(defaultUserData);

          if (!mounted) return;
          setState(() {
            userData = defaultUserData;
            _isLoading = false;
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          _error = "User not authenticated";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "Error fetching user data: $e";
        _isLoading = false;
      });
    }
  }

  void signUserOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1565c0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.white, fontFamily: 'Rubik')))
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: userData['photoUrl'] != null
                              ? NetworkImage(userData['photoUrl'])
                              : null,
                          child: userData['photoUrl'] == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          userData['name'] ?? 'User',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Rubik'
                          ),
                        ),
                        Text(
                          userData['email'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontFamily: 'Rubik'
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildStatistics(),
                        const SizedBox(height: 30),
                        ProfileButton(
                          icon: Icons.edit_rounded,
                          text: 'Edit Profile',
                          onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage()));
                            fetchUserData();
                          },
                        ),
                        ProfileButton(
                          icon: Icons.settings_rounded,
                          text: 'Settings',
                          onTap: () {
                            Navigator.pushNamed(context, '/settings');
                          },
                        ),
                        
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Exercises', userData['exercisesCompleted'] ?? 0),
          _buildStatItem('Points', userData['points'] ?? 0),
          _buildStatItem('Streak', userData['streak'] ?? 0),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Rubik'
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
            fontFamily: 'Rubik'
          ),
        ),
      ],
    );
  }
}

class ProfileButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const ProfileButton({
    required this.icon,
    required this.text,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xff1565c0),
            ),
            const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                fontFamily: 'Rubik',
                fontWeight: FontWeight.bold,
                color: Color(0xff1565c0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
