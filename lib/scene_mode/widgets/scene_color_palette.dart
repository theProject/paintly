import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/scene_provider.dart';
import '../../providers/settings_provider.dart';

class SceneColorPalette extends StatelessWidget {
  const SceneColorPalette({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SceneProvider>(
      builder: (context, provider, child) {
        if (provider.currentScene == null) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 100,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.currentScene!.colorPalette.length,
            itemBuilder: (context, index) {
              final color = provider.currentScene!.colorPalette[index];
              final isSelected = provider.selectedColor == color;
              
              // Check if this color is completed
              final isCompleted = provider.currentScene!.colorRegions
                  .where((region) => region.targetColor == color)
                  .every((region) => provider.filledRegions.containsKey(region.id));

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: BounceInUp(
                  delay: Duration(milliseconds: index * 100),
                  child: GestureDetector(
                    onTap: () {
                      if (!isCompleted) {
                        provider.selectColor(color);
                        context.read<SettingsProvider>().playSound('tap.mp3');
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isSelected ? 70 : 60,
                      height: isSelected ? 70 : 60,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.white,
                          width: isSelected ? 4 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: isSelected ? 15 : 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 30,
                            )
                          : null,
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
}
