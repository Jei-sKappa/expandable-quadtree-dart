import 'dart:ui';

import 'package:expandable_quadtree/expandable_quadtree.dart';
import 'package:expandable_quadtree/src/extensions/to_map_on_rect.dart';
import 'package:expandable_quadtree/src/helpers/rect_mapper.dart';
import 'package:test/test.dart';

void main() {
  Rect getBounds(Rect rect) => rect;
  final quadrant = Rect.fromLTWH(0, 0, 100, 100);
  final rect0 = Rect.fromLTWH(0, 0, 1, 1);
  final rect1 = Rect.fromLTWH(10, 10, 1, 1);
  final rect8 = Rect.fromLTWH(80, 80, 1, 1);
  final rect9 = Rect.fromLTWH(90, 90, 1, 1);

  group('Quadtree.fromMap', () {
    test('CachedQuadtree', () {
      final innerQuadtree = SingleRootQuadtree<Rect>(
        quadrant,
        maxItems: 1,
        maxDepth: 4,
        getBounds: getBounds,
      );
      final quadtree = CachedQuadtree<Rect>(innerQuadtree);
      expect(quadtree.insertAll([rect0, rect1, rect8, rect9]), isTrue);
      final map = quadtree.toMap((rect) => rect.toMap());
      final quadtreeFromMap = Quadtree.fromMap(
        map,
        getBounds,
        RectMapper.fromMap,
      );
      expect(quadtreeFromMap is CachedQuadtree<Rect>, isTrue);
      quadtreeFromMap as CachedQuadtree<Rect>;
      expect(quadtreeFromMap, quadtree);
      expect(quadtreeFromMap.decoratedQuadtree, quadtree.decoratedQuadtree);
    });

    test('SingleRootQuadtree', () {
      final quadtree = SingleRootQuadtree<Rect>(
        quadrant,
        maxItems: 1,
        maxDepth: 4,
        getBounds: getBounds,
      );
      expect(quadtree.insertAll([rect0, rect1, rect8, rect9]), isTrue);
      final map = quadtree.toMap((rect) => rect.toMap());
      final quadtreeFromMap =
          Quadtree.fromMap(map, getBounds, RectMapper.fromMap);
      expect(quadtreeFromMap is SingleRootQuadtree<Rect>, isTrue);
      expect(quadtreeFromMap, quadtree);
    });

    test('ExpandableQuadtree', () {
      final quadtree = ExpandableQuadtree<Rect>(
        quadrant,
        maxItems: 1,
        maxDepth: 4,
        getBounds: getBounds,
      );
      expect(quadtree.insertAll([rect0, rect1, rect8, rect9]), isTrue);
      final map = quadtree.toMap((rect) => rect.toMap());
      final quadtreeFromMap =
          Quadtree.fromMap(map, getBounds, RectMapper.fromMap);
      expect(quadtreeFromMap is ExpandableQuadtree<Rect>, isTrue);
      expect(quadtreeFromMap, quadtree);
    });

    test('VerticallyExpandableQuadtree', () {
      final quadtree = VerticallyExpandableQuadtree<Rect>(
        quadrant,
        maxItems: 1,
        maxDepth: 4,
        getBounds: getBounds,
      );
      expect(quadtree.insertAll([rect0, rect1, rect8, rect9]), isTrue);
      final map = quadtree.toMap((rect) => rect.toMap());
      final quadtreeFromMap =
          Quadtree.fromMap(map, getBounds, RectMapper.fromMap);
      expect(quadtreeFromMap is VerticallyExpandableQuadtree<Rect>, isTrue);
      expect(quadtreeFromMap, quadtree);
    });

    test('HorizontallyExpandableQuadtree', () {
      final quadtree = HorizontallyExpandableQuadtree<Rect>(
        quadrant,
        maxItems: 1,
        maxDepth: 4,
        getBounds: getBounds,
      );
      expect(quadtree.insertAll([rect0, rect1, rect8, rect9]), isTrue);
      final map = quadtree.toMap((rect) => rect.toMap());
      final quadtreeFromMap =
          Quadtree.fromMap(map, getBounds, RectMapper.fromMap);
      expect(quadtreeFromMap is HorizontallyExpandableQuadtree<Rect>, isTrue);
      expect(quadtreeFromMap, quadtree);
    });

    test('Invalid Quadtree type', () {
      final map = <String, dynamic>{
        '_type': 'InvalidQuadtree',
      };
      expect(
        () => Quadtree.fromMap(map, getBounds, RectMapper.fromMap),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
