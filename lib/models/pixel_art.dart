import 'dart:ui';

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

  /// Convert PixelArt to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'asset_path': assetPath,
      'width': width,
      'height': height,
      'palette': palette.map((p) => p.toJson()).toList(),
      'pixels': pixels,
    };
  }
}

/// Model class for color palette items
class ColorPalette {
  final int id;
  final Color color;

  ColorPalette({required this.id, required this.color});

  /// Factory constructor to create ColorPalette from JSON
  factory ColorPalette.fromJson(Map<String, dynamic> json) {
    return ColorPalette(
      id: json['id'],
      color: Color(int.parse(json['color'])),
    );
  }

  /// Convert ColorPalette to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'color': '0x${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
    };
  }
}