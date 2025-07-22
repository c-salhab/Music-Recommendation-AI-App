import 'package:flutter/material.dart';
import 'choose_artist.dart';
import 'prompt_screen.dart';
import 'choose_artist_mood_genre.dart';
import 'package:music_recommendation_ai_app/random_circles.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback showPromptScreen;

  const HomeScreen({super.key, required this.showPromptScreen});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 17, 17, 17),
      appBar: AppBar(
        title: const Text(
          'Music Playlist Generator',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: showPromptScreen,
            icon: const Icon(Icons.music_note, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          IgnorePointer(
            ignoring: true,
            child: RandomCircles(
              onMoodSelected: (_, __) {},
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: showPromptScreen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Generate by Mood & Genre'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChooseArtistScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Generate by Artist'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ArtistMoodGenreScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Generate by Artist + Mood + Genre'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}