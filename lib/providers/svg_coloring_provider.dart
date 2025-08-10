// lib/providers/svg_coloring_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/svg_art.dart';

class SvgColoringProvider extends ChangeNotifier {
  SvgArt? _currentSvgArt;
  final Map<String, Color?> _filledRegions = {};
  int? _selectedColorId;
  final Map<int, bool> _completedColors = {};
  bool _isInitialized = false;
  String? _loadedSvgContent;
  String? _originalSvgContent; // Store original SVG

  SvgArt? get currentSvgArt => _currentSvgArt;
  Map<String, Color?> get filledRegions => _filledRegions;
  int? get selectedColorId => _selectedColorId;
  Map<int, bool> get completedColors => _completedColors;
  bool get isInitialized => _isInitialized;
  String? get loadedSvgContent => _loadedSvgContent;

  Future<void> initializeSvgArt(SvgArt svgArt) async {
    // Reset state
    _currentSvgArt = null;
    _filledRegions.clear();
    _completedColors.clear();
    _selectedColorId = null;
    _loadedSvgContent = null;
    _originalSvgContent = null;
    _isInitialized = false;

    // Load new
    _currentSvgArt = svgArt;

    if (svgArt.svgContent != null) {
      _originalSvgContent = svgArt.svgContent;
      _loadedSvgContent = svgArt.svgContent;
    } else {
      try {
        final content = await rootBundle.loadString(svgArt.svgPath);
        _originalSvgContent = content;
        _loadedSvgContent = content;
      } catch (e) {
        debugPrint('Error loading SVG: $e');
      }
    }

    for (var color in svgArt.palette) {
      _completedColors[color.id] = false;
    }

    await _loadProgress();
    _isInitialized = true;
    notifyListeners();
  }

  void selectColor(int colorId) {
    _selectedColorId = colorId;
    notifyListeners();
  }

  void fillRegion(String elementId) {
    if (_currentSvgArt == null || _selectedColorId == null) return;

    final region = _currentSvgArt!.regions.firstWhere(
      (r) => r.elementId == elementId,
      orElse: () => SvgRegion(elementId: '', colorNumber: 0),
    );

    if (region.colorNumber != _selectedColorId || region.colorNumber == 0) return;

    final colorPalette = _currentSvgArt!.palette.firstWhere(
      (p) => p.id == _selectedColorId,
    );

    _filledRegions[elementId] = colorPalette.color;
    _checkColorCompletion(_selectedColorId!);
    _saveProgress();
    notifyListeners();
  }

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

  double getProgress() {
    if (_currentSvgArt == null) return 0.0;
    final totalRegions = _currentSvgArt!.regions.length;
    final filledCount = _filledRegions.length;
    return totalRegions > 0 ? filledCount / totalRegions : 0.0;
  }

  bool shouldHighlightRegion(String elementId) {
    if (_currentSvgArt == null || _selectedColorId == null) return false;

    final region = _currentSvgArt!.regions.firstWhere(
      (r) => r.elementId == elementId,
      orElse: () => SvgRegion(elementId: '', colorNumber: 0),
    );

    return region.colorNumber == _selectedColorId && !_filledRegions.containsKey(elementId);
  }

