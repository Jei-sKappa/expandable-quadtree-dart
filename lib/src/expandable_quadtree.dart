import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:expandable_quadtree/src/extensions/is_rect_out_of_bounds_on_quadtree.dart';
import 'package:expandable_quadtree/src/extensions/to_map_on_rect.dart';
import 'package:expandable_quadtree/src/helpers/calculate_quadrant_location_from_rect.dart';
import 'package:expandable_quadtree/src/helpers/rect_mapper.dart';
import 'package:expandable_quadtree/src/quadrant_location.dart';
import 'package:expandable_quadtree/src/quadtree.dart';
import 'package:expandable_quadtree/src/single_root_quadtree.dart';
import 'package:expandable_quadtree/src/extensions/expand_rect.dart';
import 'package:expandable_quadtree/src/extensions/move_rect.dart';

class ExpandableQuadtree<T> extends SingleRootQuadtree<T> with EquatableMixin {
  ExpandableQuadtree(
    super.quadrant, {
    required super.getBounds,
    super.maxItems = 4,
    super.maxDepth = 8,
  });

  factory ExpandableQuadtree.fromMap(
    Map<String, dynamic> map,
    Rect Function(T) getBounds,
    T Function(Map<String, dynamic>) fromMapT,
  ) {
    final tree = ExpandableQuadtree(
      RectMapper.fromMap(map['quadrant']),
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
  bool insert(T item) {
    _maybeExpand(item);
    return super.insert(item);
  }

  @override
  Map<String, dynamic> toMap(Map<String, dynamic> Function(T) toMapT) => {
        '_type': 'ExpandableQuadtree',
        'quadrant': root.quadrant.toMap(),
        'maxItems': maxItems,
        'maxDepth': maxDepth,
        'items': getAllItems(removeDuplicates: true).map(toMapT).toList(),
      };

  void _maybeExpand(T item) {
    final bounds = getBounds(item);

    // Expand until the rect is within the outer quadrant bounds.
    while (isRectOutOfBounds(bounds)) {
      final locs = calculateQuadrantLocationsFromRect(bounds, root.quadrant);
      _expand(locs.first);
    }
  }

  void _expand(QuadrantLocation direction) {
    final newRoot = QuadtreeNode<T>(
      root.quadrant.expandTo(direction),
      tree: this,
    );

    // The old root not will be a child of the new root node at the opposite
    // location of the requested location.
    final oldRootLocation = direction.opposite;

    for (final loc in QuadrantLocation.values) {
      if (loc == oldRootLocation) {
        newRoot.nodes[loc] = root;
      } else {
        newRoot.nodes[loc] = QuadtreeNode<T>(
          root.quadrant.moveTo(oldRootLocation, loc),
          tree: this,
        );
      }
    }

    root = newRoot;
    depth++;
    negativeDepth++;
  }
}
