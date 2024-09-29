import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

typedef MyObjectID = String;

const _colorList = [
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.yellow,
  Colors.purple,
  Colors.orange,
  Colors.pink,
  Colors.teal,
  Colors.cyan,
  Colors.lime,
  Colors.indigo,
  Colors.amber,
  Colors.brown,
  Colors.grey,
];

int _colorIndex = 0;

class MyObject with EquatableMixin {
  final MyObjectID id;
  final double x;
  final double y;
  final double width;
  final double height;
  final Color color;
  final List<int> data;

  MyObject({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  })  : color = _colorList[_colorIndex++ % _colorList.length],
        data = List<int>.generate(10, (index) => index);

  @override
  List<Object?> get props => [id, x, y, width, height, color, data];

  @override
  bool get stringify => true;

  Rect get bounds => Rect.fromLTWH(x, y, width, height);
}
