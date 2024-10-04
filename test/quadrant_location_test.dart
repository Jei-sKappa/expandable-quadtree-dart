import 'package:test/test.dart';
import 'package:fast_quadtree/src/quadrant_location.dart';

void main() {
  group('QuadrantLocation', () {
    test('isNorth returns true for north quadrants', () {
      expect(QuadrantLocation.ne.isNorth, isTrue);
      expect(QuadrantLocation.nw.isNorth, isTrue);
    });

    test('isNorth returns false for non-north quadrants', () {
      expect(QuadrantLocation.se.isNorth, isFalse);
      expect(QuadrantLocation.sw.isNorth, isFalse);
    });

    test('isSouth returns true for south quadrants', () {
      expect(QuadrantLocation.se.isSouth, isTrue);
      expect(QuadrantLocation.sw.isSouth, isTrue);
    });

    test('isSouth returns false for non-south quadrants', () {
      expect(QuadrantLocation.ne.isSouth, isFalse);
      expect(QuadrantLocation.nw.isSouth, isFalse);
    });

    test('isEast returns true for east quadrants', () {
      expect(QuadrantLocation.ne.isEast, isTrue);
      expect(QuadrantLocation.se.isEast, isTrue);
    });

    test('isEast returns false for non-east quadrants', () {
      expect(QuadrantLocation.nw.isEast, isFalse);
      expect(QuadrantLocation.sw.isEast, isFalse);
    });

    test('isWest returns true for west quadrants', () {
      expect(QuadrantLocation.nw.isWest, isTrue);
      expect(QuadrantLocation.sw.isWest, isTrue);
    });

    test('isWest returns false for non-west quadrants', () {
      expect(QuadrantLocation.ne.isWest, isFalse);
      expect(QuadrantLocation.se.isWest, isFalse);
    });

    test('opposite returns correct opposite quadrant', () {
      expect(QuadrantLocation.ne.opposite, QuadrantLocation.sw);
      expect(QuadrantLocation.nw.opposite, QuadrantLocation.se);
      expect(QuadrantLocation.sw.opposite, QuadrantLocation.ne);
      expect(QuadrantLocation.se.opposite, QuadrantLocation.nw);
    });

    test('fromMap returns correct QuadrantLocation', () {
      expect(QuadrantLocation.fromMap('ne'), QuadrantLocation.ne);
      expect(QuadrantLocation.fromMap('nw'), QuadrantLocation.nw);
      expect(QuadrantLocation.fromMap('sw'), QuadrantLocation.sw);
      expect(QuadrantLocation.fromMap('se'), QuadrantLocation.se);
    });

    test('fromMap throws ArgumentError for invalid key', () {
      expect(() => QuadrantLocation.fromMap('invalid'), throwsArgumentError);
    });

    test('toMap returns correct string representation', () {
      expect(QuadrantLocation.ne.toMap(), 'ne');
      expect(QuadrantLocation.nw.toMap(), 'nw');
      expect(QuadrantLocation.sw.toMap(), 'sw');
      expect(QuadrantLocation.se.toMap(), 'se');
    });
  });
}
