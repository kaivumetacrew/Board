import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  List<Widget> _items = [];

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Container(
        color: Colors.black,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.amber,
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
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
    setState(() {
      _items.add(Container(
        width: 100,
        height: 100,
        color: Colors.black,
      ));
    });
  }

  void _addItem(Widget widget) {
    setState(() {
      _items.add(widget);
    });
  }
}
