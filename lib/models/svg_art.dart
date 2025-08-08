// lib/models/svg_art.dart
import 'dart:ui';

/// Model class representing an SVG paint-by-number art piece
class SvgArt {
  final String name;
  final String svgPath;
  final String? svgContent;
  final List<SvgColorPalette> palette;
  final List<SvgRegion> regions;

  SvgArt({
    required this.name,
    required this.svgPath,
    this.svgContent,
    required this.palette,
    required this.regions,
  });
}

/// Model class for SVG color palette items
class SvgColorPalette {
  final int id;
  final Color color;
  final String name;

  SvgColorPalette({
    required this.id,
    required this.color,
    required this.name,
  });
}

/// Model class for SVG regions to be colored
class SvgRegion {
  final String elementId; // SVG element ID
  final int colorNumber;  // Number shown in the region
  final Rect? bounds;     // Optional bounds for tap detection

  SvgRegion({
    required this.elementId,
    required this.colorNumber,
    this.bounds,
  });
}

