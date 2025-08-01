import 'dart:ui'; // for ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
          final PixelArt pixelArt = PixelArt.fromJson(jsonData);
          loadedPages.add(pixelArt);
        } catch (e) {
          debugPrint('Error loading $jsonFile: $e');
        }
      }

      setState(() {
        coloringPages = loadedPages;
      });
    } catch (e) {
      debugPrint('Error loading coloring pages: $e');
    }
  }

  // Filter pages based on selected tab
  List<PixelArt> get filteredPages {
    if (widget.selectedTab == null || widget.selectedTab == 0) {
      return coloringPages; // All
    }
    
    // You'll need to add a category property to your PixelArt model
    // For now, returning all pages
    return coloringPages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent to show background
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
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Reduced from 10
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05), // Reduced from 0.15 to 5%
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1), // Reduced from 0.2
                width: 0.5, // Thinner border
              ),
              boxShadow: [
                BoxShadow(
                  color: [
                    colorScheme.primary,
                    colorScheme.secondary,
                    colorScheme.tertiary,
                    const Color(0xFF9DDAC8),
                    const Color(0xFF8B96A9),
                  ][index % 5].withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(2), // Small margin to see glass edge
              decoration: BoxDecoration(
                color: Colors.white, // Inner white container
                borderRadius: BorderRadius.circular(22),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.grid_on_rounded,
                            size: 48,
                            color: Colors.grey[400],
                          ),
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

// Custom painter to render pixel art preview with progress
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
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Get color data from progress or use defaults
    final List<List<int>>? coloredPixels = progress?['coloredPixels'];

    // Draw background grid
    paint.color = Colors.grey[100]!;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw colored pixels
    for (int y = 0; y < pixelArt.gridSize; y++) {
      for (int x = 0; x < pixelArt.gridSize; x++) {
        final colorIndex = pixelArt.pixels[y][x];
        if (colorIndex > 0) {
          // Check if this pixel has been colored
          final isColored = coloredPixels != null && 
                           coloredPixels[y][x] > 0;
          
          if (isColored) {
            // Use the actual color from progress
            paint.color = pixelArt.colorPalette[coloredPixels[y][x]];
          } else {
            // Show as outline/grey for uncolored
            paint.color = Colors.grey[300]!;
          }
          
          canvas.drawRect(
            Rect.fromLTWH(
              x * cellSize,
              y * cellSize,
              cellSize - 0.5, // Small gap for grid effect
              cellSize - 0.5,
            ),
            paint,
          );
        }
      }
    }
    
    // Draw subtle grid lines
    paint.color = Colors.grey.withValues(alpha: 0.1);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 0.5;
    
    for (int i = 0; i <= pixelArt.gridSize; i++) {
      // Vertical lines
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, size.height),
        paint,
      );
      // Horizontal lines
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(size.width, i * cellSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PixelArtPreviewPainter oldDelegate) => 
      oldDelegate.progress != progress;
}