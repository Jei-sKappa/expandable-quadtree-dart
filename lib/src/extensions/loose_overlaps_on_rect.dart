import 'dart:ui';

extension LooseOverlaps on Rect {
  /// Same as [overlaps] but allows the [Rect]s to be touching.
  bool looseOverlaps(Rect other) {
    if (right < other.left || other.right < left) {
      return false;
    }
    if (bottom < other.top || other.bottom < top) {
      return false;
    }
    return true;
  }
}
