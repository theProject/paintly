// lib/utils/svg_auto_palette.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart' as xml;
import 'package:path_drawing/path_drawing.dart';

import '../models/svg_art.dart'; // SvgArt, SvgRegion, SvgColorPalette

// ---- Public API -------------------------------------------------------------

/// Build a SvgArt (palette + regions) from an SVG asset file.
/// - Merges near-duplicate colors using [mergeDistance] in RGB space.
/// - Skips very small regions using [minRegionArea] (viewBox units^2).
/// - Excludes IDs by prefix/keyword (outlines, eyes, etc.).
Future<SvgArt> autoBuildSvgArtFromAsset({
  required String name,
  required String svgPath,
  double mergeDistance = 14.0,     // Euclidean RGB distance (0..441)
  double minRegionArea = 120.0,    // width*height cutoff in viewBox units
  Set<String> excludeIdPrefixes = const {'outline_', 'np_'}, // manual opt-out
  Set<String> excludeKeywords = const {'eye', 'pupil', 'glint', 'mouth', 'smile'},
}) async {
  final raw = await rootBundle.loadString(svgPath);
  return autoBuildSvgArtFromString(
    name: name,
    svgPath: svgPath,
    svgString: raw,
    mergeDistance: mergeDistance,
    minRegionArea: minRegionArea,
    excludeIdPrefixes: excludeIdPrefixes,
    excludeKeywords: excludeKeywords,
  );
}

/// Same as [autoBuildSvgArtFromAsset], but from an SVG string.
SvgArt autoBuildSvgArtFromString({
  required String name,
  required String svgPath,
  required String svgString,
  double mergeDistance = 14.0,
  double minRegionArea = 120.0,
  Set<String> excludeIdPrefixes = const {'outline_', 'np_'},
  Set<String> excludeKeywords = const {'eye', 'pupil', 'glint', 'mouth', 'smile'},
}) {
  final doc = xml.XmlDocument.parse(svgString);

  bool isExcludedId(String id) {
    final s = id.toLowerCase();
    for (final p in excludeIdPrefixes) {
      if (s.startsWith(p)) return true;
    }
    for (final k in excludeKeywords) {
      if (s.contains(k)) return true;
    }
    return false;
  }

  // Collect (id, color, area) for paintable elements
  final entries = <_PaintableEntry>[];

  for (final e in doc.findAllElements('*')) {
    final id = e.getAttribute('id');
    if (id == null || id.isEmpty || isExcludedId(id)) continue;

    final fill = _extractFillColor(e);
    if (fill == null) continue; // no fill / 'none' / gradient/pattern url()
    final path = _pathFromElement(e);
    if (path == null) continue;

    final bounds = path.getBounds();
    final area = bounds.width * bounds.height;
    if (area < minRegionArea) continue; // skip slivers

    // Convert _Color -> _Rgb for clustering
    entries.add(_PaintableEntry(id: id, color: _toRgb(fill), area: area));
  }

  // Merge colors by distance
  final clusters = <_ColorCluster>[];
  for (final ent in entries) {
    final idx = _findClusterIndex(clusters, ent.color, mergeDistance);
    if (idx == -1) {
      clusters.add(_ColorCluster(seed: ent.color));
    } else {
      clusters[idx].add(ent.color);
    }
  }

  // Assign color numbers (1..N) and build palette
  final palette = <SvgColorPalette>[];
  for (var i = 0; i < clusters.length; i++) {
    final c = clusters[i].avgColor();
    final id = i + 1;
    palette.add(
      SvgColorPalette(
        id: id,
        color: _toFlutterColor(c),
        name: _niceNameForColor(c, id),
      ),
    );
  }

  // Map each region to nearest cluster
  final regions = <SvgRegion>[];
  for (final ent in entries) {
    final clusterIdx = _findClusterIndex(clusters, ent.color, mergeDistance, allowNew: false);
    final colorNumber = (clusterIdx >= 0 ? clusterIdx : 0) + 1;
    regions.add(SvgRegion(elementId: ent.id, colorNumber: colorNumber));
  }

  return SvgArt(
    name: name,
    svgPath: svgPath,
    svgContent: null, // loading by path in your current flow
    palette: palette,
    regions: regions,
  );
}

