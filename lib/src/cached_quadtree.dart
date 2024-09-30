import 'package:equatable/equatable.dart';
import 'package:fast_quadtree/src/quadtree.dart';

class CachedQuadtree<T> extends QuadtreeDecorator<T> with EquatableMixin {
  CachedQuadtree(super._quadtree);

  final List<T> _cachedItems = [];

  List<T> get cachedItems => _cachedItems;

  @override
  List<Object?> get props => [...super.props, _cachedItems];

  @override
  bool insert(T item) {
    if (super.insert(item)) {
      _cachedItems.add(item);
      return true;
    }

    return false;
  }

  @override
  void remove(T item) {
    super.remove(item);
    _cachedItems.remove(item);
  }

  @override
  void localizedRemove(T item) {
    super.localizedRemove(item);
    _cachedItems.remove(item);
  }

  @override
  List<T> getAllItems({bool removeDuplicates = true}) => _cachedItems;

  @override
  void clear() {
    super.clear();
    _cachedItems.clear();
  }
}
