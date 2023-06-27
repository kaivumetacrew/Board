import 'package:board/util/asset.dart';
import 'package:flutter/material.dart';

import '../util/gesture_detector.dart';
import 'board_widget.dart';
import 'package:flutter/foundation.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> with TickerProviderStateMixin {
  final List<BoardItem> _boardItems = [];
  List<Widget> _boardWidgets = [];

  double boardWidth = 0;
  double boardHeight = 0;
  double boardRatio = 4 / 3;
  double defaultSize = 120;

  late AnimationController controller;
  late Animation<Alignment> focalPointAnimation;
  Alignment focalPoint = Alignment.center;
  var currentItemIndex = 0;
  Widget gestureDetectorWidget = Container();

  BoardItem? currentItem = null;

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
        child: Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.amber,
                child: Center(
                  child: Container(
                    color: Colors.white,
                    child: AspectRatio(
                      aspectRatio: 1 / boardRatio,
                      child: MatrixGestureDetector(
                        onScaleStart: () {},
                        onScaleEnd: () {},
                        onMatrixUpdate: (
                          state,
                          matrix,
                          translationDeltaMatrix,
                          scaleDeltaMatrix,
                          rotationDeltaMatrix,
                        ) {
                          if (currentItem != null) {
                            if (currentItem!.id != state.id) {
                              state.id = currentItem!.id!;
                              state.reset();
                            }
                            currentItem?.notifier.value = matrix;
                          }
                        },
                        child: Stack(
                          children: _boardWidgets,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _toolbar()
          ],
        ),
      ),
    ));
  }

  void addImage(String path) {
    int index = _boardItems.length;
    var item = BoardItem(
      index,
      assetPath: path,
    );
    currentItem = item;
    _boardItems.add(item);
    setState(() {
      _boardWidgets = mapBoardWidgets(_boardItems);
    });
  }

  List<Widget> mapBoardWidgets(List<BoardItem> items) {
    return items.map((e) {
      if (e.assetPath != null) {
        if (e.equal(currentItem)) {
          return animatedImageWidget(e);
        }
        return positionedImageWidget(e);
      }
      return const Text('error item');
    }).toList();
  }

  Widget positionedImageWidget(BoardItem item) {
    return Transform(
      transform: item.notifier.value,
      child: imageWidget(item),
    );
  }

  Widget animatedImageWidget(BoardItem item) {
    return AnimatedBuilder(
      animation: item.notifier,
      builder: (ctx, child) {
        return Transform(
          transform: item.notifier.value,
          child: imageWidget(item),
        );
      },
    );
  }

  Widget imageWidget(BoardItem item) {
    return GestureDetector(
      child: Image.asset(
        Asset.imagePath(item.assetPath!!),
        width: defaultSize,
        height: defaultSize,
        fit: BoxFit.cover,
      ),
      onTapDown: (detail) {
        currentItem = item;
        setState(() {
          _boardWidgets = mapBoardWidgets(_boardItems);
        });
        debugPrint('tap item ${item.id}');
      },
    );
  }

  /**
   * Bottom toolbar
   */
  Widget _toolbar() {
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          _toolbarButton(Icons.abc, 'Text', () {}),
          _toolbarButton(Icons.image, 'Image', () {
            addImage('galaxy1.jpg');
          }),
          _toolbarButton(Icons.emoji_emotions, 'Sticker', () {
            addImage('galaxy2.jpg');
          }),
          _toolbarButton(Icons.draw, 'Draw', () {
            addImage('galaxy3.jpg');
          }),
        ],
      ),
    );
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
}
