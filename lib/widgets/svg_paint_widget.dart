// ============================================
// 3. lib/widgets/svg_paint_widget.dart
// ============================================
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

        final coloredSvg = provider.getColoredSvg();

        return Stack(
          children: [
            SvgPicture.string(
              coloredSvg,
              fit: BoxFit.contain,
            ),
            
            // Overlay for tap detection
            ...svgArt.regions.map((region) {
              if (region.bounds != null) {
                return Positioned(
                  left: region.bounds!.left,
                  top: region.bounds!.top,
                  width: region.bounds!.width,
                  height: region.bounds!.height,
                  child: GestureDetector(
                    onTap: () {
                      provider.fillRegion(region.elementId);
                      context.read<SettingsProvider>().playSound('bubbletap.wav');
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: !provider.filledRegions.containsKey(region.elementId)
                          ? Center(
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: provider.shouldHighlightRegion(region.elementId)
                                        ? Colors.black
                                        : Colors.grey,
                                    width: provider.shouldHighlightRegion(region.elementId) ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${region.colorNumber}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: provider.shouldHighlightRegion(region.elementId)
                                        ? Colors.black
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        );
      },
    );
  }
}