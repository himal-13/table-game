import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_redirect/store_redirect.dart';
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

  // Shows a simple dialog for the 'Rate Us' feature.
  void _showRateUsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF6B588D),
          title: Text(
            'Rate Us',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Thank you for using our app! Please take a moment to rate us.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Later',
                style: TextStyle(color: Color(0xFFEBC182)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Rate Now',
                style: TextStyle(color: Color(0xFFEBC182), fontWeight: FontWeight.bold),
              ),
              onPressed: ()async {
                // In a real app, you would open the app store link here.
                Navigator.of(context).pop();
                 ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening app store...'),
                    duration: Duration(seconds: 2),
                  ),
                );
                await StoreRedirect.redirect(androidAppId: "com.multiple.tablegame",);
               
              },
            ),
          ],
        );
      },
    );
  }

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

            // Bottom Icons Row - Now interactive!
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Sound Icon: Toggles sound on/off
                InkWell(
                  onTap: _toggleSound,
                  child: Icon(
                    // Change icon based on sound state
                    _isSoundOn ? Icons.volume_up : Icons.volume_off,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                SizedBox(width: 40),
                // Rate Us Icon: Opens a dialog
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
