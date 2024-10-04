import 'dart:ui';

import 'package:expandable_quadtree/expandable_quadtree.dart';
import 'package:test/test.dart';
import 'package:expandable_quadtree/src/extensions/position_details_on_quadtree.dart';

void main() {
  final quadrant = Rect.fromLTWH(-100, -100, 100, 100);

  group('SingleRootQuadtree Extension', () {
    late SingleRootQuadtree quadtree;

    setUp(() {
      quadtree = SingleRootQuadtree(
        quadrant,
        getBounds: (p0) => throw Error(),
      );
    });

    test('right returns correct value', () {
      expect(quadtree.right, 0);
    });

    test('bottom returns correct value', () {
      expect(quadtree.bottom, 0);
    });
  });

  group('ExpandableQuadtree Extension', () {
    late ExpandableQuadtree quadtree;

    setUp(() {
      quadtree = ExpandableQuadtree(
        quadrant,
        getBounds: (p0) => throw Error(),
      );
    });

    test('right returns correct value', () {
      expect(quadtree.right, 0);
    });

    test('bottom returns correct value', () {
      expect(quadtree.bottom, 0);
    });
  });

  group('HorizontallyExpandableQuadtree Extension', () {
    late HorizontallyExpandableQuadtree quadtree;

    setUp(() {
      quadtree = HorizontallyExpandableQuadtree(
        quadrant,
        getBounds: (p0) => throw Error(),
      );
    });

    test('right returns correct value', () {
      expect(quadtree.right, 0);
    });

    test('bottom returns correct value', () {
      expect(quadtree.bottom, 0);
    });
  });

  group('VerticallyExpandableQuadtree Extension', () {
    late VerticallyExpandableQuadtree quadtree;

    setUp(() {
      quadtree = VerticallyExpandableQuadtree(
        quadrant,
        getBounds: (p0) => throw Error(),
      );
    });

    test('right returns correct value', () {
      expect(quadtree.right, 0);
    });

    test('bottom returns correct value', () {
      expect(quadtree.bottom, 0);
    });
  });
}
