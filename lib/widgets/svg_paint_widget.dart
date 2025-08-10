// ============================================
// lib/widgets/svg_paint_widget.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/svg_art.dart';
import '../providers/svg_coloring_provider.dart';
import '../providers/settings_provider.dart';

class SvgPaintWidget extends StatefulWidget {
  final SvgArt svgArt;

  const SvgPaintWidget({super.key, required this.svgArt});

  @override
  State<SvgPaintWidget> createState() => _SvgPaintWidgetState();
}

class _SvgPaintWidgetState extends State<SvgPaintWidget> {
  final GlobalKey _svgKey = GlobalKey();
  Size? _svgSize;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateScale();
    });
  }

  void _calculateScale() {
    if (_svgKey.currentContext != null) {
      final RenderBox? renderBox = _svgKey.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        setState(() {
          _svgSize = renderBox.size;
          // Calculate scale based on viewBox
          // Assuming viewBox is 400x400 for most SVGs
          _scale = _svgSize!.width / 400;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SvgColoringProvider>(
      builder: (context, provider, child) {
        if (!provider.isInitialized || provider.loadedSvgContent == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final coloredSvg = provider.getColoredSvg();

        return LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // SVG Display
                Container(
                  key: _svgKey,
                  child: SvgPicture.string(
                    coloredSvg,
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    fit: BoxFit.contain,
                  ),
                ),

                // Number overlays - only for unfilled regions
                if (_svgSize != null)
                  ...widget.svgArt.regions
                      .where((region) => !provider.filledRegions.containsKey(region.elementId))
                      .map((region) {
                    final isHighlighted = provider.shouldHighlightRegion(region.elementId);

                    // Scale the position based on actual SVG size
                    final scaledLeft = (region.position?.dx ?? 0) * _scale;
                    final scaledTop = (region.position?.dy ?? 0) * _scale;

                    return Positioned(
                      left: scaledLeft - 15, // Center the number
                      top: scaledTop - 15,
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
                  }),
              ],
            );
          },
        );
      },
    );
  }
}
