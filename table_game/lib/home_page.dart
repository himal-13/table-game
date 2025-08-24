import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:table_game/pages/challenge_mode.dart';
import 'package:table_game/pages/play_menu.dart';
import 'package:table_game/pages/stats_page.dart';
import 'package:table_game/pages/table_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // A boolean state variable to track if sound is on or off.
  bool _isSoundOn = true;

  @override
  void initState() {
    super.initState();
    // Load the saved sound setting when the widget is first created.
    _loadSoundSetting();
  }

  // Asynchronously loads the sound setting from shared preferences.
  Future<void> _loadSoundSetting() async {
    final prefs = await SharedPreferences.getInstance();
    // Use setState to rebuild the widget after loading the value.
    setState(() {
      // Get the 'isSoundOn' value, defaulting to true if not found.
      _isSoundOn = prefs.getBool('isSoundOn') ?? true;
    });
  }

  // Toggles the sound state and saves it to shared preferences.
  Future<void> _toggleSound() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSoundOn = !_isSoundOn;
      // Save the new state to local storage.
      prefs.setBool('isSoundOn', _isSoundOn);
    });
  }

  void _showRateUsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF6B588D),
          title: const Text(
            'Rate Us',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Thank you for using our app! Please take a moment to rate us.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Later',
                style: TextStyle(color: Color(0xFFEBC182)),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening app store...'),
                    duration: Duration(seconds: 2),
                  ),
                );
                await StoreRedirect.redirect(androidAppId: "com.multiple.tablegame");
              },
              child: const Text(
                'Rate Now',
                style: TextStyle(
                  color: Color(0xFFEBC182),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color transparentWhite = Color.fromARGB(22, 255, 255, 255);

    return Scaffold(
      backgroundColor: const Color(0xFF1B1B36),
      body: Stack(
        children: [
          // Background symbols
          Positioned(
            top: 50,
            left: -20,
            child: Text(
              'X',
              style: TextStyle(fontSize: 120, color: transparentWhite),
            ),
          ),
          Positioned(
            top: 150,
            left: 20,
            child: Text(
              '2',
              style: TextStyle(fontSize: 100, color: transparentWhite),
            ),
          ),
          Positioned(
            top: 250,
            left: -40,
            child: Text(
              '-',
              style: TextStyle(fontSize: 150, color: transparentWhite),
            ),
          ),
          Positioned(
            bottom: 250,
            right: -60,
            child: Text(
              '/',
              style: TextStyle(fontSize: 140, color: transparentWhite),
            ),
          ),
          Positioned(
            top: 80,
            right: -30,
            child: Text(
              '+',
              style: TextStyle(fontSize: 130, color: transparentWhite),
            ),
          ),
          Positioned(
            top: 180,
            right: 20,
            child: Text(
              '-',
              style: TextStyle(fontSize: 100, color: transparentWhite),
            ),
          ),
          Positioned(
            top: 400,
            right: 0,
            child: Text(
              'X',
              style: TextStyle(fontSize: 90, color: transparentWhite),
            ),
          ),
          Positioned(
            top: 500,
            right: -20,
            child: Text(
              '5',
              style: TextStyle(fontSize: 120, color: transparentWhite),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 50,
            child: Text(
              '3',
              style: TextStyle(fontSize: 100, color: transparentWhite),
            ),
          ),
          // Main content column
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Section with the logo and "MATH TABLE" text
                const Column(
                  children: [
                    Text(
                      'MATH',
                      style: TextStyle(
                        fontFamily: 'Riffic',
                        color: Color(0xFFFFF2D9),
                        fontSize: 65,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      'TABLE',
                      style: TextStyle(
                        fontFamily: 'Riffic',
                        color: Color(0xFFFFF2D9),
                        fontSize: 65,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),

                // Practice Button - Red
                CustomElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PlayMenu()),
                    );
                  },
                  text: 'PRACTICE',
                  buttonColor: const Color(0xFFBB2F45),
                  icon: Icons.chevron_right,
                ),
                const SizedBox(height: 30),

                // Challenge Button - Orange
                CustomElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChallengeGamePage()),
                    );
                    
                  },
                  text: 'CHALLENGE',
                  buttonColor: const Color(0xFFE44D26),
                  icon: Icons.sports_martial_arts,
                ),
                const SizedBox(height: 30),

                // Tables Button - Yellow
                CustomElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TablePage()),
                    );
                  },
                  text: 'TABLES',
                  buttonColor: const Color(0xFFF9A825),
                  icon: Icons.table_chart,
                ),
                const SizedBox(height: 60),
                

                // Bottom Icons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Sound Icon
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StatsPage()),
                        );
                      },
                      child: Icon(
                        Icons.bar_chart,
                        color: const Color(0xFFFFF2D9),
                        size: 50,
                      ),
                    ),
                    const SizedBox(width: 40),
                    InkWell(
                      onTap: _toggleSound,
                      child: Icon(
                        _isSoundOn ? Icons.volume_up : Icons.volume_off,
                        color: const Color(0xFFFFF2D9),
                        size: 50,
                      ),
                    ),
                    const SizedBox(width: 40),
                    // Rate Us Icon
                    InkWell(
                      onTap: _showRateUsDialog,
                      child: Icon(
                        Icons.star,
                        color: Colors.yellow[600],
                        size: 50,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final Color buttonColor;
  final VoidCallback onPressed;
  final IconData icon;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.buttonColor,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 28),
        label: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Riffic',
            color: Color(0xFFFFF2D9),
            fontSize: 30,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          shadowColor: Colors.black.withOpacity(0.5),
          elevation: 8,
          minimumSize: const Size(double.infinity, 70),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
