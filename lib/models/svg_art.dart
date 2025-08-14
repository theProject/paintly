// Updated lib/models/svg_art.dart

import 'dart:ui';

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

class SvgRegion {
  final String elementId;
  final int colorNumber;
  final Offset? position; // Position for the number label

  SvgRegion({
    required this.elementId,
    required this.colorNumber,
    this.position,
  });
}

