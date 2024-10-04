import 'package:fast_quadtree/src/extensions/remove_duplicates.dart';
import 'package:test/test.dart';

void main() {
  group('RemoveDuplicatesFromList', () {
    test('removes duplicates from a list of integers', () {
      final list = [1, 2, 3, 3, 4, 4, 5, 2, 5];
      final result = list.removeDuplicates();
      expect(result, [1, 2, 3, 4, 5]);
    });

    test('removes duplicates from a list of strings', () {
      final list = ['a', 'b', 'b', 'c', 'a'];
      final result = list.removeDuplicates();
      expect(result, ['a', 'b', 'c']);
    });

    test('returns an empty list when the input list is empty', () {
      final list = <int>[];
      final result = list.removeDuplicates();
      expect(result, []);
    });

    test('returns the same list when there are no duplicates', () {
      final list = [1, 2, 3, 4, 5];
      final result = list.removeDuplicates();
      expect(result, [1, 2, 3, 4, 5]);
    });

    test('removes duplicates from a list of custom objects', () {
      final list = [_CustomObject(1), _CustomObject(2), _CustomObject(1)];
      final result = list.removeDuplicates();
      expect(result, [_CustomObject(1), _CustomObject(2)]);
    });
  });
}

class _CustomObject {
  final int id;
  _CustomObject(this.id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CustomObject &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
