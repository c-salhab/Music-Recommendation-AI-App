import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ChooseArtistScreen extends StatefulWidget {
  const ChooseArtistScreen({super.key});

  @override
  State<ChooseArtistScreen> createState() => _ChooseArtistScreenState();
}

class _ChooseArtistScreenState extends State<ChooseArtistScreen> {
  String _artistName = '';
  bool _isLoading = false;
  bool _searchSubmitted = false;
  List<Map<String, String>> _playlist = [];

  Future<void> _fetchPlaylistFromArtist() async {
    if (_artistName.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchSubmitted = true;
      _playlist = [];
    });

    try {
      final response = await http.post(
        Uri.parse('http://172.20.10.5:5000/generate_by_artist'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'artist': _artistName}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final songs = data['playlist'] as List<dynamic>;

        setState(() {
          _playlist = songs.map<Map<String, String>>((song) {
            final parts = (song as String).split(' - ');
            return {
              'artist': parts[0].trim(),
              'title': parts.length > 1 ? parts[1].trim() : 'Unknown',
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch playlist');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _searchSubmitted = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _goBackToSearch() {
    setState(() {
      _searchSubmitted = false;
      _playlist = [];
      _artistName = '';
    });
  }

  Future<void> _openSpotify() async {
    final query = _playlist.map((s) => '${s['artist']} - ${s['title']}').join(', ');
    final url = Uri.parse('https://open.spotify.com/search/$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openAudiomack() async {
    final query = _playlist.map((s) => '${s['artist']} - ${s['title']}').join(', ');
    final url = Uri.parse('https://audiomack.com/search/$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  String capitalizeEachWord(String input) {
    return input
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF330000), Color(0xFF000000)],
          ),
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _isLoading
                ? Center(
                    child: Container(
                      height: 50,
                      width: 50,
                      padding: const EdgeInsets.all(12.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const CircularProgressIndicator(
                        color: Colors.black,
                      ),
                    ),
                  )
                : !_searchSubmitted
                    ? Column(
                        children: [
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.start,
                          //   children: [
                          //     GestureDetector(
                          //       onTap: () => Navigator.pop(context),
                          //       child: Container(
                          //         height: 40.0,
                          //         width: 40.0,
                          //         decoration: const BoxDecoration(
                          //           color: Color(0xFFFFFFFF),
                          //           shape: BoxShape.circle,
                          //         ),
                          //         child: const Center(
                          //           child: Icon(Icons.arrow_back, color: Colors.black),
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.arrow_back, color: Colors.black),
                                  ),
                                ),
                              ),
                              // GestureDetector(
                              //   onTap: () {
                              //     showDialog(
                              //       context: context,
                              //       builder: (context) => AlertDialog(
                              //         title: Center(
                              //           child: Text(
                              //             'Create Playlist on?',
                              //             style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
                              //           ),
                              //         ),
                              //         content: Row(
                              //           mainAxisAlignment: MainAxisAlignment.center,
                              //           children: [
                              //             GestureDetector(
                              //               onTap: _openSpotify,
                              //               child: Container(
                              //                 height: 50,
                              //                 width: 50,
                              //                 decoration: const BoxDecoration(
                              //                   shape: BoxShape.circle,
                              //                   image: DecorationImage(
                              //                     image: AssetImage("assets/images/spotify.png"),
                              //                     fit: BoxFit.cover,
                              //                   ),
                              //                 ),
                              //               ),
                              //             ),
                              //             const SizedBox(width: 12),
                              //             // GestureDetector(
                              //             //   onTap: _openAudiomack,
                              //             //   child: Container(
                              //             //     height: 50,
                              //             //     width: 50,
                              //             //     decoration: const BoxDecoration(
                              //             //       shape: BoxShape.circle,
                              //             //       image: DecorationImage(
                              //             //         image: AssetImage("assets/images/audiomack.png"),
                              //             //         fit: BoxFit.cover,
                              //             //       ),
                              //             //     ),
                              //             //   ),
                              //             // ),
                              //           ],
                              //         ),
                              //       ),
                              //     );
                              //   },
                              //   child: Container(
                              //     height: 40,
                              //     width: 40,
                              //     decoration: const BoxDecoration(
                              //       color: Colors.white,
                              //       shape: BoxShape.circle,
                              //     ),
                              //     child: const Center(
                              //       child: Icon(Icons.playlist_add_rounded, color: Colors.black),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 80,
                                    width: 80,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Image.asset("assets/images/moodify.png", fit: BoxFit.contain),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    "\nDrop your favorite artist's name — let AI cook your playlist !",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.search, color: Colors.black54),
                                        const SizedBox(width: 10.0),
                                        Expanded(
                                          child: TextField(
                                            onChanged: (value) => _artistName = value,
                                            onSubmitted: (_) => _fetchPlaylistFromArtist(),
                                            style: const TextStyle(color: Colors.black),
                                            decoration: const InputDecoration(
                                              hintText: 'Enter artist name...',
                                              hintStyle: TextStyle(color: Colors.black45),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: _fetchPlaylistFromArtist,
                                          child: const Icon(Icons.send, color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: _goBackToSearch,
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.arrow_back, color: Colors.black),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Center(
                                        child: Text(
                                          'Create Playlist on?',
                                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      content: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: _openSpotify,
                                            child: Container(
                                              height: 50,
                                              width: 50,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  image: AssetImage("assets/images/spotify.png"),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // GestureDetector(
                                          //   onTap: _openAudiomack,
                                          //   child: Container(
                                          //     height: 50,
                                          //     width: 50,
                                          //     decoration: const BoxDecoration(
                                          //       shape: BoxShape.circle,
                                          //       image: DecorationImage(
                                          //         image: AssetImage("assets/images/audiomack.png"),
                                          //         fit: BoxFit.cover,
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.playlist_add_rounded, color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Text(
                            '\n\nPlaylist for : ${capitalizeEachWord(_artistName)}\n\n',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _playlist.length,
                              itemBuilder: (context, index) {
                                final song = _playlist[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFCCCC).withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 65,
                                          width: 65,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12.0),
                                            image: const DecorationImage(
                                              image: AssetImage("assets/images/sonnetlogo.png"),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                song['artist'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.white,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                maxLines: 1,
                                              ),
                                              Text(
                                                song['title'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                maxLines: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}