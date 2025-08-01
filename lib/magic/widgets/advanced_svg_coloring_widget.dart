// lib/magic/widgets/advanced_svg_coloring_widget.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/svg_coloring_engine.dart';

/// A widget that renders an SVG as a tappable, colorable canvas,
/// using the SvgColoringEngine service under the hood.
class AdvancedSvgColoringWidget extends StatefulWidget {
  final String svgPath;
  final Map<String, Color> coloredRegions;
  final Map<String, String> regionNumbers;
  final Map<String, Color> predefinedColors;
  final Map<String, List<Color>> customizableRegions;
  final bool isCustomizing;
  final void Function(String) onRegionTap;

  const AdvancedSvgColoringWidget({
    Key? key,
    required this.svgPath,
    required this.coloredRegions,
    required this.regionNumbers,
    required this.predefinedColors,
    required this.customizableRegions,
    required this.isCustomizing,
    required this.onRegionTap,
  }) : super(key: key);

  @override
  _AdvancedSvgColoringWidgetState createState() =>
      _AdvancedSvgColoringWidgetState();
}

class _AdvancedSvgColoringWidgetState
    extends State<AdvancedSvgColoringWidget> {
  SvgColoringEngine? engine;
  String? highlightedRegion;
  Size? lastSize;

  @override
  void initState() {
    super.initState();
    _loadAndParseSvg();
  }

  @override
  void didUpdateWidget(covariant AdvancedSvgColoringWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.svgPath != widget.svgPath ||
        oldWidget.coloredRegions != widget.coloredRegions) {
      _loadAndParseSvg();
    }
  }

  Future<void> _loadAndParseSvg() async {
    final svgContent = await rootBundle.loadString(widget.svgPath);
    final newEngine = SvgColoringEngine(
      svgContent: svgContent,
      coloredRegions: widget.coloredRegions,
      regionNumbers: widget.regionNumbers,
      predefinedColors: widget.predefinedColors,
      customizableRegions: widget.customizableRegions,
      isCustomizing: widget.isCustomizing,
    );
    await newEngine.parse();
    if (mounted) {
      setState(() => engine = newEngine);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (engine == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        lastSize ??= size;

        return GestureDetector(
          onTapDown: (details) {
            final regionId = engine!.hitTest(details.localPosition, size);
            if (regionId != null) {
              widget.onRegionTap(regionId);
              setState(() => highlightedRegion = regionId);
              Future.delayed(const Duration(milliseconds: 200), () {
                if (mounted) setState(() => highlightedRegion = null);
              });
            }
          },
          child: CustomPaint(
            size: size,
            painter: _SvgColoringPainter(
              engine: engine!,
              highlightedRegion: highlightedRegion,
            ),
          ),
        );
      },
    );
  }
}

class _SvgColoringPainter extends CustomPainter {
  final SvgColoringEngine engine;
  final String? highlightedRegion;

  _SvgColoringPainter({
    required this.engine,
    this.highlightedRegion,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final viewBox = engine.viewBox;
    if (viewBox == null) return;

    // Compute scaling to maintain aspect ratio
    final scaleX = size.width / viewBox.width;
    final scaleY = size.height / viewBox.height;
    final scale = math.min(scaleX, scaleY);

    // Center the SVG
    final drawW = viewBox.width * scale;
    final drawH = viewBox.height * scale;
    final offsetX = (size.width - drawW) / 2;
    final offsetY = (size.height - drawH) / 2;

    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale, scale);

    // Draw each region
    for (final region in engine.regions) {
      final paint = Paint()..color = region.paint.color;

      if (region.paint.style == PaintingStyle.fill) {
        // Filled region
        paint.style = PaintingStyle.fill;
        canvas.drawPath(region.path, paint);

        // Outline
        paint
          ..style = PaintingStyle.stroke
          ..color = Colors.grey[600]!
          ..strokeWidth = 1.0;
        canvas.drawPath(region.path, paint);
      } else {
        // Unfilled: white fill + dashed stroke
        paint
          ..style = PaintingStyle.fill
          ..color = Colors.white;
        canvas.drawPath(region.path, paint);

        paint
          ..style = PaintingStyle.stroke
          ..color = Colors.grey[400]!
          ..strokeWidth = 2.0;
        final dashed = dashPath(
          region.path,
          dashArray: CircularIntervalList<double>([5.0, 5.0]),
        );
        canvas.drawPath(dashed, paint);
      }

      // Highlight on tap
      if (region.id == highlightedRegion) {
        final highlight = Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.yellow.withOpacity(0.3);
        canvas.drawPath(region.path, highlight);
      }

      // Draw region number label
      if (region.number != null && region.isColorable) {
        final tp = TextPainter(
          text: TextSpan(
            text: region.number,
            style: TextStyle(
              color: region.paint.style == PaintingStyle.fill
                  ? Colors.white
                  : Colors.grey[700]!,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              shadows: region.paint.style == PaintingStyle.fill
                  ? [
                      const Shadow(
                        color: Colors.black54,
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ]
                  : null,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        final pos = region.centroid -
            Offset(tp.width / 2, tp.height / 2);
        tp.paint(canvas, pos);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SvgColoringPainter old) {
    return old.engine != engine ||
        old.highlightedRegion != highlightedRegion;
  }
}
