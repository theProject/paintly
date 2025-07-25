import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../models/pixel_art.dart';

class ImageProcessor {
  static const int defaultPixelSize = 32; // Target size for pixel art
  static const int maxColors = 10; // Maximum number of colors in palette

  /// Process an image file and convert it to pixel art
  static Future<PixelArt?> processImage(File imageFile, String name) async {
    try {
      // Read and decode the image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return null;

      // Resize image to pixel art dimensions
      final resized = _resizeImage(image, defaultPixelSize);
      
      // Apply edge detection for better regions
      final processed = _preprocessImage(resized);
      
      // Extract color palette using k-means clustering
      final palette = _extractPalette(processed, maxColors);
      
      // Create pixel grid with numbered regions
      final pixelGrid = _createPixelGrid(processed, palette);
      
      // Create PixelArt object
      return PixelArt(
        name: name,
        assetPath: '', // No asset path for user-generated images
        width: resized.width,
        height: resized.height,
        palette: palette,
        pixels: pixelGrid,
      );
    } catch (e) {
      debugPrint('Error processing image: $e');
      return null;
    }
  }

  /// Resize image maintaining aspect ratio
  static img.Image _resizeImage(img.Image image, int targetSize) {
    final aspectRatio = image.width / image.height;
    int newWidth, newHeight;
    
    if (aspectRatio > 1) {
      newWidth = targetSize;
      newHeight = (targetSize / aspectRatio).round();
    } else {
      newHeight = targetSize;
      newWidth = (targetSize * aspectRatio).round();
    }
    
    return img.copyResize(image, width: newWidth, height: newHeight);
  }

  /// Preprocess image to enhance edges and simplify colors
  static img.Image _preprocessImage(img.Image image) {
    // Apply slight blur to reduce noise
    var processed = img.gaussianBlur(image, radius: 1);
    
    // Increase contrast
    processed = img.adjustColor(processed, contrast: 1.2);
    
    // Reduce colors for better segmentation
    processed = img.quantize(processed, numberOfColors: 64);
    
    return processed;
  }

