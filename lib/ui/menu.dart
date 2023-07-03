import 'package:board/ui/board/board_model.dart';
import 'package:board/ui/board/board_page.dart';
import 'package:board/util/state.dart';
import 'package:flutter/material.dart';

import '../res/color.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  Widget sampleItem(Color color) {
    var screenWidth = screenSize.width;
    var itemWidth = screenWidth;
    return Positioned(
      top: 0,
      left: 0,
      child: Container(
        width: itemWidth,
        height: itemWidth / (3 / 4),
        color: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Menu")),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                menuButton('New board', () {
                  var boardData = BoardData(
                    id: 1,
                    name: 'new board',
                    color: '#E3E9F2',
                    items: [],
                  );
                  push(BoardPage(data: boardData));
                }),
                menuButton('My boards', () {}),
              ],
            ),
          ),
          // Transform.scale(
          //   alignment: Alignment.topLeft,
          //   scale: 2,
          //   child: sampleItem(Colors.red),
          // ),
          // Transform.scale(
          //   alignment: Alignment.topLeft,
          //   scale: 1,
          //   child: sampleItem(Colors.blue),
          // ),
          // Transform.scale(
          //   alignment: Alignment.topLeft,
          //   scale: .5,
          //   child: sampleItem(Colors.green),
          // ),
        ],
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
}
