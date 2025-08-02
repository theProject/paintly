import 'dart:ui'; // for ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import '../models/pixel_art.dart';
import '../screens/coloring_screen.dart';
// If referencing MagicSceneObject

/// ─────────────────────────────────────────────────────────────────────────────
/// PROVIDER & DATA MODELS
/// ─────────────────────────────────────────────────────────────────────────────

class SceneProvider extends ChangeNotifier {
  SceneData? _currentScene;
  final Map<String, Color?> _filledRegions = {};
  Color? _selectedColor;
  final Map<String, Offset> _draggablePositions = {};

  SceneData? get currentScene => _currentScene;
  Map<String, Color?> get filledRegions => _filledRegions;
  Color? get selectedColor => _selectedColor;
  Map<String, Offset> get draggablePositions => _draggablePositions;

  void loadScene(SceneData scene) {
    _currentScene = scene;
    _filledRegions.clear();
    _draggablePositions.clear();
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
    if (_selectedColor == null || _currentScene == null) return;
    final region = _currentScene!.colorRegions.firstWhere(
      (r) => r.id == regionId,
      orElse: () => ColorRegion(id: '', targetColor: Colors.transparent, svgPath: ''),
    );
    if (region.targetColor == _selectedColor) {
      _filledRegions[regionId] = _selectedColor;
      notifyListeners();
    }
  }

  void updateDraggablePosition(String itemId, Offset newPosition) {
    _draggablePositions[itemId] = newPosition;
    notifyListeners();
  }

  double getProgress() {
    if (_currentScene == null) return 0.0;
    final total = _currentScene!.colorRegions.length;
    return total > 0 ? _filledRegions.length / total : 0.0;
  }

  bool isComplete() {
    if (_currentScene == null) return false;
    return _filledRegions.length == _currentScene!.colorRegions.length;
  }

  void addMagicObject({required String categoryId, required String objectId, required String name, required String svgPath, required Map<String, Color> colors}) {}
}

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

/// ─────────────────────────────────────────────────────────────────────────────
/// HOME SCREEN & PIXEL ART PREVIEW
/// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  final int? selectedTab;
  final VoidCallback? onTabChanged;

  const HomeScreen({
    super.key,
    this.selectedTab,
    this.onTabChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PixelArt> coloringPages = [];

  @override
  void initState() {
    super.initState();
    loadColoringPages();
  }

  Future<void> loadColoringPages() async {
    final jsonFiles = [
      'assets/data/heart.json',
      'assets/data/cat.json',
      'assets/data/flower.json',
      'assets/data/house.json',
      'assets/data/star.json',
      'assets/data/butterfly.json',
      'assets/data/tree.json',
      'assets/data/rainbow.json',
      'assets/data/smiley.json',
    ];

    final loaded = <PixelArt>[];
    for (var path in jsonFiles) {
      try {
        final str = await rootBundle.loadString(path);
        final data = json.decode(str) as Map<String, dynamic>;
        loaded.add(PixelArt.fromJson(data));
      } catch (e) {
        debugPrint('Error loading $path: $e');
      }
    }
    setState(() => coloringPages = loaded);
  }

  List<PixelArt> get filteredPages {
    if (widget.selectedTab == null || widget.selectedTab == 0) {
      return coloringPages;
    }
    // TODO: filter by category once PixelArt supports it
    return coloringPages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredPages.length,
        itemBuilder: (ctx, idx) => FadeInUp(
          delay: Duration(milliseconds: idx * 50),
          child: _buildTile(filteredPages[idx], idx),
        ),
      ),
    );
  }

  Widget _buildTile(PixelArt art, int idx) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ColoringScreen(pixelArt: art)),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: [
                    cs.primary,
                    cs.secondary,
                    cs.tertiary,
                    Color(0xFF9DDAC8),
                    Color(0xFF8B96A9),
                  ][idx % 5].withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.grid_on_rounded,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      art.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// PIXEL ART PREVIEW PAINTER
/// ─────────────────────────────────────────────────────────────────────────────

class PixelArtPreviewPainter extends CustomPainter {
  final PixelArt pixelArt;
  final double cellSize;
  final Map<String, dynamic>? progress;

  PixelArtPreviewPainter({
    required this.pixelArt,
    required this.cellSize,
    this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final colored = progress?['coloredPixels'] as List<List<int>>?;

    // background
    paint.color = Colors.grey[100]!;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // colored pixels
    for (int y = 0; y < pixelArt.gridSize; y++) {
      for (int x = 0; x < pixelArt.gridSize; x++) {
        final idx = pixelArt.pixels[y][x];
        if (idx > 0) {
          final done = colored != null && colored[y][x] > 0;
          paint.color = done
              ? pixelArt.colorPalette[colored[y][x]]
              : Colors.grey[300]!;
          canvas.drawRect(
            Rect.fromLTWH(
              x * cellSize,
              y * cellSize,
              cellSize - 0.5,
              cellSize - 0.5,
            ),
            paint,
          );
        }
      }
    }

    // grid lines
    paint
      ..color = Colors.grey.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (int i = 0; i <= pixelArt.gridSize; i++) {
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(size.width, i * cellSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PixelArtPreviewPainter old) =>
      old.progress != progress;
}
