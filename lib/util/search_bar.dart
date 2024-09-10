// ignore_for_file: library_private_types_in_public_api, use_super_parameters

import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final Function(String) onSearch;

  const CustomSearchBar({Key? key, required this.onSearch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        onChanged: onSearch,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            child: Icon(Icons.search, color: Colors.white70),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            child: IconButton(
              icon: const Icon(Icons.clear, color: Colors.white70),
              onPressed: () {
                // Clear the search field
                onSearch('');
              },
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
        ),
      ),
    );
  }
}
