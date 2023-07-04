import 'package:board/ui/board/board_model.dart';
import 'package:board/ui/board/board_page.dart';
import 'package:board/ui/board_list.dart';
import 'package:board/util/state.dart';
import 'package:flutter/material.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  Widget sampleItem(Color color) {
    final screenWidth = screenSize.width;
    final itemWidth = screenWidth;
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
                  final boardData = BoardData(
                    id: DateTime.now().millisecondsSinceEpoch,
                    name: 'new board',
                    color: '#E3E9F2',
                    items: [],
                  );
                  push(BoardPage(board: boardData));
                }),
                menuButton('My boards', () {
                  push(BoardListPage());
                }),
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
      padding: const EdgeInsets.only(bottom: 32),
      child: TextButton(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
        ),
        onPressed: onPress,
        child: Text(label, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
