// ignore_for_file: use_super_parameters, library_private_types_in_public_api, use_key_in_widget_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercise/pages/explore_page.dart';
import 'package:exercise/pages/profile_page.dart';
import 'package:exercise/util/exercise_tile.dart';
import 'package:exercise/util/emoticon_face.dart';
import 'package:exercise/util/search_bar.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:intl/intl.dart'; // Add this import

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePageContent(),
    const ExplorePage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1565c0),
      body: SafeArea(
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: const Color(0xff1565c0),
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        height: 65, // Slightly increased to accommodate text
        index: _currentIndex,
        items: const <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_rounded, size: 35, color: Color(0xff1565c0)),
              Text('Home', style: TextStyle(color: Color(0xff1565c0), fontSize: 10,fontFamily: 'Rubik')),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.explore_rounded, size: 35, color: Color(0xff1565c0)),
              Text('Explore', style: TextStyle(color: Color(0xff1565c0), fontSize: 10, fontFamily: 'Rubik')),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_rounded, size: 35, color: Color(0xff1565c0)),
              Text('Profile', style: TextStyle(color: Color(0xff1565c0), fontSize: 10, fontFamily: 'Rubik')),
            ],
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({Key? key}) : super(key: key);

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  String _searchQuery = '';
  String _userName = 'User';
  String _currentDate = '';
  final PanelController _panelController = PanelController();
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _updateCurrentDate();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _loadUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists && _mounted) {
          setState(() {
            _userName = (userDoc.data() as Map<String, dynamic>)['name'] ?? 'User';
          });
        }
      } catch (e) {
        print('Error loading user name: $e');
      }
    }
  }

  void _updateCurrentDate() {
    if (_mounted) {
      setState(() {
        _currentDate = DateFormat('d MMM, yyyy').format(DateTime.now());
      });
    }
  }

  void _handleSearch(String query) {
    if (_mounted) {
      setState(() {
        _searchQuery = query.toLowerCase();
      });
      _panelController.open();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      controller: _panelController,
      minHeight: MediaQuery.of(context).size.height * 0.43,
      maxHeight: MediaQuery.of(context).size.height * 0.8,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      panel: ExercisesPanel(searchQuery: _searchQuery),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, $_userName!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Rubik'
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentDate,
                        style: TextStyle(color: Colors.blue[200], fontFamily: 'Rubik'),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              CustomSearchBar(onSearch: _handleSearch),
              const SizedBox(height: 25),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'How do you feel?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Rubik'
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  EmoticonFace(
                    emoticonFace: '😊',
                    mood: 'Happy',
                  ),
                  EmoticonFace(
                    emoticonFace: '😔',
                    mood: 'Sad',
                  ),
                  EmoticonFace(
                    emoticonFace: '😌',
                    mood: 'Calm',
                  ),
                  EmoticonFace(
                    emoticonFace: '😠',
                    mood: 'Angry',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExercisesPanel extends StatelessWidget {
  final String searchQuery;

  const ExercisesPanel({Key? key, required this.searchQuery}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> exercises = [
      {'icon': Icons.speaker_notes_rounded, 'name': 'Speaking Skills', 'count': 15, 'color': Colors.yellow[600]},
      {'icon': Icons.book_rounded, 'name': 'Reading Skills', 'count': 8, 'color': Colors.green},
      {'icon': Icons.edit_note_rounded, 'name': 'Writing Skills', 'count': 10, 'color': Colors.pink},
      {'icon': Icons.people_rounded, 'name': 'Understanding Skills', 'count': 5, 'color': Colors.orange},
      {'icon': Icons.hearing_rounded, 'name': 'Hearing Skills', 'count': 2, 'color': Colors.brown},
      {'icon': Icons.gamepad_rounded, 'name': 'Gaming Skills', 'count': 9, 'color': Colors.redAccent},
    ];

    final filteredExercises = exercises.where((exercise) =>
        exercise['name'].toString().toLowerCase().contains(searchQuery)).toList();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 1, bottom: 10),
            child: Text(
              'Exercises',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
                fontFamily: 'Rubik'
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = filteredExercises[index];
                return ExerciseTile(
                  icon: exercise['icon'] as IconData,
                  exerciseName: exercise['name'] as String,
                  numberOfExercises: exercise['count'] as int,
                  color: exercise['color'] as Color?,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
