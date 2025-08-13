import 'package:flutter/material.dart';
import 'package:table_game/home_page.dart';

void main() {
  runApp(const MyApp());
}

// Define the custom colors used in the UI.
const Color darkPurple = Color(0xFF5A2A69);
const Color beige = Color(0xFFF7E2B5);
const Color lightPurple = Color(0xFF8B5F9C);
const Color green = Color(0xFF4CAF50); // New color for success feedback
const Color red = Color(0xFFF44336);   // New color for failure feedback

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Multiply Game',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        // Set the default font for the entire app
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: darkPurple,
      ),
      // The app now starts with the MenuPage
      home: const HomePage(),
    );
  }
}

