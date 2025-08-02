import 'package:flutter/material.dart';

/// Data model for Magic Mode objects
class MagicObject {
  final String id;
  final String name;
  final String svgPath;
  final String previewIcon;
  final Map<String, Color> predefinedColors;
  final Map<String, List<Color>> customizableRegions;
  final Map<String, String>? regionNumbers;

  MagicObject({
    required this.id,
    required this.name,
    required this.svgPath,
    required this.previewIcon,
    this.predefinedColors = const {},
    this.customizableRegions = const {},
    this.regionNumbers,
  });

  /// Get all regions that should be numbered (for paint-by-number)
  Map<String, String> getNumberedRegions({bool isCustomizing = false}) {
    if (regionNumbers != null) return regionNumbers!;
    
    final numberedRegions = <String, String>{};
    int number = 1;
    
    if (!isCustomizing) {
      // First time coloring - number all regions
      for (final region in predefinedColors.keys) {
        numberedRegions[region] = number.toString();
        number++;
      }
    }
    
    // Always number customizable regions
    for (final region in customizableRegions.keys) {
      numberedRegions[region] = number.toString();
      number++;
    }
    
    return numberedRegions;
  }

  /// Get total number of colorable regions
  int getTotalRegions({bool isCustomizing = false}) {
    if (isCustomizing) {
      return customizableRegions.length;
    }
    return predefinedColors.length + customizableRegions.length;
  }

  /// Check if a region is colorable in the current mode
  bool isRegionColorable(String regionId, {bool isCustomizing = false}) {
    if (isCustomizing) {
      return customizableRegions.containsKey(regionId);
    }
    return true; // All regions colorable in first-time mode
  }

  /// Get available colors for a region
  List<Color>? getColorsForRegion(String regionId) {
    return customizableRegions[regionId];
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'svgPath': svgPath,
      'previewIcon': previewIcon,
      'predefinedColors': predefinedColors.map((key, value) => 
      MapEntry(key, value.toARGB32()),
      ),
      'customizableRegions': customizableRegions.map((key, value) =>
        MapEntry(key, value.map((color) => color.toARGB32()).toList()),
      ),
    };
  }

  /// Create from JSON
  factory MagicObject.fromJson(Map<String, dynamic> json) {
    return MagicObject(
      id: json['id'],
      name: json['name'],
      svgPath: json['svgPath'],
      previewIcon: json['previewIcon'],
      predefinedColors: (json['predefinedColors'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, Color(value)),
      ) ?? {},
      customizableRegions: (json['customizableRegions'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>).map((color) => Color(color)).toList(),
        ),
      ) ?? {},
    );
  }

  /// Create a copy with updated values
  MagicObject copyWith({
    String? id,
    String? name,
    String? svgPath,
    String? previewIcon,
    Map<String, Color>? predefinedColors,
    Map<String, List<Color>>? customizableRegions,
    Map<String, String>? regionNumbers,
  }) {
    return MagicObject(
      id: id ?? this.id,
      name: name ?? this.name,
      svgPath: svgPath ?? this.svgPath,
      previewIcon: previewIcon ?? this.previewIcon,
      predefinedColors: predefinedColors ?? this.predefinedColors,
      customizableRegions: customizableRegions ?? this.customizableRegions,
      regionNumbers: regionNumbers ?? this.regionNumbers,
    );
  }
}

/// Extension methods for MagicObject lists
extension MagicObjectListExtension on List<MagicObject> {
  /// Find object by ID
  MagicObject? findById(String id) {
    try {
      return firstWhere((obj) => obj.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Filter by completion status
  List<MagicObject> filterByCompletion(Set<String> completedIds) {
    return where((obj) => completedIds.contains(obj.id)).toList();
  }
}
