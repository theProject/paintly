// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';

/// Enhanced color picker widget for Magic Mode
class MagicColorPicker extends StatefulWidget {
  final List<Color> colors;
  final Color? selectedColor;
  final ValueChanged<Color> onColorSelected;
  final String regionName;
  final String regionNumber;
  final Color categoryColor;
  final VoidCallback? onClose;

  const MagicColorPicker({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
    required this.regionName,
    required this.regionNumber,
    required this.categoryColor,
    this.onClose,
  });

  @override
  State<MagicColorPicker> createState() => _MagicColorPickerState();
}

class _MagicColorPickerState extends State<MagicColorPicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  Color? _hoveredColor;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  String _getColorName(Color color) {
    // Simple color naming - in production, use a comprehensive color name library
    if (color.value == Colors.white.value) return 'White';
    if (color.value == Colors.black.value) return 'Black';
    if (color.value == Colors.red.value) return 'Red';
    if (color.value == Colors.blue.value) return 'Blue';
    if (color.value == Colors.green.value) return 'Green';
    if (color.value == Colors.yellow.value) return 'Yellow';
    if (color.value == Colors.orange.value) return 'Orange';
    if (color.value == Colors.purple.value) return 'Purple';
    if (color.value == Colors.pink.value) return 'Pink';
    if (color.value == Colors.brown.value) return 'Brown';
    if (color.value == Colors.grey.value) return 'Grey';
    
    // For custom colors, return hex
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, MediaQuery.of(context).size.height * _slideAnimation.value),
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandle(),
              _buildHeader(),
              _buildColorGrid(),
              if (_hoveredColor != null)
                _buildColorInfo(_hoveredColor!),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHandle() {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Column(
        children: [
          Row(
            children: [
              ElasticIn(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      widget.regionNumber,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.categoryColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose a color for',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      widget.regionName.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildColorGrid() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: widget.colors.length,
        itemBuilder: (context, index) {
          return SlideInUp(
            delay: Duration(milliseconds: index * 30),
            child: _buildColorOption(widget.colors[index], index),
          );
        },
      ),
    );
  }
  
  Widget _buildColorOption(Color color, int index) {
    final isSelected = widget.selectedColor == color;
    final isHovered = _hoveredColor == color;
    
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _hoveredColor = color);
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        widget.onColorSelected(color);
        HapticFeedback.lightImpact();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() => _hoveredColor = null);
          }
        });
      },
      onTapCancel: () {
        setState(() => _hoveredColor = null);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..scale(isSelected ? 1.15 : (isHovered ? 1.05 : 1.0)),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected 
                  ? Colors.black 
                  : Colors.grey.withValues(alpha: 0.3),
              width: isSelected ? 3 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: isSelected ? 16 : (isHovered ? 12 : 8),
                spreadRadius: isSelected ? 2 : 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.0,
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 28,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    blurRadius: 4,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildColorInfo(Color color) {
    return FadeIn(
      duration: const Duration(milliseconds: 200),
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _getColorName(color),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Simplified color picker for quick selection
class QuickColorPicker extends StatelessWidget {
  final List<Color> colors;
  final Color? selectedColor;
  final ValueChanged<Color> onColorSelected;
  
  const QuickColorPicker({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = selectedColor == color;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onColorSelected(color),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.white,
                    width: isSelected ? 3 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
                      )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
