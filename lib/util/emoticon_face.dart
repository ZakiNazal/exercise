// ignore_for_file: library_private_types_in_public_api, use_super_parameters

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class EmoticonFace extends StatefulWidget {
  final String emoticonFace;
  final String mood;

  const EmoticonFace({
    Key? key,
    required this.emoticonFace,
    required this.mood,
  }) : super(key: key);

  @override
  _EmoticonFaceState createState() => _EmoticonFaceState();
}

class _EmoticonFaceState extends State<EmoticonFace> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 5));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _playConfetti() {
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            ElevatedButton(
              onPressed: _playConfetti,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(12),
              ),
              child: Text(
                widget.emoticonFace,
                style: const TextStyle(
                  fontSize: 28,
                  fontFamily: 'Rubik'
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.mood,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Rubik'
              ),
            ),
          ],
        ),
        Positioned.fill(
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2,
            maxBlastForce: 5,
            minBlastForce: 1,
            emissionFrequency: 0.05,
            numberOfParticles: 35,
            gravity: 0.05,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ],
          ),
        ),
      ],
    );
  }
}
