import 'package:fast_quadtree/fast_quadtree.dart';
import 'package:fast_quadtree/src/extensions/expand_quadrant.dart';
import 'package:test/test.dart';

void main() {
  group('ExpandQuadrant', () {
    group('Positive Origin', () {
      test('expands to northwest', () {
        final quadrant = Quadrant(x: 10, y: 10, width: 5, height: 5);
        final expanded = quadrant.expandTo(QuadrantLocation.nw);

        expect(expanded.x, 5);
        expect(expanded.y, 5);
        expect(expanded.width, 10);
        expect(expanded.height, 10);
      });

      test('expands to northeast', () {
        final quadrant = Quadrant(x: 10, y: 10, width: 5, height: 5);
        final expanded = quadrant.expandTo(QuadrantLocation.ne);

        expect(expanded.x, 10);
        expect(expanded.y, 5);
        expect(expanded.width, 10);
        expect(expanded.height, 10);
      });

      test('expands to southwest', () {
        final quadrant = Quadrant(x: 10, y: 10, width: 5, height: 5);
        final expanded = quadrant.expandTo(QuadrantLocation.sw);

        expect(expanded.x, 5);
        expect(expanded.y, 10);
        expect(expanded.width, 10);
        expect(expanded.height, 10);
      });

      test('expands to southeast', () {
        final quadrant = Quadrant(x: 10, y: 10, width: 5, height: 5);
        final expanded = quadrant.expandTo(QuadrantLocation.se);

        expect(expanded.x, 10);
        expect(expanded.y, 10);
        expect(expanded.width, 10);
        expect(expanded.height, 10);
      });
    });

    group('Negative Origin', () {
      test('expands to northwest', () {
        final quadrant = Quadrant(x: -10, y: -10, width: 5, height: 5);
        final expanded = quadrant.expandTo(QuadrantLocation.nw);

        expect(expanded.x, -15);
        expect(expanded.y, -15);
        expect(expanded.width, 10);
        expect(expanded.height, 10);
      });

      test('expands to northeast', () {
        final quadrant = Quadrant(x: -10, y: -10, width: 5, height: 5);
        final expanded = quadrant.expandTo(QuadrantLocation.ne);

        expect(expanded.x, -10);
        expect(expanded.y, -15);
        expect(expanded.width, 10);
        expect(expanded.height, 10);
      });

      test('expands to southwest', () {
        final quadrant = Quadrant(x: -10, y: -10, width: 5, height: 5);
        final expanded = quadrant.expandTo(QuadrantLocation.sw);

        expect(expanded.x, -15);
        expect(expanded.y, -10);
        expect(expanded.width, 10);
        expect(expanded.height, 10);
      });

      test('expands to southeast', () {
        final quadrant = Quadrant(x: -10, y: -10, width: 5, height: 5);
        final expanded = quadrant.expandTo(QuadrantLocation.se);

        expect(expanded.x, -10);
        expect(expanded.y, -10);
        expect(expanded.width, 10);
        expect(expanded.height, 10);
      });
    });
  });
}
