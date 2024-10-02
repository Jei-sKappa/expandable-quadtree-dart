import 'dart:convert';
import 'dart:isolate';
import 'package:example/model/my_object.dart';
import 'package:fast_quadtree/fast_quadtree.dart';
import 'package:flutter/material.dart';

const _encoder = JsonEncoder.withIndent('  ');

class QuadtreeController with ChangeNotifier {
  QuadtreeController({
    double quadrantX = 0,
    double quadrantY = 0,
    required double quadrantWidth,
    required double quadrantHeight,
    this.maxItems = 4,
    this.maxDepth = 4,
    this.isCached = false,
    this.isExpandable = false,
    this.isVerticallyExpandable = false,
  })  : _quadrantX = quadrantX,
        _quadrantY = quadrantY,
        _quadrantWidth = quadrantWidth,
        _quadrantHeight = quadrantHeight {
    assert(maxItems > 0, 'maxItems must be greater than 0');
    assert(maxDepth > 0, 'maxDepth must be greater than 0');
    assert(quadrantWidth > 0, 'quadrantWidth must be greater than 0');
    assert(quadrantHeight > 0, 'quadrantHeight must be greater than 0');
    assert(!(isExpandable && isVerticallyExpandable),
        'isExpandable and isVerticallyExpandable cannot both be true');
  }

  final double _quadrantX;
  final double _quadrantY;
  final double _quadrantWidth;
  final double _quadrantHeight;
  int maxItems;
  int maxDepth;
  bool isCached;
  bool isExpandable;
  bool isVerticallyExpandable;

  Isolate? _workerIsolate;
  late SendPort _sendPort;
  final ReceivePort _receivePort = ReceivePort();

  // Future to track when the worker is initialized
  Future<void>? _workerInitialized;

  // Initialize the worker isolate
  Future<void> _initializeWorker() async {
    _workerIsolate =
        await Isolate.spawn(_isolateEntryPoint, _receivePort.sendPort);
    _sendPort = await _receivePort.first;
    _createQuadtreeInWorker(); // Create the initial Quadtree in the isolate
  }

  // Sends the initial command to create the Quadtree in the worker isolate
  void _createQuadtreeInWorker() {
    final initData = {
      'quadrantX': _quadrantX,
      'quadrantY': _quadrantY,
      'quadrantWidth': _quadrantWidth,
      'quadrantHeight': _quadrantHeight,
      'maxItems': maxItems,
      'maxDepth': maxDepth,
      'isCached': isCached,
      'isExpandable': isExpandable,
      'isVerticallyExpandable': isVerticallyExpandable,
    };
    _sendPort.send(['createQuadtree', null, initData]);
  }

  // Isolate entry point where the Quadtree is managed
  static void _isolateEntryPoint(SendPort mainSendPort) {
    final receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort);

    late Quadtree<MyObject> quadtree;

