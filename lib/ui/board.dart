import 'dart:io';

import 'package:board/res/color.dart';
import 'package:board/ui/board_text.dart';
import 'package:board/ui/stickers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../util/asset.dart';
import '../util/gesture_detector.dart';
import 'board_model.dart';
import 'widget/draw.dart';

class BoardPage extends StatefulWidget {
  BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> with TickerProviderStateMixin {

  final List<BoardItem> _boardItems = [];
  List<Widget> _boardWidgets = [];
  late Size screenSize;

  double boardWidth = 0;
  double boardHeight = 0;
  double boardRatio = 4 / 3;
  Alignment focalPoint = Alignment.center;
  late AnimationController animationController;
  BoardItem _selectedItem = BoardItem.none;
  ActionItem _selectedAction = ActionItem.none;

  double opacity = 1.0;
  StrokeCap strokeType = StrokeCap.round;
  String _selectedFont = '';
  double _strokeWidth = 3.0;
  Color _selectedDrawColor = Colors.black;
  Color _selectedTextColor = Colors.black;
  List<Color> _colorList = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple
  ];

  void _clearPaint() {
    _drawController.clear();
  }

  final DrawController _drawController = DrawController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
    exportPenColor: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    _drawController.addListener(() => {});
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _drawController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    boardWidth = screenSize.width;
    boardHeight = boardWidth * boardRatio;
    _drawController.onDrawEnd = () => {_onDrawEnd()};

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Board")),
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
                  child: _dynamicToolWidget(),
                )),
                Container(
                    width: double.infinity, height: 1, color: ColorRes.text),
                _actionBar()
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              child: _actionDrawWidget(),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom action bar
  Widget _actionBar() {
    List<Widget> list = [];
    list.add(_actionButton(ActionItem.textItem, (isSelected) async {
      _pickText(BoardItem.none);
    }));
    list.add(_actionButton(ActionItem.imageItem, (isSelected) {
      _pickImage();
    }));
    list.add(_actionButton(ActionItem.stickerItem, (isSelected) {
      _pickSticker();
    }));
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

  ///
  Widget _dynamicToolWidget() {
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

  ///
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
      if (e.isImageItem || e.isStickerItem) {
        if (e.equal(_selectedItem)) {
          return _animatedImageWidget(e);
        }
        return _positionedImageWidget(e);
      }
      if (e.isDrawItem) {
        return _drawPointWidget(e);
      }
      return errorImageWidget();
    }).toList();
    return list;
  }

  /// Text
  Future<void> _pickText(BoardItem item) async {
    final Map<String, dynamic>? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TextPage(text: item.text),
        fullscreenDialog: true,
      ),
    );
    if (result == null) return;
    String text = result['text'];
    String font = result['font'];
    if (text.isEmpty || font.isEmpty) return;
    _selectedFont = font;
    if (item == BoardItem.none) {
      var item = BoardItem(_boardItems.length)
        ..text = text
        ..font = font
        ..textColor = _selectedTextColor
        ..lastUpdate = DateTime.now().millisecondsSinceEpoch;

      _boardItems.add(item);
      _selectedItem = item;
    }
    {
      _selectedItem.text = text;
    }
    _selectedAction = ActionItem.textItem;
    setState(() {
      _syncMapWidget();
    });
  }

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
      style:
          TextStyle(fontFamily: item.font, color: item.textColor, fontSize: 48),
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
            IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _pickText(_selectedItem);
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
            itemCount: _colorList.length,
            itemBuilder: (context, index) {
              var color = _colorList[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selectedItem.isTextItem) {
                      _selectedItem.textColor = color;
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

  /// Image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 4000,
        maxHeight: 4000,
        imageQuality: 100,
      );
      var item = BoardItem(_boardItems.length)
        ..file = File(pickedFile!.path!)
        ..lastUpdate = DateTime.now().millisecondsSinceEpoch;

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
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _imageWidget(BoardItem item) {
    Widget imageWidget;
    if (item.isImageItem) {
      imageWidget = Image.file(item.file!, errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
        return errorImageWidget(message: 'This image error');
      });
    } else if (item.isStickerItem) {
      imageWidget = Image.asset(imagePath(item.sticker!), errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
        return errorImageWidget(message: 'This image error');
      });
    } else {
      return errorImageWidget();
    }

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

  /// Sticker
  Future<void> _pickSticker() async {
    final Map<String, dynamic>? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StickerPage(),
        fullscreenDialog: true,
      ),
    );
    if (result == null) return;
    String sticker = result['sticker'];
    if (sticker.isEmpty) return;

    var item = BoardItem(_boardItems.length)
      ..sticker = sticker
      ..lastUpdate = DateTime.now().millisecondsSinceEpoch;
    _boardItems.add(item);
    _selectedItem = item;
    _selectedAction = ActionItem.imageItem;
    setState(() {
      _syncMapWidget();
    });
  }

  /// Draw
  final ScrollController colorListScrollCtrl = ScrollController();

  Widget _drawPointWidget(BoardItem item) {
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
            itemCount: _colorList.length,
            itemBuilder: (context, index) {
              var color = _colorList[index];
              return _drawToolColorWidget(color);
            },
          ),
        )
      ],
    );
  }

  Widget _drawToolColorWidget(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDrawColor = color;
          _drawController.penColor = color;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        child: Container(
          height: 36,
          width: 36,
          color: color,
        ),
      ),
    );
  }

  Widget _actionDrawWidget() {
    if (_selectedAction != ActionItem.drawItem) {
      return const SizedBox(width: 0.0, height: 0.0);
    }
    return DrawWidget(
      key: const Key('signature'),
      height: screenSize.width * boardRatio,
      controller: _drawController,
      backgroundColor: Colors.yellow,
    );
  }

  void _onDrawEnd() {
    var item = BoardItem(_boardItems.length)
      ..strokeColor = _selectedDrawColor
      ..lastUpdate = DateTime.now().millisecondsSinceEpoch
      ..points = _drawController.points;

    _drawController.clear();
    _boardItems.add(item);
    setState(() {
      _syncMapWidget();
    });
  }

/**
 *
 */
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
