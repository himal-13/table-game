import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_game/components/audio_manager.dart';
import 'package:table_game/main.dart';

class ChallengeGamePage extends StatefulWidget {
  const ChallengeGamePage({super.key});

  @override
  State<ChallengeGamePage> createState() => _ChallengeGamePageState();
}

class _ChallengeGamePageState extends State<ChallengeGamePage>
    with SingleTickerProviderStateMixin {
  // Game state variables for Challenge Mode
  String _currentMode = "";
  int _score = 0;
  int _highScore = 0;
  int _timeRemaining = 60; // Initial time limit for the entire game
  Timer? _timer;

  // Question and drag-and-drop state
  String _question = "";
  List<int> _correctFactors = [];
  List<int> _availableOptions = [];
  List<int?> _draggedFactors = [null, null];

  // Answer feedback
  String _feedbackMessage = "";
  bool _isGameOver = false;
  bool _isProcessing = false; // New state to control interaction during delay

  // Animation
  late AnimationController _dialogController;
  late Animation<double> _scoreAnimation;

  final Random _random = Random();
  late List<int> _numbersForMode;

  @override
  void initState() {
    super.initState();
    _dialogController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  void _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // High score is now saved per mode
      _highScore = prefs.getInt('challengeHighScore_$_currentMode') ?? 0;
    });
  }

  void _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('challengeHighScore_$_currentMode', _highScore);
  }

  // A new method to get the correct numbers based on the mode
  List<int> _getNumbersForMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'easy':
        // Easy mode uses numbers 1-5
        return List<int>.generate(5, (i) => i + 1);
      case 'normal':
        // Normal mode uses numbers 1-10
        return List<int>.generate(10, (i) => i + 1);
      case 'hard':
        // Hard mode uses numbers 11-20
        return List<int>.generate(10, (i) => i + 11);
      default:
        // Default to Normal mode if the mode is not recognized
        return List<int>.generate(10, (i) => i + 1);
    }
  }

  void _resetGame() {
    _timer?.cancel();
    setState(() {
      _score = 0;
      _timeRemaining = 60; // Reset time to 60 seconds
      _isGameOver = false;
      _feedbackMessage = "";
      _draggedFactors = [null, null];
    });
    _generateQuestion();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() => _timeRemaining--);
      } else {
        _timer?.cancel();
        _endGame();
      }
    });
  }

  void _generateQuestion() {
    // Generate numbers based on the selected mode
    int num1 = _numbersForMode[_random.nextInt(_numbersForMode.length)];
    int num2 = _random.nextInt(10) + 1;

    // Ensure the factors are unique
    while (num1 == num2) {
      num2 = _random.nextInt(10) + 1;
    }

    _correctFactors = [num1, num2];
    _correctFactors.sort(); // Sort to handle input order
    _question = "${num1 * num2}";

    // Generate a new set of options for drag-and-drop
    _generateOptions();
  }

  void _generateOptions() {
    _availableOptions.clear();
    _draggedFactors = [null, null];

    // Add correct factors
    _availableOptions.addAll(_correctFactors);

    // Add some random incorrect factors to make it a challenge
    while (_availableOptions.length < 5) {
      int randomIncorrect = _random.nextInt(20) + 1;
      if (!_availableOptions.contains(randomIncorrect) &&
          !_correctFactors.contains(randomIncorrect)) {
        _availableOptions.add(randomIncorrect);
      }
    }
    _availableOptions.shuffle();
  }

  void _checkAnswer() async {
    if (_isProcessing) return; // Prevent multiple checks

    if (_draggedFactors[0] != null && _draggedFactors[1] != null) {
      List<int> submittedFactors = _draggedFactors.cast<int>().toList();
      submittedFactors.sort();

      bool isCorrect = submittedFactors[0] == _correctFactors[0] &&
          submittedFactors[1] == _correctFactors[1];

      AudioService().playCorrectSound(isCorrect);

      if (isCorrect) {
        setState(() {
          _feedbackMessage = "Correct!";
          _score++;
          if (_score > _highScore) {
            _highScore = _score;
            _saveHighScore();
          }
          _isProcessing = true; // Start processing delay
        });

        await Future.delayed(const Duration(milliseconds: 700));

        setState(() {
          _feedbackMessage = "";
          _isProcessing = false; // End processing
        });
        _generateQuestion();
      } else {
        setState(() {
          _feedbackMessage = "Incorrect. Try again!";
          _score = _score > 0 ? _score - 1 : 0; // Penalize for wrong answer
          _draggedFactors = [null, null];
        });
      }
    } else {
      setState(() {
        _feedbackMessage = "Please drag two numbers.";
      });
    }
  }

  void _endGame() {
    _timer?.cancel();
    setState(() {
      _isGameOver = true;
    });

    _scoreAnimation = Tween(begin: 0.0, end: _score.toDouble()).animate(
      CurvedAnimation(
        parent: _dialogController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _dialogController.reset();
    _dialogController.forward();
  }

  void _onPlayAgain() {
    _resetGame();
  }

  void _selectMode(String mode) {
    setState(() {
      _currentMode = mode;
      _numbersForMode = _getNumbersForMode(mode);
    });
    _loadHighScore();
    _resetGame();
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C1938), // A darker purple at the top
              Color(0xFF4C2A4E), // A lighter purple at the bottom
            ],
          ),
        ),
        child: SafeArea(
          child: _currentMode.isEmpty
              ? _buildModeSelectionScreen()
              : (_isGameOver ? _buildGameOverScreen() : _buildGameScreen()),
        ),
      ),
    );
  }

  Widget _buildModeSelectionScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Select Challenge Mode",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFF9E6C3),
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            _buildModeButton("Easy"),
            const SizedBox(height: 20),
            _buildModeButton("Normal"),
            const SizedBox(height: 20),
            _buildModeButton("Hard"),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(String mode) {
    return ElevatedButton(
      onPressed: () => _selectMode(mode),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF9E6C3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
      ),
      child: Text(
        mode,
        style: const TextStyle(
          color: Color(0xFF4C2A4E),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Padding(
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
          const SizedBox(height: 60),
          Text(
            _question,
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 50),
          _buildAnswerArea(),
          const SizedBox(height: 40),
          _buildDraggableOptions(),
          const SizedBox(height: 20),
          Text(
            _feedbackMessage,
            style: TextStyle(
              color: _feedbackMessage.contains("Correct")
                  ? Colors.green
                  : Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerArea() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDragTarget(0),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "x",
            style: TextStyle(
              color: Color(0xFFF9E6C3),
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildDragTarget(1),
      ],
    );
  }

  Widget _buildDragTarget(int index) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (data) => !_isProcessing,
      onAcceptWithDetails: (details) {
        setState(() {
          _draggedFactors[index] = details.data;
          // Check answer immediately after a number is dropped
          _checkAnswer();
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF4C2A4E),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: candidateData.isNotEmpty ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: _draggedFactors[index] != null
                ? Text(
                    _draggedFactors[index].toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : const Text(
                    "?",
                    style: TextStyle(
                      color: Color(0xFFF9E6C3),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildDraggableOptions() {
    return AbsorbPointer(
      absorbing: _isProcessing,
      child: Wrap(
        spacing: 15,
        runSpacing: 15,
        alignment: WrapAlignment.center,
        children: _availableOptions.map((number) {
          return Draggable<int>(
            data: number,
            feedback: Material(
              color: Colors.transparent,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9E6C3),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    number.toString(),
                    style: const TextStyle(
                      color: darkPurple,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            childWhenDragging: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFF9E6C3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: const TextStyle(
                    color: darkPurple,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGameOverScreen() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: const Color(0xFF4C2A4E),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(87, 0, 0, 0),
              spreadRadius: 5,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Challenge Complete!",
              style: TextStyle(
                color: Color(0xFFF9E6C3),
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _dialogController,
              builder: (context, _) => _buildDialogItem(
                "Final Score",
                _scoreAnimation.value.round().toString(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _onPlayAgain,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF9E6C3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text(
                "Play Again",
                style: TextStyle(
                  color: Color(0xFF4C2A4E),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentMode = ""; // Go back to mode selection screen
                  _isGameOver = false; // Reset game over state
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "Exit",
                style: TextStyle(color: Color(0xFFF9E6C3), fontSize: 16),
              ),
            ),
          ],
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

  Widget _buildDialogItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFFF9E6C3), fontSize: 18),
          ),
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
    );
  }
}
