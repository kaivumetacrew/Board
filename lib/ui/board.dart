import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  List<Widget> _items = [];

  Size _screenSize = Size.zero;
  double boardWidth = 0;
  double boardHeight = 0;
  double boardRatio = 4 / 3;

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    boardWidth = _screenSize.width;
    boardHeight = boardWidth * boardRatio;
    return Container(
        color: Colors.black,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                      width: double.infinity,
                      color: Colors.black,
                      child: Center(
                          child: Container(
                        color: Colors.white,
                        child: AspectRatio(
                          aspectRatio: 1 / boardRatio,
                          child: Stack(
                            children: _items,
                          ),
                        ),
                      ))),
                ),
                SizedBox(
                  height: 80,
                  child: Row(
                    children: [
                      _toolbarButton(Icons.abc, 'Text', () {}),
                      _toolbarButton(Icons.image, 'Image', () {
                        _addImage();
                      }),
                      _toolbarButton(Icons.emoji_emotions, 'Sticker', () {}),
                      _toolbarButton(Icons.draw, 'Draw', () {}),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Widget _toolbarButton(
    IconData icon,
    String label,
    VoidCallback callback,
  ) {
    return Expanded(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
              icon: Icon(icon),
              onPressed: callback,
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addText(String label) {}

  void _addImage() {
    _addItem(
      100,
      100,
      Container(
        width: 100,
        height: 100,
        color: Colors.black,
      ),
    );
  }

  void _addItem(
    double width,
    double height,
    Widget widget,
  ) {
    var x = boardWidth / 2 - width / 2;
    var y = boardHeight / 2 - height / 2;
    var positionedWidget = Positioned(
      left: x,
      top: y,
      child: widget,
    );
    setState(() {
      _items.add(positionedWidget);
    });
  }
}
