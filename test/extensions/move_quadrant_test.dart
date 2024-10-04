import 'package:fast_quadtree/fast_quadtree.dart';
import 'package:fast_quadtree/src/extensions/move_quadrant.dart';
import 'package:test/test.dart';

void main() {
  group('MoveQuadrant extension', () {
    test('moveTo from NW to NE', () {
      final quadrant = Quadrant(x: 0, y: 0, width: 100, height: 100);
      final moved = quadrant.moveTo(QuadrantLocation.nw, QuadrantLocation.ne);
      expect(moved.x, 100);
      expect(moved.y, 0);
    });

    test('moveTo from NW to SW', () {
      final quadrant = Quadrant(x: 0, y: 0, width: 100, height: 100);
      final moved = quadrant.moveTo(QuadrantLocation.nw, QuadrantLocation.sw);
      expect(moved.x, 0);
      expect(moved.y, 100);
    });

    test('moveTo from NW to SE', () {
      final quadrant = Quadrant(x: 0, y: 0, width: 100, height: 100);
      final moved = quadrant.moveTo(QuadrantLocation.nw, QuadrantLocation.se);
      expect(moved.x, 100);
      expect(moved.y, 100);
    });

    test('moveTo from NE to NW', () {
      final quadrant = Quadrant(x: 100, y: 0, width: 100, height: 100);
      final moved = quadrant.moveTo(QuadrantLocation.ne, QuadrantLocation.nw);
      expect(moved.x, 0);
      expect(moved.y, 0);
    });

    test('moveTo from NE to SW', () {
      final quadrant = Quadrant(x: 100, y: 0, width: 100, height: 100);
      final moved = quadrant.moveTo(QuadrantLocation.ne, QuadrantLocation.sw);
      expect(moved.x, 0);
      expect(moved.y, 100);
    });

    test('moveTo from NE to SE', () {
      final quadrant = Quadrant(x: 100, y: 0, width: 100, height: 100);
      final moved = quadrant.moveTo(QuadrantLocation.ne, QuadrantLocation.se);
      expect(moved.x, 100);
      expect(moved.y, 100);
    });

    test('moveTo from SW to NW', () {
      final quadrant = Quadrant(x: 0, y: 100, width: 100, height: 100);
      final moved = quadrant.moveTo(QuadrantLocation.sw, QuadrantLocation.nw);
      expect(moved.x, 0);
      expect(moved.y, 0);
    });

    test('moveTo from SW to NE', () {
      final quadrant = Quadrant(x: 0, y: 100, width: 100, height: 100);
      final moved = quadrant.moveTo(QuadrantLocation.sw, QuadrantLocation.ne);
      expect(moved.x, 100);
      expect(moved.y, 0);
    });

    test('moveTo from SW to SE', () {
      final quadrant = Quadrant(x: 0, y: 100, width: 100, height: 100);
      final moved = quadrant.moveTo(QuadrantLocation.sw, QuadrantLocation.se);
      expect(moved.x, 100);
      expect(moved.y, 100);
    });

    test('moveTo from SE to NW', () {
      final quadrant = Quadrant(x: 100, y: 100, width: 100, height: 100);
      final moved = quadrant.moveTo(QuadrantLocation.se, QuadrantLocation.nw);
      expect(moved.x, 0);
      expect(moved.y, 0);
    });

    test('moveTo from SE to NE', () {
      final quadrant = Quadrant(x: 100, y: 100, width: 100, height: 100);
      final moved = quadrant.moveTo(QuadrantLocation.se, QuadrantLocation.ne);
      expect(moved.x, 100);
      expect(moved.y, 0);
    });

    test('moveTo from SE to SW', () {
      final quadrant = Quadrant(x: 100, y: 100, width: 100, height: 100);
      final moved = quadrant.moveTo(QuadrantLocation.se, QuadrantLocation.sw);
      expect(moved.x, 0);
      expect(moved.y, 100);
    });
  });
}
