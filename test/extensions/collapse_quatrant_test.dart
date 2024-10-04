import 'package:fast_quadtree/fast_quadtree.dart';
import 'package:fast_quadtree/src/extensions/collapse_quadrant.dart';
import 'package:test/test.dart';

void main() {
  group('CollapseQuadrant extension', () {
    group("Positive Origin", () {
      test('collapseTo NW', () {
        final quadrant = Quadrant(x: 0, y: 0, width: 100, height: 100);
        final collapsed = quadrant.collapseTo(QuadrantLocation.nw);
        expect(collapsed.x, 0);
        expect(collapsed.y, 0);
        expect(collapsed.width, 50);
        expect(collapsed.height, 50);
      });

      test('collapseTo NE', () {
        final quadrant = Quadrant(x: 0, y: 0, width: 100, height: 100);
        final collapsed = quadrant.collapseTo(QuadrantLocation.ne);
        expect(collapsed.x, 50);
        expect(collapsed.y, 0);
        expect(collapsed.width, 50);
        expect(collapsed.height, 50);
      });

      test('collapseTo SW', () {
        final quadrant = Quadrant(x: 0, y: 0, width: 100, height: 100);
        final collapsed = quadrant.collapseTo(QuadrantLocation.sw);
        expect(collapsed.x, 0);
        expect(collapsed.y, 50);
        expect(collapsed.width, 50);
        expect(collapsed.height, 50);
      });

      test('collapseTo SE', () {
        final quadrant = Quadrant(x: 0, y: 0, width: 100, height: 100);
        final collapsed = quadrant.collapseTo(QuadrantLocation.se);
        expect(collapsed.x, 50);
        expect(collapsed.y, 50);
        expect(collapsed.width, 50);
        expect(collapsed.height, 50);
      });
    });

    group("Negative Origin", () {
      test('collapseTo NW', () {
        final quadrant = Quadrant(x: -100, y: -100, width: 100, height: 100);
        final collapsed = quadrant.collapseTo(QuadrantLocation.nw);
        expect(collapsed.x, -100);
        expect(collapsed.y, -100);
        expect(collapsed.width, 50);
        expect(collapsed.height, 50);
      });

      test('collapseTo NE', () {
        final quadrant = Quadrant(x: -100, y: -100, width: 100, height: 100);
        final collapsed = quadrant.collapseTo(QuadrantLocation.ne);
        expect(collapsed.x, -50);
        expect(collapsed.y, -100);
        expect(collapsed.width, 50);
        expect(collapsed.height, 50);
      });

      test('collapseTo SW', () {
        final quadrant = Quadrant(x: -100, y: -100, width: 100, height: 100);
        final collapsed = quadrant.collapseTo(QuadrantLocation.sw);
        expect(collapsed.x, -100);
        expect(collapsed.y, -50);
        expect(collapsed.width, 50);
        expect(collapsed.height, 50);
      });

      test('collapseTo SE', () {
        final quadrant = Quadrant(x: -100, y: -100, width: 100, height: 100);
        final collapsed = quadrant.collapseTo(QuadrantLocation.se);
        expect(collapsed.x, -50);
        expect(collapsed.y, -50);
        expect(collapsed.width, 50);
        expect(collapsed.height, 50);
      });
    });
  });
}
