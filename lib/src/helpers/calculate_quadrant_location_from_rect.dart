import 'dart:ui';

import 'package:expandable_quadtree/src/quadrant_location.dart';

List<QuadrantLocation> calculateQuadrantLocationsFromRect(
  Rect itemBounds,
  Rect quadrant,
) {
  final List<QuadrantLocation> quadrants = [];
  final xMidpoint = quadrant.left + quadrant.width / 2;
  final yMidpoint = quadrant.top + quadrant.height / 2;

  final startIsNorth = itemBounds.top <= yMidpoint;
  final startIsWest = itemBounds.left <= xMidpoint;
  final endIsEast = itemBounds.left + itemBounds.width >= xMidpoint;
  final endIsSouth = itemBounds.top + itemBounds.height >= yMidpoint;

  if (startIsNorth && endIsEast) quadrants.add(QuadrantLocation.ne);
  if (startIsWest && startIsNorth) quadrants.add(QuadrantLocation.nw);
  if (startIsWest && endIsSouth) quadrants.add(QuadrantLocation.sw);
  if (endIsEast && endIsSouth) quadrants.add(QuadrantLocation.se);

  return quadrants;
}
