import 'dart:io';

import 'package:board/res/color.dart';
import 'package:board/ui/board_background.dart';
import 'package:board/ui/board_stickers.dart';
import 'package:board/ui/board_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../util/asset.dart';
import '../../util/color.dart';
import '../widget/draw.dart';
import '../widget/gesture_detector.dart';
import 'board_model.dart';
import 'board_widget.dart';

class BoardPage extends StatefulWidget {
  BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> with TickerProviderStateMixin {
  final List<BoardItem> _boardItems = [];
  String? _boardImage;
  String? _boardColor;
  List<Widget> _boardWidgets = [];
  late Size _screenSize;
  double _boardWidth = 0;
  double _boardHeight = 0;
  final double _boardRatio = 3 / 4;
  bool isFold = false;
  late Widget layout;
  late AnimationController animationController;
  BoardItem _selectedItem = BoardItem.none;
  ActionItem _selectedAction = ActionItem.none;

  Color _selectedDrawColor = Colors.black;
  Color _selectedTextColor = Colors.black;
  final List<Color> _colorList = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple
  ];
  final DrawController _drawController = DrawController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
    exportPenColor: Colors.black,
  );

  void _clearPaint() {
    _drawController.clear();
  }

  @override
  void initState() {
    super.initState();
    _drawController.addListener(() => {});
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    _drawController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateSize();
  }

  @override
  Widget build(BuildContext context) {
    updateSize();
    _drawController.onDrawEnd = () => {_onDrawEnd()};
    updateSize();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Board")),
      body: SafeArea(
        child: layout,
      ),
    );
  }

  void updateSize() {
    _screenSize = MediaQuery.of(context).size;

    debugPrint('board_app width: ${_screenSize.width}');
    debugPrint('board_app height: ${_screenSize.height}');
    var phoneRatio = 10 / 16;
    var deviceRatio = _screenSize.width / _screenSize.height;
    //isFold = phoneRatio <= deviceRatio;
    if (isFold) {
      _boardWidth = _screenSize.width * _boardRatio;
      _boardHeight = _screenSize.height;
      layout = tabletLayout();
    } else {
      _boardWidth = _screenSize.width;
      _boardHeight = _screenSize.width / _boardRatio;
      layout = phoneLayout();
    }
  }



  Widget phoneLayout() {
    return Stack(
      children: [
        boardBackground(),
        Column(
          children: [
            SizedBox(
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
            Container(width: double.infinity, height: 1, color: ColorRes.text),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                //padding: const EdgeInsets.symmetric(horizontal:4.0,vertical: 2.0),
                child: Column(
                  children: [
                    boardBackgroundButton(),
                    _dynamicToolWidget(),
                  ],
                ),
              ),
            ),
            Container(width: double.infinity, height: 1, color: ColorRes.text),
            _actionBar()
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          child: _actionDrawWidget(),
        ),
      ],
    );
  }

  Widget tabletLayout() {
    return Row(
      children: [
        Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: boardBackground(),
            ),
            Container(
              height: double.infinity,
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
          ],
        ),
        Container(
          height: double.infinity,
          width: 2,
          color: Colors.grey,
        ),
        Expanded(
          child: Column(
            children: [
              _actionBar(),
              _dynamicToolWidget(),
            ],
          ),
        )
      ],
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
    if (isFold) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list,
      );
    }
    return Container(
      color: Colors.white,
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        : Colors.grey;
    if (isFold) {
      return Row(
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
          Expanded(
            child: Text(
              item.text,
              style: TextStyle(
                color: iconColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        ],
      );
    }
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

  Widget removeButton() {
    return imageButton(
        icon: Icons.delete,
        onPressed: () {
          _boardItems.removeWhere((element) => element == _selectedItem);
          setState(() {
            _syncMapWidget();
          });
        });
  }

  Widget bringToFrontButton() {
    return imageButton(
        icon: Icons.arrow_upward,
        onPressed: () {
          var item = _selectedItem;
          int index =
              _boardItems.indexWhere((element) => element == _selectedItem);
          int nextIndex = index + 1;
          if (index >= 0 && nextIndex < _boardItems.length) {
            var nextItem = _boardItems[nextIndex];
            int tempId = item.lastUpdate;
            item.lastUpdate = nextItem.lastUpdate;
            nextItem.lastUpdate = tempId;
          }
          setState(() {
            _boardWidgets = _mapBoardWidgets(_boardItems);
          });
        });
  }

  Widget putToBackButton() {
    return imageButton(
        icon: Icons.arrow_downward,
        onPressed: () {
          var item = _selectedItem;
          int index =
              _boardItems.indexWhere((element) => element == _selectedItem);
          int prevIndex = index - 1;
          if (index >= 0 && prevIndex < _boardItems.length) {
            var prevItem = _boardItems[prevIndex];
            int tempId = item.lastUpdate;
            item.lastUpdate = prevItem.lastUpdate;
            prevItem.lastUpdate = tempId;
          }
          setState(() {
            _boardWidgets = _mapBoardWidgets(_boardItems);
          });
        });
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

  EdgeInsets boardItemMargin() {
    return const EdgeInsets.all(4.0);
  }

  Widget boardBackgroundButton() {
    return imageButton(
        icon: Icons.aspect_ratio,
        onPressed: () {
          _pickBackground();
        });
  }

  Future<void> _pickBackground() async {
    final Map<String, dynamic>? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BackgroundPage(),
        fullscreenDialog: true,
      ),
    );
    if (result == null) return;
    String? image = result['image'];
    if (image?.isNotEmpty ?? false) {
      setState(() {
        _boardImage = image;
        _boardColor = '';
      });
    }
    String? color = result['color'];
    if (color?.isNotEmpty ?? false) {
      setState(() {
        _boardColor = color;
        _boardImage = '';
      });
    }
  }

  Widget boardBackground() {
    Widget backgroundWidget;
    if (_boardImage?.isNotEmpty ?? false) {
      backgroundWidget = Image.asset(
        boardPath(_boardImage!),
        fit: BoxFit.cover,
      );
    } else if (_boardColor?.isNotEmpty ?? false) {
      backgroundWidget = Container(
        color: fromHex(_boardColor!),
      );
    } else {
      backgroundWidget = Container(color: Colors.white);
    }
    return SizedBox(
      width: _boardWidth,
      height: _boardHeight,
      child: backgroundWidget,
    );
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
        margin: boardItemMargin(),
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
              boardItemBorder(),
              Container(
                margin: boardItemMargin(),
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
            removeButton(),
            imageButton(
                icon: Icons.edit,
                onPressed: () {
                  _pickText(_selectedItem);
                }),
            bringToFrontButton(),
            putToBackButton(),
          ],
        ),
        _colorPickerWidget((color) {
          setState(() {
            if (_selectedItem.isTextItem) {
              _selectedItem.textColor = color;
              _syncMapWidget();
            }
          });
        }),
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
        margin: boardItemMargin(),
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
              boardItemBorder(),
              Container(
                margin: boardItemMargin(),
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
            removeButton(),
            bringToFrontButton(),
            putToBackButton(),
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

    String? sticker = result?['sticker'];
    if (sticker?.isEmpty ?? true) return;

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
            imageButton(
                icon: Icons.undo,
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
        _colorPickerWidget((color) {
          setState(() {
            _selectedDrawColor = color;
            _drawController.penColor = color;
          });
        }),
      ],
    );
  }

  Widget _colorPickerWidget(Function(Color) onTap) {
    return SizedBox(
      height: 38,
      width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 0, right: 0),
        itemCount: _colorList.length,
        itemBuilder: (context, index) {
          var color = _colorList[index];
          return imageButton(
              backgroundColor: color,
              onPressed: () {
                onTap(color);
              });
        },
      ),
    );
  }

  Widget _actionDrawWidget() {
    if (_selectedAction != ActionItem.drawItem) {
      return const SizedBox(width: 0.0, height: 0.0);
    }
    return DrawWidget(
      key: const Key('signature'),
      height: _boardHeight,
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
}

