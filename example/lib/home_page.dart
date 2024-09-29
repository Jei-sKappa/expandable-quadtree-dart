import 'dart:math';

import 'package:example/controller.dart';
import 'package:example/model/my_object.dart';
import 'package:example/visualizer.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

final _r = Random();
const _uuid = Uuid();

class QuadtreeHomePage extends StatefulWidget {
  const QuadtreeHomePage({super.key});

  @override
  State<QuadtreeHomePage> createState() => _QuadtreeHomePageState();
}

class _QuadtreeHomePageState extends State<QuadtreeHomePage> {
  late final QuadtreeController quadtreeController;

  @override
  void initState() {
    quadtreeController = QuadtreeController(
      quadrantWidth: 2500,
      quadrantHeight: 2500,
      maxItems: 20,
      maxDepth: 8,
    );
    super.initState();
  }

  void _handleTapDown(TapDownDetails details, BoxConstraints constraints) {
    final qW = quadtreeController.quadtree.root.quadrant.width;
    final qH = quadtreeController.quadtree.root.quadrant.height;
    final maxW = constraints.maxWidth;
    final maxH = constraints.maxHeight;
    final tapX = details.localPosition.dx;
    final tapY = details.localPosition.dy;

    // Scale the quadtree to the screen size, preserving aspect ratio
    final double scaleX = maxW / qW;
    final double scaleY = maxH / qH;
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    // Calculate the positioning to center the quadtree
    final double left = (maxW - (qW * scale)) / 2;
    final double top = (maxH - (qH * scale)) / 2;

    // First, reverse the centering
    final double adjustedX = tapX - left;
    final double adjustedY = tapY - top;

    // Then, reverse the scaling
    final x = adjustedX / scale;
    final y = adjustedY / scale;

    if (x < 0 || x > qW || y < 0 || y > qH) {
      print('  Cannot Insert: Out of bounds');
      return;
    }

    _createObjectsAndAddToQuadtree(
      quadtreeController: quadtreeController,
      offset: Offset(x, y),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quadtree Visualizer'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 260,
            child: _Controls(quadtreeController: quadtreeController),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                  ),
                  child: LayoutBuilder(builder: (context, constraints) {
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onHover: (event) {
                        print('Mouse at ${event.localPosition}');
                      },
                      child: GestureDetector(
                        onTapDown: (details) =>
                            _handleTapDown(details, constraints),
                        child: QuadtreeVisualizer(
                          quadtreeController: quadtreeController,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.quadtreeController,
  });

  final QuadtreeController quadtreeController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            'Quadrant Size: ${quadtreeController.quadrantWidth} x ${quadtreeController.quadrantHeight}',
          ),
          ListenableBuilder(
              listenable: quadtreeController,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Max Items per Node: ${quadtreeController.maxItems}'),
                    Slider(
                      min: 1,
                      max: 100,
                      divisions: 100,
                      value: quadtreeController.maxItems.toDouble(),
                      onChanged: (value) {
                        quadtreeController.updateMaxItems(value.toInt());
                      },
                    ),
                  ],
                );
              }),
          ListenableBuilder(
              listenable: quadtreeController,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Max Depth: ${quadtreeController.maxDepth ?? "Unlimited"}'),
                    StatefulBuilder(
                      builder: (context, setState) {
                        final bool isUnlimited =
                            quadtreeController.maxDepth == null;
                        if (isUnlimited) {
                          return ElevatedButton(
                            onPressed: () {
                              quadtreeController.updateMaxDepth(10);
                            },
                            child: const Text('Set Max Depth'),
                          );
                        }
                        return Row(
                          children: [
                            Expanded(
                              child: Slider(
                                min: 1,
                                max: 30,
                                divisions: 30,
                                value: quadtreeController.maxDepth!.toDouble(),
                                onChanged: (value) {
                                  quadtreeController
                                      .updateMaxDepth(value.toInt());
                                },
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                quadtreeController.updateMaxDepth(null);
                              },
                              child: const Text('Make Unlimited'),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              }),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _createObjectsAndAddToQuadtree(
                  myObject: MyObject(
                    id: _uuid.v4(),
                    x: quadtreeController.quadrantWidth / 2,
                    y: quadtreeController.quadrantHeight / 2,
                    width: quadtreeController.quadrantWidth * 0.1,
                    height: quadtreeController.quadrantHeight * 0.1,
                  ),
                  quadtreeController: quadtreeController,
                ),
                child: const Text('Add object at the same position'),
              ),
              ElevatedButton(
                onPressed: () => _createObjectsAndAddToQuadtree(
                  quadtreeController: quadtreeController,
                ),
                child: const Text('Add one Object'),
              ),
              SizedBox(
                width: 200,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Add Multiple Objects',
                    hintText: 'Enter a number...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  keyboardType: TextInputType.number,
                  onSubmitted: (value) {
                    try {
                      final count = int.parse(value);
                      _createObjectsAndAddToQuadtree(
                        count: count,
                        quadtreeController: quadtreeController,
                      );
                    } on FormatException catch (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Do you think that '$value' is a valid number?? 🤨"),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Clear the quadtree
                  quadtreeController.clearQuadtree();
                },
                child: const Text('Clear Quadtree'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void _createObjectsAndAddToQuadtree({
  MyObject? myObject,
  int count = 1,
  required QuadtreeController quadtreeController,
  Offset? offset,
}) {
  print('Adding $count objects');
  for (var i = 0; i < count; i++) {
    final maxWidth = quadtreeController.quadrantWidth;
    final maxHeight = quadtreeController.quadrantHeight;

    final width = _r.nextDouble() * (maxWidth * 0.075) + (maxWidth * 0.01);
    final height = _r.nextDouble() * (maxHeight * 0.075) + (maxHeight * 0.01);

    final maxX = maxWidth - width;
    final maxY = maxHeight - height;

    final x = offset?.dx ?? _r.nextDouble() * maxX;
    final y = offset?.dy ?? _r.nextDouble() * maxY;

    final obj = myObject ??
        MyObject(
          id: "$i-${_uuid.v4()}",
          x: x,
          y: y,
          width: width,
          height: height,
        );
    print('  Adding object $i: $obj');
    quadtreeController.insertObject(obj);
  }
  print('Added all objects');
}
