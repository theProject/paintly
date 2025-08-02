import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/coloring_provider.dart';

class ColorPaletteWidget extends StatelessWidget {
  const ColorPaletteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ColoringProvider>(
      builder: (context, provider, child) {
        if (provider.currentPixelArt == null) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 80,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.currentPixelArt!.palette.length,
            itemBuilder: (context, index) {
              final colorItem = provider.currentPixelArt!.palette[index];
              final isSelected = provider.selectedColorId == colorItem.id;
              final isCompleted = provider.completedColors[colorItem.id] ?? false;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () {
                    if (!isCompleted) {
                      provider.selectColor(colorItem.id);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorItem.color,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                // Updated to use withValues
                                color: colorItem.color.withValues(alpha: 0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Color number
                        Text(
                          '${colorItem.id}',
                          style: TextStyle(
                            color: _getContrastColor(colorItem.color),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        // Completed overlay
                        if (isCompleted)
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // Updated to use withValues
                              color: Colors.black.withValues(alpha: 0.5),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Get contrasting color for text visibility
  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
