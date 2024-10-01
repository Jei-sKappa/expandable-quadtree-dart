import 'package:example/model/my_object.dart';
import 'package:fast_quadtree/fast_quadtree.dart';
import 'package:flutter/material.dart';

class QuadtreeController with ChangeNotifier {
  QuadtreeController({
    this.quadrantX = 0,
    this.quadrantY = 0,
    required this.quadrantWidth,
    required this.quadrantHeight,
    this.maxItems = 4,
    this.maxDepth = 4,
    required this.createQuadtree,
  }) {
    quadtree = createQuadtree(
      quadrantX: quadrantX,
      quadrantY: quadrantY,
      quadrantWidth: quadrantWidth,
      quadrantHeight: quadrantHeight,
      maxItems: maxItems,
      maxDepth: maxDepth,
    );
  }

  final double quadrantX;
  final double quadrantY;
  final double quadrantWidth;
  final double quadrantHeight;
  int maxItems;
  int maxDepth;
  late Quadtree<MyObject> quadtree;

  Quadtree<MyObject> Function({
    required double quadrantX,
    required double quadrantY,
    required double quadrantWidth,
    required double quadrantHeight,
    required int maxItems,
    required int maxDepth,
  }) createQuadtree;

  void updateMaxItems(int value) {
    maxItems = value;
    createQuadtree(
      quadrantX: quadrantX,
      quadrantY: quadrantY,
      quadrantWidth: quadrantWidth,
      quadrantHeight: quadrantHeight,
      maxItems: maxItems,
      maxDepth: maxDepth,
    );
    notifyListeners();
  }

  void updateMaxDepth(int value) {
    maxDepth = value;
    createQuadtree(
      quadrantX: quadrantX,
      quadrantY: quadrantY,
      quadrantWidth: quadrantWidth,
      quadrantHeight: quadrantHeight,
      maxItems: maxItems,
      maxDepth: maxDepth,
    );
    notifyListeners();
  }

  bool insertObject(MyObject object) {
    if (quadtree.insert(object)) {
      notifyListeners();
      return true;
    }

    return false;
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
