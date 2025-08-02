import 'package:flutter/material.dart';
import '../scene_mode/data/demo_scenes.dart';

class SceneProvider extends ChangeNotifier {
  // Current scene data
  SceneData? _currentScene;
  
  // Map of region ID to filled color
  final Map<String, Color?> _filledRegions = {};
  
  // Currently selected color
  Color? _selectedColor;
  
  // Track draggable positions
  final Map<String, Offset> _draggablePositions = {};
  
  // List of all available scenes
  List<SceneData> _availableScenes = [];
  
  // Search query for filtering scenes
  String _searchQuery = '';
  
  // Selected category for filtering
  String? _selectedCategory;

  SceneData? get currentScene => _currentScene;
  Map<String, Color?> get filledRegions => _filledRegions;
  Color? get selectedColor => _selectedColor;
  Map<String, Offset> get draggablePositions => _draggablePositions;
  List<SceneData> get availableScenes => _availableScenes;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  SceneProvider() {
    _loadScenes();
  }

  void _loadScenes() {
    _availableScenes = DemoScenes.getAllScenes();
    notifyListeners();
  }

  void loadScene(SceneData scene) {
    _currentScene = scene;
    _filledRegions.clear();
    _draggablePositions.clear();
    _selectedColor = null;
    
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

  // Methods for scene selection screen
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<SceneData> getFilteredScenes() {
    var filtered = _availableScenes;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((scene) {
        return scene.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // TODO: filter by category once SceneData supports it
    // For now, returning all filtered scenes
    
    return filtered;
  }

  void resetScene() {
    if (_currentScene != null) {
      _filledRegions.clear();
      _selectedColor = null;
      
      // Reset draggable positions to initial
      for (var item in _currentScene!.draggableItems) {
        _draggablePositions[item.id] = item.initialPosition;
      }
      
      notifyListeners();
    }
  }

  // Get scene by ID
  SceneData? getSceneById(String id) {
    try {
      return _availableScenes.firstWhere((scene) => scene.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get color palette for current scene
  List<Color> getCurrentScenePalette() {
    if (_currentScene == null) return [];
    return _currentScene!.colorPalette;
  }

  // Check if a specific color is completed (all regions with that color are filled)
  bool isColorCompleted(Color color) {
    if (_currentScene == null) return false;
    
    final regionsWithColor = _currentScene!.colorRegions
        .where((region) => region.targetColor == color);
    
    if (regionsWithColor.isEmpty) return true;
    
    return regionsWithColor.every((region) => 
        _filledRegions.containsKey(region.id) && 
        _filledRegions[region.id] == color
    );
  }

  // Get number of regions for a specific color
  int getRegionCountForColor(Color color) {
    if (_currentScene == null) return 0;
    return _currentScene!.colorRegions
        .where((region) => region.targetColor == color)
        .length;
  }

  // Get filled region count for a specific color
  int getFilledRegionCountForColor(Color color) {
    if (_currentScene == null) return 0;
    return _currentScene!.colorRegions
        .where((region) => 
            region.targetColor == color && 
            _filledRegions.containsKey(region.id) &&
            _filledRegions[region.id] == color)
        .length;
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
  final String? category; // Added category support

  SceneData({
    required this.id,
    required this.name,
    required this.backgroundImage,
    required this.colorRegions,
    required this.draggableItems,
    required this.colorPalette,
    this.category,
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