import 'package:flutter/material.dart';
import '../../models/magic_object.dart';

/// Complete category and object definitions for Magic Mode
class MagicCategories {
  /// Get all available categories
  static List<MagicCategory> getAllCategories() {
    return [
      MagicCategory(
        id: 'characters',
        name: 'Characters',
        icon: Icons.face_rounded,
        color: const Color(0xFFFF6B6B),
        description: 'Color fun characters!',
      ),
      MagicCategory(
        id: 'farm',
        name: 'Farm',
        icon: Icons.agriculture_rounded,
        color: const Color(0xFF4ECDC4),
        description: 'Animals and farm life',
      ),
      MagicCategory(
        id: 'ocean',
        name: 'Ocean',
        icon: Icons.water_rounded,
        color: const Color(0xFF45B7D1),
        description: 'Underwater adventures',
      ),
      MagicCategory(
        id: 'city',
        name: 'City',
        icon: Icons.location_city_rounded,
        color: const Color(0xFF96CEB4),
        description: 'Urban exploration',
      ),
      MagicCategory(
        id: 'forest',
        name: 'Forest',
        icon: Icons.forest_rounded,
        color: const Color(0xFF88D8B0),
        description: 'Nature and wildlife',
      ),
    ];
  }

  /// Get objects for a specific category
  static List<MagicObject> getObjectsForCategory(String categoryId) {
    return categoryObjects[categoryId] ?? [];
  }

