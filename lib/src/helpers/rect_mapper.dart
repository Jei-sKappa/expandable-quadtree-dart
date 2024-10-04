import 'dart:ui';

class RectMapper {
  static Rect fromMap(Map<String, dynamic> map) {
    return Rect.fromLTRB(
      map['left'] as double,
      map['top'] as double,
      map['right'] as double,
      map['bottom'] as double,
    );
  }
}