import 'dart:math';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:fast_quadtree/src/expandable_quadtree.dart';
import 'package:fast_quadtree/src/extensions/collapse_quadrant.dart';
import 'package:fast_quadtree/src/extensions/is_rect_out_of_bounds_on_quadtree.dart';
import 'package:fast_quadtree/src/helpers/calculate_quadrant_location_from_rect.dart';
import 'package:fast_quadtree/src/extensions/remove_duplicates.dart';
import 'package:fast_quadtree/src/quadrant.dart';
import 'package:fast_quadtree/src/quadrant_location.dart';
import 'package:fast_quadtree/src/vertically_expandable_quadtree.dart';
import 'package:meta/meta.dart';

part 'quadtree_node.dart';
part 'quadtree_decorator.dart';

abstract class Quadtree<T> with EquatableMixin {
  factory Quadtree(
    Quadrant quadrant, {
    int maxItems,
    int maxDepth,
    required Rect Function(T) getBounds,
  }) = SingleRootQuadtree;

  factory Quadtree.fromMap(
    Map<String, dynamic> map,
    Rect Function(T) getBounds,
    T Function(Map<String, dynamic>) fromMapT,
  ) {
    final type = map['_type'] as String;
    switch (type) {
      case 'SingleRootQuadtree':
        return SingleRootQuadtree.fromMap(map, getBounds, fromMapT);
      case 'ExpandableQuadtree':
        return ExpandableQuadtree.fromMap(map, getBounds, fromMapT);
      case 'VerticallyExpandableQuadtree':
        return VerticallyExpandableQuadtree.fromMap(map, getBounds, fromMapT);
      default:
        throw ArgumentError('Invalid Quadtree type: $type');
    }
  }

  int get maxItems;

  int get maxDepth;

  double get left;

  double get top;

  double get width;

  double get height;

  Rect Function(T) get getBounds;

  /// The maximum depth reached in the quadtree.
  int get depth;

  @protected
  set depth(int newDepth);

  // TODO: Negative Depth should be a propery of ExpandableQuadtree
  @protected
  int get negativeDepth;

  @protected
  set negativeDepth(int newNegativeDepth);

  @protected
  void communicateNewNodeDepth(int newDepth) => depth = max(depth, newDepth);

  @override
  List<Object?> get props =>
      [maxItems, maxDepth, getBounds, depth, negativeDepth];

  @override
  bool? get stringify => true;

  /// Insert the item into the node. If the node exceeds the capacity,
  /// it will split and add all items to their corresponding subnodes.
  ///
  /// Takes quadrant to be inserted.
  bool insert(T item);

  /// Insert all items into the [Quadtree]
  bool insertAll(List<T> items);

  /// Remove the item from the [Quadtree] looping through **all** nodes.
  ///
  /// If the [Quadtree] is very deep, consider using [localizedRemove]
  void remove(T item);

  /// Remove all items from the [Quadtree] looping through **all** nodes.
  ///
  /// If the [Quadtree] is very deep, consider using [localizedRemoveAll]
  void removeAll(List<T> items);

  /// Remove the item from the [Quadtree] looping through **only** the
  /// nodes that intersect with the item.
  ///
  /// If [item.getQuadrantsLocations] is expensive, consider using [remove]
  void localizedRemove(T item);

  /// Remove all items from the [Quadtree] looping through **only** the
  /// nodes that intersect with the item.
  ///
  /// If [item.getQuadrantsLocations] is expensive, consider using [removeAll]
  void localizedRemoveAll(List<T> items);

  /// Return all items that could collide with the given item, given
  /// quadrant.
  List<T> retrieve(Quadrant quadrant);

  /// Retrieves all quadrants from the quadtree.
  ///
  /// This method traverses the entire quadtree and collects all the quadrants
  /// into a list.
  ///
  /// Returns:
  ///   A list of [Quadrant] items representing all the quadrants in the quadtree.
  List<Quadrant> getAllQuadrants();

  /// Retrieves all items stored in the quadtree.
  ///
  /// This method traverses the entire quadtree and collects all items
  /// contained within it.
  ///
  /// Returns a list of all items of type `T` stored in the quadtree.
  List<T> getAllItems({bool removeDuplicates = true});

  /// Clear the [Quadtree]
  void clear();

  Map<String, dynamic> toMap(Map<String, dynamic> Function(T) toMapT);
}

class SingleRootQuadtree<T> with EquatableMixin implements Quadtree<T> {
  SingleRootQuadtree(
    Quadrant quadrant, {
    this.maxItems = 5,
    this.maxDepth = 4,
    required this.getBounds,
  }) {
    root = QuadtreeNode<T>(
      quadrant,
      tree: this,
    );
  }

  factory SingleRootQuadtree.fromMap(
    Map<String, dynamic> map,
    Rect Function(T) getBounds,
    T Function(Map<String, dynamic>) fromMapT,
  ) {
    final tree = SingleRootQuadtree(
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
  double get left => root.quadrant.left;

  @override
  double get top => root.quadrant.top;

  @override
  double get width => root.quadrant.width;

  @override
  double get height => root.quadrant.height;

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
  void communicateNewNodeDepth(int newDepth) => _depth = max(_depth, newDepth);

  late QuadtreeNode<T> root;

  @override
  List<Object?> get props =>
      [maxItems, maxDepth, getBounds, root, _depth, _negativeDepth];

  @override
  bool? get stringify => true;

  @override
  bool insert(T item) {
    if (isRectOutOfBounds(getBounds(item))) return false;

    root.insert(item);

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
    root.remove(item);
  }

  @override
  void removeAll(List<T> items) {
    for (final item in items) {
      remove(item);
    }
  }

  @override
  void localizedRemove(T item) {
    root.localizedRemove(item);
  }

  @override
  void localizedRemoveAll(List<T> items) {
    for (final item in items) {
      localizedRemove(item);
    }
  }

  @override
  List<T> retrieve(Quadrant quadrant) {
    return root.retrieve(quadrant);
  }

  @override
  List<Quadrant> getAllQuadrants() => root.getAllQuadrants();

  @override
  List<T> getAllItems({bool removeDuplicates = true}) =>
      root.getAllItems(removeDuplicates: removeDuplicates);

  @override
  void clear() {
    root.clear();
  }

  @override
  Map<String, dynamic> toMap(Map<String, dynamic> Function(T) toMapT) => {
        '_type': 'SingleRootQuadtree',
        'quadrant': root.quadrant.toMap(),
        'maxItems': maxItems,
        'maxDepth': maxDepth,
        'items': getAllItems(removeDuplicates: true).map(toMapT).toList(),
      };
}
