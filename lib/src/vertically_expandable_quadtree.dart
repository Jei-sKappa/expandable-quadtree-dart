import 'dart:math';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:fast_quadtree/fast_quadtree.dart';
import 'package:fast_quadtree/src/extensions/position_details_on_quadtree.dart';

class VerticallyExpandableQuadtree<T> extends MultipleRootsQuadtree<T>
    with EquatableMixin {
  VerticallyExpandableQuadtree(
    super.quadrant, {
    required super.maxItems,
    required super.maxDepth,
    required super.getBounds,
  });

  factory VerticallyExpandableQuadtree.fromMap(
    Map<String, dynamic> map,
    Rect Function(T) getBounds,
    T Function(Map<String, dynamic>) fromMapT,
  ) {
    final tree = VerticallyExpandableQuadtree(
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

  late double currentTop = firstNode.quadrant.top;

  @override
  double get top => currentTop;

  double get singleNodeHeight => firstNode.quadrant.height;

  @override
  double get height =>
      ((maxVerticalRow - minVerticalRow) + 1) * singleNodeHeight;

  int minVerticalRow = 0;
  int maxVerticalRow = 0;

  @override
  List<Object?> get props => [
        maxItems,
        maxDepth,
        getBounds,
        quadtreeNodes,
        super.depth,
        super.negativeDepth,
        minVerticalRow,
        maxVerticalRow
      ];

  @override
  bool insert(T item) {
    final bounds = getBounds(item);

    // Check if the object is out of bounds horizontally
    if (bounds.left < left || bounds.right > right) {
      return false;
    }

    // Determine the vertical row (key) based on the object's y-coordinate.
    final (:topRow, :bottomRow) = _getVerticalRows(bounds);

    for (int row = topRow; row <= bottomRow; row++) {
      // If a quadtree for this row doesn't exist, create a new one.
      if (!quadtreeNodes.containsKey(row)) {
        _createNewQuadtreeNode(row);
      }

      // Insert the object into the appropriate quadtree node.
      quadtreeNodes[row]!.insert(item);
    }

    return true;
  }

  @override
  void remove(T item) {
    final bounds = getBounds(item);

    // Determine the vertical row (key) based on the object's y-coordinate.
    final (:topRow, :bottomRow) = _getVerticalRows(bounds);

    for (int row = topRow; row <= bottomRow; row++) {
      if (quadtreeNodes.containsKey(row)) {
        quadtreeNodes[row]!.remove(item);
      }
    }
  }

  @override
  void localizedRemove(T item) {
    final bounds = getBounds(item);

    // Determine the vertical row (key) based on the object's y-coordinate.
    final (:topRow, :bottomRow) = _getVerticalRows(bounds);

    for (int row = topRow; row <= bottomRow; row++) {
      if (quadtreeNodes.containsKey(row)) {
        quadtreeNodes[row]!.localizedRemove(item);
      }
    }
  }

  @override
  List<T> retrieve(Quadrant quadrant) {
    List<T> results = [];

    final quadrantBounds = quadrant.bounds;

    // Check which quadtree nodes the search bounds overlap with
    final (:topRow, :bottomRow) = _getVerticalRows(quadrantBounds);

    for (int row = topRow; row <= bottomRow; row++) {
      if (quadtreeNodes.containsKey(row)) {
        results.addAll(quadtreeNodes[row]!.retrieve(quadrant));
      }
    }

    return results;
  }

  @override
  Map<String, dynamic> toMap(Map<String, dynamic> Function(T) toMapT) => {
        '_type': 'VerticallyExpandableQuadtree',
        'quadrant': firstNode.quadrant.toMap(),
        'maxItems': maxItems,
        'maxDepth': maxDepth,
        'items': getAllItems(removeDuplicates: true).map(toMapT).toList(),
      };

  // Helper to determine which vertical row the object belongs to
  ({int topRow, int bottomRow}) _getVerticalRows(Rect bounds) => (
        topRow: (bounds.top / singleNodeHeight).floor(),
        bottomRow: (bounds.bottom / singleNodeHeight).floor()
      );

  void _createNewQuadtreeNode(int verticalRow) {
    final newTop = verticalRow * singleNodeHeight;

    final newNode = QuadtreeNode<T>(
      firstNode.quadrant.copyWith(y: newTop),
      tree: this,
    );
    quadtreeNodes[verticalRow] = newNode;

    currentTop = min(currentTop, newTop);
    minVerticalRow = min(minVerticalRow, verticalRow);
    maxVerticalRow = max(maxVerticalRow, verticalRow);
  }
}
