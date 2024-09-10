// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Yoga', 'icon': Icons.self_improvement, 'color': Colors.purple},
    {'name': 'Meditation', 'icon': Icons.spa, 'color': Colors.blue},
    {'name': 'Running', 'icon': Icons.directions_run, 'color': Colors.green},
    {'name': 'Cycling', 'icon': Icons.directions_bike, 'color': Colors.orange},
    {'name': 'Swimming', 'icon': Icons.pool, 'color': Colors.cyan},
    {'name': 'Weightlifting', 'icon': Icons.fitness_center, 'color': Colors.red},
    {'name': 'Dancing', 'icon': Icons.music_note, 'color': Colors.pink},
    {'name': 'Hiking', 'icon': Icons.landscape, 'color': Colors.brown},
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredCategories = _categories
        .where((category) => category['name'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xff1565c0),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                style: const TextStyle(color: Colors.white, fontFamily: 'Rubik'),
                decoration: InputDecoration(
                  hintText: 'Search activities...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontFamily: 'Rubik'),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: AnimationLimiter(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      columnCount: 2,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: _buildCategoryCard(filteredCategories[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        _showCategoryDetails(category);
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: category['color'],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category['icon'], size: 50, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              category['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Rubik'
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDetails(Map<String, dynamic> category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Icon(category['icon'], size: 80, color: category['color']),
              const SizedBox(height: 20),
              Text(
                category['name'],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Rubik',
                  color: category['color'],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Add functionality to start the activity
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: category['color'],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Start Activity', style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Rubik')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
