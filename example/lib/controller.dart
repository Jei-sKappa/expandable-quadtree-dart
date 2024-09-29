import 'package:example/model/my_object.dart';
import 'package:fast_quadtree/fast_quadtree.dart';
import 'package:flutter/material.dart';

Rect _getBoundFromMyObject(MyObject item) => item.bounds;

class QuadtreeController with ChangeNotifier {
  late Quadtree<MyObject> quadtree;
  final double quadrantWidth;
  final double quadrantHeight;
  int maxItems;
  int? maxDepth;

  QuadtreeController({
    required this.quadrantWidth,
    required this.quadrantHeight,
    this.maxItems = 4,
    this.maxDepth,
  }) {
    _initQuadtree();
  }

  void _initQuadtree() {
    quadtree = Quadtree<MyObject>(
      Quadrant.fromOrigin(width: quadrantWidth, height: quadrantHeight),
      maxItems: maxItems,
      maxDepth: maxDepth,
      getBounds: _getBoundFromMyObject,
    );
    notifyListeners();
  }

  void updateMaxItems(int value) {
    maxItems = value;
    _initQuadtree();
  }

  void updateMaxDepth(int? value) {
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