// ---- Internals -------------------------------------------------------------

class _PaintableEntry {
  final String id;
  final _Rgb color;   // cluster space
  final double area;
  _PaintableEntry({required this.id, required this.color, required this.area});
}

class _Rgb {
  final int r, g, b;
  const _Rgb(this.r, this.g, this.b);
}

class _ColorCluster {
  final List<_Rgb> _colors = [];
  _ColorCluster({required _Rgb seed}) {
    _colors.add(seed);
  }
  void add(_Rgb c) => _colors.add(c);

  _Rgb avgColor() {
    int r = 0, g = 0, b = 0;
    for (final c in _colors) {
      r += c.r; g += c.g; b += c.b;
    }
    final n = _colors.length;
    return _Rgb((r / n).round(), (g / n).round(), (b / n).round());
  }
}

int _findClusterIndex(List<_ColorCluster> clusters, _Rgb c, double maxDist, {bool allowNew = true}) {
  var best = -1;
  var bestDist = double.infinity;
  for (var i = 0; i < clusters.length; i++) {
    final d = _rgbDistance(c, clusters[i].avgColor());
    if (d < bestDist) {
      bestDist = d;
      best = i;
    }
  }
  if (best >= 0 && bestDist <= maxDist) return best;
  return allowNew ? -1 : best;
}

double _rgbDistance(_Rgb a, _Rgb b) {
  final dr = (a.r - b.r).toDouble();
  final dg = (a.g - b.g).toDouble();
  final db = (a.b - b.b).toDouble();
  return math.sqrt(dr*dr + dg*dg + db*db);
}

_Rgb _toRgb(_Color c) => _Rgb(c.r, c.g, c.b);
Color _toFlutterColor(_Rgb c) => Color(0xFF000000 | (c.r << 16) | (c.g << 8) | c.b);

class _Color {
  final int r, g, b;
  const _Color(this.r, this.g, this.b);
}

// Parses the element's fill from either the `fill` attribute or style="fill:...".
// Returns null for 'none' or unsupported patterns like url(#gradient).
_Color? _extractFillColor(xml.XmlElement e) {
  // Prefer explicit attribute
  final fillAttr = e.getAttribute('fill');
  final style = e.getAttribute('style');

  String? fillString;
  if (fillAttr != null && fillAttr.trim().isNotEmpty) {
    fillString = fillAttr.trim();
  } else if (style != null) {
    final m = RegExp(r'fill\s*:\s*([^;]+)').firstMatch(style);
    if (m != null) fillString = m.group(1)!.trim();
  }
  if (fillString == null) return null;

  // Unsupported / transparent
  if (fillString == 'none') return null;
  if (fillString.startsWith('url(')) return null; // gradients/patterns

  // Hex #RRGGBB or #RGB
  final hex = fillString;
  if (hex.startsWith('#')) {
    if (hex.length == 7) {
      final rgb = int.tryParse(hex.substring(1), radix: 16);
      if (rgb == null) return null;
      return _Color((rgb >> 16) & 0xFF, (rgb >> 8) & 0xFF, rgb & 0xFF);
    } else if (hex.length == 4) {
      final r = hex[1] * 2, g = hex[2] * 2, b = hex[3] * 2;
      final rgb = int.tryParse('$r$g$b', radix: 16);
      if (rgb == null) return null;
      return _Color((rgb >> 16) & 0xFF, (rgb >> 8) & 0xFF, rgb & 0xFF);
    }
  }

  // rgb()/rgba()
  final rgbm = RegExp(r'rgba?\s*\(\s*([0-9.\s,]+)\s*\)').firstMatch(fillString);
  if (rgbm != null) {
    final parts = rgbm.group(1)!.split(',').map((s) => s.trim()).toList();
    if (parts.length >= 3) {
      double toD(String s) => double.tryParse(s) ?? 0.0;
      int clamp(int v) => v.clamp(0, 255);
      final r = clamp((toD(parts[0])).round());
      final g = clamp((toD(parts[1])).round());
      final b = clamp((toD(parts[2])).round());
      return _Color(r, g, b);
    }
  }

  return null;
}

