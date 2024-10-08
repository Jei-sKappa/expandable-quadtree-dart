import 'package:example/controller.dart';
import 'package:example/model/my_object.dart';
import 'package:expandable_quadtree/expandable_quadtree.dart';
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
    // TODO: This is inefficient, becuse it'll loose the fast access to the cached items when painting the quadtree.
    if (quadtree is CachedQuadtree<MyObject>) {
      quadtree = (quadtree as CachedQuadtree<MyObject>).decoratedQuadtree;
    }
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
    debugPrint('Repainting canvas $size at $startTime');

    // Scale the quadtree to the screen size, preserving aspect ratio
    final double scaleX = size.width / quadtree.width;
    final double scaleY = size.height / quadtree.height;
    final double scale = scaleX < scaleY
        ? scaleX
        : scaleY; // Pick the smaller scale to fit in both dimensions

    canvas.translate(-quadtree.left * scale, -quadtree.top * scale);

    if (quadtree is MultipleRootsQuadtree) {
      _drawMultipleRootsQuadtree(
        canvas,
        size,
        quadtree as MultipleRootsQuadtree<MyObject>,
        scale,
      );
    } else if (quadtree is SingleRootQuadtree) {
      _drawSingleRootQuadtree(
        canvas,
        size,
        quadtree as SingleRootQuadtree<MyObject>,
        scale,
      );
    } else {
      throw Exception('Unknown quadtree type: ${quadtree.runtimeType}');
    }

    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    debugPrint('Repaint duration: ${duration.inMilliseconds} ms');
    debugPrint('-' * 75);
  }

  void _drawMultipleRootsQuadtree(
    Canvas canvas,
    Size size,
    MultipleRootsQuadtree<MyObject> quadtree,
    double scale,
  ) {
    // Iterate through all the quadtree nodes and draw each one
    for (final node in quadtree.quadtreeNodes.values) {
      // Translate canvas to draw each node
      final double left = (size.width - (quadtree.width * scale)) / 2;
      final double top = (size.height - (quadtree.height * scale)) / 2;

      // Draw the objects in the quadtree
      _drawObjects(canvas, quadtree, scale, left, top);

      // Draw the node's quadrants
      _drawQuadtreeNode(canvas, node, scale, left, top);
    }
  }

  void _drawSingleRootQuadtree(
    Canvas canvas,
    Size size,
    SingleRootQuadtree<MyObject> quadtree,
    double scale,
  ) {
    final double left = (size.width - (quadtree.width * scale)) / 2;
    final double top = (size.height - (quadtree.height * scale)) / 2;

    // Draw the objects in the quadtree
    _drawObjects(canvas, quadtree, scale, left, top);

    // Draw the quadtree quadrants recursively
    _drawQuadtreeNode(canvas, quadtree.root, scale, left, top);
  }

  // Draw all quadrants recursively
  void _drawQuadtreeNode(
    Canvas canvas,
    QuadtreeNode<MyObject> quadtreeNode,
    double scale,
    double left,
    double top,
  ) {
    _drawRect(canvas, quadtreeNode.quadrant, scale, left, top);

    if (quadtreeNode.isNotLeaf) {
      for (final child in quadtreeNode.nodes.values) {
        _drawQuadtreeNode(canvas, child, scale, left, top);
      }
    }
  }

  // Draw a single quadrant
  void _drawRect(
    Canvas canvas,
    Rect quadrant,
    double scale,
    double left,
    double top,
  ) {
    final rect = Rect.fromLTWH(
      left + quadrant.left * scale,
      top + quadrant.top * scale,
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
