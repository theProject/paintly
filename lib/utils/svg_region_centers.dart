// lib/utils/svg_region_centers.dart

import 'dart:ui';
import 'package:xml/xml.dart' as xml;
import 'package:path_drawing/path_drawing.dart';

/// Computes a best-effort center for each element with an id in the SVG.
/// - circle/ellipse/rect: exact geometric center
/// - path/polygon: center of the shape's bounding box
/// NOTE: ignores transforms (fine for your koala export).
Future<Map<String, Offset>> computeRegionCenters(String svgString) async {
  final doc = xml.XmlDocument.parse(svgString);
  final centers = <String, Offset>{};

  Iterable<xml.XmlElement> all() => doc.findAllElements('*');

  Offset? centerFor(xml.XmlElement e) {
    final tag = e.name.local;
    double toD(String? v) => v == null ? 0.0 : double.tryParse(v) ?? 0.0;

    if (tag == 'circle') {
      return Offset(toD(e.getAttribute('cx')), toD(e.getAttribute('cy')));
    }
    if (tag == 'ellipse') {
      return Offset(toD(e.getAttribute('cx')), toD(e.getAttribute('cy')));
    }
    if (tag == 'rect') {
      final x = toD(e.getAttribute('x'));
      final y = toD(e.getAttribute('y'));
      final w = toD(e.getAttribute('width'));
      final h = toD(e.getAttribute('height'));
      return Offset(x + w / 2, y + h / 2);
    }
    // path / polygon → bbox center
    final d = e.getAttribute('d');
    if (d != null) {
      final path = parseSvgPathData(d);
      final b = path.getBounds();
      return Offset(b.left + b.width / 2, b.top + b.height / 2);
    }
    final points = e.getAttribute('points'); // polygon/polyline
    if (points != null) {
      final nums = points
          .trim()
          .split(RegExp(r'[ ,]+'))
          .map((s) => double.tryParse(s) ?? 0)
          .toList();
      if (nums.length >= 2) {
        double minX = nums[0], maxX = nums[0], minY = nums[1], maxY = nums[1];
        for (int i = 0; i + 1 < nums.length; i += 2) {
          final x = nums[i], y = nums[i + 1];
          if (x < minX) minX = x; if (x > maxX) maxX = x;
          if (y < minY) minY = y; if (y > maxY) maxY = y;
        }
        return Offset((minX + maxX) / 2, (minY + maxY) / 2);
      }
    }
    return null;
  }

  for (final e in all()) {
    final id = e.getAttribute('id');
    if (id == null) continue;
    final c = centerFor(e);
    if (c != null) centers[id] = c;
  }
  return centers;
}
