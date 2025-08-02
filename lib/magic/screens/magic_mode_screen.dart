// lib/magic/screens/magic_mode_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import 'magic_category_screen.dart';

// alias your data-only class so its MagicCategory (with a single .color) doesn't clash
import '../data/magic_categories.dart' as data;
// import the UI model types you actually want everywhere else
import '../models/magic_models.dart' show MagicCategory, MagicActivity;

class MagicModeScreen extends StatefulWidget {
  const MagicModeScreen({super.key});

  @override
  State<MagicModeScreen> createState() => _MagicModeScreenState();
}

class _MagicModeScreenState extends State<MagicModeScreen> {
  // Grab the raw list and convert into your model MagicCategory
  final List<MagicCategory> categories = data.MagicCategories
      .getAllCategories()
      .map((d) => MagicCategory(
            id: d.id,
            name: d.name,
            description: d.description,
            icon: d.icon,
            // migrate .withOpacity to .withValues(alpha: …)
            primaryColor: d.color,
            secondaryColor: d.color.withValues(alpha: 0.6),
            backgroundColor: d.color.withValues(alpha: 0.1),
            activities: <MagicActivity>[],
          ))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: FadeInDown(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_fix_high_rounded,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Magic Mode',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a magical world to color!',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),

          // Category Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                childAspectRatio: 1.1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return FadeInUp(
                  delay: Duration(milliseconds: index * 100),
                  child: _buildCategoryCard(categories[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(MagicCategory category) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.read<SettingsProvider>().playSound('bubbletap.wav');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MagicCategoryScreen(category: category),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  category.primaryColor.withValues(alpha: 0.1),
                  category.primaryColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: category.primaryColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: category.backgroundColor,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.read<SettingsProvider>().playSound('bubbletap.wav');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MagicCategoryScreen(category: category),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: category.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            category.icon,
                            size: 48,
                            color: category.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          category.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: category.primaryColor,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category.description,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
