// lib/magic/models/magic_models.dart

import 'package:flutter/material.dart';

/// Represents a magic category with activities
class MagicCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final List<MagicActivity> activities;

  const MagicCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.activities,
  });
}

/// Represents a magic activity within a category
class MagicActivity {
  final String id;
  final String name;
  final IconData icon;
  final int difficulty;
  final bool isLocked;

  const MagicActivity({
    required this.id,
    required this.name,
    required this.icon,
    required this.difficulty,
    this.isLocked = false,
  });
}

/// Represents a magic object in a scene
class MagicSceneObject {
  final String id;
  final String name;
  final String svgPath;
  final Map<String, Color> coloredRegions;

  const MagicSceneObject({
    required this.id,
    required this.name,
    required this.svgPath,
    required this.coloredRegions,
  });
}