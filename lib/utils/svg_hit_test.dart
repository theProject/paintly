// lib/utils/svg_hit_test.dart
import 'dart:ui';
import 'package:xml/xml.dart' as xml;
import 'package:path_drawing/path_drawing.dart';

double _toD(String? v) => v == null ? 0.0 : double.tryParse(v) ?? 0.0;

// Build a Path (in SVG viewBox coordinates) for a single SVG element.
// Supports tags: path, rect, circle, ellipse, polygon, polyline, and g.
Path? _pathFromElement(xml.XmlElement e) {
  final tag = e.name.local;

  if (tag == 'path') {
    final d = e.getAttribute('d');
    if (d == null) return null;
    return parseSvgPathData(d);
  }

  if (tag == 'rect') {
    final x = _toD(e.getAttribute('x'));
    final y = _toD(e.getAttribute('y'));
    final w = _toD(e.getAttribute('width'));
    final h = _toD(e.getAttribute('height'));
    if (w <= 0 || h <= 0) return null;
    final p = Path()..addRect(Rect.fromLTWH(x, y, w, h));
    return p;
  }

  if (tag == 'circle') {
    final cx = _toD(e.getAttribute('cx'));
    final cy = _toD(e.getAttribute('cy'));
    final r  = _toD(e.getAttribute('r'));
    if (r <= 0) return null;
    final p = Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    return p;
  }

  if (tag == 'ellipse') {
    final cx = _toD(e.getAttribute('cx'));
    final cy = _toD(e.getAttribute('cy'));
    final rx = _toD(e.getAttribute('rx'));
    final ry = _toD(e.getAttribute('ry'));
    if (rx <= 0 || ry <= 0) return null;
    final p = Path()
      ..addOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2));
    return p;
  }

  if (tag == 'polygon' || tag == 'polyline') {
    final points = e.getAttribute('points');
    if (points == null) return null;
    final nums = points
        .trim()
        .split(RegExp(r'[ ,]+'))
        .map((s) => double.tryParse(s) ?? 0)
        .toList();
    if (nums.length < 4) return null;

    final p = Path()..moveTo(nums[0], nums[1]);
    for (int i = 2; i + 1 < nums.length; i += 2) {
      p.lineTo(nums[i], nums[i + 1]);
    }
    if (tag == 'polygon') p.close();
    return p;
  }

  if (tag == 'g') {
    // Union of all child shapes
    final p = Path();
    for (final child in e.children.whereType<xml.XmlElement>()) {
      final cp = _pathFromElement(child);
      if (cp != null) p.addPath(cp, Offset.zero);
    }
    return p;
  }

  return null;
}

/// Build hit-testable Paths for only the element IDs you care about (paintable regions).
Future<Map<String, Path>> computeSvgHitPaths(
  String svgString,
  Set<String> elementIds,
) async {
  final doc = xml.XmlDocument.parse(svgString);
  final paths = <String, Path>{};

  for (final e in doc.findAllElements('*')) {
    final id = e.getAttribute('id');
    if (id == null || !elementIds.contains(id)) continue;
    final p = _pathFromElement(e);
    if (p != null) paths[id] = p;
  }

  return paths;
}
