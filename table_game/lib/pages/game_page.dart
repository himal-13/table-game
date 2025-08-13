import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_game/main.dart';


class GamePage extends StatefulWidget {
  final List<int> selectedNumbers;

  const GamePage({super.key, required this.selectedNumbers});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with SingleTickerProviderStateMixin {
  // Game state variables
  int _score = 0;
  int _highScore = 0;
  int _timeRemaining = 15;
  int _health = 5; // Initial health
  Timer? _timer;

  // Question and options state variables
  String _question = "";
  int _correctAnswer = 0;
  List<String> _options = [];

  // For tracking game statistics
  int _totalQuestions = 0;
  int _correctAnswers = 0;
  DateTime? _questionStartTime;
  final List<int> _responseTimes = [];
  int _totalResponseTime = 0;

  // Animation controllers
  late AnimationController _dialogController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _accuracyAnimation;
  late Animation<double> _timeAnimation;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _generateQuestion();
    _startTimer();

    // Initialize animation controller
    _dialogController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  // Load high score from local storage
  void _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  // Save the new high score to local storage
  void _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', _highScore);
  }

  // Save all game stats to local storage
  void _saveGameStats() async {
    final prefs = await SharedPreferences.getInstance();
    // Add current game stats to existing stats
    int totalQuestions = prefs.getInt('totalQuestions') ?? 0;
    int correctAnswers = prefs.getInt('correctAnswers') ?? 0;
    int totalResponseTime = prefs.getInt('totalResponseTime') ?? 0;
    int totalScore = prefs.getInt('totalScore') ?? 0;

    await prefs.setInt('totalQuestions', totalQuestions + _totalQuestions);
    await prefs.setInt('correctAnswers', correctAnswers + _correctAnswers);
    await prefs.setInt('totalResponseTime', totalResponseTime + _totalResponseTime);
    await prefs.setInt('totalScore', totalScore + _score);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _timer?.cancel();
        _handleTimeOut();
      }
    });
  }

  void _handleTimeOut() {
    _checkAnswer("TimeOut"); // Treat timeout as a wrong answer
  }

  void _generateQuestion() {
    _questionStartTime = DateTime.now();
    int num1 = widget.selectedNumbers[_random.nextInt(widget.selectedNumbers.length)];
    int num2 = _random.nextInt(10) + 1;
    _correctAnswer = num1 * num2;
    _question = "$num1 x $num2";

    _options.clear();
    Set<int> incorrectAnswers = {};
    while (incorrectAnswers.length < 3) {
      int randomOffset = _random.nextInt(10) - 5;
      int incorrect = _correctAnswer + randomOffset;
      if (incorrect != _correctAnswer && !incorrectAnswers.contains(incorrect) && incorrect > 0) {
        incorrectAnswers.add(incorrect);
      }
    }

    _options.add(_correctAnswer.toString());
    _options.addAll(incorrectAnswers.map((e) => e.toString()));
    _options.shuffle();
  }

  void _checkAnswer(String selectedAnswer) {
    _timer?.cancel();
    setState(() {
      _totalQuestions++;
      // Check for timeout first, as it's a special case
      if (selectedAnswer == "TimeOut" || int.tryParse(selectedAnswer) != _correctAnswer) {
        _health--;
      } else if (int.tryParse(selectedAnswer) == _correctAnswer) {
        // Calculate and save response time
        int responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
        _responseTimes.add(responseTime);
        _totalResponseTime += responseTime;
        _correctAnswers++;
        _score++;
        if (_score > _highScore) {
          _highScore = _score;
          _saveHighScore(); // Save new high score immediately
        }
      }
    });

    if (_health <= 0) {
      _saveGameStats();
      _showGameOverDialog();
    } else {
      setState(() {
        _timeRemaining = 15;
      });
      _startTimer();
      _generateQuestion();
    }
  }

  void _showGameOverDialog() {
    double accuracy = _totalQuestions > 0 ? (_correctAnswers / _totalQuestions) * 100 : 0.0;
    int averageTime = _responseTimes.isNotEmpty
        ? (_responseTimes.reduce((a, b) => a + b) ~/ _responseTimes.length)
        : 0;
    double averageTimeInSeconds = averageTime / 1000.0;

    _scoreAnimation = Tween<double>(begin: 0, end: _score.toDouble()).animate(
      CurvedAnimation(parent: _dialogController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    _accuracyAnimation = Tween<double>(begin: 0, end: accuracy).animate(
      CurvedAnimation(parent: _dialogController, curve: const Interval(0.2, 0.7, curve: Curves.easeOut)),
    );
    _timeAnimation = Tween<double>(begin: 0, end: averageTimeInSeconds).animate(
      CurvedAnimation(parent: _dialogController, curve: const Interval(0.4, 0.9, curve: Curves.easeOut)),
    );

    _dialogController.reset();
    _dialogController.forward();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: darkPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: const Text(
              "Game Over!",
              textAlign: TextAlign.center,
              style: TextStyle(color: beige, fontWeight: FontWeight.bold, fontSize: 32),
            ),
          ),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _dialogController,
                builder: (context, child) {
                  return _buildDialogItem(
                    "Final Score:",
                    _scoreAnimation.value.round().toString(),
                    beige,
                  );
                },
              ),
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: _dialogController,
                builder: (context, child) {
                  return _buildDialogItem(
                    "Accuracy:",
                    "${_accuracyAnimation.value.toStringAsFixed(1)}%",
                    beige,
                  );
                },
              ),
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: _dialogController,
                builder: (context, child) {
                  return _buildDialogItem(
                    "Avg. Time:",
                    "${_timeAnimation.value.toStringAsFixed(2)}s",
                    beige,
                  );
                },
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: beige,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text(
                    "Play Again",
                    style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: color, fontSize: 18),
        ),
        Text(
          value,
          style: TextStyle(color: beige, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dialogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkPurple,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header with Score, HighScore, Time and Health
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildHeaderItem("SCORE", _score.toString()),
                  _buildHeaderItem("HIGHSCORE", _highScore.toString()),
                  _buildHeaderItem(
                    "TIME",
                    _timeRemaining >= 10 ? "0:$_timeRemaining" : "0:0$_timeRemaining",
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Health bar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Icon(
                    index < _health ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                    size: 30,
                  );
                }),
              ),
              const SizedBox(height: 30),

              // The multiplication question
              Center(
                child: Text(
                  _question,
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // Answer buttons
              Expanded(
                child: Center(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _options.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: _buildAnswerButton(_options[index]),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // A helper widget to build the header items (Score, HighScore, Time)
  Widget _buildHeaderItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: beige,
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
    );
  }

  // A helper widget to build the answer buttons
  Widget _buildAnswerButton(String answer) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: () => _checkAnswer(answer),
        style: ElevatedButton.styleFrom(
          backgroundColor: beige,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        child: Text(
          answer,
          style: const TextStyle(
            color: darkPurple,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
