import 'package:board/util/asset.dart';
import 'package:flutter/material.dart';

import '../util/gesture_detector.dart';
import 'board_widget.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> with TickerProviderStateMixin {
  final List<Widget> _items = [];

  double boardWidth = 0;
  double boardHeight = 0;
  double boardRatio = 4 / 3;
  double defaultSize = 120;

  late AnimationController controller;
  late Animation<Alignment> focalPointAnimation;
  Alignment focalPoint = Alignment.center;
  ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    focalPointAnimation = controller.drive(
      AlignmentTween(begin: focalPoint, end: focalPoint),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    boardWidth = screenSize.width;
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
                      ),
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
                      _toolbarButton(Icons.emoji_emotions, 'Sticker', () {
                        _addSticker();
                      }),
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
      defaultSize,
      defaultSize,
      Image.asset(
        Asset.imagePath("galaxy.jpg"),
        width: defaultSize,
        height: defaultSize,
        fit: BoxFit.cover,
      ),
    );
  }

  void _addSticker() {
    _addItem(
      100,
      100,
      Container(
        width: 100,
        height: 100,
        color: Colors.red,
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
    // var positionedWidget = Positioned(
    //   left: x,
    //   top: y,
    //   child: widget,
    // );
    var transformWidget = MatrixGestureDetector(
      onMatrixUpdate: (m, tm, sm, rm) {
        notifier.value = m;
      },
      focalPointAlignment: focalPoint,
      child: CustomPaint(
        foregroundPainter: FocalPointPainter(focalPointAnimation),
        child: AnimatedBuilder(
          animation: notifier,
          builder: (ctx, child) => Transform(
            transform: notifier.value,
            child: widget,
          ),
        ),
      ),
    );
    setState(() {
      _items.add(transformWidget);
    });
  }
}
