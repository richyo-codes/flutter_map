import 'dart:math' as math;
import 'dart:ui';

import 'package:meta/meta.dart';

/// Offset a screen-space route while preserving source vertex indices.
///
/// Uses nearest nonzero segments at repeated points and bounds miters to four
/// times the displacement. At a reversal, use the outgoing segment's normal.
@internal
List<Offset> offsetPolylinePoints(List<Offset> points, double displacement) {
  if (displacement == 0 || points.length < 2) return points;

  final incoming = List<Offset>.filled(points.length, Offset.zero);
  final outgoing = List<Offset>.filled(points.length, Offset.zero);
  var normal = Offset.zero;
  for (var i = 1; i < points.length; i++) {
    final delta = points[i] - points[i - 1];
    if (delta.distanceSquared != 0) {
      normal = Offset(-delta.dy, delta.dx) / delta.distance;
    }
    incoming[i] = normal;
  }
  normal = Offset.zero;
  for (var i = points.length - 2; i >= 0; i--) {
    final delta = points[i + 1] - points[i];
    if (delta.distanceSquared != 0) {
      normal = Offset(-delta.dy, delta.dx) / delta.distance;
    }
    outgoing[i] = normal;
  }

  return List.generate(points.length, (i) {
    final before = incoming[i] == Offset.zero ? outgoing[i] : incoming[i];
    final after = outgoing[i] == Offset.zero ? before : outgoing[i];
    var bisector = before + after;
    if (bisector.distanceSquared < 1e-12) bisector = after;
    if (bisector == Offset.zero) return points[i];
    final direction = bisector / bisector.distance;
    final alignment = direction.dx * after.dx + direction.dy * after.dy;
    final scale = 1 / math.max(alignment.abs(), 0.25);
    return points[i] + direction * displacement * scale;
  }, growable: false);
}
