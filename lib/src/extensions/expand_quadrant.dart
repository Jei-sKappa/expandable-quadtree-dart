import 'package:fast_quadtree/src/quadrant.dart';
import 'package:fast_quadtree/src/quadrant_location.dart';

extension ExpandQuadrant on Quadrant {
  Quadrant expandTo(QuadrantLocation direction) {
    late final double newX;
    late final double newY;

    switch (direction) {
      case QuadrantLocation.nw:
        newX = x - width;
        newY = y - height;
      case QuadrantLocation.ne:
        newX = x;
        newY = y - height;
      case QuadrantLocation.sw:
        newX = x - width;
        newY = y;
      case QuadrantLocation.se:
        newX = x;
        newY = y;
    }

    return Quadrant(
      x: newX,
      y: newY,
      width: width * 2,
      height: height * 2,
    );
  }
}
