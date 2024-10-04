import 'package:test/test.dart';
import 'package:fast_quadtree/src/extensions/is_inscribed_on_rect.dart';
import 'dart:ui';

void main() {
  group('IsInscribed', () {
    late Rect outer;

    setUp(() {
      outer = Rect.fromLTWH(0, 0, 100, 100);
    });

    test('returns true when rect is fully inscribed within outer rect', () {
      final inner = Rect.fromLTWH(10, 10, 50, 50);
      expect(inner.isInscribed(outer), isTrue);
    });

    test('returns false when rect exceeds outer rect on the left', () {
      final inner = Rect.fromLTWH(-10, 10, 50, 50);
      expect(inner.isInscribed(outer), isFalse);
    });

    test('returns false when rect exceeds outer rect on the right', () {
      final inner = Rect.fromLTWH(10, 10, 100, 50);
      expect(inner.isInscribed(outer), isFalse);
    });

    test('returns false when rect exceeds outer rect on the top', () {
      final inner = Rect.fromLTWH(10, -10, 50, 50);
      expect(inner.isInscribed(outer), isFalse);
    });

    test('returns false when rect exceeds outer rect on the bottom', () {
      final inner = Rect.fromLTWH(10, 10, 50, 100);
      expect(inner.isInscribed(outer), isFalse);
    });

    test('returns true when rect is exactly the same as outer rect', () {
      final rect = Rect.fromLTWH(0, 0, 100, 100);
      expect(rect.isInscribed(rect), isTrue);
    });
  });
}
