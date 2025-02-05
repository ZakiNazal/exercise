// ignore_for_file: use_super_parameters, library_private_types_in_public_api, use_key_in_widget_constructors, avoid_print, unused_element, deprecated_member_use

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

class _HomePageContentState extends State<HomePageContent> with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String _userName = 'User';
  String _currentDate = '';
  final PanelController _panelController = PanelController();
  bool _showNotifications = false;
  bool _allNotificationsCleared = false;
  final GlobalKey _notificationButtonKey = GlobalKey();
  late Offset _buttonPosition;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _updateCurrentDate();
  }

  Future<void> _loadUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists && mounted) {
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
    if (mounted) {
      setState(() {
        _currentDate = DateFormat('d MMM, yyyy').format(DateTime.now());
      });
    }
  }

  void _handleSearch(String query) {
    if (mounted) {
      setState(() {
        _searchQuery = query.toLowerCase();
      });
      _panelController.open();
    }
  }

  void _toggleNotifications() {
    if (_allNotificationsCleared) {
      // Don't show notifications if they've all been cleared
      return;
    }

    final RenderBox renderBox = _notificationButtonKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    _buttonPosition = Offset(position.dx / MediaQuery.of(context).size.width, 
                             position.dy / MediaQuery.of(context).size.height);

    setState(() {
      _showNotifications = !_showNotifications;
    });
  }

  void _closeNotifications() {
    setState(() {
      _showNotifications = false;
    });
  }

  void _onAllNotificationsCleared() {
    setState(() {
      _allNotificationsCleared = true;
      _showNotifications = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xff1565c0),
      body: SafeArea(
        child: Stack(
          children: [
            SlidingUpPanel(
              minHeight: MediaQuery.of(context).size.height * 0.43 - bottomPadding,
              maxHeight: MediaQuery.of(context).size.height * 0.8 - bottomPadding,
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
                          // Remove the notification button from here
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
            ),
            Positioned(
              top: 25,
              right: 20,
              child: GestureDetector(
                key: _notificationButtonKey,
                onTap: _toggleNotifications,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _allNotificationsCleared ? Colors.grey : Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _allNotificationsCleared ? Icons.notifications_off : Icons.notifications,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (_showNotifications)
              Positioned(
                top: 80,
                right: 20,
                child: NotificationContainer(
                  onEmpty: _onAllNotificationsCleared,
                  buttonPosition: _buttonPosition,
                ),
              ),
          ],
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

class NotificationContainer extends StatefulWidget {
  final VoidCallback onEmpty;
  final Offset buttonPosition;

  const NotificationContainer({
    Key? key,
    required this.onEmpty,
    required this.buttonPosition,
  }) : super(key: key);

  @override
  _NotificationContainerState createState() => _NotificationContainerState();
}

class _NotificationContainerState extends State<NotificationContainer> with SingleTickerProviderStateMixin {
  List<Map<String, String>> notifications = [
    {
      'title': 'New exercise available',
      'description': 'Check out the new speaking exercise!',
      'time': '2 hours ago',
    },
    {
      'title': 'Reminder',
      'description': 'Don\'t forget to complete your daily task.',
      'time': '5 hours ago',
    },
    {
      'title': 'Achievement unlocked',
      'description': 'You\'ve completed 10 exercises this week!',
      'time': '1 day ago',
    },
  ];

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _slideAnimation = Tween<Offset>(
      begin: widget.buttonPosition,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _removeNotification(int index) {
    if (!mounted) return;
    setState(() {
      notifications.removeAt(index);
      if (notifications.isEmpty) {
        _animationController.reverse().then((_) {
          widget.onEmpty();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SlideTransition(
            position: _slideAnimation,
            child: child,
          ),
        );
      },
      child: Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Rubik',
                    ),
                  ),
                  Text(
                    '${notifications.length} new',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontFamily: 'Rubik',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: notifications.isEmpty
                  ? Center(
                      child: Text(
                        'No notifications',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontFamily: 'Rubik',
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        return NotificationItem(
                          title: notifications[index]['title']!,
                          description: notifications[index]['description']!,
                          time: notifications[index]['time']!,
                          onDelete: () => _removeNotification(index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationItem extends StatefulWidget {
  final String title;
  final String description;
  final String time;
  final VoidCallback onDelete;

  const NotificationItem({
    Key? key,
    required this.title,
    required this.description,
    required this.time,
    required this.onDelete,
  }) : super(key: key);

  @override
  _NotificationItemState createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> with SingleTickerProviderStateMixin {
  AnimationController? _slideController;
  Animation<Offset>? _slideAnimation;
  bool _isRead = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.3, 0.0),
    ).animate(CurvedAnimation(
      parent: _slideController!,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _slideController?.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!mounted) return;
    if (_slideController!.isCompleted) {
      _slideController!.reverse();
    } else {
      _slideController!.forward();
    }
  }

  void _markAsRead() {
    if (!mounted) return;
    setState(() {
      _isRead = true;
      _slideController!.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        widget.onDelete();
      },
      child: GestureDetector(
        onTap: _onTap,
        child: SlideTransition(
          position: _slideAnimation!,
          child: Stack(
            children: [
              Container(
                height: 80,
                color: Colors.grey[200],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.check, color: Colors.green),
                      label: const Text('Mark as Read', style: TextStyle(color: Colors.green)),
                      onPressed: _markAsRead,
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        if (mounted) widget.onDelete();
                      },
                    ),
                  ],
                ),
              ),
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: _isRead ? Colors.grey[100] : Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[700],
                    child: Icon(
                      _getIconForNotification(widget.title),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    widget.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Rubik',
                      color: _isRead ? Colors.grey : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  subtitle: Text(
                    widget.description,
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      color: _isRead ? Colors.grey : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.time,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12, fontFamily: 'Rubik'),
                      ),
                      const SizedBox(height: 4),
                      if (!_isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.blue[700],
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForNotification(String title) {
    if (title.contains('exercise')) {
      return Icons.fitness_center;
    } else if (title.contains('Reminder')) {
      return Icons.alarm;
    } else if (title.contains('Achievement')) {
      return Icons.emoji_events;
    }
    return Icons.notifications;
  }
}
