import 'dart:ui';

import 'package:flutter/material.dart';

import '../../util/asset.dart';
import '../../util/color.dart';
import 'board_controller.dart';
import 'board_draw.dart';
import 'board_item_view.dart';
import 'board_model.dart';
import 'gesture_detector.dart';

class BoardView extends StatefulWidget {
  static const double widthDip = 320; // 900 //dip  280
  static const double heightDip = 426; // 1200



  static const double ratio = 3 / 4;
  double scale = 1;
  BoardData data;
  BoardController controller;

  BoardView({
    Key? key,
    required this.controller,
    required this.data,
    required this.scale,
  }) : super(key: key);

  @override
  State createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {

  BoardController get _controller => widget.controller;

  DrawController get _drawController => _controller.drawController;

  BoardItem get _selectedItem => _controller.selectedItem;

  @override
  void initState() {
    super.initState();
    _drawController.onDrawEnd = () => {_onDrawEnd()};
  }

  @override
  void didUpdateWidget(covariant BoardView oldWidget) {
    super.didUpdateWidget(oldWidget);

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: BoardView.widthDip,
      height: BoardView.heightDip,
      child: Stack(
        children: [
          _boardBackgroundListener(),
          _boardItemContainer(),
          _boardPaintingContainer(),
        ],
      ),
    );
  }


  /// Board item widgets
  List<Widget> get boardItemWidgets =>
      _controller.items.map(_itemToWidget).toList();

  Widget _itemToWidget(BoardItem e) {
    return BoardItemView(
      key: Key(e.id.toString()),
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
  Widget _boardBackgroundListener() {
    return ValueListenableBuilder(
      valueListenable: _controller.isChangeBackgroundNotifier,
      builder: (
        BuildContext context,
        bool value,
        Widget? child,
      ) {
        return Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          left: 0,
          child: _boardBackground(),
        );
      },
    );
  }

  Widget _boardBackground() {
    Widget background() {
      final image = _controller.boardImage;
      if (image != null) {
        return Image.asset(boardPath(image), fit: BoxFit.cover);
      }
      final color = _controller.boardColor;
      if (color != null) {
        return Container(color: fromHex(color));
      }
      return Container(color: Colors.white);
    }

    return background();
  }

  /// Container for board widgets
  Widget _boardItemContainer() {
    return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: MatrixGestureDetector(
          onScaleStart: () {},
          onScaleEnd: () {},
          scale: widget.scale,
          onMatrixUpdate: _onMatrixUpdate,
          child: ValueListenableBuilder(
            valueListenable: widget.controller,
            builder: (
              BuildContext context,
              List<BoardItem> value,
              Widget? child,
            ) {
              return Stack(children: boardItemWidgets);
            },
          ),
        ));
  }

  /// Container for user draw by finger
  Widget _boardPaintingContainer() {
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
            child: DrawView(
              width: BoardView.widthDip,
              height: BoardView.heightDip,
              controller: _drawController,
            ),
          );
        }
        return const SizedBox(
          width: 0,
          height: 0,
        );
      },
    );
  }

  /// Callback on gesture
  void _onMatrixUpdate(
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
    _selectedItem.matrixNotifier.value = matrix;
  }

  /// Callback on finger draw tap up
  void _onDrawEnd() {
    _controller.addNewItem((item) {
      item.drawPoints = _drawController.points;
    });
    _drawController.clear();
  }
}
