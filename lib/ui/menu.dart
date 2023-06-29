import 'package:board/canvas/draw.dart';
import 'package:board/ui/board.dart';
import 'package:flutter/material.dart';

import '../res/color.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Menu")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            menuButton('New board', () {
              push(const BoardPage());
            }),
            menuButton('Signature', () {
              push(SignaturePage());
            }),
            menuButton('My boards', () {}),
          ],
        ),
      ),
    );
  }

  Widget menuButton(String label, VoidCallback onPress) {
    return Padding(
      padding: EdgeInsets.only(bottom: 32),
      child: TextButton(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(ColorRes.text),
        ),
        onPressed: onPress,
        child: Text(label, style: TextStyle(fontSize: 24)),
      ),
    );
  }

  void push(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
