import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../providers/settings_provider.dart';
import 'magic_mode_screen.dart';
import '../../magic/';

class MagicCategoryScreen extends StatefulWidget {
  final MagicCategory category;

  const MagicCategoryScreen({
    super.key,
    required this.category,
  });

  @override
  State<MagicCategoryScreen> createState() => _MagicCategoryScreenState();
}

class _MagicCategoryScreenState extends State<MagicCategoryScreen> {
  late List<MagicObject> objects;

  @override
  void initState() {
    super.initState();
    _loadCategoryObjects();
  }

  void _loadCategoryObjects() {
    // Define objects for each category
    switch (widget.category.id) {
      case 'farm':
        objects = [
          MagicObject(
            id: 'chicken',
            name: 'Chicken',
            svgPath: 'assets/svg/magic/farm/chicken.svg',
            previewIcon: '🐔',
            predefinedColors: {
              'body': const Color(0xFFFFE5B4),
              'beak': const Color(0xFFFFA500),
              'legs': const Color(0xFFFF8C00),
              'eye': const Color(0xFF000000),
              'comb': const Color(0xFFDC143C),
            },
            customizableRegions: {
              'feathers': [
                const Color(0xFFFFE5B4),
                const Color(0xFFF5DEB3),
                const Color(0xFFFFDAB9),
                const Color(0xFFFFE4E1),
                const Color(0xFFFFF0F5),
              ],
              'tail': [
                const Color(0xFF8B4513),
                const Color(0xFFA0522D),
                const Color(0xFFCD853F),
              ],
            },
          ),
          MagicObject(
            id: 'cow',
            name: 'Cow',
            svgPath: 'assets/svg/magic/farm/cow.svg',
            previewIcon: '🐄',
            predefinedColors: {
              'body': const Color(0xFFF5F5DC),
              'spots': const Color(0xFF000000),
              'nose': const Color(0xFFFFB6C1),
              'hooves': const Color(0xFF2F4F4F),
            },
            customizableRegions: {
              'body_main': [
                const Color(0xFFF5F5DC),
                const Color(0xFF8B4513),
                const Color(0xFFD2691E),
                const Color(0xFF000000),
              ],
            },
          ),
          MagicObject(
            id: 'pig',
            name: 'Pig',
            svgPath: 'assets/svg/magic/farm/pig.svg',
            previewIcon: '🐷',
          ),
          MagicObject(
            id: 'farmer',
            name: 'Farmer',
            svgPath: 'assets/svg/magic/farm/farmer.svg',
            previewIcon: '👨‍🌾',
          ),
        ];
        break;
      default:
        objects = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with back button
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category.name,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: widget.category.color,
                              ),
                        ),
                        Text(
                          'Choose what to color!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Objects Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: objects.length,
              itemBuilder: (context, index) {
                return FadeInUp(
                  delay: Duration(milliseconds: index * 100),
                  child: _buildObjectCard(objects[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectCard(MagicObject object) {
    return FutureBuilder<bool>(
      future: _isObjectCompleted(object.id),
      builder: (context, snapshot) {
        final isCompleted = snapshot.data ?? false;
        
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.read<SettingsProvider>().playSound('audio/bubbletap.wav');
            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MagicColoringScreen(
                  object: object,
                  category: widget.category,
                  isCustomizing: isCompleted,
                ),
              ),
            ).then((_) => setState(() {})); // Refresh on return
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 0.5,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isCompleted 
                                      ? widget.category.color.withValues(alpha: 0.1)
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isCompleted 
                                        ? widget.category.color.withValues(alpha: 0.3)
                                        : Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: isCompleted
                                      ? FutureBuilder<String?>(
                                          future: _loadColoredSvg(object.id),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              // In a real app, render the colored SVG
                                              // For now, show a colored version
                                              return Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    object.previewIcon,
                                                    style: const TextStyle(fontSize: 48),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green.withValues(alpha: 0.2),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: const Text(
                                                      'Completed!',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                            return Text(
                                              object.previewIcon,
                                              style: const TextStyle(fontSize: 48),
                                            );
                                          },
                                        )
                                      : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.brush_rounded,
                                              size: 32,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Tap to color',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              object.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      
                      // Customize button for completed objects
                      if (isCompleted)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MagicColoringScreen(
                                      object: object,
                                      category: widget.category,
                                      isCustomizing: true,
                                    ),
                                  ),
                                ).then((_) => setState(() {}));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: widget.category.color,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.category.color.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _isObjectCompleted(String objectId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('magic_completed_${widget.category.id}_$objectId') ?? false;
  }

  Future<String?> _loadColoredSvg(String objectId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('magic_svg_${widget.category.id}_$objectId');
  }
}

// Data model for magic objects
class MagicObject {
  final String id;
  final String name;
  final String svgPath;
  final String previewIcon;
  final Map<String, Color> predefinedColors;
  final Map<String, List<Color>> customizableRegions;

  MagicObject({
    required this.id,
    required this.name,
    required this.svgPath,
    required this.previewIcon,
    this.predefinedColors = const {},
    this.customizableRegions = const {},
  });
}