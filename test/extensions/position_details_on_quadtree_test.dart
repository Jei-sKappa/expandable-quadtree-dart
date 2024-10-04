import 'package:fast_quadtree/fast_quadtree.dart';
import 'package:test/test.dart';
import 'package:fast_quadtree/src/extensions/position_details_on_quadtree.dart';

void main() {
  final quadrant = Quadrant(x: -100, y: -100, width: 100, height: 100);

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