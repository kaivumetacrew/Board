import 'package:board/main_matrix_gesture.dart';
import 'package:board/ui/board.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../transform/transform_demo.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            menuButton('New board', () {
              push(const BoardPage());
            }),
            menuButton('Demo', () {
              push(const DemoPage());
            }),
            menuButton('My boards', () {}),
          ],
        ),
      ),
    );
  }

  Widget menuButton(String label, VoidCallback onPress) {
    return TextButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
      ),
      onPressed: onPress,
      child: Text(label),
    );
  }

  void push(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
