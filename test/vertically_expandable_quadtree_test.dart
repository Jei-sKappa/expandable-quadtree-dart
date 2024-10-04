import 'package:collection/collection.dart';
import 'package:expandable_quadtree/src/extensions/loose_overlaps_on_rect.dart';
import 'package:expandable_quadtree/src/extensions/to_map_on_rect.dart';
import 'package:expandable_quadtree/src/helpers/rect_mapper.dart';
import 'package:expandable_quadtree/src/vertically_expandable_quadtree.dart';
import 'package:test/test.dart';
import 'dart:ui';

void main() {
  group('VerticallyExpandableQuadtree', () {
    final deepListEquality = const DeepCollectionEquality.unordered().equals;

    final quadrant = Rect.fromLTWH(0, 0, 100, 100);

    // NW subnode
    final nwRect = Rect.fromLTWH(10, 10, 1, 1);
    // SE -> SE subnode
    final seseRect = Rect.fromLTWH(90, 90, 1, 1);
    // SE -> NW subnode
    final senwRect = Rect.fromLTWH(60, 60, 1, 1);

    // New Root Above first root
    final newRootAboveRect = Rect.fromLTWH(0, -50, 1, 1);

    Rect getBounds(Rect rect) => rect;

    late VerticallyExpandableQuadtree<Rect> quadtree;

    setUp(() {
      quadtree = VerticallyExpandableQuadtree<Rect>(
        quadrant,
        maxItems: 1,
        maxDepth: 5,
        getBounds: getBounds,
      );
    });

    test('constructor initializes correctly', () {
      expect(quadtree.maxItems, 1);
      expect(quadtree.maxDepth, 5);
      expect(quadtree.getBounds, getBounds);
      expect(quadtree.firstNode.quadrant, quadrant);
    });

    test('fromMap initializes correctly', () {
      final map = {
        '_type': 'VerticallyExpandableQuadtree',
        'quadrant': quadrant.toMap(),
        'maxItems': 1,
        'maxDepth': 5,
        'items': [
          nwRect.toMap(),
          newRootAboveRect.toMap(),
        ]
      };

      final quadtree = VerticallyExpandableQuadtree<Rect>.fromMap(
        map,
        getBounds,
        RectMapper.fromMap,
      );

      expect(quadtree.maxItems, 1);
      expect(quadtree.maxDepth, 5);
      expect(quadtree.getBounds, getBounds);
      // First Node
      expect(quadtree.firstNode.quadrant.left, 0.0);
      expect(quadtree.firstNode.quadrant.top, 0.0);
      expect(quadtree.firstNode.quadrant.width, 100.0);
      expect(quadtree.firstNode.quadrant.height, 100.0);
      // Second Node Above
      expect(quadtree.quadtreeNodes[-1], isNotNull);
      expect(quadtree.quadtreeNodes[-1]!.quadrant.left, 0);
      expect(quadtree.quadtreeNodes[-1]!.quadrant.top, -100);
      expect(quadtree.quadtreeNodes[-1]!.quadrant.width, 100);
      expect(quadtree.quadtreeNodes[-1]!.quadrant.height, 100);

      expect(
        deepListEquality(
          quadtree.getAllItems(),
          [nwRect, newRootAboveRect],
        ),
        isTrue,
      );
    });

    test('insert adds item correctly', () {
      expect(quadtree.insert(nwRect), isTrue);
      expect(quadtree.getAllItems(), [nwRect]);
    });

    test(
        'insert adds correctly when item is outside of the first quadrant but '
        'within the same horizontal bounds ', () {
      expect(quadtree.insert(newRootAboveRect), isTrue);
      expect(quadtree.getAllItems(), [newRootAboveRect]);
    });

    test(
        'insert fails when item is outside of the first quadrant but '
        'not within the same horizontal bounds ', () {
      final item = Rect.fromLTWH(-50, 0, 1, 1);
      expect(quadtree.insert(item), isFalse);
      expect(quadtree.getAllItems(), []);
    });

    test('insertAll adds items correctly', () {
      final items = [
        nwRect,
        seseRect,
        senwRect,
        newRootAboveRect,
      ];

      expect(quadtree.insertAll(items), isTrue);
      expect(deepListEquality(quadtree.getAllItems(), items), isTrue);
    });

    test('remove removes item correctly', () {
      expect(quadtree.insert(nwRect), isTrue);
      quadtree.remove(nwRect);

      expect(quadtree.getAllItems(), []);
    });

    test('remove removes item in a root different from the first one correctly',
        () {
      expect(quadtree.insert(newRootAboveRect), isTrue);
      quadtree.remove(newRootAboveRect);

      expect(quadtree.getAllItems(), []);
    });

    test('removeAll removes items correctly', () {
      final items = [
        nwRect,
        seseRect,
        senwRect,
        newRootAboveRect,
      ];
      expect(quadtree.insertAll(items), isTrue);
      quadtree.removeAll(items);

      expect(quadtree.getAllItems(), []);
    });

    test('localizeRemove removes item correctly', () {
      expect(quadtree.insert(nwRect), isTrue);
      quadtree.localizedRemove(nwRect);

      expect(quadtree.getAllItems(), []);
    });

    test('localizeRemove removes item in a root different from the first one',
        () {
      expect(quadtree.insert(newRootAboveRect), isTrue);
      quadtree.localizedRemove(newRootAboveRect);

      expect(quadtree.getAllItems(), []);
    });

    test('localizeRemoveAll removes items correctly', () {
      final items = [
        nwRect,
        seseRect,
        senwRect,
        newRootAboveRect,
      ];
      expect(quadtree.insertAll(items), isTrue);
      quadtree.localizedRemoveAll(items);

      expect(quadtree.getAllItems(), []);
    });

    test("retrieve returns all items in node when passing firstNode's quadrant",
        () {
      final rects = [
        nwRect,
        seseRect,
        senwRect,
      ];
      quadtree.insertAll(rects);
      final items = quadtree.retrieve(quadtree.firstNode.quadrant);
      expect(deepListEquality(items, rects), isTrue);
    });

    test("retrieve returns all items in node when passing quadtree's quadrant",
        () {
      final rects = [
        nwRect,
        seseRect,
        senwRect,
        newRootAboveRect,
      ];
      quadtree.insertAll(rects);
      final items = quadtree.retrieve(quadtree.quadrant);
      expect(deepListEquality(items, rects), isTrue);
    });

    test('retrieve returns all items that overlaps with given quadrant', () {
      for (int i = -10; i < 20; i++) {
        quadtree.insert(Rect.fromLTWH(50, i * 10.0, 9.9, 9.9));
      }

      final otherRect = Rect.fromLTWH(40, -20, 20, 20 + 100 + 20);

      final items = quadtree.retrieve(otherRect);

      expect(
        deepListEquality(items, [
          Rect.fromLTWH(50, -20, 9.9, 9.9),
          Rect.fromLTWH(50, -10, 9.9, 9.9),
          Rect.fromLTWH(50, 0, 9.9, 9.9),
          Rect.fromLTWH(50, 10, 9.9, 9.9),
          Rect.fromLTWH(50, 20, 9.9, 9.9),
          Rect.fromLTWH(50, 30, 9.9, 9.9),
          Rect.fromLTWH(50, 40, 9.9, 9.9),
          Rect.fromLTWH(50, 50, 9.9, 9.9),
          Rect.fromLTWH(50, 60, 9.9, 9.9),
          Rect.fromLTWH(50, 70, 9.9, 9.9),
          Rect.fromLTWH(50, 80, 9.9, 9.9),
          Rect.fromLTWH(50, 90, 9.9, 9.9),
          Rect.fromLTWH(50, 100, 9.9, 9.9),
          Rect.fromLTWH(50, 110, 9.9, 9.9),
          Rect.fromLTWH(50, 120, 9.9, 9.9),
        ]),
        isTrue,
      );
    });

    test(
        'retrieve returns 0 elements when the given quadrant does not collide'
        "with quadtrees's quadrant", () {
      for (int i = -10; i < 20; i++) {
        quadtree.insert(Rect.fromLTWH(50, i * 10.0, 9.9, 9.9));
      }

      final otherRect = Rect.fromLTWH(300, 300, 20, 20);
      expect(quadtree.quadrant.looseOverlaps(otherRect), isFalse);

      final items = quadtree.retrieve(otherRect);
      expect(items.length, 0);
    });

    test(
        'getAllQuadrants returns all quadrants when includeNonLeafNodes is '
        'true', () {
      final quadrants = quadtree.getAllQuadrants();
      expect(quadrants.length, 1);
      expect(quadrants[0], quadtree.firstNode.quadrant);

      // Insert items to create subnodes
      expect(quadtree.insert(nwRect), isTrue);
      expect(quadtree.insert(seseRect), isTrue);
      expect(quadtree.insert(senwRect), isTrue);
      expect(quadtree.insert(newRootAboveRect), isTrue);

      final allQuadrants = quadtree.getAllQuadrants();
      expect(
        deepListEquality(allQuadrants, [
          // New Root Above First' quadrant
          Rect.fromLTWH(0, -100, 100, 100),
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
      expect(quadrants[0], quadtree.firstNode.quadrant);

      // Insert items to create subnodes
      expect(quadtree.insert(nwRect), isTrue);
      expect(quadtree.insert(seseRect), isTrue);
      expect(quadtree.insert(senwRect), isTrue);
      expect(quadtree.insert(newRootAboveRect), isTrue);

      final nonLeadRects = quadtree.getAllQuadrants(includeNonLeafNodes: false);
      expect(
        deepListEquality(nonLeadRects, [
          // New Root Above First' quadrant
          Rect.fromLTWH(0, -100, 100, 100),
          // Original quadrant
          // "quadrant" Not included
          // Subnodes 1st level
          Rect.fromLTWH(0, 0, 50, 50),
          Rect.fromLTWH(50, 0, 50, 50),
          Rect.fromLTWH(0, 50, 50, 50),
          // "Rect.fromLTWH( 50,  50,  50,  50)" Not included
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
      for (int i = -10; i < 20; i++) {
        for (int j = 0; j < 10; j++) {
          rects.add(
            Rect.fromLTWH(
              50,
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
        deepListEquality(allItems, rects),
        isTrue,
      );
    });

    test(
        'getAllItems returns all items plus duplicates in node and subnodes'
        ' when removeDuplicates is false', () {
      final List<Rect> rects = [];
      for (int i = -10; i < 20; i++) {
        for (int j = 0; j < 10; j++) {
          rects.add(
            Rect.fromLTWH(
              50,
              i * 10.0 + j * 1,
              1,
              1,
            ),
          );
        }
      }

      expect(quadtree.insertAll(rects), isTrue);

      final allItemsWithDuplicas = quadtree.getAllItems();
      expect(allItemsWithDuplicas.length >= rects.length, isTrue);

      for (final item in allItemsWithDuplicas) {
        expect(rects.contains(item), isTrue);
      }
    });

    test('clear removes all items', () {
      final items = [
        nwRect,
        seseRect,
        senwRect,
        newRootAboveRect,
      ];
      quadtree.insertAll(items);
      quadtree.clear();

      expect(quadtree.getAllItems().isEmpty, isTrue);
    });

    test('toMap returns correct map representation', () {
      expect(quadtree.insert(nwRect), isTrue);
      expect(quadtree.insert(seseRect), isTrue);
      expect(quadtree.insert(senwRect), isTrue);
      expect(quadtree.insert(newRootAboveRect), isTrue);

      final map = quadtree.toMap((item) => item.toMap());

      expect(map['_type'], 'VerticallyExpandableQuadtree');
      expect(map['quadrant'], quadrant.toMap());
      expect(map['maxItems'], 1);
      expect(map['maxDepth'], 5);
      expect(
        deepListEquality(
          map['items'],
          [
            nwRect.toMap(),
            seseRect.toMap(),
            senwRect.toMap(),
            newRootAboveRect.toMap(),
          ],
        ),
        isTrue,
      );
    });
  });
}
