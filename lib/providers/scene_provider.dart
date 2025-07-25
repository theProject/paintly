import 'package:flutter/material.dart';

class SceneProvider extends ChangeNotifier {
  // Current scene data
  SceneData? _currentScene;
  
  // Map of region ID to filled color
  final Map<String, Color?> _filledRegions = {};
  
  // Currently selected color
  Color? _selectedColor;
  
  // Track draggable positions
  final Map<String, Offset> _draggablePositions = {};

  SceneData? get currentScene => _currentScene;
  Map<String, Color?> get filledRegions => _filledRegions;
  Color? get selectedColor => _selectedColor;
  Map<String, Offset> get draggablePositions => _draggablePositions;

  void loadScene(SceneData scene) {
    _currentScene = scene;
    _filledRegions.clear();
    _draggablePositions.clear();
    
    // Initialize draggable positions
    for (var item in scene.draggableItems) {
      _draggablePositions[item.id] = item.initialPosition;
    }
    
    notifyListeners();
  }

  void selectColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  void fillRegion(String regionId) {
    if (_selectedColor != null && _currentScene != null) {
      // Check if this region should be filled with the selected color
      final region = _currentScene!.colorRegions.firstWhere(
        (r) => r.id == regionId,
        orElse: () => ColorRegion(id: '', targetColor: Colors.transparent, svgPath: ''),
      );
      
      if (region.targetColor == _selectedColor) {
        _filledRegions[regionId] = _selectedColor;
        notifyListeners();
      }
    }
  }

  void updateDraggablePosition(String itemId, Offset newPosition) {
    _draggablePositions[itemId] = newPosition;
    notifyListeners();
  }

  double getProgress() {
    if (_currentScene == null) return 0.0;
    
    final totalRegions = _currentScene!.colorRegions.length;
    final filledCount = _filledRegions.length;
    
    return totalRegions > 0 ? filledCount / totalRegions : 0.0;
  }

  bool isComplete() {
    if (_currentScene == null) return false;
    return _filledRegions.length == _currentScene!.colorRegions.length;
  }
}

// Data models for scenes
class SceneData {
  final String id;
  final String name;
  final String backgroundImage;
  final List<ColorRegion> colorRegions;
  final List<DraggableItem> draggableItems;
  final List<Color> colorPalette;

  SceneData({
    required this.id,
    required this.name,
    required this.backgroundImage,
    required this.colorRegions,
    required this.draggableItems,
    required this.colorPalette,
  });
}

class ColorRegion {
  final String id;
  final Color targetColor;
  final String svgPath;

  ColorRegion({
    required this.id,
    required this.targetColor,
    required this.svgPath,
  });
}

class DraggableItem {
  final String id;
  final String imagePath;
  final Offset initialPosition;
  final Size size;

  DraggableItem({
    required this.id,
    required this.imagePath,
    required this.initialPosition,
    required this.size,
  });
}