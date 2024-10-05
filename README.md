# Expandable Quadtree

[![Flutter CI](https://github.com/Jei-sKappa/expandable-quadtree-dart/actions/workflows/ci.yml/badge.svg)](https://github.com/Jei-sKappa/expandable-quadtree-dart/actions/workflows/ci.yml)
[![codecov](https://codecov.io/github/Jei-sKappa/expandable-quadtree-dart/graph/badge.svg?token=LYNF1FJ8YF)](https://codecov.io/github/Jei-sKappa/expandable-quadtree-dart)
[![pub package](https://img.shields.io/pub/v/expandable_quadtree.svg)](https://pub.dev/packages/expandable_quadtree)
![pub points](https://img.shields.io/pub/points/expandable_quadtree)
![pub Popularity](https://img.shields.io/pub/popularity/expandable_quadtree)
![pub Likes](https://img.shields.io/pub/likes/expandable_quadtree)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A flexible and efficient **Quadtree** implementation for Flutter and Dart, perfect for spatial indexing, collision detection, and organizing large sets of 2D data. This package supports multiple quadtree configurations, including expandable, horizontally expandable, and vertically expandable quadtrees.

## Features

- **Multiple Quadtree Configurations**:
  - Single-root quadtree
  - Multiple-root quadtree
  - Expandable quadtree
  - Horizontally/Vertically expandable quadtrees
- **Efficient Spatial Queries**: Retrieve items within a given rectangular area.
- **Customizable Depth and Item Limits**: Control how deep and full your quadtree can get.
- **Dynamic Splitting**: Nodes split automatically when capacity is exceeded.
- **Recursive Traversal**: Traverse and retrieve all quadrants or items stored in the quadtree.
- **Item Management**: Easily insert, remove, and retrieve items.
- **Handling Large Datasets**: The quadtree efficiently manages a large number of items by dividing space into smaller regions.

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  expandable_quadtree: ^0.1.0
```

and then run:

```bash
flutter pub get
```

Or just install it with flutter cli:

```bash
flutter pub add expandable_quadtree
```

## Getting Started

### Basic Usage

Here’s a simple example of how to use the quadtree to manage 2D objects in a rectangular space.

```dart
import 'dart:ui'; // For Rect

import 'package:expandable_quadtree/expandable_quadtree.dart';

void main() {
  final quadtree = Quadtree<Rect>(
    Rect.fromLTWH(0, 0, 100, 100),
    maxItems: 10,
    maxDepth: 4,
    getBounds: (item) => item,
  );

  // Insert items
  quadtree.insert(Rect.fromLTWH(10, 10, 4.99, 4.99));
  quadtree.insert(Rect.fromLTWH(10, 10, 5, 5));
  quadtree.insert(Rect.fromLTWH(20, 20, 1, 1));
  quadtree.insert(Rect.fromLTWH(35, 35, 1, 1));
  quadtree.insert(Rect.fromLTWH(35.1, 35.1, 1, 1));
  quadtree.insert(Rect.fromLTWH(40, 40, 5, 5));

  // Retrieve items within a specific area
  final items = quadtree.retrieve(Rect.fromLTWH(15, 15, 20, 20));
  print(items);
  // Output:
  // [
  //   Rect.fromLTWH(10.0, 10.0, 5.0, 5.0),
  //   Rect.fromLTWH(20.0, 20.0, 1.0, 1.0),
  //   Rect.fromLTWH(35.0, 35.0, 1.0, 1.0)
  // ]

  // Removing item recursively looping through ALL the quadtree
  // Recommended for small quadtree
  quadtree.remove(Rect.fromLTWH(10, 10, 5, 5));

  // Removing item recursively looping through ONLY the nodes that intersect with the item
  // Recommended for large quadtree
  quadtree.localizedRemove(Rect.fromLTWH(20, 20, 1, 1));

  // Get all quadrants in the quadtree
  quadtree.getAllQuadrants();

  // If you want to get only the leaf quadrants use:
  quadtree.getAllQuadrants(includeNonLeafNodes: false);

  // Get all items in the quadtree
  quadtree.getAllItems();

  // A quadtree may contain duplicates, if you want the quadtree to return also the duplicates use:
  quadtree.getAllItems(removeDuplicates: false);

  // Clear the quadtree
  quadtree.clear();
}
```

### Using Expandable Quadtree

If you need the quadtree to dynamically expand, you can use the **ExpandableQuadtree**:

```dart
final quadtree = Quadtree<Rect>(
  Rect.fromLTWH(0, 0, 100, 100),
  getBounds: (item) => item,
);

// Cannot insert items that are out of bounds
quadtree.insert(Rect.fromLTWH(150, 150, 1, 1)); // Returns false

// In order to insert items that are out of bounds, you can use ExpandableQuadtree
final expandableQuadtree = ExpandableQuadtree<Rect>(
  Rect.fromLTWH(0, 0, 100, 100),
  getBounds: (item) => item,
);

expandableQuadtree.insert(Rect.fromLTWH(150, 150, 1, 1)); // Returns true
```

### Using HorizontallyExpandable Quadtree

Use the **HorizontallyExpandableQuadtree** if you only want to expand horizontally:

```dart
final quadtree = Quadtree<Rect>(
  Rect.fromLTWH(0, 0, 100, 100),
  getBounds: (item) => item,
);

// Cannot insert items that are out of bounds horizontally
quadtree.insert(Rect.fromLTWH(-50, 0, 1, 1)); // Returns false

// In order to insert items that are out of bounds horizontally, you can use HorizontallyExpandableQuadtree
final horizontallyExpandableQuadtree = HorizontallyExpandableQuadtree<Rect>(
  Rect.fromLTWH(0, 0, 100, 100),
  getBounds: (item) => item,
);

horizontallyExpandableQuadtree.insert(Rect.fromLTWH(-50, 0, 1, 1)); // Returns true

// It also prevents inserting items that are out of bounds vertically
horizontallyExpandableQuadtree.insert(Rect.fromLTWH(0, -50, 1, 1)); // Returns false
```

### Using VerticallyExpandable Quadtree

Use the **VerticallyExpandableQuadtree** if you only want to expand vertically:

```dart
final quadtree = Quadtree<Rect>(
  Rect.fromLTWH(0, 0, 100, 100),
  getBounds: (item) => item,
);

// Cannot insert items that are out of bounds vertically
quadtree.insert(Rect.fromLTWH(0, -50, 1, 1)); // Returns false

// In order to insert items that are out of bounds vertically, you can use VerticallyExpandableQuadtree
final verticallyExpandableQuadtree = VerticallyExpandableQuadtree<Rect>(
  Rect.fromLTWH(0, 0, 100, 100),
  getBounds: (item) => item,
);

verticallyExpandableQuadtree.insert(Rect.fromLTWH(0, -50, 1, 1)); // Returns true

// It also prevents inserting items that are out of bounds horizontally
verticallyExpandableQuadtree.insert(Rect.fromLTWH(-50, 0, 1, 1)); // Returns false
```

## API Overview

### Quadtree

An abstract class representing the core **Quadtree** functionality. It provides methods for inserting, removing, and retrieving items, as well as managing quadtree depth and nodes.

- `Quadtree(Rect boundary, {int maxItems, int maxDepth, required T Function() getBounds})`: Create a new SingleRootQuadtree with the specified boundary, item limits, and depth.
- `Quadtree.fromMap(Map<String, dynamic> map, T Function() getBounds, T Function(Map<String, dynamic>) fromMapT)`: Create a new Quadtree from a map preserving the actual type of the Quadtree.
- `bool insert(T item)`: Insert an item into the quadtree.
- `bool inserAll(List<T> items)`: Insert multiple items into the quadtree.
- `void remove(T item)`: Remove an item from the quadtree.
- `void removeAll(List<T> items)`: Remove multiple items from the quadtree.
- `void localizedRemove(T item)`: Remove an item from the quadtree by traversing only the nodes that intersect with the item.
- `void localizedRemoveAll(List<T> items)`: Remove multiple items from the quadtree by traversing only the nodes that intersect with the items.
- `List<T> retrieve(Rect quadrant)`: Retrieve all items within a specific quadrant.
- `List<Rect> getAllQuadrants({bool includeNonLeafNodes = true})`: Get all quadrants in the tree.
- `List<T> getAllItems({bool removeDuplicates = true})`: Retrieve all items from the quadtree.
- `void clear()`: Clear the entire quadtree.
- `Map<String, dynamic> toMap()`: Convert the quadtree to a map.

### QuadtreeNode

Represents a node in the quadtree. Nodes contain items and may have child nodes (subnodes). The node will automatically split when it exceeds its capacity, distributing items to its subnodes.

### QuadrantLocation

An enum representing the four quadrants in a quadtree:
- `ne`: North-East
- `nw`: North-West
- `sw`: South-West
- `se`: South-East

## Use Cases

- **Game Development**: Manage 2D objects like players, enemies, or items in large game worlds.
- **Collision Detection**: Efficiently detect collisions between objects in a spatial grid.
- **Geospatial Data**: Index and query geospatial data points such as map markers or points of interest.
- **Image Processing**: Divide large images into smaller sections for pixel manipulation or analysis.

## Acknowledgments

A special thanks to [rlch](https://github.com/rlch) for his inspiring work on the [quadtree_dart](https://pub.dev/packages/quadtree_dart) package, which served as a foundational reference for this project.

## Contributing

We welcome contributions! Please open an issue or submit a pull request on [GitHub](https://github.com/Jei-sKappa/expandable-quadtree-dart).

## License

This project is licensed under the [MIT License](LICENSE).