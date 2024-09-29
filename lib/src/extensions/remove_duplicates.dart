/// Extension to remove duplicates from a list.
extension RemoveDuplicatesFromList<T> on List<T> {
  /// Remove duplicates from a list.
  List<T> removeDuplicates() => toSet().toList();
}
