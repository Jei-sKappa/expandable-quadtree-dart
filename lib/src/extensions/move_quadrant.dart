import 'package:fast_quadtree/src/quadrant.dart';
import 'package:fast_quadtree/src/quadrant_location.dart';

extension MoveQuadrant on Quadrant {
  Quadrant moveTo(QuadrantLocation from, QuadrantLocation to) {
    late final double newX;
    late final double newY;

    // Determine the x offset based on movement along the east-west axis
    if (from.isEast && to.isWest) {
      newX = x - width; // Moving from east to west (left)
    } else if (from.isWest && to.isEast) {
      newX = x + width; // Moving from west to east (right)
    } else {
      newX = x; // No horizontal change
    }

    // Determine the y offset based on movement along the north-south axis
    if (from.isNorth && to.isSouth) {
      newY = y + height; // Moving from north to south (down)
    } else if (from.isSouth && to.isNorth) {
      newY = y - height; // Moving from south to north (up)
    } else {
      newY = y; // No vertical change
    }

    return Quadrant(
      x: newX,
      y: newY,
      width: width,
      height: height,
    );
  }
}
