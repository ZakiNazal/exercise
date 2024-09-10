// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  File? _image;
  String? _currentPhotoUrl;
  bool _isLoading = false;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      try {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
        if (docSnapshot.exists) {
          final userData = docSnapshot.data();
          if (userData != null) {
            setState(() {
              _nameController.text = userData['name'] as String? ?? '';
              _emailController.text = user!.email ?? '';
              _bioController.text = userData['bio'] as String? ?? '';
              _currentPhotoUrl = userData['photoUrl'] as String?;
            });
          }
        }
      } catch (e) {
        print('Error loading user data: $e');
        // Optionally show an error message to the user
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Changes'),
          content: const Text('Are you sure you want to save these changes?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Email cannot be empty')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? photoUrl = _currentPhotoUrl;
      if (_image != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${user!.uid}.jpg');
        await ref.putFile(_image!);
        photoUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'name': _nameController.text,
        'bio': _bioController.text,
        if (photoUrl != null) 'photoUrl': photoUrl,
      });

      if (_emailController.text != user!.email) {
        await user!.updateEmail(_emailController.text);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already in use by another account.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'requires-recent-login':
          errorMessage = 'This operation is sensitive and requires recent authentication. Log in again before retrying.';
          break;
        default:
          errorMessage = 'An error occurred while updating the profile.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1565c0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Rubik',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(17.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : (_currentPhotoUrl != null
                                ? NetworkImage(_currentPhotoUrl!)
                                : const AssetImage('assets/default_avatar.png')) as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Color(0xff1565c0), size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildTextField(_nameController, 'Name', Icons.person),
                const SizedBox(height: 20),
                _buildTextField(_emailController, 'Email', Icons.email),
                const SizedBox(height: 20),
                _buildTextField(_bioController, 'Bio', Icons.description, maxLines: 3),
                const SizedBox(height: 45),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xff1565c0),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Rubik',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white, fontFamily: 'Rubik',),
        filled: true,
        fillColor: Colors.white24,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white, fontFamily: 'Rubik'),
    );
  }
}
