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

  // A helper widget to build a single stat item card
  Widget _buildStatCard(
      {required IconData icon, required Color iconColor, required String label, required String value}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: const Color(0xFFF06292), // A slightly darker pink
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 30,
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
      backgroundColor: const Color(0xFFF8BBD0), // Bright pink background
      appBar: AppBar(
        title: const Text("Statistics"),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8BBD0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildStatCard(
                icon: Icons.bolt,
                iconColor: const Color(0xFFFFEB3B), // Yellow icon
                label: "Total Questions answered",
                value: _totalQuestions.toString(),
              ),
              const SizedBox(height: 15),
              _buildStatCard(
                icon: Icons.check_circle_outline_rounded,
                iconColor: const Color(0xFF4DB6AC), // Teal icon
                label: "Right Answered",
                value: _correctAnswers.toString(),
              ),
              const SizedBox(height: 15),
              _buildStatCard(
                icon: Icons.bar_chart_rounded,
                iconColor: const Color(0xFFBA68C8), // Purple icon
                label: "Accuracy",
                value: "${accuracy.toStringAsFixed(1)}%",
              ),
              const SizedBox(height: 15),
              _buildStatCard(
                icon: Icons.access_time_rounded,
                iconColor: Colors.white,
                label: "Average Time",
                value: "${averageTime.toStringAsFixed(2)}s",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
