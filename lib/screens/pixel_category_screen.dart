import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'pixel_selection_screen.dart';

class PixelCategoryScreen extends StatelessWidget {
  const PixelCategoryScreen({super.key});

  final List<PixelCategory> categories = const [
    PixelCategory(
      id: 'ocean',
      name: 'Ocean',
      icon: Icons.water,
      color: Colors.blue,
      pixelArts: ['star', 'heart', 'smiley'], // These will be filtered by category
    ),
    PixelCategory(
      id: 'farm',
      name: 'Farm',
      icon: Icons.agriculture,
      color: Colors.green,
      pixelArts: ['house', 'tree', 'flower'],
    ),
    PixelCategory(
      id: 'city',
      name: 'City',
      icon: Icons.location_city,
      color: Colors.grey,
      pixelArts: ['house', 'tree'],
    ),
    PixelCategory(
      id: 'characters',
      name: 'Characters',
      icon: Icons.face,
      color: Colors.orange,
      pixelArts: ['cat', 'butterfly', 'smiley'],
    ),
    PixelCategory(
      id: 'nature',
      name: 'Nature',
      icon: Icons.park,
      color: Colors.teal,
      pixelArts: ['flower', 'tree', 'butterfly', 'rainbow'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 1.0,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return FadeInUp(
            delay: Duration(milliseconds: index * 100),
            child: _buildCategoryCard(context, category),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, PixelCategory category) {
    // Pre-calculate alpha variants to avoid repeated math
    final borderAlpha = (0.3 * 255).round();
    final shadowAlpha = (0.2 * 255).round();
    final bgAlpha = (0.1 * 255).round();

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.read<SettingsProvider>().playSound('tap.mp3');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PixelSelectionScreen(category: category),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: category.color.withAlpha(borderAlpha),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: category.color.withAlpha(shadowAlpha),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: category.color.withAlpha(bgAlpha),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                size: 48,
                color: category.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              category.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: category.color,
                  ),
            ),
            Text(
              '${category.pixelArts.length} designs',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PixelCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<String> pixelArts;

  const PixelCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.pixelArts,
  });
}
