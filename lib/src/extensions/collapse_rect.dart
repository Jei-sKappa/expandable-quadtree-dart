import 'dart:ui';

import 'package:fast_quadtree/src/quadrant_location.dart';

extension CollapseRect on Rect {
  Rect collapseTo(QuadrantLocation direction) {
    late final double newLeft;
    late final double newTop;

    final halfWidth = width / 2;
    final halfHeight = height / 2;

    switch (direction) {
      case QuadrantLocation.nw:
        newLeft = left;
        newTop = top;
      case QuadrantLocation.ne:
        newLeft = left + halfWidth;
        newTop = top;
      case QuadrantLocation.sw:
        newLeft = left;
        newTop = top + halfHeight;
      case QuadrantLocation.se:
        newLeft = left + halfWidth;
        newTop = top + halfHeight;
    }

    return Rect.fromLTWH(newLeft, newTop, halfWidth, halfHeight);
  }
}
