import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ArtistMoodGenreScreen extends StatefulWidget {
  const ArtistMoodGenreScreen({super.key});

  @override
  State<ArtistMoodGenreScreen> createState() => _ArtistMoodGenreScreenState();
}

class _ArtistMoodGenreScreenState extends State<ArtistMoodGenreScreen> {
  final TextEditingController _artistController = TextEditingController();
  String _selectedMood = 'Happy';
  String _selectedGenre = 'Pop';
  List<String> _playlist = [];

  final List<String> moods = ['Happy', 'Sad', 'Energetic', 'Relaxed'];
  final List<String> genres = [
    'Jazz',
    'Rock',
    'Amapiano',
    'R&B',
    'Hip-Hop',
    'Hip-Life',
    'Reggae',
    'Afrobeat',
    'Blues',
    'Punk',
    'Pop',
    'Classical',
    'Metal',
    'Reggaeton',
  ];

  Future<void> _generatePlaylist() async {
    try {
      final response = await http.post(
        Uri.parse('http://10.234.76.137:5000/generate_by_artist_and_mood'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'artist': _artistController.text,
          'mood': _selectedMood,
          'genres': _selectedGenre,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _playlist = List<String>.from(data['playlist']);
        });
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 17, 17, 17),
      appBar: AppBar(
        title: const Text(
          'Generate by Artist + Mood + Genre',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _artistController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Artist Name',
                labelStyle: const TextStyle(color: Colors.white),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              dropdownColor: Colors.black,
              value: _selectedMood,
              items: moods.map((mood) {
                return DropdownMenuItem<String>(
                  value: mood,
                  child: Text(mood, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedMood = value!),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              dropdownColor: Colors.black,
              value: _selectedGenre,
              items: genres.map((genre) {
                return DropdownMenuItem<String>(
                  value: genre,
                  child: Text(genre, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedGenre = value!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generatePlaylist,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('Generate Playlist'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _playlist.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      _playlist[index],
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
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
