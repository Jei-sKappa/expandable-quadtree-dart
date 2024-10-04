import 'dart:ui';

import 'package:fast_quadtree/src/quadrant_location.dart';

extension MoveRect on Rect {
  Rect moveTo(QuadrantLocation from, QuadrantLocation to) {
    late final double newLeft;
    late final double newTop;

    // Determine the x offset based on movement along the east-west axis
    if (from.isEast && to.isWest) {
      newLeft = left - width; // Moving from east to west (left)
    } else if (from.isWest && to.isEast) {
      newLeft = left + width; // Moving from west to east (right)
    } else {
      newLeft = left; // No horizontal change
    }

    // Determine the y offset based on movement along the north-south axis
    if (from.isNorth && to.isSouth) {
      newTop = top + height; // Moving from north to south (down)
    } else if (from.isSouth && to.isNorth) {
      newTop = top - height; // Moving from south to north (up)
    } else {
      newTop = top; // No vertical change
    }

    return Rect.fromLTWH(newLeft, newTop, width, height);
  }
}
