import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  double defaultSize = 120;
  late AnimationController controller;
  late Animation<Alignment> focalPointAnimation;
  Alignment focalPoint = Alignment.center;
  var currentItemIndex = 0;
  Widget gestureDetectorWidget = Container();

  BoardItem? _selectedItem;
  ToolbarItem? _currentTool;

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
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      color: Colors.black,
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
                                if (_selectedItem == null) {
                                  return;
                                }
                                if (_selectedItem!.id != state.id) {
                                  state.id = _selectedItem!.id!;
                                  //state.reset();
                                  state.update(_selectedItem!.matrix);
                                  return;
                                }
                                _selectedItem?.matrix = matrix;
                                _selectedItem?.notifier.value = matrix;
                              },
                              child: Stack(
                                children: _boardWidgets,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              _toolbar()
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> mapBoardWidgets(List<BoardItem> items) {
    return items.map((e) {
      if (e.file != null) {
        if (e.equal(_selectedItem)) {
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
        _selectedItem = item;
        setState(() {
          _boardWidgets = mapBoardWidgets(_boardItems);
        });
      },
      onTapDown: (detail) {},
    );
  }

  /**
   * Bottom toolbar
   */
  Widget _toolbar() {
    return Container(
      color: Colors.white,
      height: 80,
      child: Row(
        children: toolbarButtons(),
      ),
    );
  }

  List<Widget> toolbarButtons() {
    List<Widget> list = [];
    list.add(_toolbarButton(ToolbarItem.textItem, () {}));
    list.add(_toolbarButton(ToolbarItem.imageItem, () {
      _pickImage();
    }));
    list.add(_toolbarButton(ToolbarItem.stickerItem, () {}));
    list.add(_toolbarButton(ToolbarItem.drawItem, () {}));
    return list;
  }

  Widget _toolbarButton(
    ToolbarItem item,
    VoidCallback callback,
  ) {
    Color iconColor = (_currentTool == item) ? Colors.blue : Colors.black;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          IconButton(
            icon: Icon(item.icon),
            color: iconColor,
            onPressed: () {
              setState(() {
                if (_currentTool != item) {
                  _currentTool = item;
                } else {
                  _currentTool = null;
                }
              });
              callback();
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

  //Matrix4 translationDeltaMatrix = Matrix4.identity();
  //Matrix4 scaleDeltaMatrix = Matrix4.identity();
  //Matrix4 rotationDeltaMatrix = Matrix4.identity();
  Matrix4 matrix = Matrix4.identity();

  BoardItem(this.id, {this.file, this.assetPath, this.text});

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
}

class ToolbarItem {
  int id;
  IconData icon;
  String text;

  ToolbarItem(this.id, this.icon, this.text);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ToolbarItem &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  static ToolbarItem textItem = ToolbarItem(1, Icons.abc, 'text');

  static ToolbarItem imageItem = ToolbarItem(2, Icons.image, 'image');

  static ToolbarItem stickerItem = ToolbarItem(3, Icons.emoji_emotions, 'sticker');

  static ToolbarItem drawItem = ToolbarItem(4, Icons.draw, 'draw');
}
