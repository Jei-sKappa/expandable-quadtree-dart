import 'package:collection/collection.dart';
import 'package:fast_quadtree/src/extensions/loose_overlaps_on_rect.dart';
import 'package:test/test.dart';
import 'package:fast_quadtree/src/single_root_quadtree.dart';
import 'package:fast_quadtree/src/quadrant.dart';
import 'dart:ui';

void main() {
  group('SingleRootQuadtree', () {
    final deepListEquality = const DeepCollectionEquality.unordered().equals;

    final quadrant = Quadrant(x: 0, y: 0, width: 100, height: 100);

    // NW subnode
    final nwRect = Rect.fromLTWH(10, 10, 1, 1);
    // SE -> SE subnode
    final seseRect = Rect.fromLTWH(90, 90, 1, 1);
    // SE -> NW subnode
    final senwRect = Rect.fromLTWH(60, 60, 1, 1);

    Rect getBounds(Rect rect) => rect;
    Rect fromMapT(Map<String, dynamic> map) => Rect.fromLTWH(
          map['left'] as double,
          map['top'] as double,
          map['width'] as double,
          map['height'] as double,
        );
    Map<String, dynamic> toMapT(Rect rect) => {
          'left': rect.left,
          'top': rect.top,
          'width': rect.width,
          'height': rect.height,
        };

    late SingleRootQuadtree<Rect> quadtree;

    setUp(() {
      quadtree = SingleRootQuadtree<Rect>(
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
      expect(quadtree.root.quadrant, quadrant);
    });

    test('fromMap initializes correctly', () {
      final map = {
        '_type': 'SingleRootQuadtree',
        'quadrant': quadrant.toMap(),
        'maxItems': 1,
        'maxDepth': 5,
        'items': [
          toMapT(nwRect),
          toMapT(seseRect),
          toMapT(senwRect),
        ]
      };

      final quadtree =
          SingleRootQuadtree<Rect>.fromMap(map, getBounds, fromMapT);

      expect(quadtree.maxItems, 1);
      expect(quadtree.maxDepth, 5);
      expect(quadtree.getBounds, getBounds);
      expect(quadtree.root.quadrant.left, 0.0);
      expect(quadtree.root.quadrant.top, 0.0);
      expect(quadtree.root.quadrant.width, 100.0);
      expect(quadtree.root.quadrant.height, 100.0);
      expect(
        deepListEquality(quadtree.getAllItems(), [nwRect, seseRect, senwRect]),
        isTrue,
      );
    });

    test('insert adds item correctly', () {
      final item = Rect.fromLTWH(10, 10, 10, 10);
      expect(quadtree.insert(item), isTrue);
      expect(quadtree.getAllItems(), [item]);
    });

    test('insert fails when item is outside of the quadrant', () {
      final item = Rect.fromLTWH(110, 110, 10, 10);
      expect(quadtree.insert(item), isFalse);
      expect(quadtree.getAllItems(), []);
    });

    test('insertAll adds items correctly', () {
      final items = [
        Rect.fromLTWH(10, 10, 10, 10),
        Rect.fromLTWH(20, 20, 10, 10),
      ];

      expect(quadtree.insertAll(items), isTrue);
      expect(deepListEquality(quadtree.getAllItems(), items), isTrue);
    });

    test('remove removes item correctly', () {
      final item = Rect.fromLTWH(10, 10, 10, 10);
      expect(quadtree.insert(item), isTrue);
      quadtree.remove(item);

      expect(quadtree.getAllItems(), []);
    });

    test('removeAll removes items correctly', () {
      final items = [
        Rect.fromLTWH(10, 10, 10, 10),
        Rect.fromLTWH(20, 20, 10, 10),
      ];
      expect(quadtree.insertAll(items), isTrue);
      quadtree.removeAll(items);

      expect(quadtree.getAllItems(), []);
    });

    test('localizeRemove removes item correctly', () {
      final item = Rect.fromLTWH(10, 10, 10, 10);
      expect(quadtree.insert(item), isTrue);
      quadtree.localizedRemove(item);

      expect(quadtree.getAllItems(), []);
    });

    test('localizeRemoveAll removes items correctly', () {
      final items = [
        Rect.fromLTWH(10, 10, 10, 10),
        Rect.fromLTWH(20, 20, 10, 10),
      ];
      expect(quadtree.insertAll(items), isTrue);
      quadtree.localizedRemoveAll(items);

      expect(quadtree.getAllItems(), []);
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

      final otherQuadrant = Quadrant(x: 40, y: 40, width: 20, height: 20);

      final items = quadtree.retrieve(otherQuadrant);

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

      final otherQuadrant = Quadrant(x: 200, y: 200, width: 20, height: 20);
      expect(quadtree.root.quadrant.bounds.looseOverlaps(otherQuadrant.bounds),
          isFalse);

      final items = quadtree.retrieve(otherQuadrant);
      expect(items.length, 0);
    });

    test(
        'getAllQuadrants returns all quadrants when includeNonLeafNodes is '
        'true', () {
      final quadrants = quadtree.getAllQuadrants();
      expect(quadrants.length, 1);
      expect(quadrants[0], quadtree.root.quadrant);

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
          Quadrant(x: 0, y: 0, width: 50, height: 50),
          Quadrant(x: 50, y: 0, width: 50, height: 50),
          Quadrant(x: 0, y: 50, width: 50, height: 50),
          Quadrant(x: 50, y: 50, width: 50, height: 50),
          // Subnodes 2nd level
          Quadrant(x: 50, y: 50, width: 25, height: 25),
          Quadrant(x: 75, y: 50, width: 25, height: 25),
          Quadrant(x: 50, y: 75, width: 25, height: 25),
          Quadrant(x: 75, y: 75, width: 25, height: 25),
        ]),
        isTrue,
      );
    });

    test(
        'getAllQuadrants returns only leaf quadrands when includeNonLeafNodes'
        'is false', () {
      final quadrants = quadtree.getAllQuadrants(includeNonLeafNodes: false);
      expect(quadrants.length, 1);
      expect(quadrants[0], quadtree.root.quadrant);

      // Insert items to create subnodes
      expect(quadtree.insert(nwRect), isTrue);
      expect(quadtree.insert(seseRect), isTrue);
      expect(quadtree.insert(senwRect), isTrue);

      final nonLeadQuadrants =
          quadtree.getAllQuadrants(includeNonLeafNodes: false);
      expect(
        deepListEquality(nonLeadQuadrants, [
          // Original quadrant
          // "quadrant" Not included
          // Subnodes 1st level
          Quadrant(x: 0, y: 0, width: 50, height: 50),
          Quadrant(x: 50, y: 0, width: 50, height: 50),
          Quadrant(x: 0, y: 50, width: 50, height: 50),
          // "Quadrant(x: 50, y: 50, width: 50, height: 50)" Not included
          // Subnodes 2nd level
          Quadrant(x: 50, y: 50, width: 25, height: 25),
          Quadrant(x: 75, y: 50, width: 25, height: 25),
          Quadrant(x: 50, y: 75, width: 25, height: 25),
          Quadrant(x: 75, y: 75, width: 25, height: 25),
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
        deepListEquality(allItems, rects),
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

      expect(quadtree.getAllItems().isEmpty, isTrue);
    });

    test('toMap returns correct map representation', () {
      final item = Rect.fromLTWH(10, 10, 10, 10);
      expect(quadtree.insert(item), isTrue);

      final map = quadtree.toMap((rect) => {
            'left': rect.left,
            'top': rect.top,
            'width': rect.width,
            'height': rect.height,
          });

      expect(map['_type'], 'SingleRootQuadtree');
      expect(map['quadrant'], quadrant.toMap());
      expect(map['maxItems'], 1);
      expect(map['maxDepth'], 5);
      expect(
        deepListEquality(
          map['items'],
          [
            {'left': 10.0, 'top': 10.0, 'width': 10.0, 'height': 10.0}
          ],
        ),
        isTrue,
      );
    });
  });
}
