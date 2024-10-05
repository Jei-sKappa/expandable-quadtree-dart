part of 'quadtree.dart';

class QuadtreeNode<T> with EquatableMixin {
  QuadtreeNode(
    this.quadrant, {
    int depth = 0,
    int negativeDepth = 0,
    required this.tree,
  })  : _originalDepth = depth,
        _originalNegativeDepth = negativeDepth,
        items = [],
        nodes = {} {
    tree.communicateNewNodeDepth(_originalDepth + negativeDepth);
  }

  factory QuadtreeNode.fromMap(
    Map<String, dynamic> map,
    Quadtree<T> tree,
    T Function(Map<String, dynamic>) fromMapT,
  ) {
    final node = QuadtreeNode<T>(
      RectMapper.fromMap(map['quadrant']),
      depth: map['depth'] as int,
      negativeDepth: map['negativeDepth'] as int,
      tree: tree,
    );

    for (final item in (map['items'] as List)) {
      node.items.add(fromMapT(item));
    }

    for (final entry in (map['nodes'] as Map).entries) {
      final quadrantLocation = QuadrantLocation.fromMap(entry.key);
      node.nodes[quadrantLocation] = QuadtreeNode.fromMap(
        entry.value as Map<String, dynamic>,
        tree,
        fromMapT,
      );
    }

    return node;
  }

  final Rect quadrant;

  /// Items contained within the node
  final List<T> items;

  /// Subnodes of the [Quadtree].
  final Map<QuadrantLocation, QuadtreeNode<T>> nodes;

  final int _originalDepth;

  final int _originalNegativeDepth;

  int get depth =>
      _originalDepth + (tree.negativeDepth - _originalNegativeDepth);

  late final Quadtree<T> tree;

  bool get isLeaf => nodes.isEmpty;

  bool get isNotLeaf => !isLeaf;

  bool get isFull => items.length >= tree.maxItems;

  bool get canSplit => depth < tree.maxDepth;

  @override
  List<Object?> get props => [
        quadrant,
        _originalDepth,
        _originalNegativeDepth,
        nodes,
        depth,
      ];

  /// Insert the item into the node. If the node exceeds the capacity,
  /// it will split and add all items to their corresponding subnodes.
  ///
  /// Takes quadrant to be inserted.
  void insert(T item) {
    /// If we have subnodes, call [insert] on the matching subnodes.
    if (!isLeaf) {
      final quadrantLocations = _calculateQuadrantLocations(item, quadrant);

      for (int i = 0; i < quadrantLocations.length; i++) {
        nodes[quadrantLocations[i]]!.insert(item);
      }

      return;
    }

    // Quadtree is a leaf node

    if (!isFull || !canSplit) {
      items.add(item);
      return;
    }

    // We are allowed to split the node and the current quadtree is full

    if (nodes.isEmpty) _split();

    // Add items to their corresponding subnodes
    for (final obj in items) {
      _calculateQuadrantLocations(obj, quadrant).forEach((q) {
        nodes[q]!.insert(obj);
      });
    }
    // Add new item to the corresponding subnode
    _calculateQuadrantLocations(item, quadrant).forEach((q) {
      nodes[q]!.insert(item);
    });

    // Node should be cleaned up as the items are now contained within
    // subnodes.
    items.clear();
  }

  /// Insert all items into the [Quadtree]
  void insertAll(List<T> items) {
    for (final item in items) {
      insert(item);
    }
  }

  /// Remove the item from the [Quadtree] looping through **all** nodes.
  ///
  /// If the [Quadtree] is very deep, consider using [localizedRemove]
  void remove(T item) {
    if (items.remove(item)) return;

    for (final node in nodes.values) {
      node.remove(item);
    }
  }

  /// Remove all items from the [Quadtree] looping through **all** nodes.
  ///
  /// If the [Quadtree] is very deep, consider using [localizedRemoveAll]
  void removeAll(List<T> items) {
    for (final item in items) {
      remove(item);
    }
  }

  /// Remove the item from the [Quadtree] looping through **only** the
  /// nodes that intersect with the item.
  ///
  /// If [item.getRectsLocations] is expensive, consider using [remove]
  void localizedRemove(T item) {
    if (items.remove(item)) return;

    final quadrantLocations = _calculateQuadrantLocations(item, quadrant);

    for (int i = 0; i < quadrantLocations.length; i++) {
      nodes[quadrantLocations[i]]!.localizedRemove(item);
    }
  }

  /// Remove all items from the [Quadtree] looping through **only** the
  /// nodes that intersect with the item.
  ///
  /// If [item.getRectsLocations] is expensive, consider using [removeAll]
  void localizedRemoveAll(List<T> items) {
    for (final item in items) {
      localizedRemove(item);
    }
  }

