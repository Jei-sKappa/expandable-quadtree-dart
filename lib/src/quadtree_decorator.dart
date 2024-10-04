part of 'quadtree.dart';

abstract class QuadtreeDecorator<T> with EquatableMixin implements Quadtree<T> {
  QuadtreeDecorator(this.decoratedQuadtree);

  final Quadtree<T> decoratedQuadtree;

  @override
  double get left => decoratedQuadtree.left;

  @override
  double get top => decoratedQuadtree.top;

  @override
  double get width => decoratedQuadtree.width;

  @override
  double get height => decoratedQuadtree.height;

  @override
  Rect get quadrant => Rect.fromLTWH(left, top, width, height);

  @override
  int get depth => decoratedQuadtree.depth;

  @override
  set depth(int newDepth) => decoratedQuadtree.depth = newDepth;

  @override
  int get negativeDepth => decoratedQuadtree.negativeDepth;

  @override
  set negativeDepth(int newNegativeDepth) =>
      decoratedQuadtree.negativeDepth = newNegativeDepth;

  @override
  Rect Function(T p1) get getBounds => decoratedQuadtree.getBounds;

  @override
  int get maxDepth => decoratedQuadtree.maxDepth;

  @override
  int get maxItems => decoratedQuadtree.maxItems;

  @override
  void communicateNewNodeDepth(int newDepth) =>
      decoratedQuadtree.communicateNewNodeDepth(newDepth);

  @override
  bool insert(T item) => decoratedQuadtree.insert(item);

  @override
  bool insertAll(List<T> items) => decoratedQuadtree.insertAll(items);

  @override
  void remove(T item) => decoratedQuadtree.remove(item);

  @override
  void removeAll(List<T> items) => decoratedQuadtree.removeAll(items);

  @override
  void localizedRemove(T item) => decoratedQuadtree.localizedRemove(item);

  @override
  void localizedRemoveAll(List<T> items) =>
      decoratedQuadtree.localizedRemoveAll(items);

  @override
  List<T> retrieve(Rect quadrant) => decoratedQuadtree.retrieve(quadrant);

  @override
  List<Rect> getAllQuadrants({bool includeNonLeafNodes = true}) =>
      decoratedQuadtree.getAllQuadrants(
          includeNonLeafNodes: includeNonLeafNodes);

  @override
  List<T> getAllItems({bool removeDuplicates = true}) =>
      decoratedQuadtree.getAllItems(removeDuplicates: removeDuplicates);

  @override
  void clear() => decoratedQuadtree.clear();

  @override
  List<Object?> get props => [decoratedQuadtree];

  @override
  Map<String, dynamic> toMap(Map<String, dynamic> Function(T) toMapT) =>
      decoratedQuadtree.toMap(toMapT);

  @protected
  Map<String, dynamic> decoratedQuadtreeToMap(
    Map<String, dynamic> Function(T) toMapT,
  ) =>
      decoratedQuadtree.toMap(toMapT);
}
