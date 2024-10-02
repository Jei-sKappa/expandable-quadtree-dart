import 'dart:math';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:fast_quadtree/fast_quadtree.dart';
import 'package:fast_quadtree/src/extensions/position_details_on_quadtree.dart';

class VerticallyExpandableQuadtree<T>
    with EquatableMixin
    implements Quadtree<T> {
  VerticallyExpandableQuadtree(
    Quadrant quadrant, {
    required this.maxItems,
    required this.maxDepth,
    required this.getBounds,
  }) {
    quadtreeNodes[0] = QuadtreeNode<T>(
      quadrant,
      tree: this,
    );
  }

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

  @override
  final int maxItems;

  @override
  final int maxDepth;

  @override
  double get left => firstNode.quadrant.left;

  late double currentTop = firstNode.quadrant.top;

  @override
  double get top => currentTop;

  @override
  double get width => firstNode.quadrant.width;

  double get singleNodeHeight => firstNode.quadrant.height;

  @override
  double get height =>
      ((maxVerticalRow - minVerticalRow) + 1) * singleNodeHeight;

  @override
  final Rect Function(T) getBounds;

  int _depth = 0;

  @override
  int get depth => _depth;

  @override
  set depth(int newDepth) => _depth = newDepth;

  int _negativeDepth = 0;

  @override
  int get negativeDepth => _negativeDepth;

  @override
  set negativeDepth(int newNegativeDepth) => _negativeDepth = newNegativeDepth;

  @override
  void communicateNewNodeDepth(int newDepth) => depth = max(depth, newDepth);

  final Map<int, QuadtreeNode<T>> quadtreeNodes = {};

  QuadtreeNode<T> get firstNode => quadtreeNodes[0]!;

  int minVerticalRow = 0;
  int maxVerticalRow = 0;

  @override
  List<Object?> get props => [
        maxItems,
        maxDepth,
        getBounds,
        quadtreeNodes,
        _depth,
        _negativeDepth,
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
    int verticalRow = _getVerticalRow(bounds);

    // If a quadtree for this row doesn't exist, create a new one.
    if (!quadtreeNodes.containsKey(verticalRow)) {
      _createNewQuadtreeNode(verticalRow);
    }

    // Insert the object into the appropriate quadtree node.
    quadtreeNodes[verticalRow]!.insert(item);

    return true;
  }

  @override
  bool insertAll(List<T> items) {
    bool valid = true;

    for (final item in items) {
      valid = insert(item);
    }

    return valid;
  }

  @override
  void remove(T item) {
    final bounds = getBounds(item);

    // Determine the vertical row (key) based on the object's y-coordinate.
    int verticalRow = _getVerticalRow(bounds);

    if (quadtreeNodes.containsKey(verticalRow)) {
      quadtreeNodes[verticalRow]!.remove(item);
    }
  }

  @override
  void removeAll(List<T> items) {
    for (final item in items) {
      remove(item);
    }
  }

  @override
  void localizedRemove(T item) {
    final bounds = getBounds(item);

    // Determine the vertical row (key) based on the object's y-coordinate.
    int verticalRow = _getVerticalRow(bounds);

    if (quadtreeNodes.containsKey(verticalRow)) {
      quadtreeNodes[verticalRow]!.localizedRemove(item);
    }
  }

  @override
  void localizedRemoveAll(List<T> items) {
    for (final item in items) {
      localizedRemove(item);
    }
  }

  @override
  List<T> retrieve(Quadrant quadrant) {
    List<T> results = [];

    final quadrantBounds = quadrant.bounds;

    // Check which quadtree nodes the search bounds overlap with
    final topRow = _getVerticalRow(quadrantBounds);
    final bottomRow =
        _getVerticalRow(quadrantBounds.translate(0, quadrantBounds.height));

    for (int row = topRow; row <= bottomRow; row++) {
      if (quadtreeNodes.containsKey(row)) {
        results.addAll(quadtreeNodes[row]!.retrieve(quadrant));
      }
    }

    return results;
  }

  @override
  List<Quadrant> getAllQuadrants() {
    List<Quadrant> results = [];

    for (final node in quadtreeNodes.values) {
      results.addAll(node.getAllQuadrants());
    }

    return results;
  }

  @override
  List<T> getAllItems({bool removeDuplicates = true}) {
    List<T> results = [];

    for (final node in quadtreeNodes.values) {
      results.addAll(node.getAllItems(removeDuplicates: removeDuplicates));
    }

    return results;
  }

  @override
  void clear() {
    for (final node in quadtreeNodes.values) {
      node.clear();
    }
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
  // TODO" It does not take into account the height of the object because it can also be placed in multiple rows.
  int _getVerticalRow(Rect bounds) => (bounds.top / singleNodeHeight).floor();

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
