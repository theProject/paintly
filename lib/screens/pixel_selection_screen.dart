import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../models/pixel_art.dart';
import '../providers/settings_provider.dart';
import 'coloring_screen.dart';
import 'pixel_category_screen.dart';

class PixelSelectionScreen extends StatefulWidget {
  final PixelCategory category;

  const PixelSelectionScreen({super.key, required this.category});

  @override
  State<PixelSelectionScreen> createState() => _PixelSelectionScreenState();
}

class _PixelSelectionScreenState extends State<PixelSelectionScreen> {
  List<PixelArt> coloringPages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadColoringPages();
  }

  Future<void> loadColoringPages() async {
    try {
      List<PixelArt> loadedPages = [];

      // Load only the pixel arts that belong to this category
      for (String artName in widget.category.pixelArts) {
        try {
          final String jsonString = await rootBundle.loadString('assets/data/$artName.json');
          debugPrint('Loading $artName.json: $jsonString'); // Debug line
          final dynamic jsonData = json.decode(jsonString);
          
          // Ensure jsonData is a Map
          if (jsonData is Map<String, dynamic>) {
            final PixelArt pixelArt = PixelArt.fromJson(jsonData);
            loadedPages.add(pixelArt);
          } else {
            debugPrint('Error: $artName.json is not a valid JSON object');
          }
        } catch (e) {
          debugPrint('Error loading $artName.json: $e');
        }
      }

      setState(() {
        coloringPages = loadedPages;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading coloring pages: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(widget.category.icon, color: widget.category.color, size: 28),
            const SizedBox(width: 8),
            Text(
              widget.category.name,
              style: TextStyle(
                color: widget.category.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
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
              itemCount: coloringPages.length,
              itemBuilder: (context, index) {
                return FadeInUp(
                  delay: Duration(milliseconds: index * 50),
                  child: _buildPixelArtCard(coloringPages[index]),
                );
              },
            ),
    );
  }

  Widget _buildPixelArtCard(PixelArt pixelArt) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.read<SettingsProvider>().playSound('tap.mp3');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ColoringScreen(pixelArt: pixelArt),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            // UPDATED: Replaced deprecated .withOpacity()
            color: widget.category.color.withAlpha(51), // 0.2 opacity
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              // UPDATED: Replaced deprecated .withOpacity()
              color: widget.category.color.withAlpha(26), // 0.1 opacity
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
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
                  child: _buildPixelPreview(pixelArt),
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
              Text(
                '${pixelArt.palette.length} colors',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPixelPreview(PixelArt pixelArt) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = constraints.maxWidth / pixelArt.width;
        final displayHeight = cellSize * pixelArt.height;
        
        if (displayHeight > constraints.maxHeight) {
          final scale = constraints.maxHeight / displayHeight;
          return Transform.scale(
            scale: scale,
            child: _buildPixelGrid(pixelArt, cellSize),
          );
        }
        
        return Center(
          child: _buildPixelGrid(pixelArt, cellSize),
        );
      },
    );
  }

  Widget _buildPixelGrid(PixelArt pixelArt, double cellSize) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(pixelArt.height, (row) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(pixelArt.width, (col) {
            final pixelNumber = pixelArt.pixels[row][col];
            if (pixelNumber == 0) {
              // UPDATED: Used SizedBox for whitespace instead of Container
              return SizedBox(
                width: cellSize,
                height: cellSize,
              );
            }
            
            return Container(
              width: cellSize,
              height: cellSize,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                border: Border.all(
                  color: Colors.grey[400]!,
                  width: 0.5,
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}