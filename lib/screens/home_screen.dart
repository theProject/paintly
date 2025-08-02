// ignore_for_file: deprecated_member_use

import 'dart:ui'; // for ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import '../models/pixel_art.dart';
import 'coloring_screen.dart';

class HomeScreen extends StatefulWidget {
  final int? selectedTab;
  final VoidCallback? onTabChanged;

  const HomeScreen({
    super.key,
    this.selectedTab,
    this.onTabChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PixelArt> coloringPages = [];

  @override
  void initState() {
    super.initState();
    loadColoringPages();
  }

  Future<void> loadColoringPages() async {
    try {
      final List<String> jsonFiles = [
        'assets/data/heart.json',
        'assets/data/cat.json',
        'assets/data/flower.json',
        'assets/data/house.json',
        'assets/data/star.json',
        'assets/data/butterfly.json',
        'assets/data/tree.json',
        'assets/data/rainbow.json',
        'assets/data/smiley.json',
      ];

      List<PixelArt> loadedPages = [];

      for (String jsonFile in jsonFiles) {
        try {
          final String jsonString = await rootBundle.loadString(jsonFile);
          final Map<String, dynamic> jsonData = json.decode(jsonString);
          // Now using your actual PixelArt.fromJson constructor
          final List<dynamic> arts = jsonData['pixel_arts'];
          for (var artJson in arts) {
            final PixelArt pixelArt = PixelArt.fromJson(artJson);
            loadedPages.add(pixelArt);
          }
        } catch (e) {
          debugPrint('Error loading or parsing $jsonFile: $e');
        }
      }

      if (mounted) {
        setState(() {
          coloringPages = loadedPages;
        });
      }
    } catch (e) {
      debugPrint('Error loading coloring pages manifest: $e');
    }
  }

  List<PixelArt> get filteredPages {
    if (widget.selectedTab == null || widget.selectedTab == 0) {
      return coloringPages;
    }
    return coloringPages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredPages.length,
        itemBuilder: (context, index) {
          return FadeInUp(
            delay: Duration(milliseconds: index * 50),
            child: _buildColoringPageTile(filteredPages[index], index),
          );
        },
      ),
    );
  }

  Widget _buildColoringPageTile(PixelArt pixelArt, int index) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ColoringScreen(pixelArt: pixelArt),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: [
                    colorScheme.primary,
                    colorScheme.secondary,
                    colorScheme.secondaryContainer,
                    const Color(0xFF9DDAC8),
                    const Color(0xFF8B96A9),
                  ][index % 5]
                      .withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // **FIXED**: Use width and height from your model
                            final double cellWidth = constraints.maxWidth / pixelArt.width;
                            final double cellHeight = constraints.maxHeight / pixelArt.height;
                            final double cellSize = cellWidth < cellHeight ? cellWidth : cellHeight;

                            return CustomPaint(
                              painter: PixelArtPreviewPainter(
                                pixelArt: pixelArt,
                                cellSize: cellSize,
                              ),
                              size: Size.infinite,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      pixelArt.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PixelArtPreviewPainter extends CustomPainter {
  final PixelArt pixelArt;
  final double cellSize;
  final Map<String, dynamic>? progress;

  PixelArtPreviewPainter({
    required this.pixelArt,
    required this.cellSize,
    this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    final bool hasProgress = progress != null && progress!['coloredPixels'] != null;
    final List<List<int>> pixelData = hasProgress
        ? (progress!['coloredPixels'] as List)
            .map((row) => List<int>.from(row))
            .toList()
        : pixelArt.pixels;

    final List<Color> colors = pixelArt.colorPalette;

    // Center the artwork
    final totalArtWidth = pixelArt.width * cellSize;
    final totalArtHeight = pixelArt.height * cellSize;
    final offsetX = (size.width - totalArtWidth) / 2;
    final offsetY = (size.height - totalArtHeight) / 2;

    canvas.translate(offsetX, offsetY);

    // Draw the pixel art
    for (int y = 0; y < pixelArt.height; y++) {
      for (int x = 0; x < pixelArt.width; x++) {
        final int colorIndex = pixelData[y][x];

        if (colorIndex > 0 && colorIndex < colors.length) {
          paint.color = colors[colorIndex];
        } else {
          paint.color = Colors.grey[200]!;
        }
        
        canvas.drawRect(
          Rect.fromLTWH(
            x * cellSize,
            y * cellSize,
            cellSize,
            cellSize,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant PixelArtPreviewPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.pixelArt != pixelArt;
}