import 'package:equatable/equatable.dart';
import 'package:fast_quadtree/src/helpers/calculate_quadrant_location_from_rect.dart';
import 'package:fast_quadtree/src/quadrant_location.dart';
import 'package:fast_quadtree/src/quadtree.dart';
import 'package:fast_quadtree/src/extensions/expand_quadrant.dart';
import 'package:fast_quadtree/src/extensions/move_quadrant.dart';

class ExpandableQuadtree<T> extends QuadtreeDecorator<T> with EquatableMixin {
  ExpandableQuadtree(super._quadtree);

  @override
  bool insert(T item) {
    _maybeExpand(item);
    return super.insert(item);
  }

  void _maybeExpand(T item) {
    final bounds = getBounds(item);

    // Expand until the rect is within the outer quadrant bounds.
    while (isRectOutOfOuterQuadrantBounds(bounds)) {
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
