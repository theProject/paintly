import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../providers/settings_provider.dart';
import '../models/magic_models.dart';
import 'dart:math' as math;

class MagicCategoryScreen extends StatefulWidget {
  final MagicCategory category;

  const MagicCategoryScreen({
    super.key,
    required this.category,
  });

  @override
  State<MagicCategoryScreen> createState() => _MagicCategoryScreenState();
}

class _MagicCategoryScreenState extends State<MagicCategoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late AnimationController _floatController;
  late ConfettiController _confettiController;
  
  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    
    // Play category entrance sound
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().playSound('category_open.mp3');
    });
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _floatController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.category.backgroundColor,
      body: Stack(
        children: [
          // Animated background pattern
          _buildAnimatedBackground(),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                // Activities grid
                Expanded(
                  child: _buildActivitiesGrid(),
                ),
              ],
            ),
          ),
          
          // Floating magical elements
          ..._buildFloatingElements(),
          
          // Confetti
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
              numberOfParticles: 30,
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
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: MagicalBackgroundPainter(
            animationValue: _sparkleController.value,
            primaryColor: widget.category.primaryColor,
            secondaryColor: widget.category.secondaryColor,
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
          
          // Title
          Expanded(
            child: FadeInRight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.category.name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    widget.category.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Category icon
          ElasticIn(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.category.icon,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: widget.category.activities.length,
      itemBuilder: (context, index) {
        final activity = widget.category.activities[index];
        return FadeInUp(
          delay: Duration(milliseconds: index * 100),
          child: _buildActivityCard(activity, index),
        );
      },
    );
  }

  Widget _buildActivityCard(MagicActivity activity, int index) {
    return GestureDetector(
      onTap: () {
        context.read<SettingsProvider>().playSound('magic_select.mp3');
        _confettiController.play();
        
        // Navigate to activity
        _navigateToActivity(activity);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.white.withValues(alpha: 0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: widget.category.primaryColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Magical sparkle overlay
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AnimatedBuilder(
                  animation: _sparkleController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: SparkleOverlayPainter(
                        animationValue: _sparkleController.value,
                        color: widget.category.primaryColor.withValues(alpha: 0.1),
                        delay: index * 0.1,
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Activity icon with animation
                  AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, math.sin(_floatController.value * 2 * math.pi) * 5),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
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
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            activity.icon,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Activity name
                  Text(
                    activity.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.category.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  // Difficulty indicator
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: i < activity.difficulty
                              ? Colors.amber
                              : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Lock overlay if locked
            if (activity.isLocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingElements() {
    return List.generate(5, (index) {
      return AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          final offset = _floatController.value + (index * 0.2);
          return Positioned(
            left: 50 + (index * 60.0) % 300,
            top: 100 + math.sin(offset * 2 * math.pi) * 30,
            child: Transform.rotate(
              angle: offset * 2 * math.pi,
              child: Opacity(
                opacity: 0.6,
                child: Icon(
                  [
                    Icons.star,
                    Icons.favorite,
                    Icons.circle,
                    Icons.hexagon,
                    Icons.auto_awesome,
                  ][index % 5],
                  color: [
                    Colors.yellow,
                    Colors.pink,
                    widget.category.primaryColor,
                    widget.category.secondaryColor,
                    Colors.purple,
                  ][index % 5],
                  size: 20 + (index * 5.0),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  void _navigateToActivity(MagicActivity activity) {
    if (activity.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Complete more activities to unlock ${activity.name}!'),
          backgroundColor: widget.category.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Navigate based on activity type
    // You can add navigation to specific activity screens here
    debugPrint('Navigate to ${activity.name}');
  }
}

class MagicalBackgroundPainter extends CustomPainter {
  final double animationValue;
  final Color primaryColor;
  final Color secondaryColor;

  MagicalBackgroundPainter({
    required this.animationValue,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          math.cos(animationValue * 2 * math.pi) * 0.5,
          math.sin(animationValue * 2 * math.pi) * 0.5,
        ),
        radius: 1.5,
        colors: [
          primaryColor.withValues(alpha: 0.3),
          secondaryColor.withValues(alpha: 0.2),
          primaryColor.withValues(alpha: 0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(MagicalBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class SparkleOverlayPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double delay;

  SparkleOverlayPainter({
    required this.animationValue,
    required this.color,
    required this.delay,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final adjustedValue = (animationValue + delay) % 1.0;
    final sparkleRadius = size.width * 0.1 * adjustedValue;
    
    final paint = Paint()
      ..color = color.withValues(alpha: (1 - adjustedValue) * 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      sparkleRadius,
      paint,
    );
  }

  @override
  bool shouldRepaint(SparkleOverlayPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}