import 'package:example/model/my_object.dart';
import 'package:fast_quadtree/fast_quadtree.dart';
import 'package:flutter/material.dart';

Rect _getBoundFromMyObject(MyObject item) => item.bounds;

abstract class QuadtreeControllerBase with ChangeNotifier {
  QuadtreeControllerBase({
    required this.quadrantWidth,
    required this.quadrantHeight,
    this.maxItems = 4,
    this.maxDepth = 4,
  }) {
    _initQuadtree();
  }

  final double quadrantWidth;
  final double quadrantHeight;
  int maxItems;
  int maxDepth;

  Quadtree<MyObject> get quadtree;

  void _initQuadtree();

  void updateMaxItems(int value) {
    maxItems = value;
    _initQuadtree();
  }

  void updateMaxDepth(int value) {
    maxDepth = value;
    _initQuadtree();
  }

  void insertObject(MyObject object) {
    quadtree.insert(object);
    notifyListeners();
  }

  void removeObject(MyObject object) {
    quadtree.remove(object);
    notifyListeners();
  }

  void clearQuadtree() {
    quadtree.clear();
    notifyListeners();
  }
}

class QuadtreeController extends QuadtreeControllerBase {
  QuadtreeController({
    required super.quadrantWidth,
    required super.quadrantHeight,
    super.maxItems,
    super.maxDepth,
  });

  late Quadtree<MyObject> _quadtree;

  @override
  Quadtree<MyObject> get quadtree => _quadtree;

  @override
  void _initQuadtree() {
    _quadtree = Quadtree<MyObject>(
      Quadrant.fromOrigin(width: quadrantWidth, height: quadrantHeight),
      maxItems: maxItems,
      maxDepth: maxDepth,
      getBounds: _getBoundFromMyObject,
    );
    notifyListeners();
  }
}

class CachedQuadtreeController extends QuadtreeControllerBase {
  CachedQuadtreeController({
    required super.quadrantWidth,
    required super.quadrantHeight,
    super.maxItems,
    super.maxDepth,
  });

  late CachedQuadtree<MyObject> _quadtree;

  @override
  CachedQuadtree<MyObject> get quadtree => _quadtree;

  @override
  void _initQuadtree() {
    _quadtree = CachedQuadtree<MyObject>(
      Quadrant.fromOrigin(width: quadrantWidth, height: quadrantHeight),
      maxItems: maxItems,
      maxDepth: maxDepth,
      getBounds: _getBoundFromMyObject,
    );
    notifyListeners();
  }
}
