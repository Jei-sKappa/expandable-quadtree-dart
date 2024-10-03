import 'dart:ui';

extension IsInscribed on Rect {
  bool isInscribed(Rect outer) =>
      left >= outer.left &&
      right <= outer.right &&
      top >= outer.top &&
      bottom <= outer.bottom;
}
