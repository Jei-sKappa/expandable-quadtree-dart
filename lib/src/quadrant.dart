import 'dart:ui';

import 'package:equatable/equatable.dart';

class Quadrant with EquatableMixin {
  const Quadrant({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  const Quadrant.fromOrigin({
    required this.width,
    required this.height,
  })  : x = 0,
        y = 0;

  Quadrant.fromOffset(Offset offset)
      : x = offset.dx,
        y = offset.dy,
        width = 1,
        height = 1;

  const Quadrant.fromLTRB({
    required double left,
    required double top,
    required double right,
    required double bottom,
  })  : x = left,
        y = top,
        width = right - left,
        height = bottom - top;

  factory Quadrant.fromMap(
    Map<String, dynamic> map,
  ) =>
      Quadrant(
        x: map['x'] as double,
        y: map['y'] as double,
        width: map['width'] as double,
        height: map['height'] as double,
      );

  final double x;
  final double y;
  final double width;
  final double height;

  double get left => x;
  double get top => y;
  double get right => x + width;
  double get bottom => y + height;

  bool intersects(Quadrant o) =>
      left < o.right && right > o.left && top < o.bottom && bottom > o.top;

  Rect get bounds => Rect.fromLTWH(x, y, width, height);

  Quadrant copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
  }) =>
      Quadrant(
        x: x ?? this.x,
        y: y ?? this.y,
        width: width ?? this.width,
        height: height ?? this.height,
      );

  Map<String, dynamic> toMap() => {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
      };

  @override
  List<Object?> get props => [x, y, width, height];

  @override
  bool get stringify => true;
}
