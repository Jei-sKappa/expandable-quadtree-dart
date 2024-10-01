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

  MyObject._({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.color,
    required this.data,
  });

  factory MyObject.fromMap(Map<String, dynamic> map) => MyObject._(
        id: map['id'] as MyObjectID,
        x: map['x'] as double,
        y: map['y'] as double,
        width: map['width'] as double,
        height: map['height'] as double,
        color: Color(map['color'] as int),
        data: List<int>.from(map['data'] as List),
      );

  @override
  List<Object?> get props => [id, x, y, width, height, color, data];

  @override
  bool get stringify => true;

  Rect get bounds => Rect.fromLTWH(x, y, width, height);

  static Map<String, dynamic> convertToMap(MyObject myObject) =>
      myObject.toMap();

  Map<String, dynamic> toMap() => {
        'id': id,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'color': color.value,
        'data': data,
      };
}
