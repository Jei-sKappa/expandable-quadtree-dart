import 'dart:math';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:fast_quadtree/src/quadrant.dart';
import 'package:fast_quadtree/src/quadtree.dart';

class VerticallyExpandableQuadtree<T> extends QuadtreeDecorator<T>
    with EquatableMixin {
  VerticallyExpandableQuadtree(super._quadtree) {
    // Insert the root node into the quadtreeNodes map
    quadtreeNodes[0] = super.root;
  }

  final Map<int, QuadtreeNode<T>> quadtreeNodes = {};

  double get nodeHeight => super.root.quadrant.height;
  double get nodeWidth => super.root.quadrant.width;
  double get nodeX => super.root.quadrant.x;

  // TODO: Change name
  late double yCoord = super.root.quadrant.y;

  double get totalHeight =>
      ((maxVerticalRow - minVerticalRow) + 1) * nodeHeight;

  late int minVerticalRow = 0;
  late int maxVerticalRow = 0;

  // Helper to determine which vertical row the object belongs to
  int _getVerticalRow(Rect bounds) => (bounds.top / nodeHeight).floor();

  @override
  bool insert(T item) {
    final bounds = getBounds(item);

    // Check if the object is out of bounds horizontally
    if (bounds.left < nodeX || bounds.right > nodeX + nodeWidth) {
      print('ERROR! Object is out of bounds horizontally');
      return false;
    }

    // Determine the vertical row (key) based on the object's y-coordinate.
    int verticalRow = _getVerticalRow(bounds);

    // If a quadtree for this row doesn't exist, create a new one.
    if (!quadtreeNodes.containsKey(verticalRow)) {
      _createNewQuadtreeNode(verticalRow);
    }

    // Insert the object into the appropriate quadtree node.
    quadtreeNodes[verticalRow]!.insert(item);
    print('Inserted item into row $verticalRow');
    final items = quadtreeNodes[verticalRow]!.getAllItems();
    print('Items in row $verticalRow: $items');

    return true;
  }

  // TODO: Missing remove methods

  @override
  List<T> retrieve(Quadrant quadrant) {
    List<T> results = [];

    final quadrantBounds = quadrant.bounds;

    // Check which quadtree nodes the search bounds overlap with
    final topRow = _getVerticalRow(quadrantBounds);
    final bottomRow =
        _getVerticalRow(quadrantBounds.translate(0, quadrantBounds.height));

    for (int row = topRow; row <= bottomRow; row++) {
      if (quadtreeNodes.containsKey(row)) {
        results.addAll(quadtreeNodes[row]!.retrieve(quadrant));
      }
    }

    return results;
  }

  @override
  List<Quadrant> getAllQuadrants() {
    List<Quadrant> results = [];

    for (final node in quadtreeNodes.values) {
      results.addAll(node.getAllQuadrants());
    }

    return results;
  }

  @override
  List<T> getAllItems({bool removeDuplicates = true}) {
    List<T> results = [];

    for (final node in quadtreeNodes.values) {
      results.addAll(node.getAllItems(removeDuplicates: removeDuplicates));
    }

    return results;
  }

  void _createNewQuadtreeNode(int verticalRow) {
    final newY = verticalRow * nodeHeight;
    print('Creating new quadtree node');
    print('  current y = $yCoord');
    print('  at y = $newY');

    final newNode = QuadtreeNode<T>(
      Quadrant(
        x: nodeX,
        y: newY,
        width: nodeWidth,
        height: nodeHeight,
      ),
      tree: this,
    );
    quadtreeNodes[verticalRow] = newNode;

    yCoord = min(yCoord, newY);
    minVerticalRow = min(minVerticalRow, verticalRow);
    maxVerticalRow = max(maxVerticalRow, verticalRow);
  }
}
