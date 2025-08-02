// lib/scene_mode/data/demo_scenes.dart
import 'package:flutter/material.dart';
import '../../providers/scene_provider.dart';

class DemoScenes {
  static List<SceneData> getAllScenes() {
    return [
      SceneData(
        id: 'forest_scene',
        name: 'Enchanted Forest',
        backgroundImage: 'assets/scenes/forest_bg.png',
        colorRegions: [
          ColorRegion(
            id: 'tree_1',
            targetColor: Colors.green,
            svgPath: 'tree_path',
          ),
          ColorRegion(
            id: 'tree_2',
            targetColor: Colors.brown,
            svgPath: 'trunk_path',
          ),
        ],
        draggableItems: [
          DraggableItem(
            id: 'bird_1',
            imagePath: 'assets/scenes/bird.png',
            initialPosition: const Offset(100, 100),
            size: const Size(50, 50),
          ),
        ],
        colorPalette: [
          Colors.green,
          Colors.brown,
          Colors.blue,
          Colors.yellow,
        ],
        category: 'Nature',
      ),
      SceneData(
        id: 'ocean_scene',
        name: 'Ocean Adventure',
        backgroundImage: 'assets/scenes/ocean_bg.png',
        colorRegions: [
          ColorRegion(
            id: 'wave_1',
            targetColor: Colors.blue,
            svgPath: 'wave_path',
          ),
          ColorRegion(
            id: 'fish_1',
            targetColor: Colors.orange,
            svgPath: 'fish_path',
          ),
        ],
        draggableItems: [
          DraggableItem(
            id: 'shell_1',
            imagePath: 'assets/scenes/shell.png',
            initialPosition: const Offset(200, 150),
            size: const Size(40, 40),
          ),
        ],
        colorPalette: [
          Colors.blue,
          Colors.orange,
          Colors.teal,
          Colors.pink,
        ],
        category: 'Ocean',
      ),
    ];
  }
}