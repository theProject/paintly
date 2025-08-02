import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import '../../providers/scene_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/color_palette_widget.dart';
import '../../models/magic_object.dart';
import 'dart:math' as math;

class MagicColoringScreen extends StatefulWidget {
  final MagicActivity activity;
  final MagicCategory category;

  const MagicColoringScreen({
    super.key,
    required this.activity,
    required this.category,
  });

  @override
  State<MagicColoringScreen> createState() => _MagicColoringScreenState();
}

class _MagicColoringScreenState extends State<MagicColoringScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _sparkleController;
  late AnimationController _magicAnimationController;
  late AnimationController _floatController;
  
  // Magic objects on canvas
  final List<MagicObject> _magicObjects = [];
  
  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _magicAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    // Load activity scene
    _loadActivityScene();
  }

  void _loadActivityScene() {
    // Create a scene based on the activity
    final scene = SceneData(
      id: widget.activity.id,
      name: widget.activity.name,
      backgroundImage: 'assets/magic/${widget.activity.id}_bg.png',
      colorRegions: _generateColorRegions(),
      draggableItems: _generateDraggableItems(),
      colorPalette: _generateMagicPalette(),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SceneProvider>().loadScene(scene);
    });
  }

  List<ColorRegion> _generateColorRegions() {
    // Generate color regions based on activity type
    return [
      ColorRegion(
        id: 'magic_region_1',
        targetColor: widget.category.primaryColor,
        svgPath: 'magic_path_1',
      ),
      ColorRegion(
        id: 'magic_region_2',
        targetColor: widget.category.secondaryColor,
        svgPath: 'magic_path_2',
      ),
      ColorRegion(
        id: 'magic_region_3',
        targetColor: Colors.purple,
        svgPath: 'magic_path_3',
      ),
    ];
  }

  List<DraggableItem> _generateDraggableItems() {
    // Generate draggable items based on activity
    return [
      DraggableItem(
        id: '✨',
        imagePath: 'assets/magic/sparkle.png',
        initialPosition: const Offset(50, 100),
        size: const Size(50, 50),
      ),
      DraggableItem(
        id: '🌟',
        imagePath: 'assets/magic/star.png',
        initialPosition: const Offset(200, 150),
        size: const Size(60, 60),
      ),
    ];
  }

  List<Color> _generateMagicPalette() {
    return [
      widget.category.primaryColor,
      widget.category.secondaryColor,
      Colors.purple,
      Colors.pink,
      Colors.yellow,
      Colors.cyan,
    ];
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _sparkleController.dispose();
    _magicAnimationController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.category.backgroundColor,
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                // Canvas area
                Expanded(
                  child: _buildMagicCanvas(),
                ),
                
                // Magic color palette
                _buildMagicColorPalette(),
              ],
            ),
          ),
          
          // Floating magical elements
          ..._buildFloatingElements(),
          
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [
                widget.category.primaryColor,
                widget.category.secondaryColor,
                Colors.yellow,
                Colors.pink,
                Colors.purple,
              ],
              numberOfParticles: 50,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                math.cos(_sparkleController.value * 2 * math.pi) * 0.5,
                math.sin(_sparkleController.value * 2 * math.pi) * 0.5,
              ),
              radius: 1.5,
              colors: [
                widget.category.primaryColor.withValues(alpha: 0.3),
                widget.category.secondaryColor.withValues(alpha: 0.2),
                widget.category.backgroundColor,
              ],
            ),
          ),
          child: CustomPaint(
            size: MediaQuery.of(context).size,
            painter: SparkleBackgroundPainter(
              animationValue: _sparkleController.value,
              primaryColor: widget.category.primaryColor,
              secondaryColor: widget.category.secondaryColor,
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back button
          BounceIn(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.category.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                color: widget.category.primaryColor,
                onPressed: () {
                  context.read<SettingsProvider>().playSound('tap.mp3');
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Title and score
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInRight(
                  child: Text(
                    widget.activity.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                FadeInRight(
                  delay: const Duration(milliseconds: 200),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: Colors.yellow[300],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Magic Points: ${_calculateMagicPoints()}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Magic wand button
          ElasticIn(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.category.primaryColor,
                    widget.category.secondaryColor,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.category.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.auto_fix_high, color: Colors.white),
                onPressed: _activateMagicMode,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMagicCanvas() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: widget.category.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            // Scene canvas
            Consumer<SceneProvider>(
              builder: (context, provider, child) {
                // Check for completion
                if (provider.isComplete() && 
                    _confettiController.state != ConfettiControllerState.playing) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _onLevelComplete();
                  });
                }
                
                return CustomPaint(
                  size: Size.infinite,
                  painter: MagicCanvasPainter(
                    scene: provider.currentScene,
                    filledRegions: provider.filledRegions,
                    selectedColor: provider.selectedColor,
                    sparkleAnimation: _sparkleController.value,
                    magicObjects: _magicObjects,
                  ),
                  child: _buildInteractiveCanvas(provider),
                );
              },
            ),
            
            // Magic effects overlay
            if (_magicObjects.isNotEmpty)
              ...(_magicObjects.map((obj) => _buildMagicObject(obj))),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveCanvas(SceneProvider provider) {
    return GestureDetector(
      onTapUp: (details) {
        // Handle taps for coloring
        _handleCanvasTap(details.localPosition, provider);
      },
      onPanUpdate: (details) {
        // Handle drag for magic effects
        if (provider.selectedColor != null) {
          setState(() {
            _magicObjects.add(
              MagicObject(
                position: details.localPosition,
                color: provider.selectedColor!,
                size: 20 + math.Random().nextDouble() * 20,
                lifetime: DateTime.now().add(const Duration(seconds: 2)),
              ),
            );
          });
        }
      },
      child: Container(color: Colors.transparent),
    );
  }

  void _handleCanvasTap(Offset position, SceneProvider provider) {
    // Simplified tap handling - in production would check actual regions
    context.read<SettingsProvider>().playSound('magic_paint.mp3');
    
    // Create magical effect at tap position
    setState(() {
      _magicObjects.add(
        MagicObject(
          position: position,
          color: provider.selectedColor ?? Colors.purple,
          size: 30,
          lifetime: DateTime.now().add(const Duration(seconds: 1)),
        ),
      );
    });
    
    // Trigger magic animation
    _magicAnimationController.forward(from: 0);
  }

  Widget _buildMagicObject(MagicObject obj) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      left: obj.position.dx - obj.size / 2,
      top: obj.position.dy - obj.size / 2,
      child: SpinPerfect(
        duration: const Duration(seconds: 2),
        child: Container(
          width: obj.size,
          height: obj.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                obj.color,
                obj.color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMagicColorPalette() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Consumer<SceneProvider>(
        builder: (context, provider, child) {
          if (provider.currentScene == null) return const SizedBox.shrink();
          
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: provider.currentScene!.colorPalette.length,
            itemBuilder: (context, index) {
              final color = provider.currentScene!.colorPalette[index];
              final isSelected = provider.selectedColor == color;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: BounceInUp(
                  delay: Duration(milliseconds: index * 100),
                  child: GestureDetector(
                    onTap: () {
                      provider.selectColor(color);
                      context.read<SettingsProvider>().playSound('magic_select.mp3');
                      _createColorSelectionEffect(color);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isSelected ? 80 : 65,
                      height: isSelected ? 80 : 65,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color,
                            color.withValues(alpha: 0.7),
                          ],
                        ),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                          width: isSelected ? 4 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.5),
                            blurRadius: isSelected ? 20 : 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _floatController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                0,
                                isSelected ? math.sin(_floatController.value * 2 * math.pi) * 3 : 0,
                              ),
                              child: Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: isSelected ? 28 : 20,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildFloatingElements() {
    return List.generate(8, (index) {
      return AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          final offset = _floatController.value + (index * 0.125);
          final x = 50 + (index * 40.0) % (MediaQuery.of(context).size.width - 100);
          final y = 100 + math.sin(offset * 2 * math.pi) * 50 + (index * 80.0) % 400;
          
          return Positioned(
            left: x,
            top: y,
            child: Transform.rotate(
              angle: offset * 2 * math.pi,
              child: Opacity(
                opacity: 0.3 + (math.sin(offset * 2 * math.pi) * 0.3),
                child: Icon(
                  [
                    Icons.star,
                    Icons.auto_awesome,
                    Icons.favorite,
                    Icons.hexagon,
                    Icons.bubble_chart,
                    Icons.lens,
                    Icons.favorite,
                    Icons.star,
                  ][index % 8],
                  color: [
                    Colors.yellow,
                    Colors.pink,
                    Colors.purple,
                    widget.category.primaryColor,
                    widget.category.secondaryColor,
                    Colors.cyan,
                    Colors.orange,
                    Colors.white,
                  ][index % 8],
                  size: 15 + (index * 3.0),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  void _createColorSelectionEffect(Color color) {
    // Create a burst of particles when color is selected
    setState(() {
      final random = math.Random();
      for (int i = 0; i < 5; i++) {
        _magicObjects.add(
          MagicObject(
            position: Offset(
              MediaQuery.of(context).size.width / 2 + (random.nextDouble() - 0.5) * 100,
              MediaQuery.of(context).size.height - 100,
            ),
            color: color,
            size: 10 + random.nextDouble() * 20,
            lifetime: DateTime.now().add(Duration(milliseconds: 500 + random.nextInt(500))),
          ),
        );
      }
    });
    
    // Clean up old objects
    _magicObjects.removeWhere((obj) => obj.lifetime.isBefore(DateTime.now()));
  }

  void _activateMagicMode() {
    context.read<SettingsProvider>().playSound('magic_activate.mp3');
    _confettiController.play();
    
    // Fill random regions with magic
    final provider = context.read<SceneProvider>();
    if (provider.currentScene != null && provider.selectedColor != null) {
      final regions = provider.currentScene!.colorRegions;
      if (regions.isNotEmpty) {
        final randomRegion = regions[math.Random().nextInt(regions.length)];
        provider.fillRegion(randomRegion.id);
      }
    }
  }

  int _calculateMagicPoints() {
    final provider = context.read<SceneProvider>();
    return (provider.getProgress() * 100).toInt() + _magicObjects.length * 5;
  }

  void _onLevelComplete() {
    _confettiController.play();
    context.read<SettingsProvider>().playSound('level_complete.mp3');
    
    // Show completion dialog
    Future.delayed(const Duration(seconds: 2), () {
      _showCompletionDialog();
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ElasticIn(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: widget.category.backgroundColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.celebration,
                size: 80,
                color: Colors.yellow,
              ),
              const SizedBox(height: 20),
              Text(
                'Amazing!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: widget.category.primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'You earned ${_calculateMagicPoints()} magic points!',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.category.secondaryColor,
                    ),
                    child: const Text('Back'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Reset and play again
                      context.read<SceneProvider>().loadScene(
                        context.read<SceneProvider>().currentScene!,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.category.primaryColor,
                    ),
                    child: const Text('Play Again'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Magic object model
class MagicObject {
  final Offset position;
  final Color color;
  final double size;
  final DateTime lifetime;

  MagicObject({
    required this.position,
    required this.color,
    required this.size,
    required this.lifetime,
  });
}

// Custom painter for sparkle background
class SparkleBackgroundPainter extends CustomPainter {
  final double animationValue;
  final Color primaryColor;
  final Color secondaryColor;

  SparkleBackgroundPainter({
    required this.animationValue,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw animated sparkles
    for (int i = 0; i < 20; i++) {
      final offset = (animationValue + i * 0.05) % 1.0;
      final x = (i * 73) % size.width;
      final y = (i * 97) % size.height + (offset * 100);
      final radius = 2 + math.sin(offset * 2 * math.pi) * 2;
      
      paint.color = (i % 2 == 0 ? primaryColor : secondaryColor)
          .withValues(alpha: 0.3 * (1 - offset));
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(SparkleBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// Custom painter for magic canvas
class MagicCanvasPainter extends CustomPainter {
  final SceneData? scene;
  final Map<String, Color?> filledRegions;
  final Color? selectedColor;
  final double sparkleAnimation;
  final List<MagicObject> magicObjects;

  MagicCanvasPainter({
    required this.scene,
    required this.filledRegions,
    required this.selectedColor,
    required this.sparkleAnimation,
    required this.magicObjects,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (scene == null) return;

    // Draw background gradient
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          Colors.white,
          Colors.purple.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw color regions (simplified for demo)
    final regionPaint = Paint()..style = PaintingStyle.fill;
    
    // Example: Draw some magical shapes
    for (int i = 0; i < scene!.colorRegions.length; i++) {
      final region = scene!.colorRegions[i];
      final isFilled = filledRegions.containsKey(region.id);
      final fillColor = filledRegions[region.id];
      
      // Calculate position based on index
      final centerX = size.width * ((i + 1) / (scene!.colorRegions.length + 1));
      final centerY = size.height / 2;
      
      // Set color
      if (isFilled && fillColor != null) {
        regionPaint.color = fillColor;
      } else if (selectedColor == region.targetColor) {
        regionPaint.color = region.targetColor.withValues(alpha: 0.3);
      } else {
        regionPaint.color = Colors.grey.withValues(alpha: 0.2);
      }
      
      // Draw magical shape (star)
      _drawStar(canvas, Offset(centerX, centerY), 40, regionPaint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const int points = 5;
    
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final r = i.isEven ? radius : radius * 0.5;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(MagicCanvasPainter oldDelegate) {
    return oldDelegate.sparkleAnimation != sparkleAnimation ||
           oldDelegate.filledRegions != filledRegions ||
           oldDelegate.selectedColor != selectedColor ||
           oldDelegate.magicObjects.length != magicObjects.length;
  }
}