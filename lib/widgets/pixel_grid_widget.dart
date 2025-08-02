import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pixel_art.dart';
import '../providers/coloring_provider.dart';
import '../providers/settings_provider.dart';

class PixelGridWidget extends StatefulWidget {
  final PixelArt pixelArt;

  const PixelGridWidget({super.key, required this.pixelArt});

  @override
  State<PixelGridWidget> createState() => _PixelGridWidgetState();
}

class _PixelGridWidgetState extends State<PixelGridWidget> {
  // Track if we're currently dragging
  bool _isDragging = false;
  
  @override
  Widget build(BuildContext context) {
    return Consumer2<ColoringProvider, SettingsProvider>(
      builder: (context, provider, settings, child) {
        // Calculate cell size based on screen dimensions
        final screenSize = MediaQuery.of(context).size;
        final maxWidth = screenSize.width * 0.8;
        final maxHeight = screenSize.height * 0.6;
        
        final cellSize = _calculateCellSize(
          maxWidth,
          maxHeight,
          widget.pixelArt.width,
          widget.pixelArt.height,
        );

        return GestureDetector(
          // Handle drag start
          onPanStart: settings.dragToPaintEnabled ? (details) {
            _isDragging = true;
            _handleTouch(details.localPosition, provider, cellSize);
          } : null,
          // Handle drag update
          onPanUpdate: settings.dragToPaintEnabled ? (details) {
            if (_isDragging) {
              _handleTouch(details.localPosition, provider, cellSize);
            }
          } : null,
          // Handle drag end
          onPanEnd: settings.dragToPaintEnabled ? (details) {
            _isDragging = false;
          } : null,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.pixelArt.height, (row) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(widget.pixelArt.width, (col) {
                    return _buildPixelCell(context, provider, settings, row, col, cellSize);
                  }),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  /// Handle touch/drag at a specific position
  void _handleTouch(Offset localPosition, ColoringProvider provider, double cellSize) {
    // Calculate which cell was touched
    final col = (localPosition.dx / cellSize).floor();
    final row = (localPosition.dy / cellSize).floor();
    
    // Check bounds
    if (row >= 0 && row < widget.pixelArt.height && 
        col >= 0 && col < widget.pixelArt.width) {
      provider.fillPixel(row, col);
    }
  }

  /// Build individual pixel cell
  Widget _buildPixelCell(
    BuildContext context,
    ColoringProvider provider,
    SettingsProvider settings,
    int row,
    int col,
    double cellSize,
  ) {
    final pixelNumber = widget.pixelArt.pixels[row][col];
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
      onTap: !settings.dragToPaintEnabled ? () {
        provider.fillPixel(row, col);
        settings.playSound('paint.mp3');
      } : null,
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
          borderRadius: BorderRadius.circular(2),
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
