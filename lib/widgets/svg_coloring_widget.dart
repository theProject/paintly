import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for rootBundle
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xml/xml.dart' as xml;
// currently not used?  import '../providers/scene_provider.dart'; 
import '../magic/models/magic_models.dart'; 

// Replace the placeholder CustomPaint in magic_coloring_screen.dart with this widget:

class SvgColoringWidget extends StatefulWidget {
  final String svgPath;
  final Map<String, Color> coloredRegions;
  final Map<String, String> regionNumbers;
  final Map<String, Color> predefinedColors;
  final bool isCustomizing;
  final Function(String) onRegionTap;

  const SvgColoringWidget({
    super.key,
    required this.svgPath,
    required this.coloredRegions,
    required this.regionNumbers,
    required this.predefinedColors,
    required this.isCustomizing,
    required this.onRegionTap,
  });

  @override
  State<SvgColoringWidget> createState() => _SvgColoringWidgetState();
}

class _SvgColoringWidgetState extends State<SvgColoringWidget> {
  String? svgContent;
  Map<String, Rect> regionBounds = {};

  @override
  void initState() {
    super.initState();
    _loadSvg();
  }

  Future<void> _loadSvg() async {
    try {
      final String content = await rootBundle.loadString(widget.svgPath);
      setState(() {
        svgContent = _processSvg(content);
      });
    } catch (e) {
      debugPrint('Error loading SVG: $e');
    }
  }

  String _processSvg(String originalSvg) {
    final document = xml.XmlDocument.parse(originalSvg);
    
    // Process each path/shape element
    final List<xml.XmlElement> elements = [];
    elements.addAll(document.findAllElements('path'));
    elements.addAll(document.findAllElements('circle'));
    elements.addAll(document.findAllElements('rect'));
    elements.addAll(document.findAllElements('ellipse'));
    elements.addAll(document.findAllElements('polygon'));
    
    for (final element in elements) {
      final id = element.getAttribute('id');
      if (id != null) {
        // Apply colors
        Color? color;
        if (widget.coloredRegions.containsKey(id)) {
          color = widget.coloredRegions[id];
        } else if (widget.predefinedColors.containsKey(id) && !widget.isCustomizing) {
          color = widget.predefinedColors[id];
        }
        
        if (color != null) {
          element.setAttribute('fill', '#${color.toARGB32().toRadixString(16).substring(2)}');
          element.setAttribute('fill-opacity', '1.0');
        } else {
          // Uncolored regions
          element.setAttribute('fill', '#FFFFFF');
          element.setAttribute('stroke', '#CCCCCC');
          element.setAttribute('stroke-width', '2');
        }
        
        // Add interaction class
        element.setAttribute('class', 'colorable-region');
        element.setAttribute('data-region-id', id);
      }
    }
    
    // Update or add number labels
    _addNumberLabels(document);
    
    return document.toXmlString();
  }

  void _addNumberLabels(xml.XmlDocument document) {
    // Remove existing number labels
    final existingLabels = document.findAllElements('text')
        .where((e) => e.getAttribute('class') == 'region-number')
        .toList();
    for (final label in existingLabels) {
      label.parent?.children.remove(label);
    }
    
    // Add new labels for numbered regions
    final svg = document.findElements('svg').first;
    widget.regionNumbers.forEach((regionId, number) {
      // Skip if customizing and region is locked
      if (widget.isCustomizing && widget.predefinedColors.containsKey(regionId)) {
        return;
      }
      
      // Find the element
      final element = document.findAllElements('*')
          .firstWhere((e) => e.getAttribute('id') == regionId, 
                      orElse: () => xml.XmlElement(xml.XmlName('null')));
      
      if (element.name.local != 'null') {
        // Calculate center point (simplified - in production use proper bounds)
        final text = xml.XmlElement(xml.XmlName('text'));
        text.setAttribute('class', 'region-number');
        text.setAttribute('x', '50'); // You'd calculate actual position
        text.setAttribute('y', '50');
        text.setAttribute('text-anchor', 'middle');
        text.setAttribute('font-size', '14');
        text.setAttribute('font-weight', 'bold');
        text.setAttribute('fill', '#666666');
        text.setAttribute('pointer-events', 'none');
        text.innerText = number;
        
        svg.children.add(text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (svgContent == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTapDown: (details) {
        // Handle tap detection
        _handleTap(details.localPosition);
      },
      child: SvgPicture.string(
        svgContent!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
      ),
    );
  }

  void _handleTap(Offset position) {
    // In a production app, you would:
    // 1. Parse SVG paths and calculate bounds
    // 2. Check which region contains the tap point
    // 3. Call onRegionTap with the appropriate region ID
    
    // For now, simplified example:
    widget.regionNumbers.forEach((regionId, number) {
      // Check if tap is within region bounds
      // This is a placeholder - implement proper hit testing
      widget.onRegionTap(regionId);
    });
  }
}

// Enhanced color picker for Magic Mode
class MagicColorPicker extends StatelessWidget {
  final List<Color> colors;
  final Color? selectedColor;
  final ValueChanged<Color> onColorSelected;
  final String regionNumber;

  const MagicColorPicker({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
    required this.regionNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Choose color for area $regionNumber',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: colors.map((color) {
              final isSelected = selectedColor == color;
              return GestureDetector(
                onTap: () => onColorSelected(color),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey[300]!,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 28,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Integration helper for Scene Mode
class MagicObjectSceneItem extends StatelessWidget {
  final MagicSceneObject object;
  final VoidCallback onTap;

  const MagicObjectSceneItem({
    super.key,
    required this.object,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: _buildColoredSvg(),
        ),
      ),
    );
  }

  Widget _buildColoredSvg() {
    // In production, this would render the SVG with saved colors
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 32,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 4),
          Text(
            object.name,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}