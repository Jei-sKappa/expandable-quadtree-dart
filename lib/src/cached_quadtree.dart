import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:expandable_quadtree/src/quadtree.dart';
import 'package:meta/meta.dart';

class CachedQuadtree<T> extends QuadtreeDecorator<T> with EquatableMixin {
  CachedQuadtree(super.decoratedQuadtree);

  factory CachedQuadtree.fromMap(
    Map<String, dynamic> map,
    Rect Function(T) getBounds,
    T Function(Map<String, dynamic>) fromMapT,
  ) {
    final decoratedQuadtreeMap =
        map['decoratedQuadtree'] as Map<String, dynamic>;

    final decoratedQuadtree = Quadtree.fromMap(
      decoratedQuadtreeMap,
      getBounds,
      fromMapT,
    );

    final tree = CachedQuadtree(decoratedQuadtree);
    for (final itemMap in decoratedQuadtreeMap['items']) {
      tree.cachedItems.add(fromMapT(itemMap));
    }
    return tree;
  }

  @visibleForTesting
  final List<T> cachedItems = [];

  @override
  bool insert(T item) {
    if (super.insert(item)) {
      cachedItems.add(item);
      return true;
    }

    return false;
  }

  @override
  bool insertAll(List<T> items) {
    if (super.insertAll(items)) {
      cachedItems.addAll(items);
      return true;
    }

    return false;
  }

  @override
  void remove(T item) {
    super.remove(item);
    cachedItems.remove(item);
  }

  @override
  void removeAll(List<T> items) {
    super.removeAll(items);
    cachedItems.removeWhere((element) => items.contains(element));
  }

  @override
  void localizedRemove(T item) {
    super.localizedRemove(item);
    cachedItems.remove(item);
  }

  @override
  void localizedRemoveAll(List<T> items) {
    super.localizedRemoveAll(items);
    cachedItems.removeWhere((element) => items.contains(element));
  }

  @override
  List<T> getAllItems({bool removeDuplicates = true}) => cachedItems;

  @override
  void clear() {
    super.clear();
    cachedItems.clear();
  }

  @override
  Map<String, dynamic> toMap(Map<String, dynamic> Function(T) toMapT) {
    final decoratedQuadtreeMap = decoratedQuadtreeToMap(toMapT);
    return {
      '_type': 'CachedQuadtree',
      'decoratedQuadtree': decoratedQuadtreeMap,
    };
  }
}
