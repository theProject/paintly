// lib/providers/svg_coloring_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:xml/xml.dart' as xml;
import 'package:path_drawing/path_drawing.dart'; // for parseSvgPathData

import '../models/svg_art.dart';

class SvgColoringProvider extends ChangeNotifier {
  SvgArt? _currentSvgArt;
  final Map<String, Color?> _filledRegions = {};
  int? _selectedColorId;
  final Map<int, bool> _completedColors = {};
  bool _isInitialized = false;
  String? _loadedSvgContent;
  String? _originalSvgContent; // Baseline SVG (after neutralization)

  // area cache for “don’t get stuck”
  final Map<String, double> _regionArea = {};
  static const double _kAutoFillTinyArea = 150.0; // viewBox units² (400x400 basis)

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
    _regionArea.clear();
    _isInitialized = false;

    // Load new
    _currentSvgArt = svgArt;

    if (svgArt.svgContent != null) {
      _originalSvgContent = svgArt.svgContent;
      _loadedSvgContent   = svgArt.svgContent;
    } else {
      try {
        final content = await rootBundle.loadString(svgArt.svgPath);
        _originalSvgContent = content;
        _loadedSvgContent   = content;
      } catch (e) {
        debugPrint('Error loading SVG: $e');
      }
    }

    // --- Make all paintable regions start colorless (visible outline only) ---
    if (_loadedSvgContent != null) {
      try {
        final doc = xml.XmlDocument.parse(_loadedSvgContent!);

        bool isExcludedId(String id) {
          final s = id.toLowerCase();
          // Exclude pure outlines and tiny facial linework you don't want to paint
          if (s.startsWith('outline_')) return true;
          if (s.startsWith('np_')) return true; // manual opt-out prefix
          if (s.contains('eye') || s.contains('pupil') || s.contains('glint')) return true;
          if (s.contains('mouth') || s.contains('smile')) return true;
          // Nose stays paintable (black), so don't exclude 'nose'
          return false;
        }

        for (final e in doc.findAllElements('*')) {
          final id = e.getAttribute('id');
          if (id == null || isExcludedId(id)) continue;

          final style = e.getAttribute('style') ?? '';
          final hasFillStyle = style.contains('fill:');
          final hasFillAttr  = e.getAttribute('fill') != null;

          if (hasFillAttr || hasFillStyle) {
            // Remove style to avoid CSS overriding attributes
            e.removeAttribute('style');
            // Transparent until user paints
            e.setAttribute('fill', 'none');
            // Ensure visible outline
            e.setAttribute('stroke', e.getAttribute('stroke') ?? '#333333');
            e.setAttribute('stroke-width', e.getAttribute('stroke-width') ?? '1.5');
          }
        }

        // Baseline is now the colorless version
        _originalSvgContent = doc.toXmlString(pretty: false);
        _loadedSvgContent   = _originalSvgContent;
      } catch (e) {
        debugPrint('Error neutralizing SVG fills: $e');
      }
    }
    // ------------------------------------------------------------------------

    // Initialize completion tracking for the palette
    for (var color in svgArt.palette) {
      _completedColors[color.id] = false;
    }

    // Precompute region areas so we can auto-complete tiny leftovers
    _computeRegionAreas();

