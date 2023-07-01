import 'package:flutter/material.dart';

import '../../util/asset.dart';
import '../../util/color.dart';
import 'board_controller.dart';
import 'board_draw.dart';
import 'board_item_view.dart';
import 'board_model.dart';
import 'gesture_detector.dart';

class BoardView extends StatefulWidget {
  BoardController boardController;

  BoardView({
    Key? key,
    required this.boardController,
  }) : super(key: key);

  @override
  State createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  late Size _screenSize;

  double _boardWidth = 0;

  double _boardHeight = 0;

  final double _boardRatio = 3 / 4;

  BoardController get _controller => widget.boardController;

  DrawController get _drawController => _controller.drawController;

  BoardItem get _selectedItem => _controller.selectedItem;

  @override
  void initState() {
    super.initState();
    _drawController.onDrawEnd = () => {_onDrawEnd()};
  }

  @override
  void dispose() {
    super.dispose();
    _controller.drawController.dispose();
    _controller.isDrawingNotifier.dispose();
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
        boardBackgroundListener(),
        boardItemContainer(),
        boardPaintingContainer(),
      ],
    );
  }

  void updateWidgetSize() {
    _screenSize = MediaQuery.of(context).size;
    _boardWidth = _screenSize.width;
    _boardHeight = _screenSize.width / _boardRatio;
  }

  /// Board item widgets
  List<Widget> get boardItemWidgets =>
      _controller.items.map(itemToWidget).toList();

  Widget itemToWidget(BoardItem e) {
    return BoardItemView(
      item: e,
      isSelected: e.equal(_selectedItem),
      onTap: (e) {
        if (e.isTextItem || e.isImageItem || e.isStickerItem) {
          _controller.select(e);
          _controller.onItemTap(e);
        }
      },
    );
  }

  /// Board background
  Widget boardBackgroundListener() {
    return ValueListenableBuilder(
      valueListenable: _controller.isChangeBackgroundNotifier,
      builder: (
        BuildContext context,
        bool value,
        Widget? child,
      ) {
        return boardBackground();
      },
    );
  }

  Widget boardBackground() {
    Widget background() {
      var image = _controller.boardImage;
      if (image != null) {
        return Image.asset(boardPath(image), fit: BoxFit.cover);
      }
      var color = _controller.boardColor;
      if (color != null) {
        return Container(color: fromHex(color));
      }
      return Container(color: Colors.white);
    }

    return SizedBox(
      width: _boardWidth,
      height: _boardHeight,
      child: background(),
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
          onMatrixUpdate: onMatrixUpdate,
          child: ValueListenableBuilder(
            valueListenable: widget.boardController,
            builder: (
              BuildContext context,
              List<BoardItem> value,
              Widget? child,
            ) {
              return Stack(children: boardItemWidgets);
            },
          ),
        ),
      ),
    );
  }

  /// Container for user draw by finger
  Widget boardPaintingContainer() {
    return ValueListenableBuilder(
      valueListenable: _controller.isDrawingNotifier,
      builder: (
        BuildContext context,
        bool value,
        Widget? child,
      ) {
        if (value) {
          return Positioned(
            top: 0,
            left: 0,
            child: DrawWidget(
              height: _boardHeight,
              controller: _drawController,
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  /// Callback on gesture
  void onMatrixUpdate(
    MatrixGestureDetectorState state,
    Matrix4 matrix,
    Matrix4 translationDeltaMatrix,
    Matrix4 scaleDeltaMatrix,
    Matrix4 rotationDeltaMatrix,
  ) {
    if (_controller.isDrawing) {
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
  }

  /// Callback on finger draw tap up
  void _onDrawEnd() {
    _controller.addNewItem((item) {
      item.points = _drawController.points;
    });
    _drawController.clear();
  }
}
