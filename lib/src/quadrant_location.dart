enum QuadrantLocation {
  ne,
  nw,
  sw,
  se;

  bool get isNorth =>
      this == QuadrantLocation.ne || this == QuadrantLocation.nw;

  bool get isSouth =>
      this == QuadrantLocation.se || this == QuadrantLocation.sw;

  bool get isEast => this == QuadrantLocation.ne || this == QuadrantLocation.se;

  bool get isWest => this == QuadrantLocation.nw || this == QuadrantLocation.sw;

  /// Returns the opposite `QuadrantLocation` of the current instance.
  ///
  /// The mapping is as follows:
  /// - `QuadrantLocation.nw` maps to `QuadrantLocation.se`
  /// - `QuadrantLocation.ne` maps to `QuadrantLocation.sw`
  /// - `QuadrantLocation.sw` maps to `QuadrantLocation.ne`
  /// - `QuadrantLocation.se` maps to `QuadrantLocation.nw`
  QuadrantLocation get opposite => switch (this) {
        QuadrantLocation.nw => QuadrantLocation.se,
        QuadrantLocation.ne => QuadrantLocation.sw,
        QuadrantLocation.sw => QuadrantLocation.ne,
        QuadrantLocation.se => QuadrantLocation.nw,
      };

  static QuadrantLocation fromMap(String key) {
    switch (key) {
      case 'ne':
        return QuadrantLocation.ne;
      case 'nw':
        return QuadrantLocation.nw;
      case 'sw':
        return QuadrantLocation.sw;
      case 'se':
        return QuadrantLocation.se;
      default:
        throw ArgumentError.value(key, 'key', 'Invalid QuadrantLocation');
    }
  }

  String toMap() {
    switch (this) {
      case QuadrantLocation.ne:
        return 'ne';
      case QuadrantLocation.nw:
        return 'nw';
      case QuadrantLocation.sw:
        return 'sw';
      case QuadrantLocation.se:
        return 'se';
    }
  }
}