    await _loadProgress();
    _isInitialized = true;
    notifyListeners();
  }

  // ---------- Interaction ----------

  void selectColor(int colorId) {
    _selectedColorId = colorId;
    _autofillTinyLeftovers(colorId); // make sure slivers don’t block progress
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

    // Auto-complete any remaining tiny pieces for this color
    _autofillTinyLeftovers(_selectedColorId!);

    _checkColorCompletion(_selectedColorId!);
    _saveProgress();
    notifyListeners();
  }

  // ---------- Rendering ----------

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

    // Highlight selected color regions (unfilled ones)
    if (_selectedColorId != null && _currentSvgArt != null) {
      for (var region in _currentSvgArt!.regions) {
        if (region.colorNumber == _selectedColorId &&
            !_filledRegions.containsKey(region.elementId)) {
          svgContent = svgContent.replaceAllMapped(
            RegExp('id="${region.elementId}"([^>]*?)stroke-width="[^"]*"'),
            (match) => 'id="${region.elementId}"${match.group(1)}stroke-width="4"',
          );

          // If no stroke-width exists yet, add one
          svgContent = svgContent.replaceAllMapped(
            RegExp('id="${region.elementId}"([^>]*?)(/?>)'),
            (match) {
              final attrs = match.group(1) ?? '';
              final close = match.group(2) ?? '';
              if (!attrs.contains('stroke-width=')) {
                return 'id="${region.elementId}"$attrs stroke-width="4"$close';
              }
              return match.group(0)!;
            },
          );
        }
      }
    }

    return svgContent;
  }

  // ---------- Progress ----------

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

  Future<void> _saveProgress() async {
    if (_currentSvgArt == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Store as ARGB32 decimal strings
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

  // compute approximate area per region (bounding box area)
  void _computeRegionAreas() {
    if (_originalSvgContent == null || _currentSvgArt == null) return;
    try {
      final doc = xml.XmlDocument.parse(_originalSvgContent!);
      final ids = _currentSvgArt!.regions.map((r) => r.elementId).toSet();

      Path? pathFor(xml.XmlElement e) {
        final tag = e.name.local;
        double toD(String? v) => v == null ? 0.0 : double.tryParse(v) ?? 0.0;

        if (tag == 'path') {
          final d = e.getAttribute('d');
          if (d == null) return null;
          return parseSvgPathData(d);
        }
        if (tag == 'rect') {
          final x = toD(e.getAttribute('x'));
          final y = toD(e.getAttribute('y'));
          final w = toD(e.getAttribute('width'));
          final h = toD(e.getAttribute('height'));
          if (w <= 0 || h <= 0) return null;
          final p = Path()..addRect(Rect.fromLTWH(x, y, w, h));
          return p;
        }
        if (tag == 'circle') {
          final cx = toD(e.getAttribute('cx'));
          final cy = toD(e.getAttribute('cy'));
          final r  = toD(e.getAttribute('r'));
          if (r <= 0) return null;
          final p = Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
          return p;
        }
        if (tag == 'ellipse') {
          final cx = toD(e.getAttribute('cx'));
          final cy = toD(e.getAttribute('cy'));
          final rx = toD(e.getAttribute('rx'));
          final ry = toD(e.getAttribute('ry'));
          if (rx <= 0 || ry <= 0) return null;
          final p = Path()
            ..addOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2));
          return p;
        }
        if (tag == 'polygon' || tag == 'polyline') {
          final points = e.getAttribute('points');
          if (points == null) return null;
          final nums = points.trim().split(RegExp(r'[ ,]+')).map((s) => double.tryParse(s) ?? 0).toList();
          if (nums.length < 4) return null;
          final p = Path()..moveTo(nums[0], nums[1]);
          for (int i = 2; i + 1 < nums.length; i += 2) {
            p.lineTo(nums[i], nums[i + 1]);
          }
          if (tag == 'polygon') p.close();
          return p;
        }
        if (tag == 'g') {
          final p = Path();
          for (final child in e.children.whereType<xml.XmlElement>()) {
            final cp = pathFor(child);
            if (cp != null) p.addPath(cp, Offset.zero);
          }
          return p;
        }
        return null;
      }

      for (final e in doc.findAllElements('*')) {
        final id = e.getAttribute('id');
        if (id == null || !ids.contains(id)) continue;
        final p = pathFor(e);
        if (p == null) continue;
        final b = p.getBounds();
        _regionArea[id] = b.width * b.height;
      }
    } catch (e) {
      debugPrint('area compute failed: $e');
    }
  }

  // auto-fill any remaining tiny pieces for a selected color
  void _autofillTinyLeftovers(int colorId) {
    if (_currentSvgArt == null) return;

    final colorPalette = _currentSvgArt!.palette.firstWhere((p) => p.id == colorId);
    for (final r in _currentSvgArt!.regions) {
      if (r.colorNumber != colorId) continue;
      if (_filledRegions.containsKey(r.elementId)) continue;

      final area = _regionArea[r.elementId] ?? double.infinity;
      if (area <= _kAutoFillTinyArea) {
        _filledRegions[r.elementId] = colorPalette.color;
      }
    }
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

  String _rgbHex(Color color) {
    final int r = ((color.r * 255.0).round()) & 0xff;
    final int g = ((color.g * 255.0).round()) & 0xff;
    final int b = ((color.b * 255.0).round()) & 0xff;
    return '#'
        '${r.toRadixString(16).padLeft(2, "0")}'
        '${g.toRadixString(16).padLeft(2, "0")}'
        '${b.toRadixString(16).padLeft(2, "0")}'
        .toUpperCase();
  }

  Color? _parseStoredColor(dynamic value) {
    if (value == null) return null;
    if (value is int) return Color(value);

    final s = value.toString().trim();
    if (s.isEmpty) return null;

    if (s.startsWith('#')) {
      final hex = s.substring(1);
      if (hex.length == 6) {
        final rgb = int.tryParse(hex, radix: 16);
        if (rgb != null) return Color(0xFF000000 | rgb);
      }
      return null;
    }

    final asInt = int.tryParse(s);
    if (asInt != null) return Color(asInt);

    return null;
  }
}
