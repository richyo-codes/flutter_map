import 'package:flutter_map/src/misc/polyline_offsets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('positive displacement follows the right side of travel', () {
    expect(offsetPolylinePoints(const [Offset.zero, Offset(10, 0)], -3),
        const [Offset(0, -3), Offset(10, -3)]);
    expect(offsetPolylinePoints(const [Offset.zero, Offset(10, 0)], 3),
        const [Offset(0, 3), Offset(10, 3)]);
    expect(offsetPolylinePoints(const [Offset(10, 0), Offset.zero], 3),
        const [Offset(10, -3), Offset(0, -3)]);
  });

  test('duplicate vertices share the corner normal', () {
    final result = offsetPolylinePoints(const [
      Offset.zero,
      Offset(10, 0),
      Offset(10, 0),
      Offset(10, 0),
      Offset(10, 10),
    ], 2);
    for (var i = 1; i <= 3; i++) {
      expect(result[i].dx, closeTo(8, 1e-9));
      expect(result[i].dy, closeTo(2, 1e-9));
    }
  });

  test('sharp bends and reversals have finite bounded miters', () {
    for (final end in const [Offset.zero, Offset(0, 0.001)]) {
      final source = [Offset.zero, const Offset(10, 0), end];
      final result = offsetPolylinePoints(source, 3);
      for (var i = 0; i < source.length; i++) {
        expect(result[i].dx.isFinite && result[i].dy.isFinite, isTrue);
        expect((result[i] - source[i]).distance, lessThanOrEqualTo(12.000001));
      }
    }
  });

  test('zero offsets reuse geometry and degenerate routes stay unchanged', () {
    final points = [Offset.zero, const Offset(1, 0)];
    expect(identical(offsetPolylinePoints(points, 0), points), isTrue);
    expect(offsetPolylinePoints(const [], 3), isEmpty);
    expect(offsetPolylinePoints(const [Offset.zero], 3), [Offset.zero]);
    expect(offsetPolylinePoints(List.filled(4, Offset.zero), 3),
        List.filled(4, Offset.zero));
  });
}
