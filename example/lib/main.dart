import 'package:example/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const QuadtreeApp());
}

class QuadtreeApp extends StatelessWidget {
  const QuadtreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quadtree Visualizer',
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: const QuadtreeHomePage(),
    );
  }
}
