import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../util/finger_draw.dart';
import '../util/gesture_detector.dart';

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
  Alignment focalPoint = Alignment.center;
  late AnimationController controller;
  BoardItem _selectedItem = BoardItem.none;
  ActionItem _currentAction = ActionItem.none;

  GlobalKey globalKey = GlobalKey();
  List<TouchPoints?> points = [];
  double opacity = 1.0;
  StrokeCap strokeType = StrokeCap.round;
  double strokeWidth = 3.0;
  Color selectedColor = Colors.black;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    boardWidth = screenSize.width;
    boardHeight = boardWidth * boardRatio;
    return Scaffold(
      backgroundColor: Colors.white70,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
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
                            child: Stack(
                              children: _boardWidgets,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8.0),
                    child: drawToolWidget(),
                  )),
                ],
              ),
            ),
            _actionBar()
          ],
        ),
      ),
    );
  }

  /**
   * Bottom toolbar
   */
  Widget _actionBar() {
    List<Widget> list = [];
    list.add(_actionButton(ActionItem.textItem, (isSelected) {}));
    list.add(_actionButton(ActionItem.imageItem, (isSelected) {
      _pickImage();
    }));
    list.add(_actionButton(ActionItem.stickerItem, (isSelected) {}));
    list.add(_actionButton(ActionItem.drawItem, (isSelected) {
      if (isSelected) {
        _selectedItem = BoardItem.none;
        _boardWidgets = mapBoardWidgets(_boardItems);
      }
    }));
    return Container(
      color: Colors.white,
      height: 80,
      child: Row(
        children: list,
      ),
    );
  }

  Widget _actionButton(
    ActionItem item,
    Function(bool isSelected) callback,
  ) {
    Color iconColor = (_currentAction == item) ? Colors.blue : Colors.black;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          IconButton(
            icon: Icon(item.icon),
            color: iconColor,
            onPressed: () {
              setState(() {
                if (item.selectable) {
                  callback(_currentAction != item);
                  if (_currentAction != item) {
                    _currentAction = item;
                  } else {
                    _currentAction = ActionItem.none;
                  }
                  return;
                }
                _currentAction = item;
                callback(true);
              });
            },
          ),
          Text(
            item.text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /**
   * Image
   */
  List<Widget> mapBoardWidgets(List<BoardItem> items) {
    items.sort((a, b) => a.lastUpdate.compareTo(b.lastUpdate));
    var list = items.map((e) {
      if (e.file != null) {
        if (e.equal(_selectedItem)) {
          return animatedImageWidget(e);
        }
        return positionedImageWidget(e);
      }
      return const Text('error item');
    }).toList();
    return list;
  }

  Widget positionedImageWidget(BoardItem item) {
    return Transform(
      transform: item.notifier.value,
      child: Container(
        margin: const EdgeInsets.all(5.0),
        child: Container(
          child: imageWidget(item),
        ),
      ),
    );
  }

  Widget animatedImageWidget(BoardItem item) {
    return AnimatedBuilder(
      animation: item.notifier,
      builder: (ctx, child) {
        return Transform(
          transform: item.notifier.value,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                left: 0,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2)),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2)),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(5.0),
                child: Container(
                  child: imageWidget(item),
                ),
              ),
              // Positioned(
              //     left: 0,
              //     top: 0,
              //     child: Ink(
              //       decoration: const ShapeDecoration(
              //         color: Colors.black,
              //         shape: CircleBorder(),
              //       ),
              //       child: IconButton(
              //         icon: const Icon(Icons.close),
              //         color: Colors.red,
              //         onPressed: () {},
              //       ),
              //     )),
            ],
          ),
        );
      },
    );
  }

  Widget imageWidget(BoardItem item) {
    var imageWidget = Image.file(item.file!, errorBuilder:
        (BuildContext context, Object error, StackTrace? stackTrace) {
      return const Center(
        child: Text('This image type is not supported'),
      );
    });
    return GestureDetector(
      child: imageWidget,
      onTapUp: (detail) {},
      onTap: () {
        setState(() {
          item.lastUpdate = DateTime.now().millisecondsSinceEpoch;
          _currentAction = ActionItem.imageItem;
          _selectedItem = item;
          _boardWidgets = mapBoardWidgets(_boardItems);
        });
      },
      onTapDown: (detail) {},
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 4000,
        maxHeight: 4000,
        imageQuality: 100,
      );
      setState(() {
        int index = _boardItems.length;
        var item = BoardItem(
          index,
          file: File(pickedFile!.path!),
        );
        _selectedItem = item;
        _boardItems.add(item);
        setState(() {
          _boardWidgets = mapBoardWidgets(_boardItems);
        });
      });
    } catch (e) {
      setState(() {});
    }
  }

  /**
   * Draw
   */
  Widget drawToolWidget() {
    if (_currentAction != ActionItem.drawItem) {
      return const SizedBox();
    }
    return Column(
      children: [
        Row(
          children: [
            IconButton(
                icon: const Icon(Icons.undo),
                onPressed: () {
                  //TODO: undo
                }),
          ],
        ),
        Row(
          children: [
            colorButton(Colors.black),
            colorButton(Colors.red),
            colorButton(Colors.blue),
            colorButton(Colors.green),
            colorButton(Colors.yellow),
            colorButton(Colors.purple),
          ],
        ),
      ],
    );
  }

  Widget colorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        child: Container(
          height: 36,
          width: 36,
          color: color,
        ),
      ),
    );
  }

  Widget drawWidget() {
    var repaintWidget = RepaintBoundary(
      key: globalKey,
      child: Stack(
        children: <Widget>[
          CustomPaint(
            size: Size.infinite,
            painter: MyPainter(
              pointsList: points,
            ),
          ),
        ],
      ),
    );
    if (_currentAction != ActionItem.drawItem) {
      return repaintWidget;
    }
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          RenderBox renderBox = context.findRenderObject()! as RenderBox;
          points.add(TouchPoints(
              points: renderBox.globalToLocal(details.globalPosition),
              paint: Paint()
                ..strokeCap = strokeType
                ..isAntiAlias = true
                ..color = selectedColor.withOpacity(opacity)
                ..strokeWidth = strokeWidth));
        });
      },
      onPanStart: (details) {
        setState(() {
          RenderBox renderBox = context.findRenderObject()! as RenderBox;
          points.add(TouchPoints(
              points: renderBox.globalToLocal(details.globalPosition),
              paint: Paint()
                ..strokeCap = strokeType
                ..isAntiAlias = true
                ..color = selectedColor.withOpacity(opacity)
                ..strokeWidth = strokeWidth));
        });
      },
      onPanEnd: (details) {
        setState(() {
          points.add(null);
        });
      },
      child: repaintWidget,
    );
  }


}

