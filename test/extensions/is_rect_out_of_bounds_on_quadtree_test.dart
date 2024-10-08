import 'dart:ui';
import 'package:expandable_quadtree/expandable_quadtree.dart';
import 'package:test/test.dart';
import 'package:expandable_quadtree/src/extensions/is_rect_out_of_bounds_on_quadtree.dart';

void main() {
  group('SingleRootQuadtree IsRectOutOfBounds', () {
    late SingleRootQuadtree quadtree;

    setUp(() {
      quadtree = SingleRootQuadtree(
        Rect.fromLTWH(0, 0, 100, 100),
        getBounds: (p0) => throw Error(),
      );
    });

    test('rect is within bounds', () {
      final rect = Rect.fromLTWH(10, 10, 20, 20);
      expect(quadtree.isRectOutOfBounds(rect), isFalse);
    });

    test('rect is out of bounds on the left', () {
      final rect = Rect.fromLTWH(-10, 10, 20, 20);
      expect(quadtree.isRectOutOfBounds(rect), isTrue);
    });

    test('rect is out of bounds on the right', () {
      final rect = Rect.fromLTWH(90, 10, 20, 20);
      expect(quadtree.isRectOutOfBounds(rect), isTrue);
    });

    test('rect is out of bounds on the top', () {
      final rect = Rect.fromLTWH(10, -10, 20, 20);
      expect(quadtree.isRectOutOfBounds(rect), isTrue);
    });

    test('rect is out of bounds on the bottom', () {
      final rect = Rect.fromLTWH(10, 90, 20, 20);
      expect(quadtree.isRectOutOfBounds(rect), isTrue);
    });
  });

  group('ExpandableQuadtree IsRectOutOfBounds', () {
    late ExpandableQuadtree quadtree;

    setUp(() {
      quadtree = ExpandableQuadtree(
        Rect.fromLTWH(0, 0, 100, 100),
        getBounds: (p0) => throw Error(),
      );
    });

    test('rect is within bounds', () {
      final rect = Rect.fromLTWH(10, 10, 20, 20);
      expect(quadtree.isRectOutOfBounds(rect), isFalse);
    });

    test('rect is out of bounds on the left', () {
      final rect = Rect.fromLTWH(-10, 10, 20, 20);
      expect(quadtree.isRectOutOfBounds(rect), isTrue);
    });

    test('rect is out of bounds on the right', () {
      final rect = Rect.fromLTWH(90, 10, 20, 20);
      expect(quadtree.isRectOutOfBounds(rect), isTrue);
    });

    test('rect is out of bounds on the top', () {
      final rect = Rect.fromLTWH(10, -10, 20, 20);
      expect(quadtree.isRectOutOfBounds(rect), isTrue);
    });

    test('rect is out of bounds on the bottom', () {
      final rect = Rect.fromLTWH(10, 90, 20, 20);
      expect(quadtree.isRectOutOfBounds(rect), isTrue);
    });
  });

  group('HorizontallyExpandableQuadtree IsRectOutOfBounds', () {
    late HorizontallyExpandableQuadtree quadtree;

    setUp(() {
      quadtree = HorizontallyExpandableQuadtree(
        Rect.fromLTWH(0, 0, 100, 100),
        getBounds: (p0) => throw Error(),
      );
    });

    test('rect is within bounds', () {
      final rect = Rect.fromLTWH(10, 10, 20, 20);
      expect(quadtree.isRectOutOfBounds(rect), isFalse);
    });

    test('rect is out of bounds on the left', () {
      final rect = Rect.fromLTWH(-10, 10, 20, 20);
      expect(quadtree.isRectOutOfBounds(rect), isTrue);
    });

    test('rect is out of bounds on the right', () {
      final rect = Rect.fromLTWH(90, 10, 20, 20);
      expect(quadtree.isRectOutOfBounds(rect), isTrue);
    });

    test('rect is out of bounds on the top', () {
      final rect = Rect.fromLTWH(10, -10, 20, 20);
      expect(quadtree.isRectOutOfBounds(rect), isTrue);
    });

    test('rect is out of bounds on the bottom', () {
      final rect = Rect.fromLTWH(10, 90, 20, 20);
      expect(quadtree.isRectOutOfBounds(rect), isTrue);
    });
  });

  group('VerticallyExpandableQuadtree IsRectOutOfBounds', () {
    late VerticallyExpandableQuadtree quadtree;

    setUp(() {
      quadtree = VerticallyExpandableQuadtree(
        Rect.fromLTWH(0, 0, 100, 100),
        getBounds: (p0) => throw Error(),
      );
    });

    test('rect is within bounds', () {
      final rect = Rect.fromLTWH(10, 10, 20, 20);
      expect(quadtree.isRectOutOfBounds(rect), isFalse);
    });

    test('rect is out of bounds on the left', () {
      final rect = Rect.fromLTWH(-10, 10, 20, 20);
      expect(quadtree.isRectOutOfBounds(rect), isTrue);
    });

    test('rect is out of bounds on the right', () {
      final rect = Rect.fromLTWH(90, 10, 20, 20);
      expect(quadtree.isRectOutOfBounds(rect), isTrue);
    });

    test('rect is out of bounds on the top', () {
      final rect = Rect.fromLTWH(10, -10, 20, 20);
      expect(quadtree.isRectOutOfBounds(rect), isTrue);
    });

    test('rect is out of bounds on the bottom', () {
      final rect = Rect.fromLTWH(10, 90, 20, 20);
      expect(quadtree.isRectOutOfBounds(rect), isTrue);
    });
  });
}
