 import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import '../models/pixel_art.dart';
import 'coloring_screen.dart';
import 'import_image_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PixelArt> coloringPages = [];
  int selectedTab = 0;

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    child: Text(
                      '🎨 TasaiYsume',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      'Winnie and Aeris and the Magical Paintbrush',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // Category Tabs (fixed and polished)
            SizedBox(
              height: 64, // ensures room for bounce, no overflow
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildTab('All', 0, Icons.grid_view_rounded),
                  _buildTab('Animals', 1, Icons.pets_rounded),
                  _buildTab('Nature', 2, Icons.local_florist_rounded),
                  _buildTab('Objects', 3, Icons.category_rounded),
                  _buildTab('Shapes', 4, Icons.star_rounded),
                ],
              ),
            ),
            const SizedBox(height: 50),

            // Grid of coloring pages
            Expanded(
              child: GridView.builder(
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
                    child: _buildColoringPageTile(coloringPages[index], index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ImportImageScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_photo_alternate_rounded),
        label: const Text('Import Photo'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Bulletproof category tab builder (no yellow tape or overflow)
  Widget _buildTab(String label, int index, IconData icon) {
    final isSelected = selectedTab == index;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => selectedTab = index);
          },
          child: SizedBox(
            height: 56, // fixes RenderFlex overflow
            child: Align(
              alignment: Alignment.center,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack, // smooth expressive bounce
                scale: isSelected ? 1.1 : 1.0,
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 48,
                    minWidth: 48,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 20 : 16,
                    vertical: 8, // reduced to avoid scaling overflow
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.black.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        color: isSelected
                            ? Colors.white
                            : colorScheme.onSurface,
                        size: 22,
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: [
                colorScheme.primary,
                colorScheme.secondary,
                colorScheme.tertiary,
                const Color(0xFF9DDAC8),
                const Color(0xFF8B96A9),
              ][index % 5].withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
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
    );
  }
}