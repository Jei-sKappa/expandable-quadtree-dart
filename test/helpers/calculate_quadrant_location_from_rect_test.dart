import 'dart:ui';

import 'package:fast_quadtree/src/helpers/calculate_quadrant_location_from_rect.dart';
import 'package:fast_quadtree/src/quadrant.dart';
import 'package:fast_quadtree/src/quadrant_location.dart';
import 'package:test/test.dart';

void main() {
  group('calculateQuadrantLocationsFromRect', () {
    final quadrant = Quadrant(x: 0, y: 0, width: 100, height: 100);

    test('rect is in the northwest quadrant', () {
      final rect = Rect.fromLTWH(10, 10, 20, 20);
      final result = calculateQuadrantLocationsFromRect(rect, quadrant);
      expect(result, [QuadrantLocation.nw]);
    });

    test('rect is in the northeast quadrant', () {
      final rect = Rect.fromLTWH(60, 10, 20, 20);
      final result = calculateQuadrantLocationsFromRect(rect, quadrant);
      expect(result, [QuadrantLocation.ne]);
    });

    test('rect is in the southwest quadrant', () {
      final rect = Rect.fromLTWH(10, 60, 20, 20);
      final result = calculateQuadrantLocationsFromRect(rect, quadrant);
      expect(result, [QuadrantLocation.sw]);
    });

    test('rect is in the southeast quadrant', () {
      final rect = Rect.fromLTWH(60, 60, 20, 20);
      final result = calculateQuadrantLocationsFromRect(rect, quadrant);
      expect(result, [QuadrantLocation.se]);
    });

    test('rect spans northeast and northwest quadrants', () {
      final rect = Rect.fromLTWH(40, 10, 30, 20);
      final result = calculateQuadrantLocationsFromRect(rect, quadrant);
      expect(result, containsAll([QuadrantLocation.nw, QuadrantLocation.ne]));
    });

    test('rect spans southeast and southwest quadrants', () {
      final rect = Rect.fromLTWH(40, 70, 30, 20);
      final result = calculateQuadrantLocationsFromRect(rect, quadrant);
      expect(result, containsAll([QuadrantLocation.sw, QuadrantLocation.se]));
    });

    test('rect spans all quadrants', () {
      final rect = Rect.fromLTWH(40, 40, 30, 30);
      final result = calculateQuadrantLocationsFromRect(rect, quadrant);
      expect(
        result,
        containsAll([
          QuadrantLocation.nw,
          QuadrantLocation.ne,
          QuadrantLocation.sw,
          QuadrantLocation.se,
        ]),
      );
    });

    test('rect is equal to the quadrant', () {
      final rect = Rect.fromLTWH(0, 0, 100, 100);
      final result = calculateQuadrantLocationsFromRect(rect, quadrant);
      expect(
        result,
        containsAll([
          QuadrantLocation.nw,
          QuadrantLocation.ne,
          QuadrantLocation.sw,
          QuadrantLocation.se,
        ]),
      );
    });
  });
}
