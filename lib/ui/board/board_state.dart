import 'package:flutter/material.dart';

import '../widget/draw.dart';
import 'board_model.dart';

class BoardView extends StatefulWidget {
  /// constructor
  const BoardView(Key? key) : super(key: key);

  @override
  State createState() => BoardViewState();
}

/// signature widget state
class BoardViewState extends State<BoardView> {
  late Size _screenSize;
  double _boardWidth = 0;
  double _boardHeight = 0;
  final double _boardRatio = 3 / 4;

  final List<BoardItem> _boardItems = [];
  BoardItem _selectedItem = BoardItem.none;

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
  Widget build(BuildContext context) {
    return SizedBox();
  }

  void _clearPaint() {
    _drawController.clear();
  }

  @override
  void didUpdateWidget(covariant BoardView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenSize = MediaQuery.of(context).size;
  }

  void _updateWidgetSize() {
    _screenSize = MediaQuery.of(context).size;
    _boardWidth = _screenSize.width;
    _boardHeight = _screenSize.width / _boardRatio;
  }
}
