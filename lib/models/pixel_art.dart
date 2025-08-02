import 'package:flutter/material.dart';

/// Model class representing a pixel art coloring page
class PixelArt {
  final String name;
  final String assetPath;
  final int width;
  final int height;
  final List<ColorPalette> palette;
  final List<List<int>> pixels;

  PixelArt({
    required this.name,
    required this.assetPath,
    required this.width,
    required this.height,
    required this.palette,
    required this.pixels,
  });

  /// A convenient getter to convert the [palette] into a simple List<Color>
  /// that is correctly indexed for the painter.
  List<Color> get colorPalette {
    // Create a map of ID -> Color for efficient lookup.
    final Map<int, Color> colorMap = { for (var p in palette) p.id : p.color };
    // Find the highest ID to determine the size of our color list.
    int maxId = 0;
    if (palette.isNotEmpty) {
      maxId = palette.map((p) => p.id).reduce((a, b) => a > b ? a : b);
    }
    // Generate a list where the index matches the color ID.
    // If an ID is missing (e.g., jumps from 2 to 4), fill with transparent.
    return List.generate(maxId + 1, (index) {
        return colorMap[index] ?? Colors.transparent;
    });
  }


  /// Factory constructor to create PixelArt from JSON
  factory PixelArt.fromJson(Map<String, dynamic> json) {
    return PixelArt(
      name: json['name'],
      assetPath: json['asset_path'],
      width: json['width'],
      height: json['height'],
      palette: (json['palette'] as List)
          .map((p) => ColorPalette.fromJson(p))
          .toList(),
      pixels: (json['pixels'] as List)
          .map((row) => (row as List).map((pixel) => pixel as int).toList())
          .toList(),
    );
  }
}

/// Model class for color palette items
class ColorPalette {
  final int id;
  final Color color;

  ColorPalette({required this.id, required this.color});

  /// Factory constructor to create ColorPalette from JSON
  factory ColorPalette.fromJson(Map<String, dynamic> json) {
    String colorString = json['color'] as String;
    // **FIXED**: Properly parse hex strings with '0x' prefix
    if (colorString.startsWith('0x')) {
      colorString = colorString.substring(2);
    }
    return ColorPalette(
      id: json['id'],
      color: Color(int.parse(colorString, radix: 16)),
    );
  }

  /// Convert ColorPalette to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // Ensure the output format matches what the fixed fromJson expects
      'color': '0x${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
    };
  }
}