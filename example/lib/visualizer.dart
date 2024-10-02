import 'package:example/controller.dart';
import 'package:example/model/my_object.dart';
import 'package:fast_quadtree/fast_quadtree.dart';
import 'package:flutter/material.dart';

class QuadtreeVisualizer extends StatelessWidget {
  final QuadtreeController quadtreeController;

  const QuadtreeVisualizer({
    super.key,
    required this.quadtreeController,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: quadtreeController,
      builder: (context, _) {
        return RepaintBoundary(
          child: _QuadtreeVisualizer(quadtreeController),
        );
      },
    );
  }
}

class _QuadtreeVisualizer extends StatefulWidget {
  final QuadtreeController quadtreeController;
  const _QuadtreeVisualizer(this.quadtreeController);

  @override
  State<_QuadtreeVisualizer> createState() => __QuadtreeVisualizerState();
}

class __QuadtreeVisualizerState extends State<_QuadtreeVisualizer> {
  Quadtree<MyObject>? quadtree;

  @override
  void initState() {
    _loadQuadtree();
    super.initState();
  }

  @override
  void didUpdateWidget(_QuadtreeVisualizer oldWidget) {
    _loadQuadtree();

    super.didUpdateWidget(oldWidget);
  }

  Future<void> _loadQuadtree() async {
    final quadtreeMap = await widget.quadtreeController.getQuadtreeMap();
    quadtree = Quadtree<MyObject>.fromMap(
      quadtreeMap,
      (myObject) => myObject.bounds,
      MyObject.fromMap,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (quadtree == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return CustomPaint(
      painter: QuadtreePainter(
        quadtree: quadtree!,
        darkMode: Theme.of(context).brightness == Brightness.dark,
      ),
      child: Container(),
    );
  }
}

class QuadtreePainter extends CustomPainter {
  final Quadtree<MyObject> quadtree;
  final bool darkMode;

  QuadtreePainter({
    required this.quadtree,
    this.darkMode = false,
  });

  late final Paint _linePaint = Paint()
    ..color = darkMode ? Colors.white : Colors.black
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  final Paint _myObjectPaint = Paint()..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final startTime = DateTime.now();
    print('Repainting canvas $size at $startTime');
    if (quadtree is VerticallyExpandableQuadtree) {
      _drawyVerticallyExpandableQuadtree(
          canvas, size, quadtree as VerticallyExpandableQuadtree<MyObject>);
    } else {
      _drawSingleQuadtree(canvas, size, quadtree);
    }
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    print('  Repaint duration: ${duration.inMilliseconds} ms');
    print('-' * 75);
  }

  void _drawyVerticallyExpandableQuadtree(
    Canvas canvas,
    Size size,
    VerticallyExpandableQuadtree<MyObject> quadtree,
  ) {
    // 1. Retrieve all quadtree nodes from the vertically expandable quadtree
    final quadtreeNodes = quadtree.quadtreeNodes;

    // 2. Calculate the global bounds of the entire quadtree (spanning vertically)
    final double totalHeight = quadtree.totalHeight;

    final double nodeWidth = quadtree.nodeWidth;

    // 3. Scale the quadtree to the screen size, preserving aspect ratio
    final double scaleX = size.width / nodeWidth;
    final double scaleY = size.height / totalHeight;
    final double scale =
        scaleX < scaleY ? scaleX : scaleY; // Ensure it fits in both dimensions

    canvas.translate(-quadtree.nodeX * scale, -quadtree.yCoord * scale);

    // 4. Iterate through all the quadtree nodes and draw each one
    for (final node in quadtreeNodes.values) {
      // Translate canvas to draw each node
      final double left = (size.width - (node.quadrant.width * scale)) / 2;
      final double top = (size.height - (totalHeight * scale)) / 2;

      // Draw the objects in the quadtree
      _drawObjects(canvas, quadtree, scale, left, top);

      // Draw the node's quadrants
      _drawQuadtreeNode(canvas, node, scale, left, top);
    }
  }

  void _drawSingleQuadtree(
    Canvas canvas,
    Size size,
    Quadtree<MyObject> quadtree,
  ) {
    final rootNode = quadtree.root;

    // Scale the quadtree to the screen size, preserving aspect ratio
    final double scaleX = size.width / rootNode.quadrant.width;
    final double scaleY = size.height / rootNode.quadrant.height;
    final double scale = scaleX < scaleY
        ? scaleX
        : scaleY; // Pick the smaller scale to fit in both dimensions

    canvas.translate(
        -rootNode.quadrant.x * scale, -rootNode.quadrant.y * scale);

    // Calcola il posizionamento per centrare il quadtree
    final double left = (size.width - (rootNode.quadrant.width * scale)) / 2;
    final double top = (size.height - (rootNode.quadrant.height * scale)) / 2;

    // Draw the objects in the quadtree
    _drawObjects(canvas, quadtree, scale, left, top);

    // Draw the quadtree quadrants recursively
    _drawQuadtreeNode(canvas, rootNode, scale, left, top);
  }

  // Draw all quadrants recursively
  void _drawQuadtreeNode(
    Canvas canvas,
    QuadtreeNode<MyObject> quadtree,
    double scale,
    double left,
    double top,
  ) {
    _drawQuadrant(canvas, quadtree.quadrant, scale, left, top);

    if (quadtree.isNotLeaf) {
      for (final child in quadtree.nodes.values) {
        _drawQuadtreeNode(canvas, child, scale, left, top);
      }
    }
  }

  // Draw a single quadrant
  void _drawQuadrant(
    Canvas canvas,
    Quadrant quadrant,
    double scale,
    double left,
    double top,
  ) {
    final rect = Rect.fromLTWH(
      left + quadrant.x * scale,
      top + quadrant.y * scale,
      quadrant.width * scale,
      quadrant.height * scale,
    );

    // Draw the rectangle
    canvas.drawRect(rect, _linePaint);
  }

  // Draw all objects in the quadtree
  void _drawObjects(
    Canvas canvas,
    Quadtree<MyObject> quadtree,
    double scale,
    double left,
    double top,
  ) {
    final allItems = quadtree.getAllItems();

    for (final myObject in allItems) {
      _drawObject(canvas, myObject, scale, left, top);
    }
  }

  // Draw a single object (represented as a small rectangle or circle)
  void _drawObject(
    Canvas canvas,
    MyObject object,
    double scale,
    double left,
    double top,
  ) {
    final rect = Rect.fromLTWH(
      left + object.bounds.left * scale,
      top + object.bounds.top * scale,
      object.bounds.width * scale,
      object.bounds.height * scale,
    );

    // Draw the object as a filled rectangle
    _myObjectPaint.color = object.color;
    canvas.drawRect(rect, _myObjectPaint);
  }

  @override
  bool shouldRepaint(QuadtreePainter oldDelegate) {
    return true;
  }
}
