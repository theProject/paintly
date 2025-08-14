// lib/widgets/svg_paint_widget.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../models/svg_art.dart';
import '../providers/svg_coloring_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/svg_region_centers.dart';
import '../utils/svg_hit_test.dart';

class SvgPaintWidget extends StatefulWidget {
  final SvgArt svgArt;

  const SvgPaintWidget({super.key, required this.svgArt});

  @override
  State<SvgPaintWidget> createState() => _SvgPaintWidgetState();
}

class _SvgPaintWidgetState extends State<SvgPaintWidget> {
  // Cached auto-centers
  Map<String, Offset> _autoCenters = {};
  String? _centersSource;
  bool _isComputingCenters = false;

  // Cached hit-test paths
  Map<String, Path> _hitPaths = {};
  String? _hitPathsSource;
  bool _isBuildingHitPaths = false;

  Future<void> _ensureCenters(String svgSource) async {
    if (_isComputingCenters || _centersSource == svgSource) return;
    _isComputingCenters = true;
    try {
      final centers = await computeRegionCenters(svgSource);
      if (!mounted) return;
      setState(() {
        _autoCenters = centers;
        _centersSource = svgSource;
      });
    } finally {
      if (mounted) setState(() => _isComputingCenters = false);
    }
  }

  Future<void> _ensureHitPaths(String svgSource) async {
    if (_isBuildingHitPaths || _hitPathsSource == svgSource) return;
    _isBuildingHitPaths = true;
    try {
      final ids = widget.svgArt.regions.map((r) => r.elementId).toSet();
      final paths = await computeSvgHitPaths(svgSource, ids);
      if (!mounted) return;
      setState(() {
        _hitPaths = paths;
        _hitPathsSource = svgSource;
      });
    } finally {
      if (mounted) setState(() => _isBuildingHitPaths = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SvgColoringProvider>(
      builder: (context, provider, child) {
        if (!provider.isInitialized || provider.loadedSvgContent == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final rawSvg = provider.loadedSvgContent!;
        _ensureCenters(rawSvg);
        _ensureHitPaths(rawSvg);

        final coloredSvg = provider.getColoredSvg();

        return LayoutBuilder(
          builder: (context, constraints) {
            // Our exports use a 400x400 viewBox.
            const base = 400.0;
            final renderSize =
                math.min(constraints.maxWidth, constraints.maxHeight);
            final scale = renderSize / base;
            final offsetX = (constraints.maxWidth - renderSize) / 2;
            final offsetY = (constraints.maxHeight - renderSize) / 2;

            void handleTapDown(TapDownDetails details) {
              final pos = details.localPosition;
              // Convert from widget coords → SVG viewBox coords
              final svgX = (pos.dx - offsetX) / scale;
              final svgY = (pos.dy - offsetY) / scale;
              final pt = Offset(svgX, svgY);

              // Hit test in (roughly) top-most order; try later regions first
              // (If needed, we can replace with real SVG draw order.)
              final paintable = widget.svgArt.regions
                  .map((r) => r.elementId)
                  .toList()
                  .reversed;

              for (final id in paintable) {
                final p = _hitPaths[id];
                if (p != null && p.contains(pt)) {
                  provider.fillRegion(id);
                  context.read<SettingsProvider>().playSound('audio/bubbletap.wav');
                  break;
                }
              }
            }

            return GestureDetector(
              behavior: HitTestBehavior.opaque, // receive taps outside chips
              onTapDown: handleTapDown,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // SVG
                  SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: SvgPicture.string(
                      coloredSvg,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // Number overlays (only for unfilled regions)
                  ...widget.svgArt.regions
                      .where((r) =>
                          !provider.filledRegions.containsKey(r.elementId))
                      .map((region) {
                    final isHighlighted =
                        provider.shouldHighlightRegion(region.elementId);

                    final pos = region.position ?? _autoCenters[region.elementId];
                    if (pos == null) return const SizedBox.shrink();

                    final left = offsetX + (pos.dx * scale) - 15;
                    final top  = offsetY + (pos.dy * scale) - 15;

                    return Positioned(
                      left: left,
                      top: top,
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
                              color:
                                  isHighlighted ? Colors.black : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
