import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Forward declarations for classes that will be defined in magic_coloring_screen.dart
class SvgRegion {
  final String id;
  final String pathData;
  final String originalFill;
  final int targetColorNumber;

  SvgRegion({
    required this.id,
    required this.pathData,
    required this.originalFill,
    required this.targetColorNumber,
  });
}

class NumberedColor {
  final int number;
  final Color color;

  NumberedColor(this.number, this.color);
}

class MagicArt {
  final String id;
  final String name;
  final String icon;

  const MagicArt({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class MagicCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<MagicArt> magicArts;

  const MagicCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.magicArts,
  });
}

class MagicColoringProvider extends ChangeNotifier {
  // Current magic art ID
  String? _currentMagicArtId;

  // Map of region ID to filled color
  final Map<String, Color> _filledRegions = {};

  // Currently selected color number
  int? _selectedColorNumber;

  // List of regions in the current SVG
  List<SvgRegion> _regions = [];

  // Color palette
  List<NumberedColor> _colorPalette = [];

  // Completed magic arts (saved for scene mode)
  final Map<String, CompletedMagicArt> _completedArts = {};

  // Getters
  String? get currentMagicArtId => _currentMagicArtId;
  Map<String, Color> get filledRegions => _filledRegions;
  int? get selectedColorNumber => _selectedColorNumber;
  Map<String, CompletedMagicArt> get completedArts => _completedArts;

  MagicColoringProvider() {
    _loadCompletedArts();
  }

  /// Initialize with a new magic art
  void initializeMagicArt(String artId, List<SvgRegion> regions, List<NumberedColor> palette) {
    _currentMagicArtId = artId;
    _regions = regions;
    _colorPalette = palette;
    _filledRegions.clear();
    _selectedColorNumber = null;
    notifyListeners();
  }

  /// Select a color number
  void selectColor(int colorNumber) {
    _selectedColorNumber = colorNumber;
    notifyListeners();
  }

  /// Fill a region with the selected color
  void fillRegion(String regionId) {
    if (_selectedColorNumber == null) return;

    // Find the region
    final region = _regions.firstWhere(
      (r) => r.id == regionId,
      orElse: () => SvgRegion(id: '', pathData: '', originalFill: '', targetColorNumber: -1),
    );

    // Check if this region should be filled with the selected color
    if (region.targetColorNumber == _selectedColorNumber) {
      // Find the color in palette
      final numberedColor = _colorPalette.firstWhere(
        (c) => c.number == _selectedColorNumber,
      );

      _filledRegions[regionId] = numberedColor.color;
      notifyListeners();
    }
  }

  /// Get progress percentage
  double getProgress() {
    if (_regions.isEmpty) return 0.0;

    int filledCount = 0;
    for (final region in _regions) {
      if (_filledRegions.containsKey(region.id)) {
        filledCount++;
      }
    }

    return filledCount / _regions.length;
  }

  /// Check if all regions are filled
  bool isComplete() {
    if (_regions.isEmpty) return false;
    return _filledRegions.length == _regions.length;
  }

  /// Check if a specific color number is completely filled
  bool isColorCompleted(int colorNumber) {
    final regionsWithColor = _regions.where((r) => r.targetColorNumber == colorNumber);

    for (final region in regionsWithColor) {
      if (!_filledRegions.containsKey(region.id)) {
        return false;
      }
    }

    return regionsWithColor.isNotEmpty;
  }

  /// Save completed magic art for use in scene mode
  Future<void> saveCompletedMagicArt(MagicArt magicArt, MagicCategory category) async {
    if (_currentMagicArtId == null) return;

    final completedArt = CompletedMagicArt(
      id: _currentMagicArtId!,
      name: magicArt.name,
      icon: magicArt.icon,
      category: category.name,
      categoryColor: category.color,
      filledRegions: Map.from(_filledRegions),
      completedAt: DateTime.now(),
    );

    _completedArts[_currentMagicArtId!] = completedArt;

    // Save to shared preferences
    final prefs = await SharedPreferences.getInstance();
    final completedArtsJson = _completedArts.map((key, value) => 
      MapEntry(key, value.toJson())
    );
    await prefs.setString('completed_magic_arts', json.encode(completedArtsJson));

    notifyListeners();
  }

  /// Load completed arts from storage
  Future<void> _loadCompletedArts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('completed_magic_arts');

    if (jsonString != null) {
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      jsonMap.forEach((key, value) {
        _completedArts[key] = CompletedMagicArt.fromJson(value);
      });
      notifyListeners();
    }
  }

  /// Get list of completed arts for scene mode
  List<CompletedMagicArt> getCompletedArtsForSceneMode() {
    return _completedArts.values.toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }
}

/// Model for completed magic art
class CompletedMagicArt {
  final String id;
  final String name;
  final String icon;
  final String category;
  final Color categoryColor;
  final Map<String, Color> filledRegions;
  final DateTime completedAt;

  CompletedMagicArt({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    required this.categoryColor,
    required this.filledRegions,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'category': category,
      // UPDATED: Replaced .value with .toARGB32()
      'categoryColor': categoryColor.toARGB32(),
      'filledRegions': filledRegions.map((key, value) => 
        // UPDATED: Replaced .value with .toARGB32()
        MapEntry(key, value.toARGB32())
      ),
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory CompletedMagicArt.fromJson(Map<String, dynamic> json) {
    return CompletedMagicArt(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      category: json['category'],
      categoryColor: Color(json['categoryColor']),
      filledRegions: (json['filledRegions'] as Map).map((key, value) =>
        MapEntry(key.toString(), Color(value))
      ),
      completedAt: DateTime.parse(json['completedAt']),
    );
  }
}