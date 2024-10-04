import 'dart:ui';

import 'package:expandable_quadtree/expandable_quadtree.dart';
import 'package:expandable_quadtree/src/extensions/expand_rect.dart';
import 'package:test/test.dart';

void main() {
  group('ExpandRect', () {
    group('Positive Origin', () {
      test('expands to northwest', () {
        final quadrant = Rect.fromLTWH(10, 10, 5, 5);
        final expanded = quadrant.expandTo(QuadrantLocation.nw);

        expect(expanded.left, 5);
        expect(expanded.top, 5);
        expect(expanded.width, 10);
        expect(expanded.height, 10);
      });

      test('expands to northeast', () {
        final quadrant = Rect.fromLTWH(10, 10, 5, 5);
        final expanded = quadrant.expandTo(QuadrantLocation.ne);

        expect(expanded.left, 10);
        expect(expanded.top, 5);
        expect(expanded.width, 10);
        expect(expanded.height, 10);
      });

      test('expands to southwest', () {
        final quadrant = Rect.fromLTWH(10, 10, 5, 5);
        final expanded = quadrant.expandTo(QuadrantLocation.sw);

        expect(expanded.left, 5);
        expect(expanded.top, 10);
        expect(expanded.width, 10);
        expect(expanded.height, 10);
      });

      test('expands to southeast', () {
        final quadrant = Rect.fromLTWH(10, 10, 5, 5);
        final expanded = quadrant.expandTo(QuadrantLocation.se);

        expect(expanded.left, 10);
        expect(expanded.top, 10);
        expect(expanded.width, 10);
        expect(expanded.height, 10);
      });
    });

    group('Negative Origin', () {
      test('expands to northwest', () {
        final quadrant = Rect.fromLTWH(-10, -10, 5, 5);
        final expanded = quadrant.expandTo(QuadrantLocation.nw);

        expect(expanded.left, -15);
        expect(expanded.top, -15);
        expect(expanded.width, 10);
        expect(expanded.height, 10);
      });

      test('expands to northeast', () {
        final quadrant = Rect.fromLTWH(-10, -10, 5, 5);
        final expanded = quadrant.expandTo(QuadrantLocation.ne);

        expect(expanded.left, -10);
        expect(expanded.top, -15);
        expect(expanded.width, 10);
        expect(expanded.height, 10);
      });

      test('expands to southwest', () {
        final quadrant = Rect.fromLTWH(-10, -10, 5, 5);
        final expanded = quadrant.expandTo(QuadrantLocation.sw);

        expect(expanded.left, -15);
        expect(expanded.top, -10);
        expect(expanded.width, 10);
        expect(expanded.height, 10);
      });

      test('expands to southeast', () {
        final quadrant = Rect.fromLTWH(-10, -10, 5, 5);
        final expanded = quadrant.expandTo(QuadrantLocation.se);

        expect(expanded.left, -10);
        expect(expanded.top, -10);
        expect(expanded.width, 10);
        expect(expanded.height, 10);
      });
    });
  });
}
