import 'dart:math';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:expandable_quadtree/src/extensions/is_rect_out_of_bounds_on_quadtree.dart';
import 'package:expandable_quadtree/src/extensions/to_map_on_rect.dart';
import 'package:expandable_quadtree/src/helpers/rect_mapper.dart';
import 'package:expandable_quadtree/src/quadtree.dart';

class SingleRootQuadtree<T> with EquatableMixin implements Quadtree<T> {
  SingleRootQuadtree(
    Rect quadrant, {
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
  Rect get quadrant => Rect.fromLTWH(left, top, width, height);

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
  List<T> retrieve(Rect quadrant) {
    return root.retrieve(quadrant);
  }

  @override
  List<Rect> getAllQuadrants({bool includeNonLeafNodes = true}) =>
      root.getAllQuadrants(includeNonLeafNodes: includeNonLeafNodes);

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
