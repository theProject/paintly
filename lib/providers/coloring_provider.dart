import 'package:flutter/material.dart';
import '../models/pixel_art.dart';

/// Provider class to manage the coloring state
class ColoringProvider extends ChangeNotifier {
  // Current pixel art being colored
  PixelArt? _currentPixelArt;
  
  // 2D array tracking which pixels are filled
  List<List<bool>> _filledPixels = [];
  
  // 2D array storing the actual colors of filled pixels
  List<List<Color?>> _pixelColors = [];
  
  // Currently selected color ID
  int? _selectedColorId;
  
  // Map tracking which colors are completely filled
  Map<int, bool> _completedColors = {};
  
  // Flag to check if provider is initialized
  bool _isInitialized = false;

  // Getters
  PixelArt? get currentPixelArt => _currentPixelArt;
  List<List<bool>> get filledPixels => _filledPixels;
  List<List<Color?>> get pixelColors => _pixelColors;
  int? get selectedColorId => _selectedColorId;
  Map<int, bool> get completedColors => _completedColors;
  bool get isInitialized => _isInitialized;

  /// Initialize the provider with a new pixel art
  void initializePixelArt(PixelArt pixelArt) {
    _currentPixelArt = pixelArt;
    _filledPixels = List.generate(
      pixelArt.height,
      (row) => List.generate(pixelArt.width, (col) => false),
    );
    _pixelColors = List.generate(
      pixelArt.height,
      (row) => List.generate(pixelArt.width, (col) => null),
    );
    _completedColors = {};
    _selectedColorId = null;
    _isInitialized = true;
    
    // Initialize completed colors map
    for (var color in pixelArt.palette) {
      _completedColors[color.id] = false;
    }
    
    notifyListeners();
  }

  /// Select a color from the palette
  void selectColor(int colorId) {
    _selectedColorId = colorId;
    notifyListeners();
  }

  /// Fill a pixel at the given position
  void fillPixel(int row, int col) {
    if (_currentPixelArt == null || _selectedColorId == null) return;
    
    // Check if this pixel should be filled with the selected color
    final pixelNumber = _currentPixelArt!.pixels[row][col];
    if (pixelNumber != _selectedColorId || pixelNumber == 0) return;
    
    // Find the color in the palette
    final colorPalette = _currentPixelArt!.palette.firstWhere(
      (p) => p.id == _selectedColorId,
    );
    
    // Fill the pixel
    _filledPixels[row][col] = true;
    _pixelColors[row][col] = colorPalette.color;
    
    // Check if this color is now complete
    _checkColorCompletion(_selectedColorId!);
    
    notifyListeners();
  }

  /// Check if all pixels of a specific color are filled
  void _checkColorCompletion(int colorId) {
    if (_currentPixelArt == null) return;
    
    bool isComplete = true;
    
    for (int row = 0; row < _currentPixelArt!.height; row++) {
      for (int col = 0; col < _currentPixelArt!.width; col++) {
        if (_currentPixelArt!.pixels[row][col] == colorId && 
            !_filledPixels[row][col]) {
          isComplete = false;
          break;
        }
      }
      if (!isComplete) break;
    }
    
    _completedColors[colorId] = isComplete;
  }

  /// Get the progress percentage
  double getProgress() {
    if (_currentPixelArt == null) return 0.0;
    
    int totalPixels = 0;
    int filledCount = 0;
    
    for (int row = 0; row < _currentPixelArt!.height; row++) {
      for (int col = 0; col < _currentPixelArt!.width; col++) {
        if (_currentPixelArt!.pixels[row][col] != 0) {
          totalPixels++;
          if (_filledPixels[row][col]) {
            filledCount++;
          }
        }
      }
    }
    
    return totalPixels > 0 ? filledCount / totalPixels : 0.0;
  }

  /// Check if a specific pixel should be highlighted
  bool shouldHighlightPixel(int row, int col) {
    if (_currentPixelArt == null || _selectedColorId == null) return false;
    
    final pixelNumber = _currentPixelArt!.pixels[row][col];
    return pixelNumber == _selectedColorId && !_filledPixels[row][col];
  }
}