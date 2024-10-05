import 'dart:ui';
import 'package:test/test.dart';
import 'package:expandable_quadtree/src/extensions/to_map_on_rect.dart';

void main() {
  group('RectToMap', () {
    test('toMap returns correct map representation', () {
      final rect = Rect.fromLTWH(10, 20, 30, 40);
      final map = rect.toMap();

      expect(map['left'], 10);
      expect(map['top'], 20);
      expect(map['right'], 40); // 10 (left) + 30 (width)
      expect(map['bottom'], 60); // 20 (top) + 40 (height)
    });

    test('toMap handles zero width and height correctly', () {
      final rect = Rect.fromLTWH(0, 0, 0, 0);
      final map = rect.toMap();

      expect(map['left'], 0);
      expect(map['top'], 0);
      expect(map['right'], 0);
      expect(map['bottom'], 0);
    });

    test('toMap handles negative values correctly', () {
      final rect = Rect.fromLTWH(-10, -20, 30, 40);
      final map = rect.toMap();

      expect(map['left'], -10);
      expect(map['top'], -20);
      expect(map['right'], 20); // -10 (left) + 30 (width)
      expect(map['bottom'], 20); // -20 (top) + 40 (height)
    });
  });
}
