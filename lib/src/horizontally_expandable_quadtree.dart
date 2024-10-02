import 'dart:math';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:fast_quadtree/fast_quadtree.dart';
import 'package:fast_quadtree/src/extensions/position_details_on_quadtree.dart';

class HorizontallyExpandableQuadtree<T> extends MultipleRootsQuadtree<T>
    with EquatableMixin {
  HorizontallyExpandableQuadtree(
    super.quadrant, {
    required super.maxItems,
    required super.maxDepth,
    required super.getBounds,
  });

  factory HorizontallyExpandableQuadtree.fromMap(
    Map<String, dynamic> map,
    Rect Function(T) getBounds,
    T Function(Map<String, dynamic>) fromMapT,
  ) {
    final tree = HorizontallyExpandableQuadtree(
      Quadrant.fromMap(map['quadrant']),
      maxItems: map['maxItems'] as int,
      maxDepth: map['maxDepth'] as int,
      getBounds: getBounds,
    );
    final List<Map<String, dynamic>> items = map['items'];
    final List<T> itemsT = items.map(fromMapT).toList();
    tree.insertAll(itemsT);
    return tree;
  }

  late double currentLeft = firstNode.quadrant.left;

  @override
  double get left => currentLeft;

  double get singleNodeWidth => firstNode.quadrant.width;

  @override
  double get width =>
      ((maxHorizontalColumn - minHorizontalColumn) + 1) * singleNodeWidth;

  int minHorizontalColumn = 0;
  int maxHorizontalColumn = 0;

  @override
  List<Object?> get props => [
        maxItems,
        maxDepth,
        getBounds,
        quadtreeNodes,
        super.depth,
        super.negativeDepth,
        minHorizontalColumn,
        maxHorizontalColumn
      ];

  @override
  bool insert(T item) {
    final bounds = getBounds(item);

    // Check if the object is out of bounds vertically
    if (bounds.top < top || bounds.bottom > bottom) {
      return false;
    }

    // Determine the horizontal column (key) based on the object's x-coordinate.
    int horizontalColumn = _getHorizontalColumn(bounds);

    // If a quadtree for this column doesn't exist, create a new one.
    if (!quadtreeNodes.containsKey(horizontalColumn)) {
      _createNewQuadtreeNode(horizontalColumn);
    }

    // Insert the object into the appropriate quadtree node.
    quadtreeNodes[horizontalColumn]!.insert(item);

    return true;
  }

  @override
  void remove(T item) {
    final bounds = getBounds(item);

    // Determine the horizontal column (key) based on the object's x-coordinate.
    int horizontalColumn = _getHorizontalColumn(bounds);

    if (quadtreeNodes.containsKey(horizontalColumn)) {
      quadtreeNodes[horizontalColumn]!.remove(item);
    }
  }

  @override
  void localizedRemove(T item) {
    final bounds = getBounds(item);

    // Determine the horizontal column (key) based on the object's x-coordinate.
    int horizontalColumn = _getHorizontalColumn(bounds);

    if (quadtreeNodes.containsKey(horizontalColumn)) {
      quadtreeNodes[horizontalColumn]!.localizedRemove(item);
    }
  }

  @override
  List<T> retrieve(Quadrant quadrant) {
    List<T> results = [];

    final quadrantBounds = quadrant.bounds;

    // Check which quadtree nodes the search bounds overlap with
    final leftColumn = _getHorizontalColumn(quadrantBounds);
    final rightColumn =
        _getHorizontalColumn(quadrantBounds.translate(quadrantBounds.width, 0));

    for (int column = leftColumn; column <= rightColumn; column++) {
      if (quadtreeNodes.containsKey(column)) {
        results.addAll(quadtreeNodes[column]!.retrieve(quadrant));
      }
    }

    return results;
  }

  @override
  Map<String, dynamic> toMap(Map<String, dynamic> Function(T) toMapT) => {
        '_type': 'HorizontallyExpandableQuadtree',
        'quadrant': firstNode.quadrant.toMap(),
        'maxItems': maxItems,
        'maxDepth': maxDepth,
        'items': getAllItems(removeDuplicates: true).map(toMapT).toList(),
      };

  // Helper to determine which horizontal column the object belongs to
  int _getHorizontalColumn(Rect bounds) =>
      (bounds.left / singleNodeWidth).floor();

  void _createNewQuadtreeNode(int horizontalColumn) {
    final newLeft = horizontalColumn * singleNodeWidth;

    final newNode = QuadtreeNode<T>(
      firstNode.quadrant.copyWith(x: newLeft),
      tree: this,
    );
    quadtreeNodes[horizontalColumn] = newNode;

    currentLeft = min(currentLeft, newLeft);
    minHorizontalColumn = min(minHorizontalColumn, horizontalColumn);
    maxHorizontalColumn = max(maxHorizontalColumn, horizontalColumn);
  }
}