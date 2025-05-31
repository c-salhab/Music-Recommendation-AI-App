import 'package:flutter/material.dart';
import 'package:music_recommendation_ai_app/component/toggle_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TogglePage(),
    );
  }
}
