import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:fast_quadtree/src/extensions/loose_overlaps_on_rect.dart';
import 'package:fast_quadtree/src/extensions/to_map_on_rect.dart';
import 'package:fast_quadtree/src/helpers/rect_mapper.dart';
import 'package:test/test.dart';
import 'package:fast_quadtree/fast_quadtree.dart';

void main() {
  group('QuadtreeNode', () {
    final deepListEquality = const DeepCollectionEquality.unordered().equals;

    final quadrant = Rect.fromLTWH(0, 0, 100, 100);
    late Quadtree<Rect> tree;
    late QuadtreeNode<Rect> node;
    // NW subnode
    final nwRect = Rect.fromLTWH(10, 10, 1, 1);
    // SE -> SE subnode
    final seseRect = Rect.fromLTWH(90, 90, 1, 1);
    // SE -> NW subnode
    final senwRect = Rect.fromLTWH(60, 60, 1, 1);

    // Expected map representation of the quadtree node when all the above
    // rectangles are inserted
    final quadtreeNodeMap = {
      'quadrant': {
        'left': 0.0,
        'top': 0.0,
        'right': 100.0,
        'bottom': 100.0,
      },
      'depth': 0,
      'negativeDepth': 0,
      'items': [],
      'nodes': {
        'ne': {
          'quadrant': {
            'left': 50.0,
            'top': 0.0,
            'right': 100.0,
            'bottom': 50.0,
          },
          'depth': 1,
          'negativeDepth': 0,
          'items': [],
          'nodes': {},
        },
        'nw': {
          'quadrant': {
            'left': 0.0,
            'top': 0.0,
            'right': 50.0,
            'bottom': 50.0,
          },
          'depth': 1,
          'negativeDepth': 0,
          'items': [
            {
              'left': 10.0,
              'top': 10.0,
              'right': 11.0,
              'bottom': 11.0,
            },
          ],
          'nodes': {},
        },
        'se': {
          'quadrant': {
            'left': 50.0,
            'top': 50.0,
            'right': 100.0,
            'bottom': 100.0,
          },
          'depth': 1,
          'negativeDepth': 0,
          'items': [],
          'nodes': {
            'ne': {
              'quadrant': {
                'left': 75.0,
                'top': 50.0,
                'right': 100.0,
                'bottom': 75.0,
              },
              'depth': 2,
              'negativeDepth': 0,
              'items': [],
              'nodes': {},
            },
            'nw': {
              'quadrant': {
                'left': 50.0,
                'top': 50.0,
                'right': 75.0,
                'bottom': 75.0,
              },
              'depth': 2,
              'negativeDepth': 0,
              'items': [
                {
                  'left': 60.0,
                  'top': 60.0,
                  'right': 61.0,
                  'bottom': 61.0,
                },
              ],
              'nodes': {},
            },
            'se': {
              'quadrant': {
                'left': 75.0,
                'top': 75.0,
                'right': 100.0,
                'bottom': 100.0,
              },
              'depth': 2,
              'negativeDepth': 0,
              'items': [
                {
                  'left': 90.0,
                  'top': 90.0,
                  'right': 91.0,
                  'bottom': 91.0,
                },
              ],
              'nodes': {},
            },
            'sw': {
              'quadrant': {
                'left': 50.0,
                'top': 75.0,
                'right': 75.0,
                'bottom': 100.0,
              },
              'depth': 2,
              'negativeDepth': 0,
              'items': [],
              'nodes': {},
            },
          },
        },
        'sw': {
          'quadrant': {
            'left': 0.0,
            'top': 50.0,
            'right': 50.0,
            'bottom': 100.0,
          },
          'depth': 1,
          'negativeDepth': 0,
          'items': [],
          'nodes': {},
        },
      },
    };

    setUp(() {
      tree = Quadtree<Rect>(
        quadrant,
        maxItems: 1,
        maxDepth: 5,
        getBounds: (item) => item,
      );
      node = QuadtreeNode<Rect>(quadrant, tree: tree);
    });

    test('initializes correctly', () {
      expect(node.items, isEmpty);
      expect(node.nodes, isEmpty);
      expect(node.depth, 0);
      expect(node.isLeaf, isTrue);
    });

    test('fromMap initializes correctly', () {
      final node = QuadtreeNode<Rect>.fromMap(
        quadtreeNodeMap,
        tree,
        RectMapper.fromMap,
      );
      expect(node.nodes.keys, containsAll(QuadrantLocation.values));
      final seNode = node.nodes[QuadrantLocation.se]!;
      expect(seNode.isLeaf, isFalse);
      expect(seNode.items, isEmpty);
      expect(seNode.nodes.keys, containsAll(QuadrantLocation.values));
      final swnwNode = seNode.nodes[QuadrantLocation.nw]!;
      expect(swnwNode.isLeaf, isTrue);
      expect(swnwNode.items, contains(senwRect));
      final seseNode = seNode.nodes[QuadrantLocation.se]!;
      expect(seseNode.isLeaf, isTrue);
      expect(seseNode.items, contains(seseRect));
    });

    test('depth', () {
      // TODO: This is not testing negativeDepth
      expect(node.depth, 0);
    });

    test('isLeaf', () {
      expect(node.isLeaf, isTrue);

      node.insert(nwRect);
      node.insert(seseRect);
      expect(node.isLeaf, isFalse);
    });

    test('isNotLeaf', () {
      expect(node.isNotLeaf, isFalse);

      node.insert(nwRect);
      node.insert(seseRect);
      expect(node.isNotLeaf, isTrue);
    });

    test('isFull', () {
      // Initial node is not full
      expect(node.isFull, isFalse);

      // Node is full after inserting 1 item
      node.insert(nwRect);
      expect(node.isFull, isTrue);

      // Node is not full after inserting 2nd item because it splits
      // into subnodes
      node.insert(seseRect);
      expect(node.isFull, isFalse);
    });

    test('canSplit', () {
      final tree2 = Quadtree<Rect>(
        quadrant,
        maxItems: 1,
        maxDepth: 1,
        getBounds: (item) => item,
      );
      final node2 = QuadtreeNode<Rect>(quadrant, tree: tree2);

      // Initial node can split
      expect(node2.canSplit, isTrue);

      // Node can split after inserting 1 item
      node2.insert(nwRect);
      expect(node2.canSplit, isTrue);

      // Subnode can't split after inserting 1 item
      node2.insert(seseRect);
      final nwNode = node2.nodes[QuadrantLocation.nw]!;
      expect(nwNode.canSplit, isFalse);
    });

    test('insert adds item to node', () {
      final rect = Rect.fromLTWH(10, 10, 10, 10);
      node.insert(rect);
      expect(node.items, contains(rect));
    });

    test('insert splits node when full and adds items to subnodes', () {
      node.insert(nwRect);
      expect(node.isLeaf, isTrue);
      expect(node.items, contains(nwRect));
      expect(node.nodes, isEmpty);

      node.insert(seseRect);
      expect(node.isLeaf, isFalse);
      expect(node.items, isEmpty);
      expect(node.nodes.keys, containsAll(QuadrantLocation.values));
      final nwNode = node.nodes[QuadrantLocation.nw]!;
      expect(nwNode.isLeaf, isTrue);
      expect(nwNode.items, contains(nwRect));
      final seNode = node.nodes[QuadrantLocation.se]!;
      expect(seNode.isLeaf, isTrue);
      expect(seNode.items, contains(seseRect));

      node.insert(senwRect);
      expect(seNode.isLeaf, isFalse);
      expect(seNode.items, isEmpty);
      expect(seNode.nodes.keys, containsAll(QuadrantLocation.values));
      final swnwNode = seNode.nodes[QuadrantLocation.nw]!;
      expect(swnwNode.isLeaf, isTrue);
      expect(swnwNode.items, contains(senwRect));
      final seseNode = seNode.nodes[QuadrantLocation.se]!;
      expect(seseNode.isLeaf, isTrue);
      expect(seseNode.items, contains(seseRect));
    });

    test('insertAll adds all items to node', () {
      final rects = [
        Rect.fromLTWH(10, 10, 10, 10),
        Rect.fromLTWH(20, 20, 10, 10),
        Rect.fromLTWH(30, 30, 10, 10),
      ];
      node.insertAll(rects);
      expect(deepListEquality(node.getAllItems(), rects), isTrue);
    });

    test('remove removes item from node', () {
      final rect = Rect.fromLTWH(10, 10, 10, 10);
      node.insert(rect);
      node.remove(rect);
      expect(node.items, isEmpty);
    });

    test('removeAll removes all items from node', () {
      final rects = [
        Rect.fromLTWH(10, 10, 10, 10),
        Rect.fromLTWH(20, 20, 10, 10),
        Rect.fromLTWH(30, 30, 10, 10),
      ];
      node.insertAll(rects);
      node.removeAll(rects);
      expect(node.getAllItems(), []);
    });

    test('localizedRemove removes item from correct subnode', () {
      final rect = Rect.fromLTWH(10, 10, 10, 10);
      node.insert(rect);
      node.localizedRemove(rect);
      expect(node.items, isEmpty);
    });

    test('localizedRemoveAll removes items from correct subnode', () {
      final rects = [
        Rect.fromLTWH(10, 10, 10, 10),
        Rect.fromLTWH(20, 20, 10, 10),
        Rect.fromLTWH(30, 30, 10, 10),
      ];
      node.insertAll(rects);
      node.localizedRemoveAll(rects);
      expect(node.getAllItems(), []);
    });

    test("retrieve returns all items in node when passing quadtree's quadrant",
        () {
      final rects = [
        Rect.fromLTWH(10, 10, 10, 10),
        Rect.fromLTWH(20, 20, 10, 10),
        Rect.fromLTWH(30, 30, 10, 10),
      ];
      node.insertAll(rects);
      final items = node.retrieve(quadrant);
      expect(deepListEquality(items, rects), isTrue);
    });

    test('retrieve returns all items that overlaps with given quadrant', () {
      for (int i = 0; i < 10; i++) {
        node.insert(Rect.fromLTWH(i * 10.0, i * 10.0, 9.9, 9.9));
      }

      final otherRect = Rect.fromLTWH(40, 40, 20, 20);

      final items = node.retrieve(otherRect);

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
        node.insert(Rect.fromLTWH(i * 10.0, i * 10.0, 10, 10));
      }

      final otherRect = Rect.fromLTWH(200, 200, 20, 20);
      expect(node.quadrant.looseOverlaps(otherRect), isFalse);

      final items = node.retrieve(otherRect);
      expect(items.length, 0);
    });

    test(
        'getAllQuadrants returns all quadrants when includeNonLeafNodes is '
        'true', () {
      final quadrants = node.getAllQuadrants();
      expect(quadrants.length, 1);
      expect(quadrants[0], node.quadrant);

      // Insert items to create subnodes
      node.insert(nwRect);
      node.insert(seseRect);
      node.insert(senwRect);

      final allQuadrants = node.getAllQuadrants();
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
      final quadrants = node.getAllQuadrants(includeNonLeafNodes: false);
      expect(quadrants.length, 1);
      expect(quadrants[0], node.quadrant);

      // Insert items to create subnodes
      node.insert(nwRect);
      node.insert(seseRect);
      node.insert(senwRect);

      final nonLeadRects = node.getAllQuadrants(includeNonLeafNodes: false);
      expect(
        deepListEquality(nonLeadRects, [
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

      node.insertAll(rects);

      final allItems = node.getAllItems();
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

      node.insertAll(rects);

      final allItemsWithDuplicas = node.getAllItems();
      expect(allItemsWithDuplicas.length >= rects.length, isTrue);

      for (final item in allItemsWithDuplicas) {
        expect(rects.contains(item), isTrue);
      }
    });

    test('clear removes all items and subnodes', () {
      for (int i = 0; i < 5; i++) {
        node.insert(Rect.fromLTWH(i * 10.0, i * 10.0, 10, 10));
      }
      node.clear();
      expect(node.items, isEmpty);
      expect(node.nodes, isEmpty);
    });

    test('toMap returns correct map', () {
      node.insert(nwRect);
      node.insert(seseRect);
      node.insert(senwRect);

      final map = node.toMap((item) => item.toMap());
      expect(map, quadtreeNodeMap);
    });
  });
}