  String getColoredSvg() {
    if (_originalSvgContent == null) return '';

    String svgContent = _originalSvgContent!;

    // Apply fills to regions
    _filledRegions.forEach((elementId, color) {
      if (color != null) {
        final String hexColor = _rgbHex(color);

        // Replace existing fill for this element ID
        svgContent = svgContent.replaceAllMapped(
          RegExp('id="$elementId"([^>]*?)fill="[^"]*"'),
          (match) => 'id="$elementId"${match.group(1)}fill="$hexColor"',
        );

        // If no fill exists, add it
        svgContent = svgContent.replaceAllMapped(
          RegExp('id="$elementId"([^>]*?)(/?>)'),
          (match) {
            final attrs = match.group(1) ?? '';
            final close = match.group(2) ?? '';
            if (!attrs.contains('fill=')) {
              return 'id="$elementId"$attrs fill="$hexColor"$close';
            }
            return match.group(0)!;
          },
        );
      }
    });

    // Highlight selected color regions
    if (_selectedColorId != null) {
      for (var region in _currentSvgArt!.regions) {
        if (region.colorNumber == _selectedColorId && !_filledRegions.containsKey(region.elementId)) {
          svgContent = svgContent.replaceAllMapped(
            RegExp('id="${region.elementId}"([^>]*?)stroke-width="[^"]*"'),
            (match) => 'id="${region.elementId}"${match.group(1)}stroke-width="4"',
          );
        }
      }
    }

    return svgContent;
  }

  Future<void> _saveProgress() async {
    if (_currentSvgArt == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Store as ARGB32 decimal strings (future-proof + explicit format)
      final filledData = _filledRegions.map(
        (key, value) => MapEntry(key, value?.toARGB32().toString() ?? ''),
      );

      await prefs.setString(
        'svg_${_currentSvgArt!.name}_filled',
        json.encode(filledData),
      );
    } catch (e) {
      debugPrint('Error saving SVG progress: $e');
    }
  }

  Future<void> _loadProgress() async {
    if (_currentSvgArt == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final filledJson = prefs.getString('svg_${_currentSvgArt!.name}_filled');
      if (filledJson != null) {
        final filledData = json.decode(filledJson) as Map<String, dynamic>;
        _filledRegions.clear();

        filledData.forEach((key, value) {
          final color = _parseStoredColor(value);
          if (color != null) {
            _filledRegions[key] = color;
          }
        });

        for (var color in _currentSvgArt!.palette) {
          _checkColorCompletion(color.id);
        }
      }
    } catch (e) {
      debugPrint('Error loading SVG progress: $e');
    }
  }

  Future<void> resetProgress() async {
    if (_currentSvgArt == null) return;

    _filledRegions.clear();
    _completedColors.clear();
    _selectedColorId = null;

    for (var color in _currentSvgArt!.palette) {
      _completedColors[color.id] = false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('svg_${_currentSvgArt!.name}_filled');

    notifyListeners();
  }

  @override
  void dispose() {
    _filledRegions.clear();
    _completedColors.clear();
    _currentSvgArt = null;
    _loadedSvgContent = null;
    _originalSvgContent = null;
    super.dispose();
  }

  // ---------- Helpers ----------

  // New color API wants normalized components: r/g/b in 0..1
  // Build #RRGGBB (uppercase) with proper rounding.
  String _rgbHex(Color color) {
    final int r = ((color.r * 255.0).round()) & 0xff;
    final int g = ((color.g * 255.0).round()) & 0xff;
    final int b = ((color.b * 255.0).round()) & 0xff;
    return '#'
            '${r.toRadixString(16).padLeft(2, '0')}'
            '${g.toRadixString(16).padLeft(2, '0')}'
            '${b.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  // Accepts multiple historical formats:
  // - decimal ARGB string: "4281545523"
  // - int (json may restore it as int)
  // - #RRGGBB hex string: "#12ABEF"
  // - empty / null -> returns null
  Color? _parseStoredColor(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      // Already ARGB32
      return Color(value);
    }

    final s = value.toString().trim();
    if (s.isEmpty) return null;

    // #RRGGBB -> assume full opacity
    if (s.startsWith('#')) {
      final hex = s.substring(1);
      if (hex.length == 6) {
        final rgb = int.tryParse(hex, radix: 16);
        if (rgb != null) {
          return Color(0xFF000000 | rgb);
        }
      }
      // If it's some other hex length, ignore gracefully
      return null;
    }

    // Decimal ARGB32
    final asInt = int.tryParse(s);
    if (asInt != null) {
      return Color(asInt);
    }

    return null;
  }
}
