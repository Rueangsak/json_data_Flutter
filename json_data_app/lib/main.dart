import 'package:flutter/material.dart';
import 'ProvincePage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: ProvincePage(), // Set ProvincePage as the home page
    );
  }
}
