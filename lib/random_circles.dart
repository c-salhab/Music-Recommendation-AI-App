import 'package:flutter/material.dart';
import 'dart:math';

class RandomCircles extends StatefulWidget {
  final Function(String?, String?) onMoodSelected;
  const RandomCircles({super.key, required this.onMoodSelected});

  @override
  _RandomCirclesState createState() => _RandomCirclesState();
}

class _RandomCirclesState extends State<RandomCircles> {
  final Random random = Random();
  final ValueNotifier<String?> _selectedMood = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _selectedMoodImage = ValueNotifier<String?>(null);

  late BuildContext scaffoldContext; // Pour accéder au ScaffoldMessenger

  final List<Map<String, String>> moodData = [
    {'mood': 'Happy', 'image': 'assets/images/happy.png'},
    {'mood': 'Heartbroken', 'image': 'assets/images/heartbroken.png'},
    {'mood': 'Grateful', 'image': 'assets/images/grateful.png'},
    {'mood': 'Relaxed', 'image': 'assets/images/relaxed.png'},
    {'mood': 'Anxious', 'image': 'assets/images/anxious.png'},
    {'mood': 'Romance', 'image': 'assets/images/romance.png'},
    {'mood': 'Energetic', 'image': 'assets/images/energetic.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        scaffoldContext = context; // Capture du context pour le snackbar

        return LayoutBuilder(
          builder: (context, constraints) {
            final List<Widget> circles = [];
            final List<Rect> positions = [];

            for (int i = 0; i < moodData.length; i++) {
              final double size = random.nextDouble() * 100 + 50;
              double left, top;
              Rect newPosition;

              bool doesOverlap;
              int attempts = 0;
              const int maxAttempts = 100;

              do {
                left = random.nextDouble() * (constraints.maxWidth - size);
                top = random.nextDouble() * (constraints.maxHeight - size);
                newPosition = Rect.fromLTWH(left, top, size, size);
                doesOverlap = positions.any((position) => position.overlaps(newPosition));
                attempts++;
              } while (doesOverlap && attempts < maxAttempts);

              if (attempts == maxAttempts) {
                continue;
              }

              positions.add(newPosition);

              Color color = Color.fromARGB(
                255,
                random.nextInt(256),
                random.nextInt(256),
                random.nextInt(256),
              );

              circles.add(
                Positioned(
                  left: left,
                  top: top,
                  child: ValueListenableBuilder<String?>(
                    valueListenable: _selectedMood,
                    builder: (context, selectedMood, child) {
                      final bool isSelected = selectedMood == moodData[i]['mood'];
                      final Color backgroundColor = isSelected
                          ? const Color(0xFF0000FF)
                          : const Color(0xFFFFCCCC).withOpacity(0.1);

                      return GestureDetector(
                        onTap: () {
                          final String? mood = isSelected ? null : moodData[i]['mood'];
                          final String? image = isSelected ? null : moodData[i]['image'];
                          _selectedMood.value = mood;
                          _selectedMoodImage.value = image;
                          widget.onMoodSelected(mood, image);

                          if (mood != null) {
                            ScaffoldMessenger.of(scaffoldContext).hideCurrentSnackBar();
                            ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                              SnackBar(
                                content: Text(mood),
                                duration: const Duration(seconds: 2),
                                backgroundColor: const Color.fromARGB(221, 66, 66, 66),
                                // behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2.0,
                              color: backgroundColor,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFFCCCC).withOpacity(0.1)
                                  : color,
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              moodData[i]['image']!,
                              width: size * 0.8,
                              height: size * 0.8,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }

            return Stack(children: circles);
          },
        );
      },
    );
  }
}