  /// All objects organized by category
  static final Map<String, List<MagicObject>> categoryObjects = {
    'characters': [
      MagicObject(
        id: 'princess',
        name: 'Princess',
        svgPath: 'assets/svg/magic/characters/princess.svg',
        previewIcon: '👸',
        predefinedColors: {
          'face': const Color(0xFFFFDBBF),
          'eyes': const Color(0xFF4A90E2),
          'lips': const Color(0xFFFF6B6B),
          'hair_base': const Color(0xFF8B4513),
        },
        customizableRegions: {
          'dress': [
            const Color(0xFFFF6B6B), // Red
            const Color(0xFFFF69B4), // Pink
            const Color(0xFF9B59B6), // Purple
            const Color(0xFF3498DB), // Blue
            const Color(0xFFF39C12), // Gold
            const Color(0xFF2ECC71), // Green
            const Color(0xFFE74C3C), // Crimson
            const Color(0xFF1ABC9C), // Turquoise
          ],
          'accessories': [
            const Color(0xFFFFD700), // Gold
            const Color(0xFFC0C0C0), // Silver
            const Color(0xFFFF1493), // Deep Pink
            const Color(0xFF4169E1), // Royal Blue
          ],
          'shoes': [
            const Color(0xFFFF6B6B), // Red
            const Color(0xFF000000), // Black
            const Color(0xFFFFD700), // Gold
            const Color(0xFFC0C0C0), // Silver
          ],
        },
      ),
      MagicObject(
        id: 'knight',
        name: 'Knight',
        svgPath: 'assets/svg/magic/characters/knight.svg',
        previewIcon: '🤴',
        predefinedColors: {
          'face': const Color(0xFFFFDBBF),
          'eyes': const Color(0xFF654321),
          'helmet_base': const Color(0xFF708090),
        },
        customizableRegions: {
          'armor': [
            const Color(0xFFC0C0C0), // Silver
            const Color(0xFFFFD700), // Gold
            const Color(0xFF708090), // Slate Gray
            const Color(0xFF000000), // Black
            const Color(0xFFB87333), // Copper
          ],
          'cape': [
            const Color(0xFFDC143C), // Crimson
            const Color(0xFF4B0082), // Indigo
            const Color(0xFF228B22), // Forest Green
            const Color(0xFF800080), // Purple
            const Color(0xFF000080), // Navy
          ],
          'shield_emblem': [
            const Color(0xFFFFD700), // Gold
            const Color(0xFFC0C0C0), // Silver
            const Color(0xFFFF0000), // Red
            const Color(0xFF0000FF), // Blue
          ],
        },
      ),
      MagicObject(
        id: 'wizard',
        name: 'Wizard',
        svgPath: 'assets/svg/magic/characters/wizard.svg',
        previewIcon: '🧙‍♂️',
        predefinedColors: {
          'face': const Color(0xFFFFDBBF),
          'eyes': const Color(0xFF4682B4),
          'beard': const Color(0xFFE5E5E5),
        },
        customizableRegions: {
          'robe': [
            const Color(0xFF4B0082), // Indigo
            const Color(0xFF191970), // Midnight Blue
            const Color(0xFF8B008B), // Dark Magenta
            const Color(0xFF2F4F4F), // Dark Slate Gray
            const Color(0xFF800000), // Maroon
          ],
          'hat': [
            const Color(0xFF4B0082), // Indigo
            const Color(0xFF000080), // Navy
            const Color(0xFF800080), // Purple
            const Color(0xFF483D8B), // Dark Slate Blue
          ],
          'stars': [
            const Color(0xFFFFD700), // Gold
            const Color(0xFFC0C0C0), // Silver
            const Color(0xFFFFFFFF), // White
            const Color(0xFFD2691E), // Chocolate
            const Color(0xFFFFD700), // Gold
          ],
          'tail': [
            const Color(0xFF000000), // Black
            const Color(0xFF8B4513), // Brown
            const Color(0xFFFFFFFF), // White
            const Color(0xFFD2691E), // Chocolate
          ],
        },
      ),
      MagicObject(
        id: 'farmer',
        name: 'Farmer',
        svgPath: 'assets/svg/magic/farm/farmer.svg',
        previewIcon: '👨‍🌾',
        predefinedColors: {
          'face': const Color(0xFFFFDBBF),
          'eyes': const Color(0xFF654321),
          'hair': const Color(0xFF8B4513),
        },
        customizableRegions: {
          'shirt': [
            const Color(0xFF0000FF), // Blue
            const Color(0xFFFF0000), // Red
            const Color(0xFF228B22), // Green
            const Color(0xFFFFFF00), // Yellow
            const Color(0xFFFFA500), // Orange
          ],
          'overalls': [
            const Color(0xFF4169E1), // Royal Blue
            const Color(0xFF708090), // Slate Gray
            const Color(0xFF8B4513), // Brown
            const Color(0xFF000080), // Navy
          ],
          'hat': [
            const Color(0xFFDEB887), // Burlywood
            const Color(0xFF8B4513), // Brown
            const Color(0xFFFF0000), // Red
            const Color(0xFF228B22), // Green
          ],
        },
      ),
    ],
    
    'ocean': [
      MagicObject(
        id: 'fish',
        name: 'Fish',
        svgPath: 'assets/svg/magic/ocean/fish.svg',
        previewIcon: '🐠',
        predefinedColors: {
          'eye': const Color(0xFF000000),
          'pupil': const Color(0xFFFFFFFF),
          'mouth': const Color(0xFF000000),
        },
        customizableRegions: {
          'body': [
            const Color(0xFFFF6347), // Coral
            const Color(0xFF4169E1), // Royal Blue
            const Color(0xFFFFD700), // Gold
            const Color(0xFF32CD32), // Lime Green
            const Color(0xFFFF1493), // Deep Pink
            const Color(0xFF00CED1), // Dark Turquoise
            const Color(0xFFFFA500), // Orange
            const Color(0xFF9370DB), // Medium Purple
          ],
          'fins': [
            const Color(0xFFFF6347), // Coral
            const Color(0xFF4169E1), // Royal Blue
            const Color(0xFFFFD700), // Gold
            const Color(0xFF00CED1), // Dark Turquoise
            const Color(0xFF98FB98), // Pale Green
          ],
          'stripes': [
            const Color(0xFFFFFFFF), // White
            const Color(0xFF000000), // Black
            const Color(0xFFFFD700), // Gold
            const Color(0xFFC0C0C0), // Silver
          ],
        },
      ),
      MagicObject(
        id: 'octopus',
        name: 'Octopus',
        svgPath: 'assets/svg/magic/ocean/octopus.svg',
        previewIcon: '🐙',
        predefinedColors: {
          'eyes': const Color(0xFF000000),
          'pupils': const Color(0xFFFFFFFF),
        },
        customizableRegions: {
          'body': [
            const Color(0xFFFF6347), // Coral
            const Color(0xFF9370DB), // Purple
            const Color(0xFFFF1493), // Deep Pink
            const Color(0xFFFFA500), // Orange
            const Color(0xFF4169E1), // Royal Blue
            const Color(0xFF00CED1), // Dark Turquoise
          ],
          'tentacles': [
            const Color(0xFFFF6347), // Coral
            const Color(0xFF9370DB), // Purple
            const Color(0xFFFF1493), // Deep Pink
            const Color(0xFFFFA500), // Orange
          ],
          'suction_cups': [
            const Color(0xFFFFB6C1), // Light Pink
            const Color(0xFFDDA0DD), // Plum
            const Color(0xFFF0E68C), // Khaki
          ],
        },
      ),
      MagicObject(
        id: 'whale',
        name: 'Whale',
        svgPath: 'assets/svg/magic/ocean/whale.svg',
        previewIcon: '🐋',
        predefinedColors: {
          'eye': const Color(0xFF000000),
          'blowhole': const Color(0xFF4682B4),
        },
        customizableRegions: {
          'body': [
            const Color(0xFF4682B4), // Steel Blue
            const Color(0xFF191970), // Midnight Blue
            const Color(0xFF708090), // Slate Gray
            const Color(0xFF000080), // Navy
            const Color(0xFF483D8B), // Dark Slate Blue
          ],
          'belly': [
            const Color(0xFFFFFFFF), // White
            const Color(0xFFF0F8FF), // Alice Blue
            const Color(0xFFE0FFFF), // Light Cyan
          ],
        },
      ),
      MagicObject(
        id: 'seahorse',
        name: 'Seahorse',
        svgPath: 'assets/svg/magic/ocean/seahorse.svg',
        previewIcon: '🌊',
        predefinedColors: {
          'eye': const Color(0xFF000000),
          'snout': const Color(0xFFFFA500),
        },
        customizableRegions: {
          'body': [
            const Color(0xFFFFD700), // Gold
            const Color(0xFFFF6347), // Coral
            const Color(0xFF98FB98), // Pale Green
            const Color(0xFF87CEEB), // Sky Blue
            const Color(0xFFDDA0DD), // Plum
            const Color(0xFFFFA500), // Orange
          ],
          'fins': [
            const Color(0xFF87CEEB), // Sky Blue
            const Color(0xFFFFB6C1), // Light Pink
            const Color(0xFF98FB98), // Pale Green
          ],
        },
      ),
      MagicObject(
        id: 'dolphin',
        name: 'Dolphin',
        svgPath: 'assets/svg/magic/ocean/dolphin.svg',
        previewIcon: '🐬',
        predefinedColors: {
          'eye': const Color(0xFF000000),
          'blowhole': const Color(0xFF708090),
        },
        customizableRegions: {
          'body': [
            const Color(0xFF708090), // Slate Gray
            const Color(0xFF4682B4), // Steel Blue
            const Color(0xFF87CEEB), // Sky Blue
            const Color(0xFF00CED1), // Dark Turquoise
            const Color(0xFFB0C4DE), // Light Steel Blue
          ],
          'belly': [
            const Color(0xFFFFFFFF), // White
            const Color(0xFFF0F8FF), // Alice Blue
            const Color(0xFFF5F5F5), // White Smoke
          ],
        },
      ),
      MagicObject(
        id: 'turtle',
        name: 'Sea Turtle',
        svgPath: 'assets/svg/magic/ocean/turtle.svg',
        previewIcon: '🐢',
        predefinedColors: {
          'eyes': const Color(0xFF000000),
          'head': const Color(0xFF228B22),
        },
        customizableRegions: {
          'shell': [
            const Color(0xFF228B22), // Forest Green
            const Color(0xFF8B4513), // Saddle Brown
            const Color(0xFF556B2F), // Dark Olive Green
            const Color(0xFF2E8B57), // Sea Green
            const Color(0xFF006400), // Dark Green
          ],
          'shell_pattern': [
            const Color(0xFFFFD700), // Gold
            const Color(0xFF8B4513), // Brown
            const Color(0xFF000000), // Black
            const Color(0xFF228B22), // Green
          ],
          'flippers': [
            const Color(0xFF228B22), // Forest Green
            const Color(0xFF2E8B57), // Sea Green
            const Color(0xFF3CB371), // Medium Sea Green
          ],
        },
      ),
    ],
    
    'city': [
      MagicObject(
        id: 'car',
        name: 'Car',
        svgPath: 'assets/svg/magic/city/car.svg',
        previewIcon: '🚗',
        predefinedColors: {
          'windows': const Color(0xFF87CEEB),
          'wheels': const Color(0xFF000000),
          'headlights': const Color(0xFFFFFF00),
          'taillights': const Color(0xFFFF0000),
        },
        customizableRegions: {
          'body': [
            const Color(0xFFFF0000), // Red
            const Color(0xFF0000FF), // Blue
            const Color(0xFF00FF00), // Green
            const Color(0xFFFFFF00), // Yellow
            const Color(0xFFFF69B4), // Pink
            const Color(0xFF800080), // Purple
            const Color(0xFFFFA500), // Orange
            const Color(0xFF000000), // Black
            const Color(0xFFFFFFFF), // White
            const Color(0xFFC0C0C0), // Silver
          ],
          'details': [
            const Color(0xFFC0C0C0), // Silver
            const Color(0xFFFFD700), // Gold
            const Color(0xFF000000), // Black
            const Color(0xFFFFFFFF), // White
          ],
        },
      ),
      MagicObject(
        id: 'bus',
        name: 'Bus',
        svgPath: 'assets/svg/magic/city/bus.svg',
        previewIcon: '🚌',
        predefinedColors: {
          'windows': const Color(0xFF87CEEB),
          'wheels': const Color(0xFF000000),
          'door': const Color(0xFF708090),
        },
        customizableRegions: {
          'body': [
            const Color(0xFFFFFF00), // Yellow (School Bus)
            const Color(0xFFFF0000), // Red
            const Color(0xFF0000FF), // Blue
            const Color(0xFF228B22), // Green
            const Color(0xFFFFA500), // Orange
            const Color(0xFF800080), // Purple
          ],
          'stripes': [
            const Color(0xFF000000), // Black
            const Color(0xFFFFFFFF), // White
            const Color(0xFFC0C0C0), // Silver
          ],
        },
      ),
      MagicObject(
        id: 'building',
        name: 'Building',
        svgPath: 'assets/svg/magic/city/building.svg',
        previewIcon: '🏢',
        predefinedColors: {
          'windows': const Color(0xFF87CEEB),
          'door': const Color(0xFF8B4513),
        },
        customizableRegions: {
          'walls': [
            const Color(0xFFD3D3D3), // Light Gray
            const Color(0xFFDEB887), // Burlywood
            const Color(0xFFCD853F), // Peru
            const Color(0xFFFF6347), // Tomato
            const Color(0xFF4682B4), // Steel Blue
            const Color(0xFFFFFFFF), // White
          ],
          'roof': [
            const Color(0xFF8B0000), // Dark Red
            const Color(0xFF708090), // Slate Gray
            const Color(0xFF2F4F4F), // Dark Slate Gray
            const Color(0xFF8B4513), // Brown
          ],
        },
      ),
      MagicObject(
        id: 'helicopter',
        name: 'Helicopter',
        svgPath: 'assets/svg/magic/city/helicopter.svg',
        previewIcon: '🚁',
        predefinedColors: {
          'windows': const Color(0xFF87CEEB),
          'rotor': const Color(0xFF708090),
          'tail_light': const Color(0xFFFF0000),
        },
        customizableRegions: {
          'body': [
            const Color(0xFFFF0000), // Red
            const Color(0xFF0000FF), // Blue
            const Color(0xFFFFFF00), // Yellow
            const Color(0xFF228B22), // Green
            const Color(0xFFFFA500), // Orange
            const Color(0xFF000080), // Navy
            const Color(0xFFFFFFFF), // White
          ],
          'stripes': [
            const Color(0xFF000000), // Black
            const Color(0xFFFFFFFF), // White
            const Color(0xFFFFD700), // Gold
          ],
        },
      ),
      MagicObject(
        id: 'firetruck',
        name: 'Fire Truck',
        svgPath: 'assets/svg/magic/city/firetruck.svg',
        previewIcon: '🚒',
        predefinedColors: {
          'windows': const Color(0xFF87CEEB),
          'wheels': const Color(0xFF000000),
          'lights': const Color(0xFFFF0000),
          'ladder': const Color(0xFFC0C0C0),
        },
        customizableRegions: {
          'body': [
            const Color(0xFFFF0000), // Traditional Red
            const Color(0xFFFFFF00), // Yellow
            const Color(0xFF32CD32), // Lime Green
            const Color(0xFFFFFFFF), // White
          ],
          'details': [
            const Color(0xFFFFD700), // Gold
            const Color(0xFFC0C0C0), // Silver
            const Color(0xFFFFFFFF), // White
          ],
        },
      ),
      MagicObject(
        id: 'policeman',
        name: 'Police Officer',
        svgPath: 'assets/svg/magic/city/policeman.svg',
        previewIcon: '👮',
        predefinedColors: {
          'face': const Color(0xFFFFDBBF),
          'eyes': const Color(0xFF654321),
          'badge': const Color(0xFFFFD700),
        },
        customizableRegions: {
          'uniform': [
            const Color(0xFF000080), // Navy Blue
            const Color(0xFF000000), // Black
            const Color(0xFF4169E1), // Royal Blue
            const Color(0xFF708090), // Slate Gray
          ],
          'hat': [
            const Color(0xFF000080), // Navy Blue
            const Color(0xFF000000), // Black
            const Color(0xFF4169E1), // Royal Blue
          ],
        },
      ),
    ],
    
    'forest': [
      MagicObject(
        id: 'tree',
        name: 'Tree',
        svgPath: 'assets/svg/magic/forest/tree.svg',
        previewIcon: '🌳',
        predefinedColors: {
          'trunk': const Color(0xFF8B4513),
          'branches': const Color(0xFF654321),
          'roots': const Color(0xFF654321),
        },
        customizableRegions: {
          'leaves': [
            const Color(0xFF228B22), // Forest Green
            const Color(0xFF32CD32), // Lime Green
            const Color(0xFFFF8C00), // Dark Orange (Autumn)
            const Color(0xFFFFD700), // Gold (Autumn)
            const Color(0xFFDC143C), // Crimson (Autumn)
            const Color(0xFF00FF00), // Bright Green
            const Color(0xFF556B2F), // Dark Olive Green
          ],
          'fruits': [
            const Color(0xFFFF0000), // Red Apple
            const Color(0xFFFFA500), // Orange
            const Color(0xFFFFFF00), // Lemon
            const Color(0xFF32CD32), // Green Apple
            const Color(0xFF8B008B), // Plum
          ],
        },
      ),
      MagicObject(
        id: 'butterfly',
        name: 'Butterfly',
        svgPath: 'assets/svg/magic/forest/butterfly.svg',
        previewIcon: '🦋',
        predefinedColors: {
          'body': const Color(0xFF000000),
          'antennae': const Color(0xFF000000),
          'eyes': const Color(0xFF000000),
        },
        customizableRegions: {
          'wings_upper': [
            const Color(0xFFFF69B4), // Hot Pink
            const Color(0xFF4169E1), // Royal Blue
            const Color(0xFFFFD700), // Gold
            const Color(0xFF9370DB), // Medium Purple
            const Color(0xFFFF6347), // Tomato
            const Color(0xFF00CED1), // Dark Turquoise
            const Color(0xFFFFA500), // Orange
          ],
          'wings_lower': [
            const Color(0xFF87CEEB), // Sky Blue
            const Color(0xFF98FB98), // Pale Green
            const Color(0xFFDDA0DD), // Plum
            const Color(0xFFF0E68C), // Khaki
            const Color(0xFFFFB6C1), // Light Pink
          ],
          'wing_patterns': [
            const Color(0xFF000000), // Black
            const Color(0xFFFFFFFF), // White
            const Color(0xFFFFD700), // Gold
            const Color(0xFFC0C0C0), // Silver
          ],
        },
      ),
      MagicObject(
        id: 'owl',
        name: 'Owl',
        svgPath: 'assets/svg/magic/forest/owl.svg',
        previewIcon: '🦉',
        predefinedColors: {
          'eyes': const Color(0xFFFFD700),
          'pupils': const Color(0xFF000000),
          'beak': const Color(0xFFFFA500),
        },
        customizableRegions: {
          'feathers': [
            const Color(0xFF8B4513), // Saddle Brown
            const Color(0xFFD2691E), // Chocolate
            const Color(0xFF696969), // Dim Gray
            const Color(0xFFF5DEB3), // Wheat
            const Color(0xFFDEB887), // Burlywood
          ],
          'chest_feathers': [
            const Color(0xFFF5DEB3), // Wheat
            const Color(0xFFFFFFFF), // White
            const Color(0xFFDEB887), // Burlywood
          ],
        },
      ),
      MagicObject(
        id: 'deer',
        name: 'Deer',
        svgPath: 'assets/svg/magic/forest/deer.svg',
        previewIcon: '🦌',
        predefinedColors: {
          'eyes': const Color(0xFF000000),
          'nose': const Color(0xFF000000),
          'hooves': const Color(0xFF000000),
        },
        customizableRegions: {
          'fur': [
            const Color(0xFF8B4513), // Saddle Brown
            const Color(0xFFD2691E), // Chocolate
            const Color(0xFFDEB887), // Burlywood
            const Color(0xFFA0522D), // Sienna
            const Color(0xFFCD853F), // Peru
          ],
          'antlers': [
            const Color(0xFF8B4513), // Brown
            const Color(0xFFD2691E), // Chocolate
            const Color(0xFFF5DEB3), // Wheat
          ],
          'spots': [
            const Color(0xFFFFFFFF), // White
            const Color(0xFFF5DEB3), // Wheat
            const Color(0xFFFFE4B5), // Moccasin
          ],
        },
      ),
      MagicObject(
        id: 'rabbit',
        name: 'Rabbit',
        svgPath: 'assets/svg/magic/forest/rabbit.svg',
        previewIcon: '🐰',
        predefinedColors: {
          'eyes': const Color(0xFF000000),
          'nose': const Color(0xFFFF69B4),
          'inner_ears': const Color(0xFFFFB6C1),
        },
        customizableRegions: {
          'fur': [
            const Color(0xFFFFFFFF), // White
            const Color(0xFF8B4513), // Brown
            const Color(0xFF696969), // Gray
            const Color(0xFF000000), // Black
            const Color(0xFFDEB887), // Burlywood
            const Color(0xFFD2691E), // Chocolate
          ],
          'tail': [
            const Color(0xFFFFFFFF), // White
            const Color(0xFFF5F5F5), // White Smoke
            const Color(0xFFDEB887), // Burlywood
          ],
        },
      ),
      MagicObject(
        id: 'fox',
        name: 'Fox',
        svgPath: 'assets/svg/magic/forest/fox.svg',
        previewIcon: '🦊',
        predefinedColors: {
          'eyes': const Color(0xFF000000),
          'nose': const Color(0xFF000000),
          'inner_ears': const Color(0xFFFFB6C1),
        },
        customizableRegions: {
          'fur': [
            const Color(0xFFFF8C00), // Dark Orange
            const Color(0xFFD2691E), // Chocolate
            const Color(0xFF8B4513), // Saddle Brown
            const Color(0xFFA0522D), // Sienna
            const Color(0xFFFF6347), // Tomato
          ],
          'chest_fur': [
            const Color(0xFFFFFFFF), // White
            const Color(0xFFF5F5F5), // White Smoke
            const Color(0xFFF5DEB3), // Wheat
          ],
          'tail_tip': [
            const Color(0xFFFFFFFF), // White
            const Color(0xFF000000), // Black
            const Color(0xFFF5DEB3), // Wheat
          ],
        },
      ),
    ],
  };
}

