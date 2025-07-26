import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProgressProvider extends ChangeNotifier {
  final Map<String, PixelArtProgress> _progress = {};
  
  ProgressProvider() {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString('pixel_art_progress') ?? '{}';
    final Map<String, dynamic> progressMap = json.decode(progressJson);
    
    progressMap.forEach((key, value) {
      _progress[key] = PixelArtProgress.fromJson(value);
    });
    
    notifyListeners();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressMap = <String, dynamic>{};
    
    _progress.forEach((key, value) {
      progressMap[key] = value.toJson();
    });
    
    await prefs.setString('pixel_art_progress', json.encode(progressMap));
  }

  PixelArtProgress getProgress(String artId) {
    return _progress[artId] ?? PixelArtProgress(artId: artId);
  }

  void updateProgress(String artId, List<List<bool>> filledPixels) {
    final progress = getProgress(artId);
    
    // Calculate completion percentage
    int totalPixels = 0;
    int filledCount = 0;
    
    for (var row in filledPixels) {
      for (var filled in row) {
        totalPixels++;
        if (filled) filledCount++;
      }
    }
    
    progress.percentComplete = totalPixels > 0 ? (filledCount / totalPixels) : 0.0;
    progress.isComplete = progress.percentComplete >= 1.0;
    progress.lastPlayed = DateTime.now();
    progress.filledPixels = filledPixels;
    
    _progress[artId] = progress;
    _saveProgress();
    notifyListeners();
  }

  void resetProgress(String artId) {
    _progress.remove(artId);
    _saveProgress();
    notifyListeners();
  }
}

class PixelArtProgress {
  final String artId;
  double percentComplete;
  bool isComplete;
  DateTime? lastPlayed;
  List<List<bool>>? filledPixels;

  PixelArtProgress({
    required this.artId,
    this.percentComplete = 0.0,
    this.isComplete = false,
    this.lastPlayed,
    this.filledPixels,
  });

  factory PixelArtProgress.fromJson(Map<String, dynamic> json) {
    return PixelArtProgress(
      artId: json['artId'],
      percentComplete: json['percentComplete'] ?? 0.0,
      isComplete: json['isComplete'] ?? false,
      lastPlayed: json['lastPlayed'] != null 
          ? DateTime.parse(json['lastPlayed']) 
          : null,
      filledPixels: json['filledPixels'] != null
          ? (json['filledPixels'] as List).map((row) => 
              (row as List).map((cell) => cell as bool).toList()
            ).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'artId': artId,
      'percentComplete': percentComplete,
      'isComplete': isComplete,
      'lastPlayed': lastPlayed?.toIso8601String(),
      'filledPixels': filledPixels,
    };
  }
}