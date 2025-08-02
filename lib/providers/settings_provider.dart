// lib/providers/settings_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class SettingsProvider extends ChangeNotifier {
  // Audio player instance
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Settings
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;
  bool _hasSeenIntro = false;
  bool _dragToPaintEnabled = false;        // new field
  double _soundVolume = 0.8;
  double _musicVolume = 0.5;

  // Getters
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get hasSeenIntro => _hasSeenIntro;
  bool get dragToPaintEnabled => _dragToPaintEnabled;  // new getter
  double get soundVolume => _soundVolume;
  double get musicVolume => _musicVolume;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _musicEnabled = prefs.getBool('musicEnabled') ?? true;
    _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
    _hasSeenIntro = prefs.getBool('hasSeenIntro') ?? false;
    _dragToPaintEnabled = prefs.getBool('dragToPaintEnabled') ?? false;  // load it
    _soundVolume = prefs.getDouble('soundVolume') ?? 0.8;
    _musicVolume = prefs.getDouble('musicVolume') ?? 0.5;

    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setBool('musicEnabled', _musicEnabled);
    await prefs.setBool('vibrationEnabled', _vibrationEnabled);
    await prefs.setBool('hasSeenIntro', _hasSeenIntro);
    await prefs.setBool('dragToPaintEnabled', _dragToPaintEnabled);  // save it
    await prefs.setDouble('soundVolume', _soundVolume);
    await prefs.setDouble('musicVolume', _musicVolume);
  }

  // Existing setters...
  void setSoundEnabled(bool value) {
    _soundEnabled = value;
    _saveSettings();
    notifyListeners();
  }

  void setMusicEnabled(bool value) {
    _musicEnabled = value;
    _saveSettings();
    notifyListeners();
  }

  void setVibrationEnabled(bool value) {
    _vibrationEnabled = value;
    _saveSettings();
    notifyListeners();
  }

  void setHasSeenIntro(bool value) {
    _hasSeenIntro = value;
    _saveSettings();
    notifyListeners();
  }

  // New toggle methods
  void toggleSound() {
    setSoundEnabled(!_soundEnabled);
  }

  void toggleMusic() {
    setMusicEnabled(!_musicEnabled);
  }

  void toggleDragToPaint() {
    _dragToPaintEnabled = !_dragToPaintEnabled;
    _saveSettings();
    notifyListeners();
  }

  // Volume setters...
  void setSoundVolume(double value) {
    _soundVolume = value.clamp(0.0, 1.0);
    _saveSettings();
    notifyListeners();
  }

  void setMusicVolume(double value) {
    _musicVolume = value.clamp(0.0, 1.0);
    _saveSettings();
    notifyListeners();
  }

  // Audio playback...
  Future<void> playSound(String soundFile) async {
    if (!_soundEnabled) return;

    try {
      await _audioPlayer.setVolume(_soundVolume);
      await _audioPlayer.play(AssetSource('audio/$soundFile'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  Future<void> playBackgroundMusic(String musicFile) async {
    if (!_musicEnabled) return;

    try {
      await _audioPlayer.setVolume(_musicVolume);
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('audio/$musicFile'));
    } catch (e) {
      debugPrint('Error playing music: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping music: $e');
    }
  }

  void resetSettings() {
    _soundEnabled = true;
    _musicEnabled = true;
    _vibrationEnabled = true;
    _dragToPaintEnabled = false;  // reset it too
    _soundVolume = 0.8;
    _musicVolume = 0.5;
    _saveSettings();
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
