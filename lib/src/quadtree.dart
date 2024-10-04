import 'dart:math';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:expandable_quadtree/src/cached_quadtree.dart';
import 'package:expandable_quadtree/src/expandable_quadtree.dart';
import 'package:expandable_quadtree/src/extensions/collapse_rect.dart';
import 'package:expandable_quadtree/src/extensions/is_inscribed_on_rect.dart';
import 'package:expandable_quadtree/src/extensions/loose_overlaps_on_rect.dart';
import 'package:expandable_quadtree/src/extensions/to_map_on_rect.dart';
import 'package:expandable_quadtree/src/helpers/calculate_quadrant_location_from_rect.dart';
import 'package:expandable_quadtree/src/extensions/remove_duplicates.dart';
import 'package:expandable_quadtree/src/helpers/rect_mapper.dart';
import 'package:expandable_quadtree/src/horizontally_expandable_quadtree.dart';
import 'package:expandable_quadtree/src/quadrant_location.dart';
import 'package:expandable_quadtree/src/single_root_quadtree.dart';
import 'package:expandable_quadtree/src/vertically_expandable_quadtree.dart';
import 'package:meta/meta.dart';

part 'quadtree_node.dart';
part 'quadtree_decorator.dart';

abstract class Quadtree<T> with EquatableMixin {
  factory Quadtree(
    Rect quadrant, {
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
      case 'CachedQuadtree':
        return CachedQuadtree.fromMap(map, getBounds, fromMapT);
      case 'SingleRootQuadtree':
        return SingleRootQuadtree.fromMap(map, getBounds, fromMapT);
      case 'ExpandableQuadtree':
        return ExpandableQuadtree.fromMap(map, getBounds, fromMapT);
      case 'VerticallyExpandableQuadtree':
        return VerticallyExpandableQuadtree.fromMap(map, getBounds, fromMapT);
      case 'HorizontallyExpandableQuadtree':
        return HorizontallyExpandableQuadtree.fromMap(map, getBounds, fromMapT);
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

  Rect get quadrant;

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
  /// If [item.getRectsLocations] is expensive, consider using [remove]
  void localizedRemove(T item);

  /// Remove all items from the [Quadtree] looping through **only** the
  /// nodes that intersect with the item.
  ///
  /// If [item.getRectsLocations] is expensive, consider using [removeAll]
  void localizedRemoveAll(List<T> items);

  /// Return all items that could collide with the given item, given
  /// quadrant.
  List<T> retrieve(Rect quadrant);

  /// Retrieves all quadrants from the quadtree.
  ///
  /// This method traverses the entire quadtree and collects all the quadrants
  /// into a list.
  ///
  /// Returns:
  ///   A list of [Rect] items representing all the quadrants in the quadtree.
  List<Rect> getAllQuadrants({bool includeNonLeafNodes});

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
