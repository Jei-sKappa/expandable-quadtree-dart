import 'package:expandable_quadtree/src/single_root_quadtree.dart';
import 'package:test/test.dart';
import 'package:expandable_quadtree/src/quadtree.dart';
import 'dart:ui';

class TestQuadtreeDecorator<T> extends QuadtreeDecorator<T> {
  TestQuadtreeDecorator(super.decoratedQuadtree);
}

void main() {
  group('QuadtreeDecorator', () {
    late Quadtree<Rect> quadtree;
    late TestQuadtreeDecorator<Rect> quadtreeDecorator;

    setUp(() {
      quadtree = SingleRootQuadtree<Rect>(Rect.fromLTWH(0, 0, 100, 100),
          maxItems: 10, maxDepth: 5, getBounds: (rect) => rect);
      quadtreeDecorator = TestQuadtreeDecorator<Rect>(quadtree);
    });

    test('should return correct left value', () {
      expect(quadtreeDecorator.left, 0);
    });

    test('should return correct top value', () {
      expect(quadtreeDecorator.top, 0);
    });

    test('should return correct width value', () {
      expect(quadtreeDecorator.width, 100);
    });

    test('should return correct height value', () {
      expect(quadtreeDecorator.height, 100);
    });

    test('should return correct quadrant', () {
      expect(quadtreeDecorator.quadrant, Rect.fromLTWH(0, 0, 100, 100));
    });

    test('should return correct depth', () {
      expect(quadtreeDecorator.depth, 0);
    });

    test('should set depth correctly', () {
      quadtreeDecorator.depth = 3;
      expect(quadtreeDecorator.depth, 3);
    });

    test('should return correct negativeDepth', () {
      expect(quadtreeDecorator.negativeDepth, 0);
    });

    test('should set negativeDepth correctly', () {
      quadtreeDecorator.negativeDepth = 2;
      expect(quadtreeDecorator.negativeDepth, 2);
    });

    test('should return correct maxDepth', () {
      expect(quadtreeDecorator.maxDepth, 5);
    });

    test('should return correct maxItems', () {
      expect(quadtreeDecorator.maxItems, 10);
    });

    test('should insert item correctly', () {
      final item = Rect.fromLTWH(10, 10, 10, 10);
      expect(quadtreeDecorator.insert(item), true);
    });

    test('should insert all items correctly', () {
      final items = [
        Rect.fromLTWH(10, 10, 10, 10),
        Rect.fromLTWH(20, 20, 10, 10)
      ];
      expect(quadtreeDecorator.insertAll(items), true);
    });

    test('should remove item correctly', () {
      final item = Rect.fromLTWH(10, 10, 10, 10);
      quadtreeDecorator.insert(item);
      quadtreeDecorator.remove(item);
      expect(quadtreeDecorator.retrieve(item).isEmpty, true);
    });

    test('should remove all items correctly', () {
      final items = [
        Rect.fromLTWH(10, 10, 10, 10),
        Rect.fromLTWH(20, 20, 10, 10)
      ];
      quadtreeDecorator.insertAll(items);
      quadtreeDecorator.removeAll(items);
      expect(quadtreeDecorator.getAllItems().isEmpty, true);
    });

    test('should retrieve items correctly', () {
      final item = Rect.fromLTWH(10, 10, 10, 10);
      quadtreeDecorator.insert(item);
      final retrievedItems =
          quadtreeDecorator.retrieve(Rect.fromLTWH(0, 0, 100, 100));
      expect(retrievedItems.contains(item), true);
    });

    test('should clear all items', () {
      final item = Rect.fromLTWH(10, 10, 10, 10);
      quadtreeDecorator.insert(item);
      quadtreeDecorator.clear();
      expect(quadtreeDecorator.getAllItems().isEmpty, true);
    });

    test('should return correct props', () {
      expect(quadtreeDecorator.props, [quadtree]);
    });

    test('should convert to map correctly', () {
      final item = Rect.fromLTWH(10, 10, 10, 10);
      quadtreeDecorator.insert(item);
      final map = quadtreeDecorator.toMap((rect) => {
            'left': rect.left,
            'top': rect.top,
            'width': rect.width,
            'height': rect.height,
          });
      expect(map['items'].length, 1);
    });
  });
}