  /// Extract color palette using k-means clustering
  static List<ColorPalette> _extractPalette(img.Image image, int numColors) {
    // Collect all unique colors
    final colorCounts = <int, int>{};
    
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final color = _pixelToInt(pixel);
        colorCounts[color] = (colorCounts[color] ?? 0) + 1;
      }
    }
    
    // Sort colors by frequency
    final sortedColors = colorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // K-means clustering for color reduction
    final dominantColors = _kMeansClustering(
      sortedColors.map((e) => e.key).take(numColors * 3).toList(),
      numColors,
    );
    
    // Create palette
    final palette = <ColorPalette>[];
    for (int i = 0; i < dominantColors.length; i++) {
      // Skip colors that are too similar to white (background)
      final color = Color(dominantColors[i]);
      if (_getColorBrightness(color) > 0.95) continue;
      
      palette.add(ColorPalette(
        id: palette.length + 1,
        color: color,
      ));
    }
    
    // Ensure we have at least 2 colors
    if (palette.length < 2) {
      palette.add(ColorPalette(id: palette.length + 1, color: Colors.grey));
    }
    
    return palette;
  }

  /// Simple k-means clustering for color reduction
  static List<int> _kMeansClustering(List<int> colors, int k) {
    if (colors.length <= k) return colors;
    
    // Initialize centroids randomly
    final random = Random();
    final centroids = <int>[];
    final usedIndices = <int>{};
    
    while (centroids.length < k && centroids.length < colors.length) {
      final index = random.nextInt(colors.length);
      if (!usedIndices.contains(index)) {
        centroids.add(colors[index]);
        usedIndices.add(index);
      }
    }
    
    // Iterate to find optimal centroids
    for (int iteration = 0; iteration < 10; iteration++) {
      final clusters = List.generate(k, (_) => <int>[]);
      
      // Assign colors to nearest centroid
      for (final color in colors) {
        int nearestIndex = 0;
        double minDistance = double.infinity;
        
        for (int i = 0; i < centroids.length; i++) {
          final distance = _colorDistance(color, centroids[i]);
          if (distance < minDistance) {
            minDistance = distance;
            nearestIndex = i;
          }
        }
        
        clusters[nearestIndex].add(color);
      }
      
      // Update centroids
      for (int i = 0; i < centroids.length; i++) {
        if (clusters[i].isNotEmpty) {
          centroids[i] = _averageColor(clusters[i]);
        }
      }
    }
    
    return centroids;
  }

  /// Calculate distance between two colors
  static double _colorDistance(int color1, int color2) {
    final c1 = Color(color1);
    final c2 = Color(color2);
    
    final dr = ((c1.r * 255).round() & 0xff) - ((c2.r * 255).round() & 0xff);
    final dg = ((c1.g * 255).round() & 0xff) - ((c2.g * 255).round() & 0xff);
    final db = ((c1.b * 255).round() & 0xff) - ((c2.b * 255).round() & 0xff);
    
    return sqrt(dr * dr + dg * dg + db * db);
  }

  /// Calculate average color from a list
  static int _averageColor(List<int> colors) {
    if (colors.isEmpty) return 0;
    
    int totalR = 0, totalG = 0, totalB = 0;
    
    for (final color in colors) {
      final c = Color(color);
      totalR += (c.r * 255).round() & 0xff;
      totalG += (c.g * 255).round() & 0xff;
      totalB += (c.b * 255).round() & 0xff;
    }
    
    final count = colors.length;
    return Color.fromARGB(
      255,
      (totalR / count).round(),
      (totalG / count).round(),
      (totalB / count).round(),
    ).toARGB32();
  }

  /// Get brightness of a color (0-1)
  static double _getColorBrightness(Color color) {
    final r = (color.r * 255).round() & 0xff;
    final g = (color.g * 255).round() & 0xff;
    final b = (color.b * 255).round() & 0xff;
    return (r * 299 + g * 587 + b * 114) / 255000;
  }

  /// Create numbered pixel grid
  static List<List<int>> _createPixelGrid(
    img.Image image,
    List<ColorPalette> palette,
  ) {
    final grid = List.generate(
      image.height,
      (_) => List.filled(image.width, 0),
    );
    
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final color = _pixelToInt(pixel);
        
        // Skip very bright pixels (background)
        if (_getColorBrightness(Color(color)) > 0.95) {
          grid[y][x] = 0;
          continue;
        }
        
        // Find nearest color in palette
        int nearestId = 1;
        double minDistance = double.infinity;
        
        for (final paletteColor in palette) {
          final distance = _colorDistance(color, paletteColor.color.toARGB32());
          if (distance < minDistance) {
            minDistance = distance;
            nearestId = paletteColor.id;
          }
        }
        
        grid[y][x] = nearestId;
      }
    }
    
    // Apply edge smoothing
    return _smoothEdges(grid);
  }

  /// Convert image pixel to int color
  static int _pixelToInt(img.Pixel pixel) {
    return Color.fromARGB(
      255,
      pixel.r.toInt(),
      pixel.g.toInt(),
      pixel.b.toInt(),
    ).toARGB32();
  }

  /// Smooth edges by removing isolated pixels
  static List<List<int>> _smoothEdges(List<List<int>> grid) {
    final height = grid.length;
    final width = grid[0].length;
    final smoothed = List.generate(
      height,
      (y) => List<int>.from(grid[y]),
    );
    
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        final current = grid[y][x];
        if (current == 0) continue;
        
        // Count neighbors with same color
        int sameColorCount = 0;
        final neighbors = [
          grid[y - 1][x],
          grid[y + 1][x],
          grid[y][x - 1],
          grid[y][x + 1],
        ];
        
        for (final neighbor in neighbors) {
          if (neighbor == current) sameColorCount++;
        }
        
        // Remove isolated pixels
        if (sameColorCount < 2) {
          // Find most common neighbor color
          final colorCounts = <int, int>{};
          for (final neighbor in neighbors) {
            if (neighbor != 0) {
              colorCounts[neighbor] = (colorCounts[neighbor] ?? 0) + 1;
            }
          }
          
          if (colorCounts.isNotEmpty) {
            final mostCommon = colorCounts.entries
                .reduce((a, b) => a.value > b.value ? a : b)
                .key;
            smoothed[y][x] = mostCommon;
          }
        }
      }
    }
    
    return smoothed;
  }
}