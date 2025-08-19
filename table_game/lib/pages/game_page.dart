import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_game/components/audio_manager.dart';
import 'package:table_game/main.dart';
import 'package:table_game/pages/play_menu.dart';

class GamePage extends StatefulWidget {
  final List<int> selectedNumbers;

  const GamePage({super.key, required this.selectedNumbers});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  // Game state variables
  int _score = 0;
  int _highScore = 0;
  int _timeRemaining = 15;
  int _health = 5;
  Timer? _timer;

  // Question and options
  String _question = "";
  int _correctAnswer = 0;
  List<String> _options = [];

  // Answer feedback
  String _selectedAnswer = "";
  bool _showAnswer = false;

  // Statistics
  int _totalQuestions = 0;
  int _correctAnswers = 0;
  DateTime? _questionStartTime;
  final List<int> _responseTimes = [];
  int _totalResponseTime = 0;

  // Animation
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

    _dialogController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  void _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  void _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', _highScore);
  }

  void _saveGameStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'totalQuestions',
      (prefs.getInt('totalQuestions') ?? 0) + _totalQuestions,
    );
    await prefs.setInt(
      'correctAnswers',
      (prefs.getInt('correctAnswers') ?? 0) + _correctAnswers,
    );
    await prefs.setInt(
      'totalResponseTime',
      (prefs.getInt('totalResponseTime') ?? 0) + _totalResponseTime,
    );
    await prefs.setInt(
      'totalScore',
      (prefs.getInt('totalScore') ?? 0) + _score,
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() => _timeRemaining--);
      } else {
        _timer?.cancel();
        _checkAnswer("TimeOut");
      }
    });
  }

  void _generateQuestion() {
    _questionStartTime = DateTime.now();
    int num1 =
        widget.selectedNumbers[_random.nextInt(widget.selectedNumbers.length)];
    int num2 = _random.nextInt(10) + 1;
    _correctAnswer = num1 * num2;
    _question = "$num1 x $num2";

    Set<int> options = {_correctAnswer};
    while (options.length < 4) {
      int offset = _random.nextInt(10) - 5;
      int option = _correctAnswer + offset;
      if (option > 0 && !options.contains(option)) {
        options.add(option);
      }
    }

    _options = options.toList().map((e) => e.toString()).toList();
    _options.shuffle();
  }

  void _checkAnswer(String selectedAnswer) {
    _timer?.cancel();
    setState(() {
      _selectedAnswer = selectedAnswer;
      _showAnswer = true;
      _totalQuestions++;

      bool isCorrect =
          selectedAnswer != "TimeOut" &&
          int.tryParse(selectedAnswer) == _correctAnswer;
      AudioService().playCorrectSound(isCorrect);

      if (isCorrect) {
        int responseTime = DateTime.now()
            .difference(_questionStartTime!)
            .inMilliseconds;
        _responseTimes.add(responseTime);
        _totalResponseTime += responseTime;
        _correctAnswers++;
        _score++;
        if (_score > _highScore) {
          _highScore = _score;
          _saveHighScore();
        }
      } else {
        _health--;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (_health <= 0) {
        _saveGameStats();
        AudioService().playGameOverSound();
        _showGameOverDialog();
      } else {
        setState(() {
          _selectedAnswer = "";
          _showAnswer = false;
          _timeRemaining = 15;
        });
        _startTimer();
        _generateQuestion();
      }
    });
  }

  void _showGameOverDialog() {
    double accuracy = _totalQuestions > 0
        ? (_correctAnswers / _totalQuestions) * 100
        : 0;
    int avgTime = _responseTimes.isNotEmpty
        ? _responseTimes.reduce((a, b) => a + b) ~/ _responseTimes.length
        : 0;

    _scoreAnimation = Tween(begin: 0.0, end: _score.toDouble()).animate(
      CurvedAnimation(
        parent: _dialogController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _accuracyAnimation = Tween(begin: 0.0, end: accuracy).animate(
      CurvedAnimation(
        parent: _dialogController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );
    _timeAnimation = Tween(begin: 0.0, end: avgTime / 1000.0).animate(
      CurvedAnimation(
        parent: _dialogController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
      ),
    );

    _dialogController.reset();
    _dialogController.forward();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: darkPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Game Over!",
          style: TextStyle(
            color: beige,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _dialogController,
              builder: (context, _) => _buildDialogItem(
                "Score:",
                _scoreAnimation.value.round().toString(),
              ),
            ),
            AnimatedBuilder(
              animation: _dialogController,
              builder: (context, _) => _buildDialogItem(
                "Accuracy:",
                "${_accuracyAnimation.value.toStringAsFixed(1)}%",
              ),
            ),
            AnimatedBuilder(
              animation: _dialogController,
              builder: (context, _) => _buildDialogItem(
                "Avg Time:",
                "${_timeAnimation.value.toStringAsFixed(2)}s",
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const PlayMenu()),
              (route) => false,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: beige,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              "Play Again",
              style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: beige, fontSize: 18)),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildHeaderItem("SCORE", _score.toString()),
                  _buildHeaderItem("HIGHSCORE", _highScore.toString()),
                  _buildHeaderItem(
                    "TIME",
                    _timeRemaining.toString().padLeft(2, '0'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < _health ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                _question,
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 50),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: _options.length,
                  itemBuilder: (context, i) => _buildAnswerButton(_options[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: beige, fontSize: 16)),
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

  Widget _buildAnswerButton(String answer) {
    bool isCorrectAnswer = int.tryParse(answer) == _correctAnswer;
    bool isSelectedAnswer = answer == _selectedAnswer;

    Color backgroundColor = beige;
    Color textColor = darkPurple;

    if (_showAnswer) {
      if (isCorrectAnswer) {
        backgroundColor = Colors.green;
        textColor = Colors.white;
      } else if (isSelectedAnswer) {
        backgroundColor = Colors.red;
        textColor = Colors.white;
      }
    }

    return ElevatedButton(
      onPressed: _showAnswer ? null : () => _checkAnswer(answer),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        textStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        disabledBackgroundColor: backgroundColor,
        disabledForegroundColor: textColor,
      ),
      child: Text(answer),
    );
  }
}
