import 'package:flutter/material.dart';
import 'package:table_game/main.dart';
import 'package:table_game/pages/game_page.dart';

class PlayMenu extends StatefulWidget {
  const PlayMenu({super.key});

  @override
  State<PlayMenu> createState() => _PlayMenuState();
}

class _PlayMenuState extends State<PlayMenu> {
  // A list to hold the numbers (tables) selected by the user
  final List<int> _selectedNumbers = [];

  // Toggles the selection of a number
  void _toggleNumber(int number) {
    setState(() {
      if (_selectedNumbers.contains(number)) {
        _selectedNumbers.remove(number);
      } else {
        _selectedNumbers.add(number);
      }
    });
  }

  // Navigates to the game page with the selected numbers
  void _startGame() {
    if (_selectedNumbers.isNotEmpty) {
      // Sort the numbers for a consistent appearance
      _selectedNumbers.sort();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GamePage(selectedNumbers: _selectedNumbers),
        ),
      );
    } else {
      // Show a snackbar if no numbers are selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one number to start.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // A helper widget to build the number selection buttons
  Widget _buildNumberButton(int number) {
    final isSelected = _selectedNumbers.contains(number);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () => _toggleNumber(number),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? lightPurple : beige,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          minimumSize: const Size(60, 60), // Fixed size for square buttons
        ),
        child: Text(
          number.toString(),
          style: TextStyle(
            color: isSelected ? Colors.white : darkPurple,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkPurple,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Select Tables',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                // Grid of number buttons
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(12, (index) => _buildNumberButton(index + 1)),
                ),
                const SizedBox(height: 50),
                // Start Game button
                SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: beige,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    child: const Text(
                      'Start Game',
                      style: TextStyle(
                        color: darkPurple,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
