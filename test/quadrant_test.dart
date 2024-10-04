import 'dart:ui';

import 'package:test/test.dart';
import 'package:fast_quadtree/src/quadrant.dart';

void main() {
  group('Quadrant', () {
    test('default constructor initializes correctly', () {
      final quadrant = Quadrant(x: 10, y: 20, width: 30, height: 40);
      expect(quadrant.x, 10);
      expect(quadrant.y, 20);
      expect(quadrant.width, 30);
      expect(quadrant.height, 40);
    });

    test('fromOrigin constructor initializes correctly', () {
      final quadrant = Quadrant.fromOrigin(width: 50, height: 60);
      expect(quadrant.x, 0);
      expect(quadrant.y, 0);
      expect(quadrant.width, 50);
      expect(quadrant.height, 60);
    });

    test('fromOffset constructor initializes correctly', () {
      final quadrant = Quadrant.fromOffset(Offset(70, 80));
      expect(quadrant.x, 70);
      expect(quadrant.y, 80);
      expect(quadrant.width, 1);
      expect(quadrant.height, 1);
    });

    test('fromLTRB constructor initializes correctly', () {
      final quadrant =
          Quadrant.fromLTRB(left: 10, top: 20, right: 50, bottom: 60);
      expect(quadrant.x, 10);
      expect(quadrant.y, 20);
      expect(quadrant.width, 40);
      expect(quadrant.height, 40);
    });

    test('fromMap constructor initializes correctly', () {
      final map = {'x': 10.0, 'y': 20.0, 'width': 30.0, 'height': 40.0};
      final quadrant = Quadrant.fromMap(map);
      expect(quadrant.x, 10);
      expect(quadrant.y, 20);
      expect(quadrant.width, 30);
      expect(quadrant.height, 40);
    });

    test('intersects returns true for intersecting quadrants', () {
      final q1 = Quadrant(x: 0, y: 0, width: 50, height: 50);
      final q2 = Quadrant(x: 25, y: 25, width: 50, height: 50);
      expect(q1.intersects(q2), isTrue);
    });

    test('intersects returns false for non-intersecting quadrants', () {
      final q1 = Quadrant(x: 0, y: 0, width: 50, height: 50);
      final q2 = Quadrant(x: 60, y: 60, width: 50, height: 50);
      expect(q1.intersects(q2), isFalse);
    });

    test('bounds returns correct Rect', () {
      final quadrant = Quadrant(x: 10, y: 20, width: 30, height: 40);
      expect(quadrant.bounds, Rect.fromLTWH(10, 20, 30, 40));
    });

    test('copyWith returns a copy with updated values', () {
      final quadrant = Quadrant(x: 10, y: 20, width: 30, height: 40);
      final copy = quadrant.copyWith(x: 15, height: 45);
      expect(copy.x, 15);
      expect(copy.y, 20);
      expect(copy.width, 30);
      expect(copy.height, 45);
    });

    test('copyWith with no changes is equal to original', () {
      final quadrant = Quadrant(x: 10, y: 20, width: 30, height: 40);
      final copy = quadrant.copyWith();
      expect(copy == quadrant, isTrue);
    });

    test('toMap returns correct map', () {
      final quadrant = Quadrant(x: 10, y: 20, width: 30, height: 40);
      final map = quadrant.toMap();
      expect(map['x'], 10);
      expect(map['y'], 20);
      expect(map['width'], 30);
      expect(map['height'], 40);
    });

    test('Equatable props are correct', () {
      final quadrant = Quadrant(x: 10, y: 20, width: 30, height: 40);
      expect(quadrant.props, [10, 20, 30, 40]);
    });

    test('stringify is true', () {
      final quadrant = Quadrant(x: 10, y: 20, width: 30, height: 40);
      expect(quadrant.stringify, isTrue);
    });
  });
}