/// Data model for Magic Mode categories
class MagicCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  MagicCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint,
      'color': color.value,
      'description': description,
    };
  }

  /// Create from JSON
  factory MagicCategory.fromJson(Map<String, dynamic> json) {
    return MagicCategory(
      id: json['id'],
      name: json['name'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      color: Color(json['color']),
      description: json['description'],
    );
  }
}
            Color(0xFF00FFFF), // Cyan
          ],
        },
      ),
      MagicObject(
        id = 'fairy',
        name = 'Fairy',
        svgPath = 'assets/svg/magic/characters/fairy.svg',
        previewIcon = '🧚‍♀️',
        predefinedColors = {
          'face': const Color(0xFFFFDBBF),
          'eyes': const Color(0xFF90EE90),
          'hair': const Color(0xFFFFD700),
        },
        customizableRegions = {
          'dress': [
            const Color(0xFFFFB6C1), // Light Pink
            const Color(0xFFE6E6FA), // Lavender
            const Color(0xFF98FB98), // Pale Green
            const Color(0xFFADD8E6), // Light Blue
            const Color(0xFFFFF0F5), // Lavender Blush
          ],
          'wings': [
            const Color(0xFFE6E6FA), // Lavender
            const Color(0xFF87CEEB), // Sky Blue
            const Color(0xFFFFB6C1), // Light Pink
            const Color(0xFF98FB98), // Pale Green
            const Color(0xFFF0E68C), // Khaki
          ],
          'wand_star': [
            const Color(0xFFFFD700), // Gold
            const Color(0xFFC0C0C0), // Silver
            const Color(0xFFFF69B4), // Hot Pink
          ],
        },
      ),
    ],
    
    'farm': [
      MagicObject(
        id = 'chicken',
        name = 'Chicken',
        svgPath = 'assets/svg/magic/farm/chicken.svg',
        previewIcon = '🐔',
        predefinedColors = {
          'beak': const Color(0xFFFFA500),
          'legs': const Color(0xFFFF8C00),
          'eyes': const Color(0xFF000000),
          'comb': const Color(0xFFDC143C),
          'wattle': const Color(0xFFDC143C),
        },
        customizableRegions = {
          'body': [
            const Color(0xFFFFFFFF), // White
            const Color(0xFFF5DEB3), // Wheat
            const Color(0xFF8B4513), // Saddle Brown
            const Color(0xFF000000), // Black
            const Color(0xFFFF6347), // Tomato Red
            const Color(0xFFDEB887), // Burlywood
          ],
          'tail_feathers': [
            const Color(0xFF8B4513), // Saddle Brown
            const Color(0xFF000000), // Black
            const Color(0xFFFFD700), // Gold
            const Color(0xFF228B22), // Forest Green
            const Color(0xFF4B0082), // Indigo
          ],
          'wing_details': [
            const Color(0xFFF5DEB3), // Wheat
            const Color(0xFF8B4513), // Saddle Brown
            const Color(0xFF000000), // Black
            const Color(0xFFD2691E), // Chocolate
          ],
        },
      ),
      MagicObject(
        id = 'cow',
        name = 'Cow',
        svgPath = 'assets/svg/magic/farm/cow.svg',
        previewIcon = '🐄',
        predefinedColors = {
          'nose': const Color(0xFFFFB6C1),
          'hooves': const Color(0xFF2F4F4F),
          'eyes': const Color(0xFF000000),
          'horns': const Color(0xFFF5DEB3),
          'udder': const Color(0xFFFFB6C1),
        },
        customizableRegions = {
          'body': [
            const Color(0xFFFFFFFF), // White
            const Color(0xFF8B4513), // Brown
            const Color(0xFF000000), // Black
            const Color(0xFFDEB887), // Tan
            const Color(0xFFD2691E), // Chocolate
          ],
          'spots': [
            const Color(0xFF000000), // Black
            const Color(0xFF8B4513), // Brown
            const Color(0xFF696969), // Dim Gray
            const Color(0xFFD2691E), // Chocolate
          ],
        },
      ),
      MagicObject(
        id = 'pig',
        name = 'Pig',
        svgPath = 'assets/svg/magic/farm/pig.svg',
        previewIcon = '🐷',
        predefinedColors = {
          'snout': const Color(0xFFFF69B4),
          'eyes': const Color(0xFF000000),
          'hooves': const Color(0xFF8B4513),
          'tail': const Color(0xFFFFB6C1),
        },
        customizableRegions = {
          'body': [
            const Color(0xFFFFB6C1), // Light Pink
            const Color(0xFFFF69B4), // Hot Pink
            const Color(0xFFFFC0CB), // Pink
            const Color(0xFF8B4513), // Brown (muddy)
            const Color(0xFFDEB887), // Burlywood
          ],
          'ears': [
            const Color(0xFFFFB6C1), // Light Pink
            const Color(0xFFFF69B4), // Hot Pink
            const Color(0xFFFFC0CB), // Pink
          ],
        },
      ),
      MagicObject(
        id = 'sheep',
        name = 'Sheep',
        svgPath = 'assets/svg/magic/farm/sheep.svg',
        previewIcon = '🐑',
        predefinedColors = {
          'face': const Color(0xFF2F4F4F),
          'eyes': const Color(0xFF000000),
          'hooves': const Color(0xFF000000),
        },
        customizableRegions = {
          'wool': [
            const Color(0xFFFFFFFF), // White
            const Color(0xFFF5F5F5), // White Smoke
            const Color(0xFFD3D3D3), // Light Gray
            const Color(0xFF000000), // Black
            const Color(0xFF8B4513), // Brown
          ],
        },
      ),
      MagicObject(
        id = 'horse',
        name = 'Horse',
        svgPath = 'assets/svg/magic/farm/horse.svg',
        previewIcon = '🐴',
        predefinedColors = {
          'eyes': const Color(0xFF000000),
          'hooves': const Color(0xFF000000),
          'nostrils': const Color(0xFF000000),
        },
        customizableRegions = {
          'body': [
            const Color(0xFF8B4513), // Saddle Brown
            const Color(0xFF000000), // Black
            const Color(0xFFFFFFFF), // White
            const Color(0xFFD2691E), // Chocolate
            const Color(0xFFA0522D), // Sienna
            const Color(0xFF696969), // Dim Gray
          ],
          'mane': [
            const Color(0xFF000000), // Black
            const Color(0xFF8B4513), // Brown
            const Color(0xFFFFFFFF), // White