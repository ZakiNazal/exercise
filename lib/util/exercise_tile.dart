// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class ExerciseTile extends StatelessWidget {
  final IconData icon;
  final String exerciseName;
  final int numberOfExercises;
  final Color? color;

  const ExerciseTile({
    Key? key,
    required this.icon,
    required this.exerciseName,
    required this.numberOfExercises,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color?.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(exerciseName),
      subtitle: Text('$numberOfExercises exercises'),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        // Navigate to exercise details
      },
    );
  }
}
