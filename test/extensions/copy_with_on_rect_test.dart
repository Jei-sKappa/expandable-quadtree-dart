import 'dart:ui';
import 'package:expandable_quadtree/src/extensions/copy_with_on_rect.dart';
import 'package:test/test.dart';

void main() {
  group('RectCopyWith', () {
    final rect = Rect.fromLTWH(10, 20, 30, 40);

    test('copyWithLTRB copies with new values', () {
      final newRect =
          rect.copyWithLTRB(left: 15, top: 25, right: 35, bottom: 45);
      expect(newRect, Rect.fromLTRB(15, 25, 35, 45));
    });

    test('copyWithLTRB copies with some new values', () {
      final newRect = rect.copyWithLTRB(left: 15);
      expect(newRect, Rect.fromLTRB(15, 20, 40, 60));
    });

    test('copyWithLTRB copies with no new values', () {
      final newRect = rect.copyWithLTRB();
      expect(newRect, rect);
    });

    test('copyWithLTWH copies with new values', () {
      final newRect =
          rect.copyWithLTWH(left: 15, top: 25, width: 35, height: 45);
      expect(newRect, Rect.fromLTWH(15, 25, 35, 45));
    });

    test('copyWithLTWH copies with some new values', () {
      final newRect = rect.copyWithLTWH(left: 15);
      expect(newRect, Rect.fromLTWH(15, 20, 30, 40));
    });

    test('copyWithLTWH copies with no new values', () {
      final newRect = rect.copyWithLTWH();
      expect(newRect, rect);
    });
  });
}
