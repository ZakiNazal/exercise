// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, use_super_parameters, sized_box_for_whitespace, avoid_print

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _getAppVersion();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
      _selectedLanguage = prefs.getString('selected_language') ?? 'English';
    });
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
      await prefs.setBool('dark_mode_enabled', _darkModeEnabled);
      await prefs.setString('selected_language', _selectedLanguage);
    } catch (e) {
      print('Error saving settings: $e');
      // Consider showing a user-friendly error message
    }
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  void _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseAuth.instance.signOut();
        Navigator.of(context).pushReplacementNamed('/login');
      } catch (e) {
        print('Error signing out: $e');
        // Show error message to user
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1565c0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Rubik',
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Account'),
          _buildListTile(
            'Edit Profile',
            Icons.person,
            onTap: () {
              // Navigate to edit profile page
            },
          ),
          _buildListTile(
            'Change Password',
            Icons.lock,
            onTap: () {
              // Navigate to change password page
            },
          ),
          _buildSectionHeader('Preferences'),
          SwitchListTile(
            title: const Text('Enable Notifications', style: TextStyle(color: Colors.white, fontFamily: 'Rubik')),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              _saveSettings();
            },
            activeColor: Colors.blue[400],
            secondary: const Icon(Icons.notifications, color: Colors.white),
          ),
          SwitchListTile(
            title: const Text('Dark Mode', style: TextStyle(color: Colors.white, fontFamily: 'Rubik')),
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
              });
              _saveSettings();
            },
            activeColor: Colors.blue[400],
            secondary: const Icon(Icons.brightness_4, color: Colors.white),
          ),
          _buildListTile(
            'Language',
            Icons.language,
            trailing: Container(
              width: 120, // Adjust this value as needed
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedLanguage = newValue;
                          });
                          _saveSettings();
                        }
                      },
                      items: <String>['English', 'Spanish', 'French', 'German']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      dropdownColor: Colors.white,
                      icon: const SizedBox.shrink(), // Hide the default arrow
                      style: const TextStyle(color: Colors.black, fontFamily: 'Rubik'),
                      selectedItemBuilder: (BuildContext context) {
                        return <String>['English', 'Spanish', 'French', 'German']
                            .map<Widget>((String value) {
                          return Container(
                            alignment: Alignment.centerRight,
                            child: Text(
                              value,
                              style: const TextStyle(color: Colors.white, fontFamily: 'Rubik'),
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  const SizedBox(width: 4), // Add some space between text and arrow
                  const Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
          _buildSectionHeader('Support'),
          _buildListTile(
            'Help Center',
            Icons.help,
            onTap: () {
              // Navigate to help center page
            },
          ),
          _buildListTile(
            'Privacy Policy',
            Icons.privacy_tip,
            onTap: () {
              // Navigate to privacy policy page
            },
          ),
          _buildListTile(
            'Terms of Service',
            Icons.description,
            onTap: () {
              // Navigate to terms of service page
            },
          ),
          _buildSectionHeader('About'),
          _buildListTile(
            'App Version',
            Icons.info,
            trailing: Text(_appVersion, style: const TextStyle(color: Colors.white, fontFamily: 'Rubik')),
          ),
          _buildListTile(
            'Sign Out',
            Icons.exit_to_app,
            onTap: _signOut,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Rubik'
        ),
      ),
    );
  }

  Widget _buildListTile(String title, IconData icon, {Widget? trailing, VoidCallback? onTap}) {
    if (title == 'Language') {
      return ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white, fontFamily: 'Rubik')),
        leading: Icon(icon, color: Colors.white),
        trailing: trailing,
        onTap: onTap,
      );
    }
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white, fontFamily: 'Rubik')),
      leading: Icon(icon, color: Colors.white),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