class BoardItem {
  int id;
  String? assetPath = null;
  File? file = null;
  String? text = null;
  ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
  bool isLockRotate = true;
  bool isLockScale = true;
  bool isLockMove = true;
  int lastUpdate = 0;

  //Matrix4 translationDeltaMatrix = Matrix4.identity();
  //Matrix4 scaleDeltaMatrix = Matrix4.identity();
  //Matrix4 rotationDeltaMatrix = Matrix4.identity();
  Matrix4 matrix = Matrix4.identity();

  BoardItem(this.id,
      {this.file, this.assetPath, this.text, this.lastUpdate = 0});

  bool equal(BoardItem? item) {
    if (item == null) return false;
    return id == item.id;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  static BoardItem none = BoardItem(-1);
}

class ActionItem {
  int id;
  IconData icon;
  String text;
  bool selectable = false;

  ActionItem(this.id, this.icon, this.text, {this.selectable = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActionItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  static ActionItem none = ActionItem(-1, Icons.abc, 'none');

  static ActionItem textItem = ActionItem(1, Icons.abc, 'text');

  static ActionItem imageItem = ActionItem(2, Icons.image, 'image');

  static ActionItem stickerItem =
      ActionItem(3, Icons.emoji_emotions, 'sticker');

  static ActionItem drawItem =
      ActionItem(4, Icons.draw, 'draw', selectable: true);
}