// Friendly palette names
String _niceNameForColor(_Rgb c, int fallbackId) {
  final r = c.r.toDouble(), g = c.g.toDouble(), b = c.b.toDouble();
  final maxc = [r, g, b].reduce(math.max);
  final minc = [r, g, b].reduce(math.min);
  final lum = (0.2126*r + 0.7152*g + 0.0722*b) / 255.0;
  final sat = (maxc - minc) / (maxc == 0 ? 1 : maxc);

  bool near(double v, double t, double eps) => (v - t).abs() <= eps;

  if (near(r, g, 10) && near(g, b, 10)) {
    if (lum < 0.08) return 'Black';
    if (lum > 0.92) return 'White';
    return 'Grey';
  }
  if (r > g && r > b) {
    if (r - g < 30 && g > b) return 'Orange';
    if (r - b < 30 && g < b) return 'Pink';
    return 'Red';
  }
  if (g > r && g > b) return 'Green';
  if (b > r && b > g) return 'Blue';
  if (sat < 0.15) return 'Grey';
  return 'Color $fallbackId';
}

// Convert an XmlElement to a Path.
// Supports tags: path, rect, circle, ellipse, polygon, polyline, g (union of children).
Path? _pathFromElement(xml.XmlElement e) {
  final tag = e.name.local;

  if (tag == 'path') {
    final d = e.getAttribute('d');
    if (d == null) return null;
    return parseSvgPathData(d);
  }
  if (tag == 'rect') {
    double toD(String? v) => v == null ? 0.0 : double.tryParse(v) ?? 0.0;
    final x = toD(e.getAttribute('x'));
    final y = toD(e.getAttribute('y'));
    final w = toD(e.getAttribute('width'));
    final h = toD(e.getAttribute('height'));
    if (w <= 0 || h <= 0) return null;
    final p = Path()..addRect(Rect.fromLTWH(x, y, w, h));
    return p;
  }
  if (tag == 'circle') {
    double toD(String? v) => v == null ? 0.0 : double.tryParse(v) ?? 0.0;
    final cx = toD(e.getAttribute('cx'));
    final cy = toD(e.getAttribute('cy'));
    final r  = toD(e.getAttribute('r'));
    if (r <= 0) return null;
    final p = Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    return p;
  }
  if (tag == 'ellipse') {
    double toD(String? v) => v == null ? 0.0 : double.tryParse(v) ?? 0.0;
    final cx = toD(e.getAttribute('cx'));
    final cy = toD(e.getAttribute('cy'));
    final rx = toD(e.getAttribute('rx'));
    final ry = toD(e.getAttribute('ry'));
    if (rx <= 0 || ry <= 0) return null;
    final p = Path()
      ..addOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2));
    return p;
  }
  if (tag == 'polygon' || tag == 'polyline') {
    final points = e.getAttribute('points');
    if (points == null) return null;
    final nums = points.trim().split(RegExp(r'[ ,]+')).map((s) => double.tryParse(s) ?? 0).toList();
    if (nums.length < 4) return null;
    final p = Path()..moveTo(nums[0], nums[1]);
    for (int i = 2; i + 1 < nums.length; i += 2) {
      p.lineTo(nums[i], nums[i + 1]);
    }
    if (tag == 'polygon') p.close();
    return p;
  }
  if (tag == 'g') {
    final p = Path();
    for (final child in e.children.whereType<xml.XmlElement>()) {
      final cp = _pathFromElement(child);
      if (cp != null) p.addPath(cp, Offset.zero);
    }
    return p;
  }
  return null;
}
