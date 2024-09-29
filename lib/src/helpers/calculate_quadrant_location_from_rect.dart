import 'dart:ui';

import 'package:fast_quadtree/src/quadrant.dart';
import 'package:fast_quadtree/src/quadrant_location.dart';

List<QuadrantLocation> calculateQuadrantLocationsFromRect(
  Rect itemBounds,
  Quadrant quadrant,
) {
  final List<QuadrantLocation> quadrants = [];
  final xMidpoint = quadrant.x + quadrant.width / 2;
  final yMidpoint = quadrant.y + quadrant.height / 2;

  final startIsNorth = itemBounds.top <= yMidpoint;
  final startIsWest = itemBounds.left <= xMidpoint;
  final endIsEast = itemBounds.left + itemBounds.width >= xMidpoint;
  final endIsSouth = itemBounds.top + itemBounds.height >= yMidpoint;

  if (startIsNorth && endIsEast) quadrants.add(QuadrantLocation.ne);
  if (startIsWest && startIsNorth) quadrants.add(QuadrantLocation.nw);
  if (startIsWest && endIsSouth) quadrants.add(QuadrantLocation.sw);
  if (endIsEast && endIsSouth) quadrants.add(QuadrantLocation.se);

  if (quadrants.isEmpty) {
    print('WARNING: QuadrantLocation is empty');
    print('  bounds: $itemBounds');
    print(
        "    startIsNorth: ${itemBounds.topLeft.dy} < $yMidpoint = $startIsNorth");
    print(
        "    startIsWest: ${itemBounds.topLeft.dx} < $xMidpoint = $startIsWest");
    print(
        "    endIsEast: ${itemBounds.topLeft.dx + itemBounds.width} > $xMidpoint = $endIsEast");
    print(
        "    endIsSouth: ${itemBounds.topLeft.dy + itemBounds.height} > $yMidpoint = $endIsSouth");
    print('      -');
    print('      startIsNorth && endIsEast: ${startIsNorth && endIsEast}');
    print('      startIsWest && startIsNorth: ${startIsWest && startIsNorth}');
    print('      startIsWest && endIsSouth: ${startIsWest && endIsSouth}');
    print('      endIsEast && endIsSouth: ${endIsEast && endIsSouth}');
    print('-' * 50);
    throw Exception('QuadrantLocation is empty');
  }

  return quadrants;
}
