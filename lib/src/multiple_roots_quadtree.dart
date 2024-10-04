import 'dart:math';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:fast_quadtree/src/extensions/remove_duplicates.dart';
import 'package:fast_quadtree/src/quadrant.dart';
import 'package:fast_quadtree/src/quadtree.dart';

abstract class MultipleRootsQuadtree<T>
    with EquatableMixin
    implements Quadtree<T> {
  MultipleRootsQuadtree(
    Quadrant quadrant, {
    this.maxItems = 5,
    this.maxDepth = 4,
    required this.getBounds,
  }) {
    quadtreeNodes[0] = QuadtreeNode<T>(
      quadrant,
      tree: this,
    );
  }

  @override
  final int maxItems;

  @override
  final int maxDepth;

  @override
  double get left => firstNode.quadrant.left;

  @override
  double get top => firstNode.quadrant.top;

  @override
  double get width => firstNode.quadrant.width;

  @override
  double get height => firstNode.quadrant.height;

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

  @override
  bool insertAll(List<T> items) {
    bool valid = true;

    for (final item in items) {
      valid = insert(item);
    }

    return valid;
  }

  @override
  void removeAll(List<T> items) {
    for (final item in items) {
      remove(item);
    }
  }

  @override
  void localizedRemoveAll(List<T> items) {
    for (final item in items) {
      localizedRemove(item);
    }
  }

  @override
  List<Quadrant> getAllQuadrants({bool includeNonLeafNodes = true}) {
    List<Quadrant> results = [];

    for (final node in quadtreeNodes.values) {
      results.addAll(
        node.getAllQuadrants(includeNonLeafNodes: includeNonLeafNodes),
      );
    }

    return results;
  }

  @override
  List<T> getAllItems({bool removeDuplicates = true}) {
    final items = _getAllItems();

    if (removeDuplicates) return items.removeDuplicates();

    return items;
  }

  List<T> _getAllItems() {
    final items = <T>[];

    for (final node in quadtreeNodes.values) {
      items.addAll(node.getAllItems(removeDuplicates: false));
    }

    return items;
  }

  @override
  void clear() {
    for (final node in quadtreeNodes.values) {
      node.clear();
    }
  }
}
