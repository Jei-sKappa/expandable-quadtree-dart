import 'package:test/test.dart';
import 'package:expandable_quadtree/src/helpers/rect_mapper.dart';

void main() {
  group('RectMapper', () {
    test('fromMap creates Rect correctly', () {
      final map = {
        'left': 10.0,
        'top': 20.0,
        'right': 30.0,
        'bottom': 40.0,
      };

      final rect = RectMapper.fromMap(map);

      expect(rect.left, 10.0);
      expect(rect.top, 20.0);
      expect(rect.right, 30.0);
      expect(rect.bottom, 40.0);
    });

    test('fromMap throws error on invalid map', () {
      final map = {
        'left': 'invalid',
        'top': 20.0,
        'right': 30.0,
        'bottom': 40.0,
      };

      expect(() => RectMapper.fromMap(map), throwsA(isA<TypeError>()));
    });
  });
}
