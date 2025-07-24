import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pixel_art.dart';
import '../providers/coloring_provider.dart';

class PixelGridWidget extends StatelessWidget {
  final PixelArt pixelArt;

  const PixelGridWidget({super.key, required this.pixelArt});

  @override
  Widget build(BuildContext context) {
    return Consumer<ColoringProvider>(
      builder: (context, provider, child) {
        // Calculate cell size based on screen dimensions
        final screenSize = MediaQuery.of(context).size;
        final maxWidth = screenSize.width * 0.8;
        final maxHeight = screenSize.height * 0.6;
        
        final cellSize = _calculateCellSize(
          maxWidth,
          maxHeight,
          pixelArt.width,
          pixelArt.height,
        );

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(pixelArt.height, (row) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(pixelArt.width, (col) {
                  return _buildPixelCell(context, provider, row, col, cellSize);
                }),
              );
            }),
          ),
        );
      },
    );
  }

  /// Build individual pixel cell
  Widget _buildPixelCell(
    BuildContext context,
    ColoringProvider provider,
    int row,
    int col,
    double cellSize,
  ) {
    final pixelNumber = pixelArt.pixels[row][col];
    final isFilled = provider.filledPixels[row][col];
    final pixelColor = provider.pixelColors[row][col];
    final shouldHighlight = provider.shouldHighlightPixel(row, col);

    // Empty pixel (0)
    if (pixelNumber == 0) {
      return Container(
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!, width: 0.5),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        provider.fillPixel(row, col);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          color: isFilled
              ? pixelColor
              : shouldHighlight
                  ? Colors.grey[300]
                  : Colors.white,
          border: Border.all(
            color: shouldHighlight ? Colors.black : Colors.grey[400]!,
            width: shouldHighlight ? 1.5 : 0.5,
          ),
        ),
        child: !isFilled
            ? Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: cellSize * 0.4,
                    fontWeight: FontWeight.bold,
                    color: shouldHighlight ? Colors.black : Colors.grey[600],
                  ),
                  child: Text('$pixelNumber'),
                ),
              )
            : null,
      ),
    );
  }

  /// Calculate optimal cell size
  double _calculateCellSize(
    double maxWidth,
    double maxHeight,
    int gridWidth,
    int gridHeight,
  ) {
    final widthBasedSize = maxWidth / gridWidth;
    final heightBasedSize = maxHeight / gridHeight;
    return widthBasedSize < heightBasedSize ? widthBasedSize : heightBasedSize;
  }
}