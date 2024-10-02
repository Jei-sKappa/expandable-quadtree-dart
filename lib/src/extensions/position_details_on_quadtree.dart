import 'package:fast_quadtree/src/quadtree.dart';

extension PositionDetails<T> on Quadtree<T> {
  double get right => left + width;

  double get bottom => top + height;
}
