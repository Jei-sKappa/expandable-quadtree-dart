import 'dart:ui';

import 'package:fast_quadtree/src/quadrant_location.dart';

extension ExpandRect on Rect {
  Rect expandTo(QuadrantLocation direction) {
    late final double newLeft;
    late final double newTop;

    switch (direction) {
      case QuadrantLocation.nw:
        newLeft = left - width;
        newTop = top - height;
      case QuadrantLocation.ne:
        newLeft = left;
        newTop = top - height;
      case QuadrantLocation.sw:
        newLeft = left - width;
        newTop = top;
      case QuadrantLocation.se:
        newLeft = left;
        newTop = top;
    }

    return Rect.fromLTWH(newLeft, newTop, width * 2, height * 2);
  }
}
