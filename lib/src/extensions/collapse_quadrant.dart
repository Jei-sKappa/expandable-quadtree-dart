import 'package:fast_quadtree/src/quadrant.dart';
import 'package:fast_quadtree/src/quadrant_location.dart';

extension CollapseQuadrant on Quadrant {
  Quadrant collapseTo(QuadrantLocation direction) {
    late final double newX;
    late final double newY;

    final halfWidth = width / 2;
    final halfHeight = height / 2;

    switch (direction) {
      case QuadrantLocation.nw:
        newX = x;
        newY = y;
      case QuadrantLocation.ne:
        newX = x + halfWidth;
        newY = y;
      case QuadrantLocation.sw:
        newX = x;
        newY = y + halfHeight;
      case QuadrantLocation.se:
        newX = x + halfWidth;
        newY = y + halfHeight;
    }

    return Quadrant(
      x: newX,
      y: newY,
      width: halfWidth,
      height: halfHeight,
    );
  }
}
