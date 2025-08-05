import 'dart:ui'; // for ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart'; // <-- Add this import
import '../models/pixel_art.dart';
import '../providers/coloring_provider.dart'; // <-- Add this import
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadColoringPages();
  }

  Future<void> loadColoringPages() async {
    setState(() {
      isLoading = true;
    });
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/pixel_art.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      final List<PixelArt> loadedPages =
          jsonList.map((json) => PixelArt.fromJson(json)).toList();

      if (mounted) {
        setState(() {
          coloringPages = loadedPages;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading or parsing pixel_art.json: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
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
            // ================== THIS IS THE FIX ==================
            builder: (context) => ChangeNotifierProvider(
              create: (_) => ColoringProvider(), // Creates a new provider for this screen
              child: ColoringScreen(pixelArt: pixelArt),
            ),
            // =====================================================
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13), // 0.05 opacity
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withAlpha(26), // 0.1 opacity
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
                      .withAlpha(26), // 0.1 opacity
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
                            final double cellWidth =
                                constraints.maxWidth / pixelArt.width;
                            final double cellHeight =
                                constraints.maxHeight / pixelArt.height;
                            final double cellSize =
                                cellWidth < cellHeight ? cellWidth : cellHeight;

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

    final bool hasProgress =
        progress != null && progress!['coloredPixels'] != null;
    final List<List<int>> pixelData = hasProgress
        ? (progress!['coloredPixels'] as List)
            .map((row) => List<int>.from(row))
            .toList()
        : pixelArt.pixels;

    final List<Color> colors = pixelArt.colorPalette;

    final totalArtWidth = pixelArt.width * cellSize;
    final totalArtHeight = pixelArt.height * cellSize;
    final offsetX = (size.width - totalArtWidth) / 2;
    final offsetY = (size.height - totalArtHeight) / 2;

    canvas.translate(offsetX, offsetY);

    for (int y = 0; y < pixelArt.height; y++) {
      for (int x = 0; x < pixelArt.width; x++) {
        final int colorIndex = pixelData[y][x];

        if (colorIndex > 0 && colorIndex <= colors.length) {
          paint.color = colors[colorIndex - 1];
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