import 'dart:ui';

import 'package:expandable_quadtree/src/extensions/position_details_on_quadtree.dart';
import 'package:expandable_quadtree/src/quadtree.dart';

extension IsRectOutOfBounds<T> on Quadtree<T> {
  bool isRectOutOfBounds(Rect rect) =>
      rect.left < left ||
      rect.right > right ||
      rect.top < top ||
      rect.bottom > bottom;
}
