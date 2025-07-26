import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class SettingsProvider extends ChangeNotifier {
  bool _dragToPaintEnabled = false;
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMusicPlaying = false;

  bool get dragToPaintEnabled => _dragToPaintEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _dragToPaintEnabled = prefs.getBool('dragToPaintEnabled') ?? false;
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _musicEnabled = prefs.getBool('musicEnabled') ?? true;
    
    notifyListeners();
    
    if (_musicEnabled) {
      playBackgroundMusic();
    }
  }

  Future<void> toggleDragToPaint() async {
    _dragToPaintEnabled = !_dragToPaintEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dragToPaintEnabled', _dragToPaintEnabled);
    notifyListeners();
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', _soundEnabled);
    notifyListeners();
  }

  Future<void> toggleMusic() async {
    _musicEnabled = !_musicEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('musicEnabled', _musicEnabled);
    
    if (_musicEnabled) {
      playBackgroundMusic();
    } else {
      stopBackgroundMusic();
    }
    
    notifyListeners();
  }

  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled || _isMusicPlaying) return;
    
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(0.3);
      await _audioPlayer.play(AssetSource('audio/MagicPaint.mp3'));
      _isMusicPlaying = true;
    } catch (e) {
      debugPrint('Error playing background music: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _audioPlayer.stop();
    _isMusicPlaying = false;
  }

  Future<void> playSound(String soundFile) async {
    if (!_soundEnabled) return;
    
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('audio/$soundFile'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}