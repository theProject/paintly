import 'package:flutter/material.dart';
import '../../providers/scene_provider.dart';

class DemoScenes {
  static List<SceneData> getAllScenes() {
    return [
      _createDentistOfficeScene(),
      _createBeachScene(),
      _createSpaceScene(),
      _createFarmScene(),
    ];
  }

  static SceneData _createDentistOfficeScene() {
    return SceneData(
      id: 'dentist_office',
      name: 'Dentist Office',
      backgroundImage: 'assets/scenes/dentist_bg.png',
      colorRegions: [
        ColorRegion(
          id: 'chair',
          targetColor: Colors.blue,
          svgPath: 'chair_path',
        ),
        ColorRegion(
          id: 'table',
          targetColor: Colors.brown,
          svgPath: 'table_path',
        ),
        ColorRegion(
          id: 'lamp',
          targetColor: Colors.yellow,
          svgPath: 'lamp_path',
        ),
      ],
      draggableItems: [
        DraggableItem(
          id: '🦷',
          imagePath: 'assets/scenes/tooth.png',
          initialPosition: const Offset(50, 100),
          size: const Size(60, 60),
        ),
        DraggableItem(
          id: '🪥',
          imagePath: 'assets/scenes/toothbrush.png',
          initialPosition: const Offset(250, 150),
          size: const Size(80, 40),
        ),
      ],
      colorPalette: [
        Colors.blue,
        Colors.brown,
        Colors.yellow,
        Colors.green,
        Colors.pink,
      ],
    );
  }

  static SceneData _createBeachScene() {
    return SceneData(
      id: 'beach',
      name: 'Sunny Beach',
      backgroundImage: 'assets/scenes/beach_bg.png',
      colorRegions: [
        ColorRegion(
          id: 'umbrella',
          targetColor: Colors.red,
          svgPath: 'umbrella_path',
        ),
        ColorRegion(
          id: 'sandcastle',
          targetColor: Colors.orange,
          svgPath: 'sandcastle_path',
        ),
        ColorRegion(
          id: 'ball',
          targetColor: Colors.purple,
          svgPath: 'ball_path',
        ),
      ],
      draggableItems: [
        DraggableItem(
          id: '🏖️',
          imagePath: 'assets/scenes/beach_chair.png',
          initialPosition: const Offset(100, 200),
          size: const Size(80, 80),
        ),
        DraggableItem(
          id: '🦀',
          imagePath: 'assets/scenes/crab.png',
          initialPosition: const Offset(200, 250),
          size: const Size(60, 60),
        ),
      ],
      colorPalette: [
        Colors.red,
        Colors.orange,
        Colors.purple,
        Colors.blue,
        Colors.yellow,
      ],
    );
  }

  static SceneData _createSpaceScene() {
    return SceneData(
      id: 'space',
      name: 'Outer Space',
      backgroundImage: 'assets/scenes/space_bg.png',
      colorRegions: [
        ColorRegion(
          id: 'rocket',
          targetColor: Colors.red,
          svgPath: 'rocket_path',
        ),
        ColorRegion(
          id: 'planet',
          targetColor: Colors.green,
          svgPath: 'planet_path',
        ),
        ColorRegion(
          id: 'stars',
          targetColor: Colors.yellow,
          svgPath: 'stars_path',
        ),
      ],
      draggableItems: [
        DraggableItem(
          id: '🚀',
          imagePath: 'assets/scenes/rocket.png',
          initialPosition: const Offset(150, 100),
          size: const Size(70, 100),
        ),
        DraggableItem(
          id: '👽',
          imagePath: 'assets/scenes/alien.png',
          initialPosition: const Offset(250, 200),
          size: const Size(60, 60),
        ),
      ],
      colorPalette: [
        Colors.red,
        Colors.green,
        Colors.yellow,
        Colors.purple,
        Colors.blue,
      ],
    );
  }

  static SceneData _createFarmScene() {
    return SceneData(
      id: 'farm',
      name: 'Happy Farm',
      backgroundImage: 'assets/scenes/farm_bg.png',
      colorRegions: [
        ColorRegion(
          id: 'barn',
          targetColor: Colors.red,
          svgPath: 'barn_path',
        ),
        ColorRegion(
          id: 'tractor',
          targetColor: Colors.green,
          svgPath: 'tractor_path',
        ),
        ColorRegion(
          id: 'fence',
          targetColor: Colors.brown,
          svgPath: 'fence_path',
        ),
      ],
      draggableItems: [
        DraggableItem(
          id: '🐄',
          imagePath: 'assets/scenes/cow.png',
          initialPosition: const Offset(100, 150),
          size: const Size(80, 70),
        ),
        DraggableItem(
          id: '🐔',
          imagePath: 'assets/scenes/chicken.png',
          initialPosition: const Offset(220, 180),
          size: const Size(50, 50),
        ),
      ],
      colorPalette: [
        Colors.red,
        Colors.green,
        Colors.brown,
        Colors.yellow,
        Colors.orange,
      ],
    );
  }
}