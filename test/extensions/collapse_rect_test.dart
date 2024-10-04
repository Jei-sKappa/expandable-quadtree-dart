import 'dart:ui';

import 'package:fast_quadtree/fast_quadtree.dart';
import 'package:fast_quadtree/src/extensions/collapse_rect.dart';
import 'package:test/test.dart';

void main() {
  group('CollapseRect extension', () {
    group("Positive Origin", () {
      test('collapseTo NW', () {
        final quadrant = Rect.fromLTWH(0, 0, 100, 100);
        final collapsed = quadrant.collapseTo(QuadrantLocation.nw);
        expect(collapsed.left, 0);
        expect(collapsed.top, 0);
        expect(collapsed.width, 50);
        expect(collapsed.height, 50);
      });

      test('collapseTo NE', () {
        final quadrant = Rect.fromLTWH(0, 0, 100, 100);
        final collapsed = quadrant.collapseTo(QuadrantLocation.ne);
        expect(collapsed.left, 50);
        expect(collapsed.top, 0);
        expect(collapsed.width, 50);
        expect(collapsed.height, 50);
      });

      test('collapseTo SW', () {
        final quadrant = Rect.fromLTWH(0, 0, 100, 100);
        final collapsed = quadrant.collapseTo(QuadrantLocation.sw);
        expect(collapsed.left, 0);
        expect(collapsed.top, 50);
        expect(collapsed.width, 50);
        expect(collapsed.height, 50);
      });

      test('collapseTo SE', () {
        final quadrant = Rect.fromLTWH(0, 0, 100, 100);
        final collapsed = quadrant.collapseTo(QuadrantLocation.se);
        expect(collapsed.left, 50);
        expect(collapsed.top, 50);
        expect(collapsed.width, 50);
        expect(collapsed.height, 50);
      });
    });

    group("Negative Origin", () {
      test('collapseTo NW', () {
        final quadrant = Rect.fromLTWH(-100, -100, 100, 100);
        final collapsed = quadrant.collapseTo(QuadrantLocation.nw);
        expect(collapsed.left, -100);
        expect(collapsed.top, -100);
        expect(collapsed.width, 50);
        expect(collapsed.height, 50);
      });

      test('collapseTo NE', () {
        final quadrant = Rect.fromLTWH(-100, -100, 100, 100);
        final collapsed = quadrant.collapseTo(QuadrantLocation.ne);
        expect(collapsed.left, -50);
        expect(collapsed.top, -100);
        expect(collapsed.width, 50);
        expect(collapsed.height, 50);
      });

      test('collapseTo SW', () {
        final quadrant = Rect.fromLTWH(-100, -100, 100, 100);
        final collapsed = quadrant.collapseTo(QuadrantLocation.sw);
        expect(collapsed.left, -100);
        expect(collapsed.top, -50);
        expect(collapsed.width, 50);
        expect(collapsed.height, 50);
      });

      test('collapseTo SE', () {
        final quadrant = Rect.fromLTWH(-100, -100, 100, 100);
        final collapsed = quadrant.collapseTo(QuadrantLocation.se);
        expect(collapsed.left, -50);
        expect(collapsed.top, -50);
        expect(collapsed.width, 50);
        expect(collapsed.height, 50);
      });
    });
  });
}
