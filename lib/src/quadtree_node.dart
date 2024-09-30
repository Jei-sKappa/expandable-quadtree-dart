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
    tree._communicateNewNodeDepth(_originalDepth + negativeDepth);
  }

  final Quadrant quadrant;

  /// Items contained within the node
  final List<T> items;

  /// Subnodes of the [Quadtree].
  final Map<QuadrantLocation, QuadtreeNode<T>> nodes;

  final int _originalDepth;

  final int _originalNegativeDepth;

  int get depth =>
      _originalDepth + (tree._negativeDepth - _originalNegativeDepth);

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

  @override
  bool get stringify => true;

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
  /// If [item.getQuadrantsLocations] is expensive, consider using [remove]
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
  /// If [item.getQuadrantsLocations] is expensive, consider using [removeAll]
  void localizedRemoveAll(List<T> items) {
    for (final item in items) {
      localizedRemove(item);
    }
  }

  /// Return all items that could collide with the given item, given
  /// quadrant.
  List<T> retrieve(Quadrant quadrant) {
    final quadrantLocations =
        calculateQuadrantLocationsFromRect(quadrant.bounds, this.quadrant);
    final List<T> items = [...this.items];

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
  ///
  /// - Parameter quadtree: The quadtree from which to retrieve all quadrants.
  /// - Returns: A list of all quadrants in the quadtree.
  static List<Quadrant> getAllQuadrantsFromTreeNode<T>(
    QuadtreeNode<T> quadtreeNode,
  ) {
    final List<Quadrant> nodes = [quadtreeNode.quadrant];

    for (final node in quadtreeNode.nodes.values) {
      nodes.addAll(getAllQuadrantsFromTreeNode(node));
    }

    return nodes;
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
  /// - `quadtree`: The root node of the quadtree from which to collect items.
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
  /// final allItems = QuadtreeNode.getAllItemFromTree(quadtree);
  /// ```
  static List<T> getAllItemFromTree<T>(
    QuadtreeNode<T> quadtreeNode, {
    bool removeDuplicates = true,
  }) {
    final items = _getAllItemFromTree(quadtreeNode);

    if (removeDuplicates) return items.removeDuplicates();

    return items;
  }

  static List<T> _getAllItemFromTree<T>(QuadtreeNode<T> quadtreeNode) {
    final List<T> items = [...quadtreeNode.items];

    for (final node in quadtreeNode.nodes.values) {
      items.addAll(
        _getAllItemFromTree(node),
      );
    }

    return items;
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
  List<T> getAllItems({bool removeDuplicates = true}) =>
      getAllItemFromTree(this, removeDuplicates: removeDuplicates);

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
      negativeDepth: tree._negativeDepth,
      tree: tree,
    );

    // Top-left node
    final nw = QuadtreeNode<T>(
      quadrant.collapseTo(QuadrantLocation.nw),
      depth: nextDepth,
      negativeDepth: tree._negativeDepth,
      tree: tree,
    );

    // Bottom-left node
    final sw = QuadtreeNode<T>(
      quadrant.collapseTo(QuadrantLocation.sw),
      depth: nextDepth,
      negativeDepth: tree._negativeDepth,
      tree: tree,
    );

    // Bottom-right node
    final se = QuadtreeNode<T>(
      quadrant.collapseTo(QuadrantLocation.se),
      depth: nextDepth,
      negativeDepth: tree._negativeDepth,
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
    Quadrant quadrant,
  ) {
    final bounds = tree.getBounds(item);
    return calculateQuadrantLocationsFromRect(bounds, quadrant);
  }
}
