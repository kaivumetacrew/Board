import 'package:flutter/material.dart';

import '../../util/asset.dart';
import '../../util/color.dart';
import '../widget/draw.dart';
import '../widget/gesture_detector.dart';
import 'board_model.dart';

class BoardController  {

  BoardController();

}

class BoardView extends StatefulWidget {

  final BoardController controller;

  const BoardView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State createState() => BoardViewState();
}


/// signature widget state
class BoardViewState extends State<BoardView> {
  late Size _screenSize;

  double _boardWidth = 0;

  double _boardHeight = 0;

  double _boardRatio = 3 / 4;

  bool isDrawing = false;

  String? _boardImage;

  String? _boardColor = '#FFCDD2';

  BoardItem _selectedItem = BoardItem.none;

  List<BoardItem> _boardItems = [];

  List<Widget> _boardWidgets = [];

  final DrawController _drawController = DrawController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
    exportPenColor: Colors.black,
  );

  @override
  void initState() {
    super.initState();

  }

  @override
  void didUpdateWidget(covariant BoardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateWidgetSize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenSize = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    updateWidgetSize();
    return Stack(
      children: [
        boardBackground(),
        boardItemContainer(),
        boardPaintingContainer(),
      ],
    );
  }

  void clearPaint() {
    _drawController.clear();
  }

  void updateWidgetSize() {
    _screenSize = MediaQuery.of(context).size;
    _boardWidth = _screenSize.width;
    _boardHeight = _screenSize.width / _boardRatio;
  }

  /// Board background
  Widget boardBackground() {
    Widget backgroundWidget;
    if (_boardImage?.isNotEmpty ?? false) {
      backgroundWidget = Image.asset(
        boardPath(_boardImage!),
        fit: BoxFit.cover,
      );
    } else if (_boardColor?.isNotEmpty ?? false) {
      backgroundWidget = Container(color: fromHex(_boardColor!));
    } else {
      backgroundWidget = Container(color: Colors.white);
    }
    return SizedBox(
      width: _boardWidth,
      height: _boardHeight,
      child: backgroundWidget,
    );
  }

  /// Container for board widgets
  Widget boardItemContainer() {
    return SizedBox(
      width: double.infinity,
      child: AspectRatio(
        aspectRatio: _boardRatio,
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
            if (isDrawing) {
              return;
            }
            if (_selectedItem == BoardItem.none) {
              return;
            }
            if (_selectedItem.id != state.id) {
              state.id = _selectedItem.id;
              state.update(_selectedItem.matrix);
              return;
            }
            _selectedItem.matrix = matrix;
            _selectedItem.notifier.value = matrix;
          },
          child: Stack(children: _boardWidgets),
        ),
      ),
    );
  }

  /// Container for user draw by finger
  Widget boardPaintingContainer() {
    if (!isDrawing) {
      return const SizedBox(width: 0.0, height: 0.0);
    }
    return Positioned(
      top: 0,
      left: 0,
      child: DrawWidget(
        key: const Key('signature'),
        height: _boardHeight,
        controller: _drawController,
        backgroundColor: Colors.yellow,
      ),
    );
  }

  /// Space between selected item widget and border
  EdgeInsets boardItemMargin() {
    return const EdgeInsets.all(4.0);
  }

  /// Border of selected item
  Widget boardItemBorder() {
    return Positioned(
      top: 0,
      bottom: 0,
      right: 0,
      left: 0,
      child: Container(
        decoration:
            BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
        child: Container(
          decoration:
              BoxDecoration(border: Border.all(color: Colors.white, width: 1)),
        ),
      ),
    );
  }

  void notifyBoardItemsChanged() {
    _boardItems.sort((a, b) => a.lastUpdate.compareTo(b.lastUpdate));
    _boardWidgets = _boardItems.map(itemToWidget).toList();
  }

  Widget itemToWidget(BoardItem e) {
    if (e.isTextItem) {
      return e.equal(_selectedItem)
          ? animatedTextWidget(e)
          : positionedTextWidget(e);
    }
    if (e.isImageItem || e.isStickerItem) {
      return e.equal(_selectedItem)
          ? animatedImageWidget(e)
          : positionedImageWidget(e);
    }
    if (e.isDrawItem) {
      return drawPointWidget(e);
    }
    return errorImageWidget();
  }

  /// Widget for text object on board container
  Widget positionedBoardItemWidget({
    required BoardItem item,
    required Widget child,
  }) {
    return Transform(
      transform: item.notifier.value,
      child: Container(
        margin: boardItemMargin(),
        child: Container(
          child: textWidget(item),
        ),
      ),
    );
  }

  Widget animatedBoardItemWidget({
    required BoardItem item,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: item.notifier,
      builder: (ctx, child) {
        return Transform(
          transform: item.notifier.value,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              boardItemBorder(),
              Container(
                margin: boardItemMargin(),
                child: Container(
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget positionedTextWidget(BoardItem item) {
    return positionedBoardItemWidget(
      item: item,
      child: textWidget(item),
    );
  }

  Widget animatedTextWidget(BoardItem item) {
    return animatedBoardItemWidget(
      item: item,
      child: textWidget(item),
    );
  }

  Widget textWidget(BoardItem item) {
    var textWidget = Text(
      item.text!,
      style:
          TextStyle(fontFamily: item.font, color: item.textColor, fontSize: 48),
    );
    return GestureDetector(
      child: textWidget,
      onTap: () {
        _selectedItem = item;
        setState(() {
          notifyBoardItemsChanged();
        });
      },
    );
  }

  Widget drawPointWidget(BoardItem item) {
    return Container(
      color: const Color.fromARGB(100, 163, 93, 65),
      child: CustomPaint(
        painter: PointPainter(
            points: item.points,
            strokeColor: item.strokeColor,
            strokeWidth: item.strokeWidth,
            strokeCap: item.strokeCap,
            strokeJoin: item.strokeJoin),
      ),
    );
  }

  Widget positionedImageWidget(BoardItem item) {
    return positionedBoardItemWidget(
      item: item,
      child: imageWidget(item),
    );
  }

  Widget animatedImageWidget(BoardItem item) {
    return animatedBoardItemWidget(
      item: item,
      child: imageWidget(item),
    );
  }

  Widget errorImageWidget({String message = 'item error'}) {
    return Container(
      width: 100,
      height: 100,
      color: Colors.red,
      child: Center(
        widthFactor: double.infinity,
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 8, color: Colors.white),
        ),
      ),
    );
  }

  Widget imageWidget(BoardItem item) {
    Widget imageWidget;
    if (item.isImageItem) {
      imageWidget = Image.file(item.file!, errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
        return errorImageWidget(message: 'This image error');
      });
    } else if (item.isStickerItem) {
      imageWidget = Image.asset(stickerPath(item.sticker!), errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
        return errorImageWidget(message: 'This image error');
      });
    } else {
      return errorImageWidget();
    }
    return GestureDetector(
      child: imageWidget,
      onTap: () {
        _selectedItem = item;
        setState(() {
          notifyBoardItemsChanged();
        });
      },
    );
  }
}
