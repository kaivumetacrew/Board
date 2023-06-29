import 'dart:io';

import 'package:board/res/color.dart';
import 'package:board/ui/board_text.dart';
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
  ActionItem _selectedAction = ActionItem.none;

  GlobalKey globalKey = GlobalKey();
  List<TouchPoints?> points = [];
  double opacity = 1.0;
  StrokeCap strokeType = StrokeCap.round;
  String selectedFont = '';
  double strokeWidth = 3.0;
  Color selectedColor = Colors.black;
  List<Color> colorList = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple
  ];

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
      backgroundColor: Colors.white,
      appBar:  AppBar(title: const Text("Board")),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
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
                          if (_selectedAction != ActionItem.imageItem &&
                              _selectedAction != ActionItem.textItem) {
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
                  ),
                ),
                Container(
                    width: double.infinity, height: 1, color: ColorRes.text),
                Expanded(
                    child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(4.0),
                  child: _toolWidget(),
                )),
                Container(
                    width: double.infinity, height: 1, color: ColorRes.text),
                _actionBar()
              ],
            ),
            _actionDrawWidget(),
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
    list.add(_actionButton(ActionItem.textItem, (isSelected) async {
      pickText();
    }));
    list.add(_actionButton(ActionItem.imageItem, (isSelected) {
      _pickImage();
    }));
    list.add(_actionButton(ActionItem.stickerItem, (isSelected) {}));
    list.add(_actionButton(ActionItem.drawItem, (isSelected) {
      if (isSelected) {
        _selectedItem = BoardItem.none;
        _syncMapWidget();
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

  Future<void> pickText() async {
    final Map<String, dynamic>? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TextPage(text: ''),
        fullscreenDialog: true,
      ),
    );
    if (result == null) return;
    String text = result['text'];
    String font = result['font'];
    if (text.isEmpty || font.isEmpty) return;
    selectedFont = font;
    var item = BoardItem(_boardItems.length, text: text, font: font);
    item.lastUpdate = DateTime.now().millisecondsSinceEpoch;
    _selectedItem = item;
    _boardItems.add(item);
    _selectedAction = ActionItem.textItem;
    setState(() {
      _syncMapWidget();
    });
  }

  Widget _actionButton(
    ActionItem item,
    Function(bool isSelected) callback,
  ) {
    Color iconColor = (item.selectable && _selectedAction == item)
        ? ColorRes.primary
        : ColorRes.lightGray;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          IconButton(
            icon: Icon(item.icon),
            color: iconColor,
            onPressed: () {
              setState(() {
                if (!item.selectable) {
                  _selectedAction = ActionItem.none;
                  callback(false);
                  return;
                }
                if (_selectedAction != item) {
                  _selectedAction = item;
                  callback(true);
                  return;
                }
                _selectedAction = ActionItem.none;
                callback(false);
              });
            },
          ),
          Text(
            item.text,
            style:  TextStyle(
              color: iconColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /**
   *
   */
  Widget _toolWidget() {
    if (_selectedAction == ActionItem.textItem) {
      return _textToolWidget();
    }
    if (_selectedAction == ActionItem.imageItem) {
      return _imageToolWidget();
    }
    if (_selectedAction == ActionItem.drawItem) {
      return _drawToolWidget();
    }
    return const SizedBox();
  }

  /**
   *
   */
  void _syncMapWidget() {
    _boardWidgets = _mapBoardWidgets(_boardItems);
  }

  List<Widget> _mapBoardWidgets(List<BoardItem> items) {
    items.sort((a, b) => a.lastUpdate.compareTo(b.lastUpdate));
    var list = items.map((e) {
      if (e.isTextItem) {
        if (e.equal(_selectedItem)) {
          return _animatedTextWidget(e);
        }
        return _positionedTextWidget(e);
      }
      if (e.isImageItem) {
        if (e.equal(_selectedItem)) {
          return _animatedImageWidget(e);
        }
        return _positionedImageWidget(e);
      }
      if (e.isDrawItem) {
        return _drawPointWidget(e.points);
      }
      return const Text('error item');
    }).toList();
    return list;
  }

  /**
   * Text
   */
  Widget _positionedTextWidget(BoardItem item) {
    return Transform(
      transform: item.notifier.value,
      child: Container(
        margin: const EdgeInsets.all(5.0),
        child: Container(
          child: _textWidget(item),
        ),
      ),
    );
  }

  Widget _animatedTextWidget(BoardItem item) {
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
                      border: Border.all(color: Colors.black, width: 1)),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1)),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(5.0),
                child: Container(
                  child: _textWidget(item),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _textWidget(BoardItem item) {
    var textWidget = Text(
      item.text!,
      style: TextStyle(fontFamily: item.font, color: item.color, fontSize: 48),
    );
    return GestureDetector(
      child: textWidget,
      onTap: () {
        _selectedAction = ActionItem.textItem;
        _selectedItem = item;
        setState(() {
          debugPrint("onTap text item${item.id}");
          //item.lastUpdate = DateTime.now().millisecondsSinceEpoch;
          _syncMapWidget();
        });
      },
    );
  }

  Widget _textToolWidget() {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _boardItems
                      .removeWhere((element) => element == _selectedItem);
                  setState(() {
                    _syncMapWidget();
                  });
                }),
          ],
        ),
        SizedBox(
          height: 40,
          width: double.infinity,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            controller: colorListScrollCtrl,
            shrinkWrap: true,
            padding: const EdgeInsets.only(left: 0, right: 0),
            itemCount: colorList.length,
            itemBuilder: (context, index) {
              var color = colorList[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selectedItem.isTextItem) {
                      _selectedItem.color = color;
                      _syncMapWidget();
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 2.0),
                  child: Container(
                    height: 36,
                    width: 36,
                    color: color,
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  /**
   * Image
   */
  Widget _positionedImageWidget(BoardItem item) {
    return Transform(
      transform: item.notifier.value,
      child: Container(
        margin: const EdgeInsets.all(5.0),
        child: Container(
          child: _imageWidget(item),
        ),
      ),
    );
  }

  Widget _animatedImageWidget(BoardItem item) {
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
                      border: Border.all(color: Colors.black, width: 1)),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1)),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(5.0),
                child: Container(
                  child: _imageWidget(item),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _imageWidget(BoardItem item) {
    var imageWidget = Image.file(item.file!, errorBuilder:
        (BuildContext context, Object error, StackTrace? stackTrace) {
      return const Center(
        child: Text('This image type is not supported'),
      );
    });
    return GestureDetector(
      child: imageWidget,
      onTap: () {
        _selectedAction = ActionItem.imageItem;
        _selectedItem = item;
        setState(() {
          debugPrint("onTap image item ${item.id}");
          //item.lastUpdate = DateTime.now().millisecondsSinceEpoch;
          _syncMapWidget();
        });
      },
    );
  }

  Widget _imageToolWidget() {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _boardItems
                      .removeWhere((element) => element == _selectedItem);
                  setState(() {
                    _syncMapWidget();
                  });
                }),
            IconButton(
                icon: const Icon(Icons.arrow_upward),
                onPressed: () {
                  // if (_currentAction != ActionItem.imageItem ||
                  //     _selectedItem == BoardItem.none) {
                  //   return;
                  // }
                  // var item = _selectedItem;
                  // int index = _boardItems.indexWhere((element) => element == _selectedItem);
                  // int nextIndex = index + 1;
                  // if (index >= 0 && nextIndex < _boardItems.length) {
                  //   var nextItem = _boardItems[nextIndex];
                  //   int tempId = item.lastUpdate;
                  //   item.lastUpdate = nextItem.lastUpdate;
                  //   nextItem.lastUpdate = tempId;
                  // }
                  // setState(() {
                  //   _boardWidgets = _mapBoardWidgets(_boardItems);
                  // });
                }),
            IconButton(
                icon: const Icon(Icons.arrow_downward), onPressed: () {}),
          ],
        ),
      ],
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
      var item = BoardItem(
        _boardItems.length,
        file: File(pickedFile!.path!),
      );
      item.lastUpdate = DateTime.now().millisecondsSinceEpoch;
      _selectedItem = item;
      _boardItems.add(item);
      _selectedAction = ActionItem.imageItem;
      setState(() {
        _syncMapWidget();
      });
    } catch (e) {
      setState(() {});
    }
  }

  /**
   * Draw
   */
  final ScrollController colorListScrollCtrl = ScrollController();

  Widget _drawPointWidget(List<TouchPoints?> points) {
    return Container(
      color: const Color.fromARGB(100, 163, 93, 65),
      child: CustomPaint(
        painter: MyPainter(
          pointsList: points,
        ),
      ),
    );
  }

  Widget _drawToolWidget() {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
                icon: const Icon(Icons.undo),
                onPressed: () {
                  var item = _boardItems.reversed
                      .firstWhere((element) => element.points.isNotEmpty);
                  _boardItems.removeWhere((element) => element.id == item.id);
                  setState(() {
                    _syncMapWidget();
                  });
                }),
          ],
        ),
        SizedBox(
          height: 40,
          width: double.infinity,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            controller: colorListScrollCtrl,
            shrinkWrap: true,
            padding: const EdgeInsets.only(left: 0, right: 0),
            itemCount: colorList.length,
            itemBuilder: (context, index) {
              var color = colorList[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedColor = color;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 2.0),
                  child: Container(
                    height: 36,
                    width: 36,
                    color: color,
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _actionDrawWidget() {
    if (_selectedAction != ActionItem.drawItem) {
      return const SizedBox(width: 0.0, height: 0.0);
    }

    var repaintBound= RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: MyPainter(
          pointsList: points,
        ),
      ),
    );
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
          var item = BoardItem(_boardItems.length);
          item.lastUpdate = DateTime.now().millisecondsSinceEpoch;
          item.points = points;
          points = [];
          _boardItems.add(item);
          _syncMapWidget();
        });
      },
      child: SizedBox(
        width: double.infinity,
        child: AspectRatio(
            aspectRatio: 1 / boardRatio,
            child: repaintBound
        ),
      ),
    );

  }

/**
 *
 */
}

class BoardItem {
  int id;
  String? assetPath = null;
  File? file = null;
  String? text = null;
  String? font = null;
  Color color = Colors.black;
  ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
  bool isLockRotate = true;
  bool isLockScale = true;
  bool isLockMove = true;
  int lastUpdate = 0;
  List<TouchPoints?> points = [];

  //Matrix4 translationDeltaMatrix = Matrix4.identity();
  //Matrix4 scaleDeltaMatrix = Matrix4.identity();
  //Matrix4 rotationDeltaMatrix = Matrix4.identity();
  Matrix4 matrix = Matrix4.identity();

  BoardItem(this.id,
      {this.file, this.assetPath, this.text, this.font, this.lastUpdate = 0});

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

  bool get isTextItem => text != null && text!.isNotEmpty;

  bool get isImageItem => file != null;

  bool get isDrawItem => points.isNotEmpty;
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
