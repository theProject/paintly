// ============================================
// 2. lib/providers/svg_coloring_provider.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/svg_art.dart';

class SvgColoringProvider extends ChangeNotifier {
  // Current SVG art being colored
  SvgArt? _currentSvgArt;
  
  // Map of element ID to filled color
  final Map<String, Color?> _filledRegions = {};
  
  // Currently selected color ID
  int? _selectedColorId;
  
  // Map tracking which colors are completely filled
  final Map<int, bool> _completedColors = {};
  
  // Flag to check if provider is initialized
  bool _isInitialized = false;
  
  // Loaded SVG content
  String? _loadedSvgContent;

  // Getters
  SvgArt? get currentSvgArt => _currentSvgArt;
  Map<String, Color?> get filledRegions => _filledRegions;
  int? get selectedColorId => _selectedColorId;
  Map<int, bool> get completedColors => _completedColors;
  bool get isInitialized => _isInitialized;
  String? get loadedSvgContent => _loadedSvgContent;

  /// Initialize the provider with new SVG art
  Future<void> initializeSvgArt(SvgArt svgArt) async {
    _currentSvgArt = svgArt;
    _filledRegions.clear();
    _completedColors.clear();
    _selectedColorId = null;
    
    // Load SVG content
    if (svgArt.svgContent != null) {
      _loadedSvgContent = svgArt.svgContent;
    } else {
      try {
        _loadedSvgContent = await rootBundle.loadString(svgArt.svgPath);
      } catch (e) {
        debugPrint('Error loading SVG: $e');
      }
    }
    
    // Initialize completed colors map
    for (var color in svgArt.palette) {
      _completedColors[color.id] = false;
    }
    
    // Load saved progress
    await _loadProgress();
    
    _isInitialized = true;
    notifyListeners();
  }

  /// Select a color from the palette
  void selectColor(int colorId) {
    _selectedColorId = colorId;
    notifyListeners();
  }

  /// Fill a region with the selected color
  void fillRegion(String elementId) {
    if (_currentSvgArt == null || _selectedColorId == null) return;
    
    // Find the region
    final region = _currentSvgArt!.regions.firstWhere(
      (r) => r.elementId == elementId,
      orElse: () => SvgRegion(elementId: '', colorNumber: 0),
    );
    
    // Check if this region should be filled with the selected color
    if (region.colorNumber != _selectedColorId || region.colorNumber == 0) return;
    
    // Find the color in the palette
    final colorPalette = _currentSvgArt!.palette.firstWhere(
      (p) => p.id == _selectedColorId,
    );
    
    // Fill the region
    _filledRegions[elementId] = colorPalette.color;
    
    // Check if this color is now complete
    _checkColorCompletion(_selectedColorId!);
    
    // Save progress
    _saveProgress();
    
    notifyListeners();
  }

  /// Check if all regions of a specific color are filled
  void _checkColorCompletion(int colorId) {
    if (_currentSvgArt == null) return;
    
    bool isComplete = true;
    
    for (var region in _currentSvgArt!.regions) {
      if (region.colorNumber == colorId && !_filledRegions.containsKey(region.elementId)) {
        isComplete = false;
        break;
      }
    }
    
    _completedColors[colorId] = isComplete;
  }

  /// Get the progress percentage
  double getProgress() {
    if (_currentSvgArt == null) return 0.0;
    
    final totalRegions = _currentSvgArt!.regions.length;
    final filledCount = _filledRegions.length;
    
    return totalRegions > 0 ? filledCount / totalRegions : 0.0;
  }

  /// Check if a specific region should be highlighted
  bool shouldHighlightRegion(String elementId) {
    if (_currentSvgArt == null || _selectedColorId == null) return false;
    
    final region = _currentSvgArt!.regions.firstWhere(
      (r) => r.elementId == elementId,
      orElse: () => SvgRegion(elementId: '', colorNumber: 0),
    );
    
    return region.colorNumber == _selectedColorId && !_filledRegions.containsKey(elementId);
  }

  /// Get SVG content with colors applied
  String getColoredSvg() {
    if (_loadedSvgContent == null) return '';
    
    String svgContent = _loadedSvgContent!;
    
    // Apply colors to filled regions
    _filledRegions.forEach((elementId, color) {
      if (color != null) {
        final hexColor = '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
        
        // Replace fill for elements with this ID
        svgContent = svgContent.replaceAllMapped(
          RegExp('(id="$elementId"[^>]*)(fill="[^"]*")'),
          (match) => '${match.group(1)}fill="$hexColor"',
        );
        
        // If no fill attribute exists, add it
        svgContent = svgContent.replaceAllMapped(
          RegExp('(id="$elementId"[^>]*)(>)'),
          (match) {
            final attributes = match.group(1)!;
            if (!attributes.contains('fill=')) {
              return '$attributes fill="$hexColor"${match.group(2)}';
            }
            return match.group(0)!;
          },
        );
      }
    });
    
    // Highlight selected regions
    if (_selectedColorId != null) {
      for (var region in _currentSvgArt!.regions) {
        if (region.colorNumber == _selectedColorId && !_filledRegions.containsKey(region.elementId)) {
          svgContent = svgContent.replaceAllMapped(
            RegExp('(id="${region.elementId}"[^>]*)(stroke-width="[^"]*")'),
            (match) => '${match.group(1)}stroke-width="3"',
          );
        }
      }
    }
    
    return svgContent;
  }

  /// Save progress to local storage
  Future<void> _saveProgress() async {
    if (_currentSvgArt == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save filled regions
      final filledData = _filledRegions.map((key, value) => 
        MapEntry(key, value?.toARGB32().toString() ?? ''),
      );
      
      await prefs.setString(
        'svg_${_currentSvgArt!.name}_filled',
        json.encode(filledData),
      );
      
      // Save completion status
      if (getProgress() >= 1.0) {
        final completedList = prefs.getStringList('completed_svgs') ?? [];
        if (!completedList.contains(_currentSvgArt!.name)) {
          completedList.add(_currentSvgArt!.name);
          await prefs.setStringList('completed_svgs', completedList);
        }
      }
    } catch (e) {
      debugPrint('Error saving SVG progress: $e');
    }
  }

  /// Load saved progress
  Future<void> _loadProgress() async {
    if (_currentSvgArt == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load filled regions
      final filledJson = prefs.getString('svg_${_currentSvgArt!.name}_filled');
      if (filledJson != null) {
        final filledData = json.decode(filledJson) as Map<String, dynamic>;
        _filledRegions.clear();
        
        filledData.forEach((key, value) {
          if (value != null && value.toString().isNotEmpty) {
            _filledRegions[key] = Color(int.parse(value.toString()));
          }
        });
        
        // Update completed colors
        for (var color in _currentSvgArt!.palette) {
          _checkColorCompletion(color.id);
        }
      }
    } catch (e) {
      debugPrint('Error loading SVG progress: $e');
    }
  }

  /// Reset all progress for current SVG art
  Future<void> resetProgress() async {
    if (_currentSvgArt == null) return;
    
    _filledRegions.clear();
    _completedColors.clear();
    _selectedColorId = null;
    
    // Reinitialize completed colors map
    for (var color in _currentSvgArt!.palette) {
      _completedColors[color.id] = false;
    }
    
    // Clear saved data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('svg_${_currentSvgArt!.name}_filled');
    
    // Remove from completed list
    final completedList = prefs.getStringList('completed_svgs') ?? [];
    completedList.remove(_currentSvgArt!.name);
    await prefs.setStringList('completed_svgs', completedList);
    
    notifyListeners();
  }
}