import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pixel_art.dart';
import '../providers/coloring_provider.dart';
import '../widgets/pixel_grid_widget.dart';
import '../widgets/color_palette_widget.dart';

class ColoringScreen extends StatefulWidget {
  final PixelArt pixelArt;

  const ColoringScreen({super.key, required this.pixelArt});

  @override
  State<ColoringScreen> createState() => _ColoringScreenState();
}

class _ColoringScreenState extends State<ColoringScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize the coloring provider with the selected pixel art
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ColoringProvider>().initializePixelArt(widget.pixelArt);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: Colors.blue),
            onPressed: () {
              // Handle completion check
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Main canvas area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    // Updated to use withValues
                    color: Colors.grey.withValues(alpha: 0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Consumer<ColoringProvider>(
                  builder: (context, provider, child) {
                    if (!provider.isInitialized) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 10.0,
                      boundaryMargin: const EdgeInsets.all(100),
                      child: Center(
                        child: PixelGridWidget(
                          pixelArt: widget.pixelArt,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Color palette
          const ColorPaletteWidget(),
        ],
      ),
    );
  }
}