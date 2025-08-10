// ============================================
// lib/screens/svg_home_screen.dart
// ============================================
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
      // Cute Cactus
      SvgArt(
        name: 'Cute Cactus',
        svgPath: 'assets/svg/cactus.svg',
        palette: [
          SvgColorPalette(id: 1, color: const Color(0xFF7CB342), name: 'Green'),
          SvgColorPalette(id: 2, color: const Color(0xFF558B2F), name: 'Dark Green'),
          SvgColorPalette(id: 3, color: const Color(0xFFE91E63), name: 'Pink'),
          SvgColorPalette(id: 4, color: const Color(0xFF8D6E63), name: 'Brown'),
          SvgColorPalette(id: 5, color: const Color(0xFFFFEB3B), name: 'Yellow'),
          SvgColorPalette(id: 6, color: const Color(0xFF9C27B0), name: 'Purple'),
        ],
        regions: [
          // Cactus body parts (Green - 1)
          SvgRegion(elementId: 'cactus_body_1', colorNumber: 1, position: const Offset(200, 280)),
          SvgRegion(elementId: 'left_arm_1', colorNumber: 1, position: const Offset(120, 250)),
          SvgRegion(elementId: 'right_arm_1', colorNumber: 1, position: const Offset(280, 220)),
          
          // Stripes (Dark Green - 2)
          SvgRegion(elementId: 'stripe1_2', colorNumber: 2, position: const Offset(170, 280)),
          SvgRegion(elementId: 'stripe2_2', colorNumber: 2, position: const Offset(200, 280)),
          SvgRegion(elementId: 'stripe3_2', colorNumber: 2, position: const Offset(230, 280)),
          SvgRegion(elementId: 'left_stripe1_2', colorNumber: 2, position: const Offset(105, 250)),
          SvgRegion(elementId: 'left_stripe2_2', colorNumber: 2, position: const Offset(120, 250)),
          SvgRegion(elementId: 'left_stripe3_2', colorNumber: 2, position: const Offset(135, 250)),
          SvgRegion(elementId: 'right_stripe1_2', colorNumber: 2, position: const Offset(265, 220)),
          SvgRegion(elementId: 'right_stripe2_2', colorNumber: 2, position: const Offset(280, 220)),
          SvgRegion(elementId: 'right_stripe3_2', colorNumber: 2, position: const Offset(295, 220)),
          
          // Pot and flowers (Pink - 3)
          SvgRegion(elementId: 'pot_rim_3', colorNumber: 3, position: const Offset(200, 395)),
          SvgRegion(elementId: 'flower1_petal1_3', colorNumber: 3, position: const Offset(185, 165)),
          SvgRegion(elementId: 'flower1_petal2_3', colorNumber: 3, position: const Offset(215, 165)),
          SvgRegion(elementId: 'flower1_petal3_3', colorNumber: 3, position: const Offset(185, 195)),
          SvgRegion(elementId: 'flower1_petal4_3', colorNumber: 3, position: const Offset(215, 195)),
          SvgRegion(elementId: 'flower2_petal1_3', colorNumber: 3, position: const Offset(150, 200)),
          SvgRegion(elementId: 'flower2_petal2_3', colorNumber: 3, position: const Offset(170, 200)),
          SvgRegion(elementId: 'flower2_petal3_3', colorNumber: 3, position: const Offset(150, 220)),
          SvgRegion(elementId: 'flower2_petal4_3', colorNumber: 3, position: const Offset(170, 220)),
          
          // Pot base (Brown - 4)
          SvgRegion(elementId: 'pot_base_4', colorNumber: 4, position: const Offset(200, 440)),
          
          // Yellow elements (5)
          SvgRegion(elementId: 'flower1_center_5', colorNumber: 5, position: const Offset(200, 180)),
          SvgRegion(elementId: 'flower2_center_5', colorNumber: 5, position: const Offset(160, 210)),
          SvgRegion(elementId: 'pot_heart_5', colorNumber: 5, position: const Offset(190, 435)),
          SvgRegion(elementId: 'cheek1_5', colorNumber: 5, position: const Offset(160, 290)),
          SvgRegion(elementId: 'cheek2_5', colorNumber: 5, position: const Offset(240, 290)),
          
          // Pot band (Purple - 6)
          SvgRegion(elementId: 'pot_band_6', colorNumber: 6, position: const Offset(200, 415)),
        ],
      ),
      
      // Keep your existing butterfly if you want
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
          SvgRegion(elementId: 'wing_ul_1', colorNumber: 1, position: const Offset(120, 140)),
          SvgRegion(elementId: 'wing_ur_1', colorNumber: 1, position: const Offset(280, 140)),
          SvgRegion(elementId: 'wing_ll_2', colorNumber: 2, position: const Offset(130, 200)),
          SvgRegion(elementId: 'wing_lr_2', colorNumber: 2, position: const Offset(270, 200)),
          SvgRegion(elementId: 'body_3', colorNumber: 3, position: const Offset(200, 170)),
          SvgRegion(elementId: 'spot1_4', colorNumber: 4, position: const Offset(100, 150)),
          SvgRegion(elementId: 'spot2_4', colorNumber: 4, position: const Offset(300, 150)),
          SvgRegion(elementId: 'spot3_4', colorNumber: 4, position: const Offset(130, 200)),
          SvgRegion(elementId: 'spot4_4', colorNumber: 4, position: const Offset(270, 200)),
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
        context.read<SettingsProvider>().playSound('audio/bubbletap.wav');
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