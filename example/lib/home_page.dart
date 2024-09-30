import 'dart:math';

import 'package:example/controller.dart';
import 'package:example/model/my_object.dart';
import 'package:example/visualizer.dart';
import 'package:fast_quadtree/fast_quadtree.dart';
import 'package:flutter/foundation.dart';
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
  late final QuadtreeControllerBase quadtreeController;
  bool showQuatreeRepresentation = true;

  @override
  void initState() {
    quadtreeController = CachedQuadtreeController(
      quadrantWidth: 5000,
      quadrantHeight: 2500,
      maxItems: 20,
      maxDepth: 5,
    );
    _createObjectsAndAddToQuadtree(
      context: context,
      quadtreeController: quadtreeController,
      count: 40,
    );
    super.initState();
  }

  void _handleTapDown(TapDownDetails details, BoxConstraints constraints) {
    final qX = quadtreeController.quadtree.root.quadrant.x;
    final qY = quadtreeController.quadtree.root.quadrant.y;
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
    double x = tapX - left;
    double y = tapY - top;

    // Then, reverse the scaling
    x = x / scale;
    y = y / scale;

    // Translate the tap to the quadrant
    x = x + qX;
    y = y + qY;

    _createObjectsAndAddToQuadtree(
      context: context,
      quadtreeController: quadtreeController,
      offset: Offset(x, y),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quadtree Visualizer'),
        actions: [
          Switch.adaptive(
            value: showQuatreeRepresentation,
            onChanged: (value) {
              setState(() {
                showQuatreeRepresentation = value;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _Controls(quadtreeController: quadtreeController),
          const Divider(),
          if (showQuatreeRepresentation)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                  ),
                  child: LayoutBuilder(builder: (context, constraints) {
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
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
        ],
      ),
    );
  }
}

class _Controls extends StatefulWidget {
  const _Controls({
    required this.quadtreeController,
  });

  final QuadtreeControllerBase quadtreeController;

  @override
  State<_Controls> createState() => _ControlsState();
}

class _ControlsState extends State<_Controls> {
  Duration? timeToRetrieveObjects;
  bool isLoadingRetrieveObjects = false;
  Duration? timeToGetAllObjects;
  bool isLoadingGetAllObjects = false;
  Duration? timeToGetAllObjectsWithoutDuplicates;
  bool isLoadingGetAllObjectsWithoutDuplicates = false;
  Duration? timeToGetAllQuadrants;
  bool isLoadingGetAllQuadrants = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            'Quadrant Size: ${widget.quadtreeController.quadrantWidth} x ${widget.quadtreeController.quadrantHeight}',
          ),
          if (widget.quadtreeController is CachedQuadtreeController)
            ListenableBuilder(
              listenable: widget.quadtreeController,
              builder: (context, _) {
                return Text(
                  'Number of Objects: ${widget.quadtreeController.quadtree.getAllItems().length}',
                );
              },
            ),
          ListenableBuilder(
            listenable: widget.quadtreeController,
            builder: (context, _) {
              return Text(
                'Current depth: ${widget.quadtreeController.quadtree.depth}',
              );
            },
          ),
          ListenableBuilder(
              listenable: widget.quadtreeController,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Max Items per Node: ${widget.quadtreeController.maxItems}'),
                    Slider(
                      min: 1,
                      max: 100,
                      divisions: 100,
                      value: widget.quadtreeController.maxItems.toDouble(),
                      onChanged: (value) {
                        widget.quadtreeController.updateMaxItems(value.toInt());
                      },
                    ),
                  ],
                );
              }),
          ListenableBuilder(
              listenable: widget.quadtreeController,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Max Depth: ${widget.quadtreeController.maxDepth}'),
                    Slider(
                      min: 1,
                      max: 30,
                      divisions: 30,
                      value: widget.quadtreeController.maxDepth.toDouble(),
                      onChanged: (value) {
                        widget.quadtreeController.updateMaxDepth(value.toInt());
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
                onPressed: () {
                  final qX = widget.quadtreeController.quadtree.root.quadrant.y;
                  final qY = widget.quadtreeController.quadtree.root.quadrant.x;
                  final qW  = widget.quadtreeController.quadtree.root.quadrant.width;
                  final qH = widget.quadtreeController.quadtree.root.quadrant.height;

                  final x = _r.nextDouble() * ((qX - qW) * 16) + (qX - qW);
                  final y = _r.nextDouble() * ((qY - qH) * 16) + (qY - qH);

                  _createObjectsAndAddToQuadtree(
                    context: context,
                    myObject: MyObject(
                      id: _uuid.v4(),
                      x: x,
                      y: y,
                      width: widget.quadtreeController.quadrantWidth * 0.25,
                      height: widget.quadtreeController.quadrantHeight * 0.25,
                    ),
                    quadtreeController: widget.quadtreeController,
                  );
                },
                child: const Text(
                  'Add object far away from the quadrant bounds',
                ),
              ),
              ElevatedButton(
                onPressed: () => _createObjectsAndAddToQuadtree(
                  context: context,
                  quadtreeController: widget.quadtreeController,
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
                        context: context,
                        count: count,
                        quadtreeController: widget.quadtreeController,
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
                  widget.quadtreeController.clearQuadtree();
                },
                child: const Text('Clear Quadtree'),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isLoadingGetAllObjectsWithoutDuplicates = true;
                        timeToGetAllObjectsWithoutDuplicates = null;
                      });
                      final start = DateTime.now();
                      await compute(
                        _getAllObjectsWithoutDuplicates,
                        widget.quadtreeController.quadtree,
                      );
                      final end = DateTime.now();
                      setState(() {
                        isLoadingGetAllObjectsWithoutDuplicates = false;
                        timeToGetAllObjectsWithoutDuplicates =
                            end.difference(start);
                      });
                    },
                    child: const Text('Get all objects without duplicates'),
                  ),
                  if (isLoadingGetAllObjectsWithoutDuplicates)
                    const CircularProgressIndicator.adaptive(),
                  if (timeToGetAllObjectsWithoutDuplicates != null)
                    Text(
                        'Time taken: ${timeToGetAllObjectsWithoutDuplicates!.inMilliseconds}ms'),
                ],
              ),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isLoadingGetAllObjects = true;
                        timeToGetAllObjects = null;
                      });
                      final start = DateTime.now();
                      await compute(
                        _getAllObjects,
                        widget.quadtreeController.quadtree,
                      );
                      final end = DateTime.now();
                      setState(() {
                        isLoadingGetAllObjects = false;
                        timeToGetAllObjects = end.difference(start);
                      });
                    },
                    child: const Text('Get all objects'),
                  ),
                  if (isLoadingGetAllObjects)
                    const CircularProgressIndicator.adaptive(),
                  if (timeToGetAllObjects != null)
                    Text(
                        'Time taken: ${timeToGetAllObjects!.inMilliseconds}ms'),
                ],
              ),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isLoadingGetAllQuadrants = true;
                        timeToGetAllQuadrants = null;
                      });
                      final start = DateTime.now();
                      await compute(
                        _getAllQuadrants,
                        widget.quadtreeController.quadtree,
                      );
                      final end = DateTime.now();
                      setState(() {
                        isLoadingGetAllQuadrants = false;
                        timeToGetAllQuadrants = end.difference(start);
                      });
                    },
                    child: const Text('Get all quadrants'),
                  ),
                  if (isLoadingGetAllQuadrants)
                    const CircularProgressIndicator.adaptive(),
                  if (timeToGetAllQuadrants != null)
                    Text(
                        'Time taken: ${timeToGetAllQuadrants!.inMilliseconds}ms'),
                ],
              ),
              // Retrieve Objects
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isLoadingRetrieveObjects = true;
                        timeToRetrieveObjects = null;
                      });
                      final width =
                          widget.quadtreeController.quadrantWidth * 0.01;
                      final height =
                          widget.quadtreeController.quadrantHeight * 0.01;
                      final x =
                          widget.quadtreeController.quadrantWidth / 2 - width;
                      final y =
                          widget.quadtreeController.quadrantHeight / 2 - height;
                      final rect = Rect.fromLTWH(x, y, width, height);

                      final start = DateTime.now();
                      await compute(
                        _retrieveObjects,
                        _RetrieveObjectsParams(
                          widget.quadtreeController.quadtree,
                          rect,
                        ),
                      );
                      final end = DateTime.now();
                      setState(() {
                        isLoadingRetrieveObjects = false;
                        timeToRetrieveObjects = end.difference(start);
                      });
                    },
                    child: const Text('Retrieve Objects'),
                  ),
                  if (isLoadingRetrieveObjects)
                    const CircularProgressIndicator.adaptive(),
                  if (timeToRetrieveObjects != null)
                    Text(
                        'Time taken: ${timeToRetrieveObjects!.inMilliseconds}ms'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void _createObjectsAndAddToQuadtree({
  required BuildContext context,
  MyObject? myObject,
  int count = 1,
  required QuadtreeControllerBase quadtreeController,
  Offset? offset,
}) {
  print('Adding $count objects');
  for (var i = 0; i < count; i++) {
    final maxWidth = quadtreeController.quadtree.root.quadrant.width;
    final maxHeight = quadtreeController.quadtree.root.quadrant.height;

    final width = _r.nextDouble() * (maxWidth * 0.075) + (maxWidth * 0.01);
    final height = _r.nextDouble() * (maxHeight * 0.075) + (maxHeight * 0.01);

    final maxX = maxWidth - width;
    final maxY = maxHeight - height;

    final x = offset?.dx ??
        (_r.nextDouble() * maxX) + quadtreeController.quadtree.root.quadrant.x;
    final y = offset?.dy ??
        (_r.nextDouble() * maxY) + quadtreeController.quadtree.root.quadrant.y;

    final obj = myObject ??
        MyObject(
          id: "$i-${_uuid.v4()}",
          x: x,
          y: y,
          width: width,
          height: height,
        );
    if (i % 1000 == 0) print('  Adding object $i: $obj');
    quadtreeController.insertObject(obj);
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Added $count objects"),
      duration: const Duration(seconds: 2),
    ),
  );
}

List<MyObject> _getAllObjectsWithoutDuplicates(Quadtree<MyObject> quadtree) {
  return quadtree.getAllItems(removeDuplicates: true);
}

List<MyObject> _getAllObjects(Quadtree<MyObject> quadtree) {
  return quadtree.getAllItems(removeDuplicates: false);
}

List<Quadrant> _getAllQuadrants(Quadtree<MyObject> quadtree) {
  return quadtree.getAllQuadrants();
}

class _RetrieveObjectsParams {
  final Quadtree<MyObject> quadtree;
  final Rect bounds;

  _RetrieveObjectsParams(this.quadtree, this.bounds);
}

List<MyObject> _retrieveObjects(_RetrieveObjectsParams params) {
  return params.quadtree.retrieve(
    Quadrant(
      x: params.bounds.left,
      y: params.bounds.top,
      width: params.bounds.width,
      height: params.bounds.height,
    ),
  );
}
