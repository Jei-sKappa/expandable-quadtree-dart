import 'dart:ui';

extension RectCopyWith on Rect {
  Rect copyWithLTRB({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return Rect.fromLTRB(
      left ?? this.left,
      top ?? this.top,
      right ?? this.right,
      bottom ?? this.bottom,
    );
  }

  Rect copyWithLTWH({
    double? left,
    double? top,
    double? width,
    double? height,
  }) {
    return Rect.fromLTWH(
      left ?? this.left,
      top ?? this.top,
      width ?? this.width,
      height ?? this.height,
    );
  }
}