    receivePort.listen((message) {
      final String command = message[0];
      final SendPort? replyPort = message[1];

      if (command == 'createQuadtree') {
        final data = message[2];
        quadtree = Quadtree<MyObject>(
          Quadrant(
            x: data['quadrantX'],
            y: data['quadrantY'],
            width: data['quadrantWidth'],
            height: data['quadrantHeight'],
          ),
          maxItems: data['maxItems'],
          maxDepth: data['maxDepth'],
          getBounds: (MyObject object) => object.bounds,
        );

        if (data['isCached']) {
          quadtree = CachedQuadtree<MyObject>(quadtree);
        }
        if (data['isExpandable']) {
          quadtree = ExpandableQuadtree<MyObject>(quadtree);
        }
        if (data['isVerticallyExpandable']) {
          quadtree = VerticallyExpandableQuadtree<MyObject>(quadtree);
        }
      } else if (command == 'getX') {
        if (quadtree is VerticallyExpandableQuadtree) {
          replyPort!.send((quadtree as VerticallyExpandableQuadtree).nodeX);
        } else {
          replyPort!.send(quadtree.root.quadrant.x);
        }
      } else if (command == 'getY') {
        if (quadtree is VerticallyExpandableQuadtree) {
          replyPort!.send((quadtree as VerticallyExpandableQuadtree).yCoord);
        } else {
          replyPort!.send(quadtree.root.quadrant.y);
        }
      } else if (command == 'getWidth') {
        if (quadtree is VerticallyExpandableQuadtree) {
          replyPort!.send((quadtree as VerticallyExpandableQuadtree).nodeWidth);
        } else {
          replyPort!.send(quadtree.root.quadrant.width);
        }
      } else if (command == 'getHeight') {
        if (quadtree is VerticallyExpandableQuadtree) {
          replyPort!
              .send((quadtree as VerticallyExpandableQuadtree).totalHeight);
        } else {
          replyPort!.send(quadtree.root.quadrant.height);
        }
      } else if (command == 'getDepth') {
        replyPort!.send(quadtree.depth);
      } else if (command == 'insertObject') {
        final MyObject object = message[2];
        final result = quadtree.insert(object);
        replyPort!.send(result);
      } else if (command == 'insertAllObjects') {
        final List<MyObject> objects = message[2];
        final result = quadtree.insertAll(objects);
        replyPort!.send(result);
      } else if (command == 'removeObject') {
        final MyObject object = message[2];
        quadtree.remove(object);
        replyPort!.send(null);
      } else if (command == 'removeAllObjects') {
        final List<MyObject> objects = message[2];
        quadtree.removeAll(objects);
        replyPort!.send(null);
      } else if (command == 'localRemoveObject') {
        final MyObject object = message[2];
        quadtree.localizedRemove(object);
        replyPort!.send(null);
      } else if (command == 'localRemoveAllObjects') {
        final List<MyObject> objects = message[2];
        quadtree.localizedRemoveAll(objects);
        replyPort!.send(null);
      } else if (command == 'clearQuadtree') {
        quadtree.clear();
        replyPort!.send(null);
      } else if (command == 'getAllObjectsWithoutDuplicates') {
        final objects = quadtree.getAllItems(removeDuplicates: true);
        replyPort!.send(objects);
      } else if (command == 'getAllObjects') {
        final objects = quadtree.getAllItems(removeDuplicates: false);
        replyPort!.send(objects);
      } else if (command == 'getAllQuadrants') {
        final quadrants = quadtree.getAllQuadrants();
        replyPort!.send(quadrants);
      } else if (command == 'retrieveObjects') {
        final Rect bounds = message[2];
        final objects = quadtree.retrieve(
          Quadrant(
            x: bounds.left,
            y: bounds.top,
            width: bounds.width,
            height: bounds.height,
          ),
        );
        replyPort!.send(objects);
      } else if (command == 'getQuadtreeMap') {
        final quadtreeMap = quadtree.toMap(MyObject.convertToMap);
        replyPort!.send(quadtreeMap);
      } else if (command == 'getQuadtreeJson') {
        final bool formatted = message[2];
        final quadtreeMap = quadtree.toMap(MyObject.convertToMap);
        if (formatted) {
          replyPort!.send(_encoder.convert(quadtreeMap));
        } else {
          replyPort!.send(jsonEncode(quadtreeMap));
        }
      } else {
        throw Exception('Invalid command: $command');
      }
    });
  }

  // Await worker initialization before performing any action
  Future<void> _ensureInitialized() async {
    _workerInitialized ??= _initializeWorker();
    await _workerInitialized;
  }

  // Update the maxItems parameter in the isolate
  Future<void> updateMaxItems(int value) async {
    await _ensureInitialized();
    maxItems = value;
    _createQuadtreeInWorker();
    notifyListeners();
  }

  // Update the maxDepth parameter in the isolate
  Future<void> updateMaxDepth(int value) async {
    await _ensureInitialized();
    maxDepth = value;
    _createQuadtreeInWorker();
    notifyListeners();
  }

  // Update the isCached parameter in the isolate
  Future<void> updateIsCached(bool value) async {
    await _ensureInitialized();
    isCached = value;
    _createQuadtreeInWorker();
    notifyListeners();
  }

  // Update the isExpandable parameter in the isolate
  Future<void> updateIsExpandable(bool value) async {
    await _ensureInitialized();
    isExpandable = value;
    _createQuadtreeInWorker();
    notifyListeners();
  }

  // Update the isVerticallyExpandable parameter in the isolate
  Future<void> updateIsVerticallyExpandable(bool value) async {
    await _ensureInitialized();
    isVerticallyExpandable = value;
    _createQuadtreeInWorker();
    notifyListeners();
  }

  Future<double> getX() async {
    await _ensureInitialized();
    final responsePort = ReceivePort();
    _sendPort.send(['getX', responsePort.sendPort]);
    final double x = await responsePort.first;
    return x;
  }

  Future<double> getY() async {
    await _ensureInitialized();
    final responsePort = ReceivePort();
    _sendPort.send(['getY', responsePort.sendPort]);
    final double y = await responsePort.first;
    return y;
  }

  Future<double> getWidth() async {
    await _ensureInitialized();
    final responsePort = ReceivePort();
    _sendPort.send(['getWidth', responsePort.sendPort]);
    final double width = await responsePort.first;
    return width;
  }

  Future<double> getHeight() async {
    await _ensureInitialized();
    final responsePort = ReceivePort();
    _sendPort.send(['getHeight', responsePort.sendPort]);
    final double height = await responsePort.first;
    return height;
  }

  Future<int> getDepth() async {
    await _ensureInitialized();
    final responsePort = ReceivePort();
    _sendPort.send(['getDepth', responsePort.sendPort]);
    final int depth = await responsePort.first;
    return depth;
  }

  // Insert an object into the quadtree using the isolate
  Future<bool> insertObject(MyObject object) async {
    await _ensureInitialized();
    final responsePort = ReceivePort();
    _sendPort.send(['insertObject', responsePort.sendPort, object]);
    final bool result = await responsePort.first;
    if (result) notifyListeners();
    return result;
  }

  // Insert multiple objects into the quadtree using the isolate
  Future<bool> insertAllObjects(List<MyObject> objects) async {
    await _ensureInitialized();
    final responsePort = ReceivePort();
    _sendPort.send(['insertAllObjects', responsePort.sendPort, objects]);
    final bool result = await responsePort.first;
    if (result) notifyListeners();
    return result;
  }

  // Remove an object from the quadtree using the isolate
  Future<void> removeObject(MyObject object) async {
    await _ensureInitialized();
    final responsePort = ReceivePort();
    _sendPort.send(['removeObject', responsePort.sendPort, object]);
    await responsePort.first;
    notifyListeners();
  }

  // Remove multiple objects from the quadtree using the isolate
  Future<void> removeAllObjects(List<MyObject> objects) async {
    await _ensureInitialized();
    final responsePort = ReceivePort();
    _sendPort.send(['removeAllObjects', responsePort.sendPort, objects]);
    await responsePort.first;
    notifyListeners();
  }

  // Remove an object from the quadtree using the isolate
  Future<void> localRemoveObject(MyObject object) async {
    await _ensureInitialized();
    final responsePort = ReceivePort();
    _sendPort.send(['localRemoveObject', responsePort.sendPort, object]);
    await responsePort.first;
    notifyListeners();
  }

  // Remove multiple objects from the quadtree using the isolate
  Future<void> localRemoveAllObjects(List<MyObject> objects) async {
    await _ensureInitialized();
    final responsePort = ReceivePort();
    _sendPort.send(['localRemoveAllObjects', responsePort.sendPort, objects]);
    await responsePort.first;
    notifyListeners();
  }

  // Clear the quadtree using the isolate
  Future<void> clearQuadtree() async {
    await _ensureInitialized();
    final responsePort = ReceivePort();
    _sendPort.send(['clearQuadtree', responsePort.sendPort]);
    await responsePort.first;
    notifyListeners();
  }

  // Retrieve all objects without duplicates from the quadtree
  Future<List<MyObject>> getAllObjectsWithoutDuplicates() async {
    await _ensureInitialized();
    final responsePort = ReceivePort();
    _sendPort.send(['getAllObjectsWithoutDuplicates', responsePort.sendPort]);
    final List<MyObject> objects = await responsePort.first;
    return objects;
  }

  // Retrieve all objects with duplicates from the quadtree
  Future<List<MyObject>> getAllObjects() async {
    await _ensureInitialized();
    final responsePort = ReceivePort();
    _sendPort.send(['getAllObjects', responsePort.sendPort]);
    final List<MyObject> objects = await responsePort.first;
    return objects;
  }

  // Retrieve all quadrants from the quadtree
  Future<List<Quadrant>> getAllQuadrants() async {
    await _ensureInitialized();
    final responsePort = ReceivePort();
    _sendPort.send(['getAllQuadrants', responsePort.sendPort]);
    final List<Quadrant> quadrants = await responsePort.first;
    return quadrants;
  }

  // Retrieve objects within specific bounds from the quadtree
  Future<List<MyObject>> retrieveObjects(Rect bounds) async {
    await _ensureInitialized();
    final responsePort = ReceivePort();
    _sendPort.send(['retrieveObjects', responsePort.sendPort, bounds]);
    final List<MyObject> objects = await responsePort.first;
    return objects;
  }

  // Retrive the Map representation of the Quadtree
  Future<Map<String, dynamic>> getQuadtreeMap() async {
    await _ensureInitialized();
    final responsePort = ReceivePort();
    _sendPort.send(['getQuadtreeMap', responsePort.sendPort]);
    final Map<String, dynamic> quadtreeMap = await responsePort.first;
    return quadtreeMap;
  }

  // Retrive the JSON representation of the Quadtree
  Future<String> getQuadtreeJson(bool formatted) async {
    await _ensureInitialized();
    final responsePort = ReceivePort();
    _sendPort.send(['getQuadtreeJson', responsePort.sendPort, formatted]);
    final String quadtreeJson = await responsePort.first;
    return quadtreeJson;
  }

  // Dispose of the worker isolate when no longer needed
  @override
  void dispose() {
    _workerIsolate?.kill(priority: Isolate.immediate);
    _receivePort.close();
    super.dispose();
  }
}
