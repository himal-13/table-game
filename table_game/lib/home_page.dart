import 'package:flutter/material.dart';
import 'package:table_game/pages/play_menu.dart';
import 'package:table_game/pages/stats_page.dart';
import 'package:table_game/pages/table_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // A dark purple color that matches the image
    const Color cardColor = Color(0xFF4C3C63);
    const Color buttonColor = Color(0xFF6B588D);
    const Color iconColor = Color(0xFFEBC182);

    return Scaffold(
      backgroundColor: cardColor, // The background of the whole app screen
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Welcome Text
            Text(
              'Table Game',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            SizedBox(height: 40),

            // Play Button
            CustomElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PlayMenu()),
                );
              },
              icon: Icons.play_arrow,
              text: 'PLAY',
              buttonColor: buttonColor,
              iconColor: iconColor,
            ),
            SizedBox(height: 30),

            // Table Button
            CustomElevatedButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TablePage()),
                );
              },
              icon: Icons.grid_view,
              text: 'TABLE',
              buttonColor: buttonColor,
              iconColor: iconColor,
            ),
            SizedBox(height: 30),

            // Stats Button
            CustomElevatedButton(
              onPressed: (){
               Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StatsPage()),
                );
              },
              icon: Icons.bar_chart,
              text: 'STATS',
              buttonColor: buttonColor,
              iconColor: iconColor,
            ),
            SizedBox(height: 60),

            // Bottom Icons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.volume_up, color: Colors.white, size: 50),
                SizedBox(width: 40),
                Icon(Icons.music_note, color: Colors.white, size: 50),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// A custom button widget to reduce code repetition and make the UI cleaner
class CustomElevatedButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color buttonColor;
  final Color iconColor;
  final VoidCallback onPressed;

  const CustomElevatedButton({
    super.key,
    required this.icon,
    required this.text,
    required this.buttonColor,
    required this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: ElevatedButton.icon(
        onPressed: () {
          onPressed();
        },
        icon: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        label: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15.0),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          shadowColor: const Color.fromARGB(134, 0, 0, 0),
          elevation: 8,
          minimumSize: const Size(double.infinity, 70), // Full width button

          alignment: Alignment.center, // Align content to the left
        ),
      ),
    );
  }
}
