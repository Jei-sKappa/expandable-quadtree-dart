part of 'quadtree.dart';

class QuadtreeDecorator<T> with EquatableMixin implements Quadtree<T> {
  final Quadtree<T> _quadtree;

  QuadtreeDecorator(this._quadtree);

  factory QuadtreeDecorator.fromMap(
    Map<String, dynamic> map,
    Rect Function(T) getBounds,
    T Function(Map<String, dynamic>) fromMapT,
  ) =>
      QuadtreeDecorator(
        Quadtree.fromMap(
          map,
          getBounds,
          fromMapT,
        ),
      );

  @override
  double get left => _quadtree.left;

  @override
  double get top => _quadtree.top;

  @override
  double get width => _quadtree.width;

  @override
  double get height => _quadtree.height;

  @override
  int get depth => _quadtree.depth;

  @override
  set depth(int newDepth) => _quadtree.depth = newDepth;

  @override
  int get negativeDepth => _quadtree.negativeDepth;

  @override
  set negativeDepth(int newNegativeDepth) =>
      _quadtree.negativeDepth = newNegativeDepth;

  @override
  Rect Function(T p1) get getBounds => _quadtree.getBounds;

  @override
  int get maxDepth => _quadtree.maxDepth;

  @override
  int get maxItems => _quadtree.maxItems;

  @override
  void communicateNewNodeDepth(int newDepth) =>
      _quadtree.communicateNewNodeDepth(newDepth);

  @override
  bool insert(T item) => _quadtree.insert(item);

  @override
  bool insertAll(List<T> items) => _quadtree.insertAll(items);

  @override
  void remove(T item) => _quadtree.remove(item);

  @override
  void removeAll(List<T> items) => _quadtree.removeAll(items);

  @override
  void localizedRemove(T item) => _quadtree.localizedRemove(item);

  @override
  void localizedRemoveAll(List<T> items) => _quadtree.localizedRemoveAll(items);

  @override
  List<T> retrieve(Quadrant quadrant) => _quadtree.retrieve(quadrant);

  @override
  List<Quadrant> getAllQuadrants({bool includeNonLeafNodes = true}) =>
      _quadtree.getAllQuadrants(includeNonLeafNodes: includeNonLeafNodes);

  @override
  List<T> getAllItems({bool removeDuplicates = true}) =>
      _quadtree.getAllItems(removeDuplicates: removeDuplicates);

  @override
  void clear() => _quadtree.clear();

  @override
  List<Object?> get props => [_quadtree];

  @override
  Map<String, dynamic> toMap(Map<String, dynamic> Function(T) toMapT) =>
      _quadtree.toMap(toMapT);
}
