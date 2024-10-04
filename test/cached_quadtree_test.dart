import 'package:collection/collection.dart';
import 'package:expandable_quadtree/src/cached_quadtree.dart';
import 'package:expandable_quadtree/src/extensions/loose_overlaps_on_rect.dart';
import 'package:expandable_quadtree/src/extensions/to_map_on_rect.dart';
import 'package:expandable_quadtree/src/helpers/rect_mapper.dart';
import 'package:test/test.dart';
import 'package:expandable_quadtree/src/single_root_quadtree.dart';
import 'dart:ui';

void main() {
  group('CachedQuadtree', () {
    final deepListEquality = const DeepCollectionEquality.unordered().equals;

    final quadrant = Rect.fromLTWH(0, 0, 100, 100);

    // NW subnode
    final nwRect = Rect.fromLTWH(10, 10, 1, 1);
    // SE -> SE subnode
    final seseRect = Rect.fromLTWH(90, 90, 1, 1);
    // SE -> NW subnode
    final senwRect = Rect.fromLTWH(60, 60, 1, 1);

    Rect getBounds(Rect rect) => rect;

    late CachedQuadtree<Rect> quadtree;

    setUp(() {
      quadtree = CachedQuadtree(
        SingleRootQuadtree<Rect>(
          quadrant,
          maxItems: 1,
          maxDepth: 5,
          getBounds: getBounds,
        ),
      );
    });

    test('constructor initializes correctly', () {
      expect(quadtree.decoratedQuadtree is SingleRootQuadtree, isTrue);
      expect(quadtree.maxItems, 1);
      expect(quadtree.maxDepth, 5);
      expect(quadtree.getBounds, getBounds);
      expect(
        quadtree.quadrant,
        Rect.fromLTWH(
            quadrant.left, quadrant.top, quadrant.width, quadrant.height),
      );
      expect(quadtree.cachedItems.isEmpty, isTrue);
    });

    test('fromMap initializes correctly', () {
      final map = {
        '_type': 'CachedQuadtree',
        'decoratedQuadtree': {
          '_type': 'SingleRootQuadtree',
          'quadrant': quadrant.toMap(),
          'maxItems': 1,
          'maxDepth': 5,
          'items': [
            nwRect.toMap(),
            seseRect.toMap(),
            senwRect.toMap(),
          ]
        },
      };

      final quadtree =
          CachedQuadtree<Rect>.fromMap(map, getBounds, RectMapper.fromMap);

      expect(quadtree.decoratedQuadtree is SingleRootQuadtree, isTrue);
      expect(quadtree.maxItems, 1);
      expect(quadtree.maxDepth, 5);
      expect(quadtree.getBounds, getBounds);
      expect(quadtree.left, 0.0);
      expect(quadtree.top, 0.0);
      expect(quadtree.width, 100.0);
      expect(quadtree.height, 100.0);
      expect(
        deepListEquality(
          quadtree.getAllItems(),
          quadtree.decoratedQuadtree.getAllItems(),
        ),
        isTrue,
      );
      expect(
        deepListEquality(quadtree.getAllItems(), [nwRect, seseRect, senwRect]),
        isTrue,
      );
      expect(
        deepListEquality(
          quadtree.cachedItems,
          [nwRect, seseRect, senwRect],
        ),
        isTrue,
      );
    });

    test('insert adds item correctly', () {
      final item = Rect.fromLTWH(10, 10, 10, 10);
      expect(quadtree.insert(item), isTrue);
      expect(
        deepListEquality(
          quadtree.getAllItems(),
          quadtree.decoratedQuadtree.getAllItems(),
        ),
        isTrue,
      );
      expect(quadtree.getAllItems(), [item]);
      expect(
        deepListEquality(
          quadtree.cachedItems,
          [item],
        ),
        isTrue,
      );
    });

    test('insert fails when item is outside of the quadrant', () {
      final item = Rect.fromLTWH(110, 110, 10, 10);
      expect(quadtree.insert(item), isFalse);
      expect(
        deepListEquality(
          quadtree.getAllItems(),
          quadtree.decoratedQuadtree.getAllItems(),
        ),
        isTrue,
      );
      expect(quadtree.getAllItems(), []);
      expect(
        deepListEquality(
          quadtree.cachedItems,
          [],
        ),
        isTrue,
      );
    });

    test('insertAll adds items correctly', () {
      final items = [
        Rect.fromLTWH(10, 10, 10, 10),
        Rect.fromLTWH(20, 20, 10, 10),
      ];

      expect(quadtree.insertAll(items), isTrue);
      expect(
        deepListEquality(
          quadtree.getAllItems(),
          quadtree.decoratedQuadtree.getAllItems(),
        ),
        isTrue,
      );
      expect(deepListEquality(quadtree.getAllItems(), items), isTrue);
      expect(
        deepListEquality(
          quadtree.cachedItems,
          items,
        ),
        isTrue,
      );
    });

    test('remove removes item correctly', () {
      final item = Rect.fromLTWH(10, 10, 10, 10);
      expect(quadtree.insert(item), isTrue);
      quadtree.remove(item);

      expect(
        deepListEquality(
          quadtree.getAllItems(),
          quadtree.decoratedQuadtree.getAllItems(),
        ),
        isTrue,
      );
      expect(quadtree.getAllItems(), []);
      expect(
        deepListEquality(
          quadtree.cachedItems,
          [],
        ),
        isTrue,
      );
    });

    test('removeAll removes items correctly', () {
      final items = [
        Rect.fromLTWH(10, 10, 10, 10),
        Rect.fromLTWH(20, 20, 10, 10),
      ];
      expect(quadtree.insertAll(items), isTrue);
      quadtree.removeAll(items);

      expect(
        deepListEquality(
          quadtree.getAllItems(),
          quadtree.decoratedQuadtree.getAllItems(),
        ),
        isTrue,
      );
      expect(quadtree.getAllItems(), []);
      expect(
        deepListEquality(
          quadtree.cachedItems,
          [],
        ),
        isTrue,
      );
    });

    test('localizeRemove removes item correctly', () {
      final item = Rect.fromLTWH(10, 10, 10, 10);
      expect(quadtree.insert(item), isTrue);
      quadtree.localizedRemove(item);

      expect(
        deepListEquality(
          quadtree.getAllItems(),
          quadtree.decoratedQuadtree.getAllItems(),
        ),
        isTrue,
      );
      expect(quadtree.getAllItems(), []);
      expect(
        deepListEquality(
          quadtree.cachedItems,
          [],
        ),
        isTrue,
      );
    });

    test('localizeRemoveAll removes items correctly', () {
      final items = [
        Rect.fromLTWH(10, 10, 10, 10),
        Rect.fromLTWH(20, 20, 10, 10),
      ];
      expect(quadtree.insertAll(items), isTrue);
      quadtree.localizedRemoveAll(items);

      expect(
        deepListEquality(
          quadtree.getAllItems(),
          quadtree.decoratedQuadtree.getAllItems(),
        ),
        isTrue,
      );
      expect(quadtree.getAllItems(), []);
      expect(
        deepListEquality(
          quadtree.cachedItems,
          [],
        ),
        isTrue,
      );
    });

    test("retrieve returns all items in node when passing quadtree's quadrant",
        () {
      final rects = [
        Rect.fromLTWH(10, 10, 10, 10),
        Rect.fromLTWH(20, 20, 10, 10),
        Rect.fromLTWH(30, 30, 10, 10),
      ];
      expect(quadtree.insertAll(rects), isTrue);
      final items = quadtree.retrieve(quadrant);
      expect(deepListEquality(items, rects), isTrue);
    });

    test('retrieve returns all items that overlaps with given quadrant', () {
      for (int i = 0; i < 10; i++) {
        quadtree.insert(Rect.fromLTWH(i * 10.0, i * 10.0, 9.9, 9.9));
      }

      final otherRect = Rect.fromLTWH(40, 40, 20, 20);

      final items = quadtree.retrieve(otherRect);

      expect(
        deepListEquality(items, [
          Rect.fromLTWH(40, 40, 9.9, 9.9),
          Rect.fromLTWH(50, 50, 9.9, 9.9),
          Rect.fromLTWH(60, 60, 9.9, 9.9),
        ]),
        isTrue,
      );
    });

    test(
        'retrieve returns 0 elements when the given quadrant does not collide'
        "with quadtrees's quadrant", () {
      for (int i = 0; i < 9; i++) {
        quadtree.insert(Rect.fromLTWH(i * 10.0, i * 10.0, 10, 10));
      }

      final otherRect = Rect.fromLTWH(200, 200, 20, 20);
      expect(quadtree.quadrant.looseOverlaps(otherRect), isFalse);

      final items = quadtree.retrieve(otherRect);
      expect(items.length, 0);
    });

    test(
        'getAllQuadrants returns all quadrants when includeNonLeafNodes is '
        'true', () {
      final quadrants = quadtree.getAllQuadrants();
      expect(quadrants.length, 1);
      expect(quadrants[0], quadtree.quadrant);

      // Insert items to create subnodes
      expect(quadtree.insert(nwRect), isTrue);
      expect(quadtree.insert(seseRect), isTrue);
      expect(quadtree.insert(senwRect), isTrue);

      final allQuadrants = quadtree.getAllQuadrants();
      expect(
        deepListEquality(allQuadrants, [
          // Original quadrant
          quadrant,
          // Subnodes 1st level
          Rect.fromLTWH(0, 0, 50, 50),
          Rect.fromLTWH(50, 0, 50, 50),
          Rect.fromLTWH(0, 50, 50, 50),
          Rect.fromLTWH(50, 50, 50, 50),
          // Subnodes 2nd level
          Rect.fromLTWH(50, 50, 25, 25),
          Rect.fromLTWH(75, 50, 25, 25),
          Rect.fromLTWH(50, 75, 25, 25),
          Rect.fromLTWH(75, 75, 25, 25),
        ]),
        isTrue,
      );
    });

    test(
        'getAllQuadrants returns only leaf quadrands when includeNonLeafNodes'
        'is false', () {
      final quadrants = quadtree.getAllQuadrants(includeNonLeafNodes: false);
      expect(quadrants.length, 1);
      expect(quadrants[0], quadtree.quadrant);

      // Insert items to create subnodes
      expect(quadtree.insert(nwRect), isTrue);
      expect(quadtree.insert(seseRect), isTrue);
      expect(quadtree.insert(senwRect), isTrue);

      final nonLeadRects = quadtree.getAllQuadrants(includeNonLeafNodes: false);
      expect(
        deepListEquality(nonLeadRects, [
          // Original quadrant
          // "quadrant" Not included
          // Subnodes 1st level
          Rect.fromLTWH(0, 0, 50, 50),
          Rect.fromLTWH(50, 0, 50, 50),
          Rect.fromLTWH(0, 50, 50, 50),
          // "Rect.fromLTWH(50, 50, 50, 50)" Not included
          // Subnodes 2nd level
          Rect.fromLTWH(50, 50, 25, 25),
          Rect.fromLTWH(75, 50, 25, 25),
          Rect.fromLTWH(50, 75, 25, 25),
          Rect.fromLTWH(75, 75, 25, 25),
        ]),
        isTrue,
      );
    });

    test('getAllItems returns all items in node and subnodes', () {
      final List<Rect> rects = [];
      for (int i = 0; i < 10; i++) {
        for (int j = 0; j < 10; j++) {
          rects.add(
            Rect.fromLTWH(
              i * 10.0 + j * 1,
              i * 10.0 + j * 1,
              1,
              1,
            ),
          );
        }
      }

      expect(quadtree.insertAll(rects), isTrue);

      final allItems = quadtree.getAllItems();
      expect(
        deepListEquality(
          allItems,
          quadtree.decoratedQuadtree.getAllItems(),
        ),
        isTrue,
      );
      expect(
        deepListEquality(allItems, rects),
        isTrue,
      );
      expect(
        deepListEquality(
          quadtree.cachedItems,
          rects,
        ),
        isTrue,
      );
    });

    test(
        'getAllItems returns all items plus duplicates in node and subnodes'
        ' when removeDuplicates is false', () {
      final List<Rect> rects = [];
      for (int i = 0; i < 10; i++) {
        for (int j = 0; j < 10; j++) {
          rects.add(
            Rect.fromLTWH(
              i * 10.0 + j * 1,
              i * 10.0 + j * 1,
              1,
              1,
            ),
          );
        }
      }

      expect(quadtree.insertAll(rects), isTrue);

      final allItemsWithDuplicas = quadtree.getAllItems();
      expect(
        deepListEquality(
          allItemsWithDuplicas,
          quadtree.decoratedQuadtree.getAllItems(),
        ),
        isTrue,
      );
      expect(
        deepListEquality(
          quadtree.cachedItems,
          rects,
        ),
        isTrue,
      );
      expect(allItemsWithDuplicas.length >= rects.length, isTrue);

      for (final item in allItemsWithDuplicas) {
        expect(rects.contains(item), isTrue);
      }
    });

    test('clear removes all items', () {
      final items = [
        Rect.fromLTWH(10, 10, 10, 10),
        Rect.fromLTWH(20, 20, 10, 10),
      ];
      expect(quadtree.insertAll(items), isTrue);
      quadtree.clear();

      expect(
        deepListEquality(
          quadtree.getAllItems(),
          quadtree.decoratedQuadtree.getAllItems(),
        ),
        isTrue,
      );
      expect(quadtree.getAllItems().isEmpty, isTrue);
      expect(
        deepListEquality(
          quadtree.cachedItems,
          [],
        ),
        isTrue,
      );
    });

    test('toMap returns correct map representation', () {
      final item = Rect.fromLTWH(10, 10, 10, 10);
      expect(quadtree.insert(item), isTrue);

      final map = quadtree.toMap((item) => item.toMap());
      expect(map['_type'], 'CachedQuadtree');

      final decoratedQuadtreeMap = map['decoratedQuadtree'];
      expect(decoratedQuadtreeMap['_type'], 'SingleRootQuadtree');
      expect(decoratedQuadtreeMap['quadrant'], quadrant.toMap());
      expect(decoratedQuadtreeMap['maxItems'], 1);
      expect(decoratedQuadtreeMap['maxDepth'], 5);
      expect(
        deepListEquality(decoratedQuadtreeMap['items'], [item.toMap()]),
        isTrue,
      );
    });
  });
}
