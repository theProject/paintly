import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/pixel_art.dart';
import '../providers/progress_provider.dart';

class PixelArtPreview extends StatelessWidget {
  final PixelArt pixelArt;
  final PixelArtProgress progress;
  final double size;

  const PixelArtPreview({
    super.key,
    required this.pixelArt,
    required this.progress,
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: PixelArtPreviewPainter(
        pixelArt: pixelArt,
        progress: progress,
      ),
    );
  }
}

class PixelArtPreviewPainter extends CustomPainter {
  final PixelArt pixelArt;
  final PixelArtProgress progress;

  PixelArtPreviewPainter({
    required this.pixelArt,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / pixelArt.width;
    final cellHeight = size.height / pixelArt.height;
    final cellSize = math.min(cellWidth, cellHeight);
    
    // Center the grid
    final offsetX = (size.width - cellSize * pixelArt.width) / 2;
    final offsetY = (size.height - cellSize * pixelArt.height) / 2;

    // Draw background
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      ),
      bgPaint,
    );

    // Draw pixels
    for (int row = 0; row < pixelArt.height; row++) {
      for (int col = 0; col < pixelArt.width; col++) {
        final pixelNumber = pixelArt.pixels[row][col];
        
        if (pixelNumber == 0) continue; // Skip empty pixels
        
        final x = offsetX + col * cellSize;
        final y = offsetY + row * cellSize;
        
        final rect = Rect.fromLTWH(x, y, cellSize, cellSize);
        
        // Check if pixel is filled
        final isFilled = progress.filledPixels != null &&
            row < progress.filledPixels!.length &&
            col < progress.filledPixels![row].length &&
            progress.filledPixels![row][col];
        
        final paint = Paint()
          ..style = PaintingStyle.fill;
        
        if (isFilled || progress.isComplete) {
          // Show actual color
          final colorPalette = pixelArt.palette.firstWhere(
            (p) => p.id == pixelNumber,
            orElse: () => ColorPalette(id: pixelNumber, color: Colors.grey),
          );
          paint.color = colorPalette.color;
        } else {
          // Show grey for unfilled
          paint.color = Colors.grey[300]!;
        }
        
        canvas.drawRect(rect, paint);
        
        // Draw subtle border
        final borderPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5
          ..color = Colors.grey[400]!;
        
        canvas.drawRect(rect, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(PixelArtPreviewPainter oldDelegate) {
    return progress.percentComplete != oldDelegate.progress.percentComplete;
  }
}
