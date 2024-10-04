import 'dart:ui';

import 'package:expandable_quadtree/expandable_quadtree.dart';
import 'package:expandable_quadtree/src/extensions/move_rect.dart';
import 'package:test/test.dart';

void main() {
  group('MoveRect extension', () {
    test('moveTo from NW to NE', () {
      final quadrant = Rect.fromLTWH(0, 0, 100, 100);
      final moved = quadrant.moveTo(QuadrantLocation.nw, QuadrantLocation.ne);
      expect(moved.left, 100);
      expect(moved.top, 0);
    });

    test('moveTo from NW to SW', () {
      final quadrant = Rect.fromLTWH(0, 0, 100, 100);
      final moved = quadrant.moveTo(QuadrantLocation.nw, QuadrantLocation.sw);
      expect(moved.left, 0);
      expect(moved.top, 100);
    });

    test('moveTo from NW to SE', () {
      final quadrant = Rect.fromLTWH(0, 0, 100, 100);
      final moved = quadrant.moveTo(QuadrantLocation.nw, QuadrantLocation.se);
      expect(moved.left, 100);
      expect(moved.top, 100);
    });

    test('moveTo from NE to NW', () {
      final quadrant = Rect.fromLTWH(100, 0, 100, 100);
      final moved = quadrant.moveTo(QuadrantLocation.ne, QuadrantLocation.nw);
      expect(moved.left, 0);
      expect(moved.top, 0);
    });

    test('moveTo from NE to SW', () {
      final quadrant = Rect.fromLTWH(100, 0, 100, 100);
      final moved = quadrant.moveTo(QuadrantLocation.ne, QuadrantLocation.sw);
      expect(moved.left, 0);
      expect(moved.top, 100);
    });

    test('moveTo from NE to SE', () {
      final quadrant = Rect.fromLTWH(100, 0, 100, 100);
      final moved = quadrant.moveTo(QuadrantLocation.ne, QuadrantLocation.se);
      expect(moved.left, 100);
      expect(moved.top, 100);
    });

    test('moveTo from SW to NW', () {
      final quadrant = Rect.fromLTWH(0, 100, 100, 100);
      final moved = quadrant.moveTo(QuadrantLocation.sw, QuadrantLocation.nw);
      expect(moved.left, 0);
      expect(moved.top, 0);
    });

    test('moveTo from SW to NE', () {
      final quadrant = Rect.fromLTWH(0, 100, 100, 100);
      final moved = quadrant.moveTo(QuadrantLocation.sw, QuadrantLocation.ne);
      expect(moved.left, 100);
      expect(moved.top, 0);
    });

    test('moveTo from SW to SE', () {
      final quadrant = Rect.fromLTWH(0, 100, 100, 100);
      final moved = quadrant.moveTo(QuadrantLocation.sw, QuadrantLocation.se);
      expect(moved.left, 100);
      expect(moved.top, 100);
    });

    test('moveTo from SE to NW', () {
      final quadrant = Rect.fromLTWH(100, 100, 100, 100);
      final moved = quadrant.moveTo(QuadrantLocation.se, QuadrantLocation.nw);
      expect(moved.left, 0);
      expect(moved.top, 0);
    });

    test('moveTo from SE to NE', () {
      final quadrant = Rect.fromLTWH(100, 100, 100, 100);
      final moved = quadrant.moveTo(QuadrantLocation.se, QuadrantLocation.ne);
      expect(moved.left, 100);
      expect(moved.top, 0);
    });

    test('moveTo from SE to SW', () {
      final quadrant = Rect.fromLTWH(100, 100, 100, 100);
      final moved = quadrant.moveTo(QuadrantLocation.se, QuadrantLocation.sw);
      expect(moved.left, 0);
      expect(moved.top, 100);
    });
  });
}
