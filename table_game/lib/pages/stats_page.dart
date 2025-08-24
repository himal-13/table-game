import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int _totalQuestions = 0;
  int _correctAnswers = 0;
  int _totalResponseTime = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  // Load all game stats from local storage
  void _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalQuestions = prefs.getInt('totalQuestions') ?? 0;
      _correctAnswers = prefs.getInt('correctAnswers') ?? 0;
      _totalResponseTime = prefs.getInt('totalResponseTime') ?? 0;
    });
  }

  // A new method to reset all stats to zero
  void _resetStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalQuestions', 0);
    await prefs.setInt('correctAnswers', 0);
    await prefs.setInt('totalResponseTime', 0);
    
    // After resetting, reload the stats to update the UI
    _loadStats();
  }

  // Function to show the confirmation dialog
  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2F33),
          title: const Text(
            "Confirm Reset",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to reset all your stats? This action cannot be undone.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            TextButton(
              onPressed: () {
                _resetStats(); // Call the reset method
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                "Reset",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  // A helper widget to build a single stat item card with a modern design
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      color: const Color(0xFF2C2F33), // Darker card background
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 30,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white, // White text for values
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[400], // Lighter grey for labels
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double accuracy = _totalQuestions > 0 ? (_correctAnswers / _totalQuestions) * 100 : 0.0;
    double averageTime = _totalQuestions > 0 ? (_totalResponseTime / _totalQuestions) / 1000 : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF23272A), // Very dark background
      appBar: AppBar(
        title: const Text(
          "Your Stats",
          style: TextStyle(
            color: Colors.white, // White app bar title
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // White back button icon
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Overall Performance",
                style: TextStyle(
                  color: Colors.white, // White text for section title
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildStatCard(
                icon: Icons.check_circle_outline_rounded,
                iconColor: Colors.greenAccent,
                label: "Correct Answers",
                value: _correctAnswers.toString(),
              ),
              const SizedBox(height: 15),
              _buildStatCard(
                icon: Icons.bolt_rounded,
                iconColor: Colors.orangeAccent,
                label: "Total Questions",
                value: _totalQuestions.toString(),
              ),
              const SizedBox(height: 15),
              _buildStatCard(
                icon: Icons.bar_chart_rounded,
                iconColor: Colors.blueAccent,
                label: "Accuracy Rate",
                value: "${accuracy.toStringAsFixed(1)}%",
              ),
              const SizedBox(height: 15),
              _buildStatCard(
                icon: Icons.access_time_rounded,
                iconColor: Colors.purpleAccent,
                label: "Average Response Time",
                value: "${averageTime.toStringAsFixed(2)}s",
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _showResetDialog, // Call the new dialog method
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: const Text(
                    "Reset Stats",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}