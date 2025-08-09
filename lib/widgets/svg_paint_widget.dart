// lib/widgets/svg_paint_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/svg_art.dart';
import '../providers/svg_coloring_provider.dart';
import '../providers/settings_provider.dart';

class SvgPaintWidget extends StatelessWidget {
  final SvgArt svgArt;

  const SvgPaintWidget({super.key, required this.svgArt});

  @override
  Widget build(BuildContext context) {
    return Consumer<SvgColoringProvider>(
      builder: (context, provider, child) {
        if (provider.loadedSvgContent == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Get the colored SVG (with fills applied)
        final coloredSvg = provider.getColoredSvg();

        return Stack(
          alignment: Alignment.center,
          children: [
            // Base SVG - NOT draggable, just displays
            SvgPicture.string(
              coloredSvg,
              fit: BoxFit.contain,
            ),
            
            // Number overlay - positioned on regions
            ...svgArt.regions.map((region) {
              final isFilled = provider.filledRegions.containsKey(region.elementId);
              final isHighlighted = provider.shouldHighlightRegion(region.elementId);
              
              // Skip if already filled
              if (isFilled) return const SizedBox.shrink();
              
              // Use the position from the region if provided
              return Positioned(
                left: region.position?.dx,
                top: region.position?.dy,
                child: GestureDetector(
                  onTap: () {
                    provider.fillRegion(region.elementId);
                    context.read<SettingsProvider>().playSound('bubbletap.wav');
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isHighlighted ? Colors.black : Colors.grey[600]!,
                        width: isHighlighted ? 2.5 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${region.colorNumber}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isHighlighted ? Colors.black : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}





// ============================================
// Example Room SVG (like your image)
// assets/svg/room_scene.svg
// ============================================
/*
<svg viewBox="0 0 800 600" xmlns="http://www.w3.org/2000/svg">
  <!-- Background -->
  <rect width="800" height="600" fill="#F5F5F5"/>
  
  <!-- Wall (Color 1 - Light Blue) -->
  <rect id="wall_1" x="0" y="0" width="800" height="400" fill="white" stroke="#333" stroke-width="2"/>
  
  <!-- Floor (Color 2 - Brown) -->
  <rect id="floor_2" x="0" y="400" width="800" height="200" fill="white" stroke="#333" stroke-width="2"/>
  
  <!-- Bookshelf (Color 3 - Dark Brown) -->
  <rect id="bookshelf_3" x="50" y="150" width="200" height="250" fill="white" stroke="#333" stroke-width="2"/>
  
  <!-- Books on shelf (Color 4 - Mixed) -->
  <rect id="book1_4" x="60" y="180" width="30" height="60" fill="white" stroke="#333" stroke-width="2"/>
  <rect id="book2_4" x="95" y="180" width="30" height="60" fill="white" stroke="#333" stroke-width="2"/>
  <rect id="book3_4" x="130" y="180" width="30" height="60" fill="white" stroke="#333" stroke-width="2"/>
  
  <!-- Picture Frame on wall (Color 5 - Gold) -->
  <rect id="frame_5" x="300" y="50" width="150" height="120" fill="white" stroke="#333" stroke-width="3"/>
  
  <!-- Picture content (Color 6 - Green) -->
  <rect id="picture_6" x="315" y="65" width="120" height="90" fill="white" stroke="#333" stroke-width="2"/>
  
  <!-- Couch (Color 7 - Red) -->
  <rect id="couch_base_7" x="400" y="320" width="300" height="80" fill="white" stroke="#333" stroke-width="2"/>
  <rect id="couch_back_7" x="400" y="250" width="300" height="70" fill="white" stroke="#333" stroke-width="2"/>
  
  <!-- Character body (Color 8 - Skin tone) -->
  <ellipse id="char_body_8" cx="250" cy="350" rx="40" ry="60" fill="white" stroke="#333" stroke-width="2"/>
  
  <!-- Character head (Color 8 - Skin tone) -->
  <circle id="char_head_8" cx="250" cy="280" r="30" fill="white" stroke="#333" stroke-width="2"/>
  
  <!-- Character shirt (Color 9 - Blue) -->
  <rect id="char_shirt_9" x="220" y="320" width="60" height="50" fill="white" stroke="#333" stroke-width="2"/>
  
  <!-- Character pants (Color 10 - Black) -->
  <rect id="char_pants_10" x="225" y="370" width="50" height="40" fill="white" stroke="#333" stroke-width="2"/>
  
  <!-- Camera on tripod (Color 11 - Black) -->
  <rect id="camera_body_11" x="600" y="250" width="60" height="40" fill="white" stroke="#333" stroke-width="2"/>
  <circle id="camera_lens_11" cx="630" cy="270" r="15" fill="white" stroke="#333" stroke-width="2"/>
  
  <!-- Tripod legs (Color 12 - Silver) -->
  <line id="tripod1_12" x1="615" y1="290" x2="600" y2="400" stroke="#333" stroke-width="3"/>
  <line id="tripod2_12" x1="630" y1="290" x2="630" y2="400" stroke="#333" stroke-width="3"/>
  <line id="tripod3_12" x1="645" y1="290" x2="660" y2="400" stroke="#333" stroke-width="3"/>
  
  <!-- Lamp (Color 13 - Yellow) -->
  <ellipse id="lamp_shade_13" cx="500" cy="100" rx="60" ry="30" fill="white" stroke="#333" stroke-width="2"/>
  
  <!-- TV Screen (Color 14 - Gray) -->
  <rect id="tv_screen_14" x="550" y="50" width="200" height="120" fill="white" stroke="#333" stroke-width="2"/>
  
  <!-- Plant pot (Color 15 - Terra cotta) -->
  <rect id="pot_15" x="100" y="430" width="60" height="50" fill="white" stroke="#333" stroke-width="2"/>
  
  <!-- Plant leaves (Color 16 - Green) -->
  <ellipse id="leaf1_16" cx="130" cy="420" rx="20" ry="30" fill="white" stroke="#333" stroke-width="2"/>
  <ellipse id="leaf2_16" cx="110" cy="415" rx="15" ry="25" fill="white" stroke="#333" stroke-width="2"/>
</svg>
*/

// ============================================
// Updated lib/screens/svg_home_screen.dart
// Add this room scene to your SVG list
// ============================================
/*
Add to getSvgArtPieces():

SvgArt(
  name: 'Living Room',
  svgPath: 'assets/svg/room_scene.svg',
  palette: [
    SvgColorPalette(id: 1, color: Color(0xFFE3F2FD), name: 'Light Blue'),
    SvgColorPalette(id: 2, color: Color(0xFF8D6E63), name: 'Brown'),
    SvgColorPalette(id: 3, color: Color(0xFF5D4037), name: 'Dark Brown'),
    SvgColorPalette(id: 4, color: Colors.red, name: 'Red Books'),
    SvgColorPalette(id: 5, color: Color(0xFFFFD700), name: 'Gold Frame'),
    SvgColorPalette(id: 6, color: Colors.green, name: 'Picture'),
    SvgColorPalette(id: 7, color: Colors.red, name: 'Red Couch'),
    SvgColorPalette(id: 8, color: Color(0xFFFFDBAC), name: 'Skin'),
    SvgColorPalette(id: 9, color: Colors.blue, name: 'Blue Shirt'),
    SvgColorPalette(id: 10, color: Colors.black, name: 'Black Pants'),
    SvgColorPalette(id: 11, color: Colors.black, name: 'Camera'),
    SvgColorPalette(id: 12, color: Colors.grey, name: 'Tripod'),
    SvgColorPalette(id: 13, color: Colors.yellow, name: 'Lamp'),
    SvgColorPalette(id: 14, color: Colors.grey, name: 'TV'),
    SvgColorPalette(id: 15, color: Color(0xFFD84315), name: 'Pot'),
    SvgColorPalette(id: 16, color: Colors.green, name: 'Leaves'),
  ],
  regions: [
    SvgRegion(elementId: 'wall_1', colorNumber: 1),
    SvgRegion(elementId: 'floor_2', colorNumber: 2),
    SvgRegion(elementId: 'bookshelf_3', colorNumber: 3),
    SvgRegion(elementId: 'book1_4', colorNumber: 4),
    SvgRegion(elementId: 'book2_4', colorNumber: 4),
    SvgRegion(elementId: 'book3_4', colorNumber: 4),
    SvgRegion(elementId: 'frame_5', colorNumber: 5),
    SvgRegion(elementId: 'picture_6', colorNumber: 6),
    SvgRegion(elementId: 'couch_base_7', colorNumber: 7),
    SvgRegion(elementId: 'couch_back_7', colorNumber: 7),
    SvgRegion(elementId: 'char_body_8', colorNumber: 8),
    SvgRegion(elementId: 'char_head_8', colorNumber: 8),
    SvgRegion(elementId: 'char_shirt_9', colorNumber: 9),
    SvgRegion(elementId: 'char_pants_10', colorNumber: 10),
    SvgRegion(elementId: 'camera_body_11', colorNumber: 11),
    SvgRegion(elementId: 'camera_lens_11', colorNumber: 11),
    SvgRegion(elementId: 'tripod1_12', colorNumber: 12),
    SvgRegion(elementId: 'tripod2_12', colorNumber: 12),
    SvgRegion(elementId: 'tripod3_12', colorNumber: 12),
    SvgRegion(elementId: 'lamp_shade_13', colorNumber: 13),
    SvgRegion(elementId: 'tv_screen_14', colorNumber: 14),
    SvgRegion(elementId: 'pot_15', colorNumber: 15),
    SvgRegion(elementId: 'leaf1_16', colorNumber: 16),
    SvgRegion(elementId: 'leaf2_16', colorNumber: 16),
  ],
),
*/