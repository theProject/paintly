import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/scene_provider.dart';
import '../../providers/settings_provider.dart';

class SceneCanvas extends StatelessWidget {
  const SceneCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SceneProvider>(
      builder: (context, provider, child) {
        if (provider.currentScene == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final scene = provider.currentScene!;
        
        return LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade50,
                        Colors.purple.shade50,
                      ],
                    ),
                  ),
                ),
                
                // Color regions
                ...scene.colorRegions.map((region) {
                  final isFilled = provider.filledRegions.containsKey(region.id);
                  final fillColor = provider.filledRegions[region.id];
                  
                  return Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        provider.fillRegion(region.id);
                        if (provider.filledRegions.containsKey(region.id)) {
                          context.read<SettingsProvider>().playSound('paint.mp3');
                        }
                      },
                      child: CustomPaint(
                        painter: RegionPainter(
                          svgPath: region.svgPath,
                          fillColor: fillColor,
                          targetColor: region.targetColor,
                          isHighlighted: provider.selectedColor == region.targetColor && !isFilled,
                        ),
                      ),
                    ),
                  );
                }),
                
                // Draggable items
                ...scene.draggableItems.map((item) {
                  final position = provider.draggablePositions[item.id] ?? item.initialPosition;
                  
                  return Positioned(
                    left: position.dx,
                    top: position.dy,
                    child: Draggable(
                      feedback: _buildDraggableItem(item, 1.1),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: _buildDraggableItem(item, 1.0),
                      ),
                      onDragEnd: (details) {
                        final RenderBox box = context.findRenderObject() as RenderBox;
                        final localPosition = box.globalToLocal(details.offset);
                        provider.updateDraggablePosition(item.id, localPosition);
                        context.read<SettingsProvider>().playSound('drop.mp3');
                      },
                      child: _buildDraggableItem(item, 1.0),
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

  Widget _buildDraggableItem(DraggableItem item, double scale) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: item.size.width,
        height: item.size.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            item.id,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}

class RegionPainter extends CustomPainter {
  final String svgPath;
  final Color? fillColor;
  final Color targetColor;
  final bool isHighlighted;

  RegionPainter({
    required this.svgPath,
    required this.fillColor,
    required this.targetColor,
    required this.isHighlighted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = fillColor ?? (isHighlighted ? targetColor.withValues(alpha: 0.3) : Colors.transparent);

    // Create a simple shape for demo - in production, parse SVG path
    final path = Path();
    
    // Example: Draw different shapes based on svgPath ID
    if (svgPath.contains('chair')) {
      // Draw chair shape
      path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.2, size.height * 0.6, size.width * 0.15, size.height * 0.3),
        const Radius.circular(8),
      ));
    } else if (svgPath.contains('table')) {
      // Draw table shape
      path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.4, size.height * 0.5, size.width * 0.3, size.height * 0.2),
        const Radius.circular(8),
      ));
    } else if (svgPath.contains('lamp')) {
      // Draw lamp shape
      path.addOval(Rect.fromLTWH(size.width * 0.7, size.height * 0.2, size.width * 0.1, size.height * 0.1));
    }

    canvas.drawPath(path, paint);

    // Draw outline
    if (isHighlighted) {
      final outlinePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = targetColor;
      canvas.drawPath(path, outlinePaint);
    }
  }

  @override
  bool shouldRepaint(RegionPainter oldDelegate) {
    return fillColor != oldDelegate.fillColor || isHighlighted != oldDelegate.isHighlighted;
  }
}
