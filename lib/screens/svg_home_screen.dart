// 1. lib/screens/svg_home_screen.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../models/svg_art.dart';
import 'svg_coloring_screen.dart';
import '../providers/settings_provider.dart';
import 'package:provider/provider.dart';

class SvgHomeScreen extends StatelessWidget {
  const SvgHomeScreen({super.key});

  static List<SvgArt> getSvgArtPieces() {
    return [
      SvgArt(
        name: 'Butterfly Garden',
        svgPath: 'assets/svg/butterfly_coloring.svg',
        palette: [
          SvgColorPalette(id: 1, color: Colors.purple, name: 'Purple'),
          SvgColorPalette(id: 2, color: Colors.pink, name: 'Pink'),
          SvgColorPalette(id: 3, color: Colors.brown, name: 'Brown'),
          SvgColorPalette(id: 4, color: Colors.yellow, name: 'Yellow'),
        ],
        regions: [
          SvgRegion(elementId: 'wing_ul_1', colorNumber: 1),
          SvgRegion(elementId: 'wing_ur_1', colorNumber: 1),
          SvgRegion(elementId: 'wing_ll_2', colorNumber: 2),
          SvgRegion(elementId: 'wing_lr_2', colorNumber: 2),
          SvgRegion(elementId: 'body_3', colorNumber: 3),
          SvgRegion(elementId: 'spot1_4', colorNumber: 4),
          SvgRegion(elementId: 'spot2_4', colorNumber: 4),
          SvgRegion(elementId: 'spot3_4', colorNumber: 4),
          SvgRegion(elementId: 'spot4_4', colorNumber: 4),
        ],
      ),
      SvgArt(
        name: 'Flower Garden',
        svgPath: 'assets/svg/flower_garden.svg',
        palette: [
          SvgColorPalette(id: 1, color: Colors.yellow, name: 'Sun'),
          SvgColorPalette(id: 2, color: Colors.orange, name: 'Rays'),
          SvgColorPalette(id: 3, color: Colors.red, name: 'Red Petals'),
          SvgColorPalette(id: 4, color: Colors.yellow, name: 'Center'),
          SvgColorPalette(id: 5, color: Colors.purple, name: 'Purple'),
          SvgColorPalette(id: 6, color: Colors.pink, name: 'Pink'),
          SvgColorPalette(id: 7, color: Colors.blue, name: 'Blue'),
          SvgColorPalette(id: 8, color: Colors.grey.shade100, name: 'White'),
          SvgColorPalette(id: 9, color: Colors.green, name: 'Stems'),
          SvgColorPalette(id: 10, color: const Color(0xFF2E7D32), name: 'Leaves'),
          SvgColorPalette(id: 11, color: const Color(0xFF81C784), name: 'Grass'),
          SvgColorPalette(id: 12, color: const Color(0xFFB3E5FC), name: 'Clouds'),
        ],
        regions: [
          SvgRegion(elementId: 'sun_1', colorNumber: 1),
          SvgRegion(elementId: 'ray1_2', colorNumber: 2),
          SvgRegion(elementId: 'ray2_2', colorNumber: 2),
          SvgRegion(elementId: 'f1_petal1_3', colorNumber: 3),
          SvgRegion(elementId: 'f1_center_4', colorNumber: 4),
          SvgRegion(elementId: 'f2_petal1_5', colorNumber: 5),
          SvgRegion(elementId: 'f2_center_6', colorNumber: 6),
          SvgRegion(elementId: 'f3_petals_7', colorNumber: 7),
          SvgRegion(elementId: 'f3_center_8', colorNumber: 8),
          SvgRegion(elementId: 'stem1_9', colorNumber: 9),
          SvgRegion(elementId: 'leaf1_10', colorNumber: 10),
          SvgRegion(elementId: 'grass_11', colorNumber: 11),
          SvgRegion(elementId: 'cloud1_12', colorNumber: 12),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final svgPieces = getSvgArtPieces();
    
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
        itemCount: svgPieces.length,
        itemBuilder: (context, index) {
          return FadeInUp(
            delay: Duration(milliseconds: index * 50),
            child: _buildSvgTile(context, svgPieces[index], index),
          );
        },
      ),
    );
  }

  Widget _buildSvgTile(BuildContext context, SvgArt svgArt, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: () {
        context.read<SettingsProvider>().playSound('bubbletap.wav');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SvgColoringScreen(svgArt: svgArt),
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
              ][index % 3].withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 6),
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
                    gradient: LinearGradient(
                      colors: [
                        svgArt.palette[0].color.withValues(alpha: 0.2),
                        svgArt.palette[1].color.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.palette_outlined,
                          size: 48,
                          color: svgArt.palette[0].color,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${svgArt.palette.length} Colors',
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
                svgArt.name,
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