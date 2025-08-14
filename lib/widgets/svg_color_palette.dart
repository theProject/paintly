//lib/widgets/svg_color_palette.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/svg_coloring_provider.dart';
import '../providers/settings_provider.dart';

class SvgColorPalette extends StatelessWidget {
  const SvgColorPalette({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SvgColoringProvider>(
      builder: (context, provider, child) {
        if (provider.currentSvgArt == null) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 100,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.currentSvgArt!.palette.length,
            itemBuilder: (context, index) {
              final colorItem = provider.currentSvgArt!.palette[index];
              final isSelected = provider.selectedColorId == colorItem.id;
              final isCompleted = provider.completedColors[colorItem.id] ?? false;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: BounceInUp(
                  delay: Duration(milliseconds: index * 50),
                  child: GestureDetector(
                    onTap: () {
                      if (!isCompleted) {
                        provider.selectColor(colorItem.id);
                        context.read<SettingsProvider>().playSound('bubbletap.wav');
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isSelected ? 65 : 55,
                      height: isSelected ? 65 : 55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorItem.color,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.white,
                          width: isSelected ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorItem.color.withValues(alpha: 0.4),
                            blurRadius: isSelected ? 15 : 8,
                            spreadRadius: isSelected ? 2 : 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (!isCompleted)
                            Text(
                              '${colorItem.id}',
                              style: TextStyle(
                                color: _getContrastColor(colorItem.color),
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          if (isCompleted)
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
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
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}