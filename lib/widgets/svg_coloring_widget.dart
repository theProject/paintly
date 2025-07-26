import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

class SvgColoringWidget extends StatefulWidget {
  final String svgPath;
  final List<Color> colorPalette;
  
  const SvgColoringWidget({
    super.key,
    required this.svgPath,
    required this.colorPalette,
  });

  @override
  State<SvgColoringWidget> createState() => _SvgColoringWidgetState();
}

class _SvgColoringWidgetState extends State<SvgColoringWidget> {
  String? _svgContent;
  Color? _selectedColor;
  final Map<String, Color> _filledRegions = {};

  @override
  void initState() {
    super.initState();
    _loadSvg();
  }

  Future<void> _loadSvg() async {
    try {
      final svgString = await rootBundle.loadString(widget.svgPath);
      setState(() {
        _svgContent = svgString;
      });
    } catch (e) {
      debugPrint('Error loading SVG: $e');
    }
  }

  String _updateSvgWithColors() {
    if (_svgContent == null) return '';
    
    String updatedSvg = _svgContent!;
    
    // Update SVG with filled colors
    _filledRegions.forEach((id, color) {
      // Convert color to hex string
      final hexColor = '#${color.toARGB32().toRadixString(16).substring(2)}';
      
      // Replace fill color for elements with this ID
      // This is a simple approach - for production, use proper SVG parsing
      updatedSvg = updatedSvg.replaceAllMapped(
        RegExp('id="$id"[^>]*'),
        (match) {
          final matchStr = match.group(0)!;
          // Remove existing fill and add new one
          return '${matchStr.replaceAll(RegExp(r'fill="[^"]*"'), '')} fill="$hexColor"';
        },
      );
    });
    
    return updatedSvg;
  }

  @override
  Widget build(BuildContext context) {
    if (_svgContent == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // SVG Display with interaction
        Expanded(
          child: GestureDetector(
            onTapUp: (details) {
              // This is simplified - in production you'd need to:
              // 1. Convert tap coordinates to SVG coordinates
              // 2. Find which path/region was tapped
              // 3. Fill that region with selected color
              // For now, showing the concept
            },
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: SvgPicture.string(
                  _updateSvgWithColors(),
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.6,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        
        // Color Palette
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.colorPalette.length,
            itemBuilder: (context, index) {
              final color = widget.colorPalette[index];
              final isSelected = _selectedColor == color;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                  HapticFeedback.lightImpact();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: isSelected ? 65 : 55,
                  height: isSelected ? 65 : 55,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.white,
                      width: isSelected ? 3 : 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: isSelected ? 15 : 8,
                        spreadRadius: isSelected ? 2 : 0,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Example usage in a screen:
class SvgColoringScreen extends StatelessWidget {
  const SvgColoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('SVG Coloring'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SvgColoringWidget(
        svgPath: 'assets/svg/BottleFriends.svg',
        colorPalette: [
          colorScheme.primary,
          colorScheme.secondary,
          colorScheme.tertiary,
          colorScheme.primaryContainer,
          colorScheme.secondaryContainer,
          const Color(0xFFE93A45), // Red
          const Color(0xFFFABF23), // Yellow
          const Color(0xFFFF8A3D), // Orange
          const Color(0xFF51BAA3), // Teal
          const Color(0xFF9B72AA), // Purple
        ],
      ),
    );
  }
}