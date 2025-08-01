// lib/magic/services/svg_coloring_engine.dart

import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart' as xml;
import 'package:path_drawing/path_drawing.dart';

/// Data model representing one region within an SVG.
class SvgRegion {
  final String id;
  final Path path;
  final Rect bounds;
  final Offset centroid;
  final Paint paint;
  final bool isColorable;
  final String? number;
  
  SvgRegion({
    required this.id,
    required this.path,
    required this.bounds,
    required this.centroid,
    required this.paint,
    this.isColorable = true,
    this.number,
  });
}

/// Engine to parse an SVG string into a list of [SvgRegion]s,
/// each with its own path, paint, and metadata.
class SvgColoringEngine {
  final String svgContent;
  final Map<String, Color> coloredRegions;
  final Map<String, String> regionNumbers;
  final Map<String, Color> predefinedColors;
  final Map<String, List<Color>> customizableRegions;
  final bool isCustomizing;
  
  List<SvgRegion> regions = [];
  Size? viewBox;
  Matrix4? transform;
  
  SvgColoringEngine({
    required this.svgContent,
    required this.coloredRegions,
    required this.regionNumbers,
    required this.predefinedColors,
    required this.customizableRegions,
    required this.isCustomizing,
  });
  
  /// Parses the SVG content, extracting viewBox and all drawable elements.
  Future<void> parse() async {
    final document = xml.XmlDocument.parse(svgContent);
    final svgElement = document.findElements('svg').first;
    
    // Extract viewBox if present
    final viewBoxStr = svgElement.getAttribute('viewBox');
    if (viewBoxStr != null) {
      final parts = viewBoxStr.split(' ').map(double.parse).toList();
      viewBox = Size(parts[2], parts[3]);
    }
    
    await _parseElements(svgElement);
  }
  
  Future<void> _parseElements(xml.XmlElement parent) async {
    for (final element in parent.children.whereType<xml.XmlElement>()) {
      switch (element.name.local) {
        case 'path':
          _parsePath(element);
          break;
        case 'circle':
          _parseCircle(element);
          break;
        case 'rect':
          _parseRect(element);
          break;
        case 'ellipse':
          _parseEllipse(element);
          break;
        case 'polygon':
          _parsePolygon(element);
          break;
        case 'g':
          await _parseElements(element);
          break;
      }
    }
  }
  
  void _parsePath(xml.XmlElement element) {
    final id = element.getAttribute('id');
    final d = element.getAttribute('d');
    if (id == null || d == null) return;
    
    try {
      final path = parseSvgPathData(d);
      final bounds = path.getBounds();
      final centroid = _calculateCentroid(path, bounds);
      final paint = _createPaint(element, id);
      final isColorable = !isCustomizing || customizableRegions.containsKey(id);
      
      regions.add(SvgRegion(
        id: id,
        path: path,
        bounds: bounds,
        centroid: centroid,
        paint: paint,
        isColorable: isColorable,
        number: regionNumbers[id],
      ));
    } catch (e) {
      debugPrint('Error parsing path $id: $e');
    }
  }
  
  void _parseCircle(xml.XmlElement element) {
    final id = element.getAttribute('id');
    if (id == null) return;
    
    final cx = double.tryParse(element.getAttribute('cx') ?? '') ?? 0;
    final cy = double.tryParse(element.getAttribute('cy') ?? '') ?? 0;
    final r = double.tryParse(element.getAttribute('r') ?? '') ?? 0;
    
    final path = Path()..addOval(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
    );
    final bounds = path.getBounds();
    final centroid = Offset(cx, cy);
    final paint = _createPaint(element, id);
    final isColorable = !isCustomizing || customizableRegions.containsKey(id);
    
    regions.add(SvgRegion(
      id: id,
      path: path,
      bounds: bounds,
      centroid: centroid,
      paint: paint,
      isColorable: isColorable,
      number: regionNumbers[id],
    ));
  }
  