  /// Return all items that overlaps with the given item, given quadrant.
  List<T> retrieve(Rect quadrant) {
    // If the node's quadrant is completely contained within the given
    // quadrant, return all items in the node.
    if (this.quadrant.isInscribed(quadrant)) {
      return getAllItems(removeDuplicates: true);
    }

    // The node's quadrant it's not fully contained within the given quadrant
    // so we need to check if every item is contained within the given quadrant.

    final List<T> items = [];
    for (final item in this.items) {
      if (quadrant.looseOverlaps(tree.getBounds(item))) {
        items.add(item);
      }
    }

    final quadrantLocations = calculateQuadrantLocationsFromRect(
      quadrant,
      this.quadrant,
    );

    // Recursively retrieve items from subnodes in the relevant quadrants.
    if (nodes.isNotEmpty) {
      for (final q in quadrantLocations) {
        items.addAll(nodes[q]!.retrieve(quadrant));
      }
    }

    return items.removeDuplicates();
  }

  /// Retrieves all quadrants from the given quadtree, including nested
  /// quadrants.
  ///
  /// This method is a recursive function that traverses the entire quadtree
  /// structure and collects all quadrants into a single list.
  /// Parameters:
  /// - `includeNonLeafNodes` (optional): A boolean flag indicating whether to
  /// include non-leaf nodes in the resulting list. Defaults to `true`.
  ///
  /// Returns: A list of all quadrants in the quadtree.
  List<Rect> getAllQuadrants({bool includeNonLeafNodes = true}) {
    if (includeNonLeafNodes) {
      return _getAllQuadrants();
    }

    return _getAllRectOnLeafNodes();
  }

  List<Rect> _getAllQuadrants() {
    final List<Rect> quadrants = [quadrant];

    for (final node in nodes.values) {
      quadrants.addAll(node._getAllQuadrants());
    }

    return quadrants;
  }

  List<Rect> _getAllRectOnLeafNodes() {
    final List<Rect> quadrants = [];

    if (isLeaf) {
      quadrants.add(quadrant);
    }

    // Node is not a leaf node

    for (final node in nodes.values) {
      quadrants.addAll(node._getAllRectOnLeafNodes());
    }

    return quadrants;
  }

  /// Retrieves all items from the quadtree, optionally removing duplicates.
  ///
  /// This method traverses the entire quadtree and collects all items into a
  /// single list. If `removeDuplicates` is set to `true`, duplicate items will
  /// be removed from the resulting list.
  ///
  /// Type Parameters:
  /// - `T`: The type of items stored in the quadtree.
  ///
  /// Parameters:
  /// - `removeDuplicates` (optional): A boolean flag indicating whether to
  ///   remove duplicate items from the resulting list. Defaults to `true`.
  ///
  /// Returns:
  /// A list containing all items from the quadtree, with duplicates removed if
  /// `removeDuplicates` is `true`.
  ///
  /// Example:
  /// ```dart
  /// final quadtree = QuadtreeNode<int>();
  /// // Add items to the quadtree...
  /// final allItems = quadtree.getAllItem();
  /// ```
  List<T> getAllItems({bool removeDuplicates = true}) {
    final items = _getAllItems();

    if (removeDuplicates) return items.removeDuplicates();

    return items;
  }

  List<T> _getAllItems() {
    final List<T> items = [...this.items];

    for (final node in nodes.values) {
      items.addAll(node._getAllItems());
    }

    return items;
  }

  /// Clear the [Quadtree]
  void clear() {
    items.clear();

    for (final node in nodes.values) {
      node.clear();
    }

    nodes.clear();
  }

  /// Split the node into 4 subnodes (ne, nw, sw, se)
  void _split() {
    final nextDepth = _originalDepth + 1;

    // Top-right node
    final ne = QuadtreeNode<T>(
      quadrant.collapseTo(QuadrantLocation.ne),
      depth: nextDepth,
      negativeDepth: tree.negativeDepth,
      tree: tree,
    );

    // Top-left node
    final nw = QuadtreeNode<T>(
      quadrant.collapseTo(QuadrantLocation.nw),
      depth: nextDepth,
      negativeDepth: tree.negativeDepth,
      tree: tree,
    );

    // Bottom-left node
    final sw = QuadtreeNode<T>(
      quadrant.collapseTo(QuadrantLocation.sw),
      depth: nextDepth,
      negativeDepth: tree.negativeDepth,
      tree: tree,
    );

    // Bottom-right node
    final se = QuadtreeNode<T>(
      quadrant.collapseTo(QuadrantLocation.se),
      depth: nextDepth,
      negativeDepth: tree.negativeDepth,
      tree: tree,
    );

    nodes
      ..[QuadrantLocation.ne] = ne
      ..[QuadrantLocation.nw] = nw
      ..[QuadrantLocation.sw] = sw
      ..[QuadrantLocation.se] = se;
  }

  List<QuadrantLocation> _calculateQuadrantLocations(
    T item,
    Rect quadrant,
  ) {
    final bounds = tree.getBounds(item);
    return calculateQuadrantLocationsFromRect(bounds, quadrant);
  }

  Map<String, dynamic> toMap(Map<String, dynamic> Function(T) toMapT) {
    return {
      'quadrant': quadrant.toMap(),
      'depth': _originalDepth,
      'negativeDepth': _originalNegativeDepth,
      'items': items.map(toMapT).toList(),
      'nodes': nodes.map(
        (quandrantLoc, node) => MapEntry(
          quandrantLoc.toMap(),
          node.toMap(toMapT),
        ),
      ),
    };
  }
}
