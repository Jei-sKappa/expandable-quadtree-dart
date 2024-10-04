import 'dart:ui';
import 'package:expandable_quadtree/src/extensions/loose_overlaps_on_rect.dart';
import 'package:test/test.dart';

void main() {
  group('LooseOverlaps on Rect', () {
    test('rectangles that are the same should return true', () {
      final rect1 = Rect.fromLTWH(0, 0, 10, 10);
      final rect2 = Rect.fromLTWH(0, 0, 10, 10);
      expect(rect1.looseOverlaps(rect2), isTrue);
    });

    test('rectangles that fully overlap should return true', () {
      final rect1 = Rect.fromLTWH(0, 0, 10, 10);
      final rect2 = Rect.fromLTWH(5, 5, 6, 6);
      expect(rect1.looseOverlaps(rect2), isTrue);
    });

    test('rectangles positioned side by side horizontally should return true',
        () {
      final rect1 = Rect.fromLTWH(0, 0, 10, 10);
      final rect2 = Rect.fromLTWH(10, 0, 10, 10);
      expect(rect1.looseOverlaps(rect2), isTrue);
    });

    test('rectangles positioned side by side vertically should return true',
        () {
      final rect1 = Rect.fromLTWH(0, 0, 10, 10);
      final rect2 = Rect.fromLTWH(0, 10, 10, 10);
      expect(rect1.looseOverlaps(rect2), isTrue);
    });

    test('rectangles that touch at the corner should return true', () {
      final rect1 = Rect.fromLTWH(0, 0, 10, 10);
      final rect2 = Rect.fromLTWH(10, 10, 10, 10);
      expect(rect1.looseOverlaps(rect2), isTrue);
    });

    test('rectangles that do not touch or overlap should return false', () {
      final rect1 = Rect.fromLTWH(0, 0, 10, 10);
      final rect2 = Rect.fromLTWH(20, 20, 10, 10);
      expect(rect1.looseOverlaps(rect2), isFalse);
    });
  });
}
