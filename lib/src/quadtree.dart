import 'dart:math';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:fast_quadtree/src/extensions/collapse_quadrant.dart';
import 'package:fast_quadtree/src/helpers/calculate_quadrant_location_from_rect.dart';
import 'package:fast_quadtree/src/extensions/remove_duplicates.dart';
import 'package:fast_quadtree/src/quadrant.dart';
import 'package:fast_quadtree/src/quadrant_location.dart';
import 'package:meta/meta.dart';

part 'quadtree_node.dart';
part 'quadtree_decorator.dart';

class Quadtree<T> with EquatableMixin {
  Quadtree(
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

  Quadtree._({
    required Quadrant quadrant,
    required this.maxItems,
    required this.maxDepth,
    required this.getBounds,
  }) {
    root = QuadtreeNode<T>(
      quadrant,
      tree: this,
    );
  }

  factory Quadtree.fromMap(
    Map<String, dynamic> map,
    Rect Function(T) getBounds,
    T Function(Map<String, dynamic>) fromMapT,
  ) {
    final tree = Quadtree._(
      quadrant: Quadrant.fromMap(map['quadrant']),
      maxItems: map['maxItems'] as int,
      maxDepth: map['maxDepth'] as int,
      getBounds: getBounds,
    );
    final List<Map<String, dynamic>> items = map['items'];
    final List<T> itemsT = items.map(fromMapT).toList();
    tree.insertAll(itemsT);
    return tree;
  }

  final int maxItems;

  final int maxDepth;

  final Rect Function(T) getBounds;

  late QuadtreeNode<T> root;

  /// The maximum depth reached in the quadtree.
  int _depth = 0;

  int get depth => _depth;

  @protected
  set depth(int newDepth) => _depth = newDepth;

  // TODO: Negative Depth should be a propery of ExpandableQuadtree
  int _negativeDepth = 0;

  @protected
  int get negativeDepth => _negativeDepth;

  @protected
  set negativeDepth(int newNegativeDepth) => _negativeDepth = newNegativeDepth;

  int _lastUpdated = DateTime.now().millisecondsSinceEpoch;

  int get lastUpdated => _lastUpdated;

  void _updateLastUpdated() {
    _lastUpdated = DateTime.now().millisecondsSinceEpoch;
  }

  void _communicateNewNodeDepth(int newDepth) => _depth = max(_depth, newDepth);

  @override
  List<Object?> get props => [maxItems, maxDepth, getBounds, root, _depth];

  @override
  bool? get stringify => true;

  bool isRectOutOfOuterQuadrantBounds(Rect rect) =>
      rect.left < root.quadrant.left ||
      rect.right > root.quadrant.right ||
      rect.top < root.quadrant.top ||
      rect.bottom > root.quadrant.bottom;

  /// Insert the item into the node. If the node exceeds the capacity,
  /// it will split and add all items to their corresponding subnodes.
  ///
  /// Takes quadrant to be inserted.
  bool insert(T item) {
    if (isRectOutOfOuterQuadrantBounds(getBounds(item))) return false;

    root.insert(item);
    _updateLastUpdated();

    return true;
  }

  /// Insert all items into the [Quadtree]
  bool insertAll(List<T> items) {
    bool valid = true;

    for (final item in items) {
      valid = insert(item);
    }
    _updateLastUpdated();

    return valid;
  }

  /// Remove the item from the [Quadtree] looping through **all** nodes.
  ///
  /// If the [Quadtree] is very deep, consider using [localizedRemove]
  void remove(T item) {
    root.remove(item);
    _updateLastUpdated();
  }

  /// Remove all items from the [Quadtree] looping through **all** nodes.
  ///
  /// If the [Quadtree] is very deep, consider using [localizedRemoveAll]
  void removeAll(List<T> items) {
    for (final item in items) {
      remove(item);
    }
    _updateLastUpdated();
  }

  /// Remove the item from the [Quadtree] looping through **only** the
  /// nodes that intersect with the item.
  ///
  /// If [item.getQuadrantsLocations] is expensive, consider using [remove]
  void localizedRemove(T item) {
    root.localizedRemove(item);
    _updateLastUpdated();
  }

  /// Remove all items from the [Quadtree] looping through **only** the
  /// nodes that intersect with the item.
  ///
  /// If [item.getQuadrantsLocations] is expensive, consider using [removeAll]
  void localizedRemoveAll(List<T> items) {
    for (final item in items) {
      localizedRemove(item);
    }
    _updateLastUpdated();
  }

  /// Return all items that could collide with the given item, given
  /// quadrant.
  List<T> retrieve(Quadrant quadrant) {
    return root.retrieve(quadrant);
  }

  /// Retrieves all quadrants from the given quadtree, including nested quadrants.
  ///
  /// This method is a recursive function that traverses the entire quadtree
  /// structure and collects all quadrants into a single list.
  ///
  /// - Parameter quadtree: The quadtree from which to retrieve all quadrants.
  /// - Returns: A list of all quadrants in the quadtree.
  static List<Quadrant> getAllQuadrantsFromTree<T>(Quadtree<T> quadtree) =>
      quadtree.root.getAllQuadrants();

  /// Retrieves all quadrants from the quadtree.
  ///
  /// This method traverses the entire quadtree and collects all the quadrants
  /// into a list.
  ///
  /// Returns:
  ///   A list of [Quadrant] items representing all the quadrants in the quadtree.
  List<Quadrant> getAllQuadrants() => getAllQuadrantsFromTree(this);

  /// Recursively retrieves all items from a given quadtree.
  ///
  /// This function traverses the entire quadtree, collecting all items
  /// that extend the `QuadrandtLocalizerMixin` from the root node and its
  /// child nodes.
  ///
  /// - Parameters:
  ///   - quadtree: The root quadtree from which to retrieve items.
  ///
  /// - Returns: A list of all items contained within the quadtree and its
  ///   child nodes.
  static List<T> getAllItemsFromTree<T>(
    Quadtree<T> quadtree, {
    bool removeDuplicates = true,
  }) =>
      QuadtreeNode.getAllItemFromTree(
        quadtree.root,
        removeDuplicates: removeDuplicates,
      );

  /// Retrieves all items stored in the quadtree.
  ///
  /// This method traverses the entire quadtree and collects all items
  /// contained within it.
  ///
  /// Returns a list of all items of type `T` stored in the quadtree.
  List<T> getAllItems({bool removeDuplicates = true}) =>
      getAllItemsFromTree(this, removeDuplicates: removeDuplicates);

  /// Clear the [Quadtree]
  void clear() {
    root.clear();
    _updateLastUpdated();
  }

  Map<String, dynamic> toMap(Map<String, dynamic> Function(T) toMapT) => {
        'quadrant': root.quadrant.toMap(),
        'maxItems': maxItems,
        'maxDepth': maxDepth,
        'items': getAllItems(removeDuplicates: true).map(toMapT).toList(),
      };
}
