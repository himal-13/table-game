import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum to clearly define sound types
enum SoundType {
  correct,
  wrong,
  levelComplete,
  gameOver,
}

class AudioService extends ChangeNotifier {
  // Map to hold dedicated AudioPlayer instances for each sound type
  final Map<SoundType, AudioPlayer> _players = {};

  AudioService() {
    init();
  }

  Future<void> init() async {
    // Initialize players for known sound types
    _players[SoundType.correct] = AudioPlayer();
    _players[SoundType.wrong] = AudioPlayer();
    _players[SoundType.levelComplete] = AudioPlayer();
    _players[SoundType.gameOver] = AudioPlayer();
  }

  // Generic play method that checks the sound setting from SharedPreferences
  Future<void> _playSound(String audioPath) async {
    final prefs = await SharedPreferences.getInstance();
    final bool isSoundOn = prefs.getBool('isSoundOn') ?? true;

    if (isSoundOn) {
      await AudioPlayer().play(AssetSource(audioPath));
    }
  }

  void playCorrectSound(bool isCorrect) async {
    String audioPath = isCorrect ? 'audio/success.mp3' : 'audio/failed.mp3';
    await _playSound(audioPath);
  }

  void playLevelCompleteSound() async {
    String audioPath = "audio/level-complete.mp3";
    await _playSound(audioPath);
  }

  void playGameOverSound() async {
    String audioPath = "audio/gameover.mp3";
    await _playSound(audioPath);
  }

  @override
  void dispose() {
    _players.forEach((key, player) {
      player.dispose(); // Dispose each individual player
    });
    _players.clear();
    super.dispose();
  }
}