  void _parseRect(xml.XmlElement element) {
    final id = element.getAttribute('id');
    if (id == null) return;
    
    final x = double.tryParse(element.getAttribute('x') ?? '') ?? 0;
    final y = double.tryParse(element.getAttribute('y') ?? '') ?? 0;
    final w = double.tryParse(element.getAttribute('width') ?? '') ?? 0;
    final h = double.tryParse(element.getAttribute('height') ?? '') ?? 0;
    final rx = double.tryParse(element.getAttribute('rx') ?? '') ?? 0;
    final ry = double.tryParse(element.getAttribute('ry') ?? '') ?? 0;
    
    final path = Path();
    if (rx > 0 || ry > 0) {
      path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        Radius.circular(math.max(rx, ry)),
      ));
    } else {
      path.addRect(Rect.fromLTWH(x, y, w, h));
    }
    
    final bounds = path.getBounds();
    final centroid = Offset(x + w/2, y + h/2);
    final paint = _createPaint(element, id);
    final isColorable = !isCustomizing || customizableRegions.containsKey(id);
    
    regions.add(SvgRegion(
      id: id,
      path: path,
      bounds: bounds,
      centroid: centroid,
      paint: paint,
      isColorable: isColorable,
      number: regionNumbers[id],
    ));
  }
  
  void _parseEllipse(xml.XmlElement element) {
    final id = element.getAttribute('id');
    if (id == null) return;
    
    final cx = double.tryParse(element.getAttribute('cx') ?? '') ?? 0;
    final cy = double.tryParse(element.getAttribute('cy') ?? '') ?? 0;
    final rx = double.tryParse(element.getAttribute('rx') ?? '') ?? 0;
    final ry = double.tryParse(element.getAttribute('ry') ?? '') ?? 0;
    
    final path = Path()..addOval(
      Rect.fromCenter(center: Offset(cx, cy), width: rx*2, height: ry*2),
    );
    final bounds = path.getBounds();
    final centroid = Offset(cx, cy);
    final paint = _createPaint(element, id);
    final isColorable = !isCustomizing || customizableRegions.containsKey(id);
    
    regions.add(SvgRegion(
      id: id,
      path: path,
      bounds: bounds,
      centroid: centroid,
      paint: paint,
      isColorable: isColorable,
      number: regionNumbers[id],
    ));
  }
  
  void _parsePolygon(xml.XmlElement element) {
    final id = element.getAttribute('id');
    final pts = element.getAttribute('points');
    if (id == null || pts == null) return;
    
    final coords = pts
      .split(RegExp(r'[\s,]+'))
      .map(double.tryParse)
      .where((n) => n != null)
      .cast<double>()
      .toList();
    
    if (coords.length < 4) return;
    final path = Path()..moveTo(coords[0], coords[1]);
    for (var i = 2; i < coords.length; i += 2) {
      path.lineTo(coords[i], coords[i+1]);
    }
    path.close();
    
    final bounds = path.getBounds();
    final centroid = _calculateCentroid(path, bounds);
    final paint = _createPaint(element, id);
    final isColorable = !isCustomizing || customizableRegions.containsKey(id);
    
    regions.add(SvgRegion(
      id: id,
      path: path,
      bounds: bounds,
      centroid: centroid,
      paint: paint,
      isColorable: isColorable,
      number: regionNumbers[id],
    ));
  }
  
  Paint _createPaint(xml.XmlElement element, String id) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;
    
    if (coloredRegions.containsKey(id)) {
      paint.color = coloredRegions[id]!;
    } else if (!isCustomizing && predefinedColors.containsKey(id)) {
      paint.color = predefinedColors[id]!;
    } else {
      paint
        ..style = PaintingStyle.stroke
        ..color = Colors.grey[400]!;
    }
    
    final fillOpacity = element.getAttribute('fill-opacity');
    if (fillOpacity != null) {
      paint.color = paint.color.withOpacity(
        double.tryParse(fillOpacity) ?? paint.color.opacity,
      );
    }
    final sw = element.getAttribute('stroke-width');
    if (sw != null) {
      paint.strokeWidth = double.tryParse(sw) ?? paint.strokeWidth;
    }
    
    return paint;
  }
  
  Offset _calculateCentroid(Path path, Rect bounds) {
    return bounds.center;
  }
  
  /// Returns the ID of the topmost region containing [point],
  /// or null if none.
  String? hitTest(Offset point, Size canvasSize) {
    if (viewBox == null) return null;
    final scaleX = viewBox!.width / canvasSize.width;
    final scaleY = viewBox!.height / canvasSize.height;
    final svgPoint = Offset(point.dx * scaleX, point.dy * scaleY);
    
    for (var i = regions.length - 1; i >= 0; i--) {
      final region = regions[i];
      if (region.isColorable && region.path.contains(svgPoint)) {
        return region.id;
      }
    }
    return null;
  }
}
