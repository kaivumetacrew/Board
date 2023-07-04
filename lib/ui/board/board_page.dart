import 'dart:io';
import 'dart:typed_data';

import 'package:board/util/file.dart';
import 'package:board/util/state.dart';
import 'package:board/util/string.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../util/widget.dart';
import '../board_background.dart';
import '../board_stickers.dart';
import 'board_actionbar.dart';
import 'board_controller.dart';
import 'board_model.dart';
import 'board_view.dart';
import 'board_widget.dart';

class BoardPage extends StatefulWidget {
  BoardData board;

  BoardPage({
    super.key,
    required this.board,
  });

  @override
  State<BoardPage> createState() => BoardPageState();
}

class BoardPageState extends State<BoardPage> with TickerProviderStateMixin {
  double _boardFoldedDipWidth = 0;
  double _boardBottom = 1;
  double _boardRight = 1;
  double _boardScale = 1;
  bool _isPortrait = true;

  final GlobalKey _widgetKey = GlobalKey();
  ScreenshotController screenshotController = ScreenshotController();
  final BoardController _boardController = BoardController([]);
  final ActionBarController _actionBarController =
      ActionBarController(ActionItem.none);

  BoardPageState();

  @override
  void initState() {
    super.initState();
    lockPortrait();
    final board = widget.board;
    _boardController
      ..items = board.items
      ..boardColor = board.color
      ..boardImage = board.image
      ..onItemTap = (item) {
        if (item.isNone) {
          _boardController.deselectItem();
        } else {
          _actionBarController.value = ActionItem.mapFormBoardItem(item);
        }
      };
  }

  @override
  void dispose() {
    super.dispose();
    _actionBarController.dispose();
    _boardController.dispose();
  }

  @override
  void didUpdateWidget(covariant BoardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateScreenArgs();
  }

  @override
  Widget build(BuildContext context) {
    _updateScreenArgs();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.board.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _boardController.deselectItem();
              showSnackBar('saved');
              saveBoard().then((value) {
                Navigator.pop(context);
              });
            },
          ),
        ],
      ),
      body: SafeArea(child: _content()),
    );
  }

  Widget _content() {
    if (_isPortrait) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _boardView(),
          _boardScaleExpand(),
          separator(axis: Axis.vertical),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: Stack(
                children: [
                  _backgroundButton(),
                  _dynamicToolWidget(),
                ],
              ),
            ),
          ),
          separator(axis: Axis.vertical),
          _actionBar()
        ],
      );
    }
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _boardView(),
              _boardScaleExpand(),
              separator(axis: Axis.horizontal),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: Stack(
                    children: [
                      _backgroundButton(),
                      _dynamicToolWidget(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        separator(axis: Axis.vertical),
        _actionBar()
      ],
    );
  }

  void _updateScreenArgs() {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidthDip = screenSize.width;
    double minRatio = 10 / 16;
    double screenRatio = screenSize.width / screenSize.height;
    _isPortrait = minRatio > screenRatio;
    if (_isPortrait) {
      double boardWidthDip = pixelToDip(BoardView.widthPx);
      // if (boardWidthDip > screenWidthDip) {
      //   boardWidthDip = screenWidthDip;
      // }
      double boardHeightDip = boardWidthDip / BoardView.ratio;
      _boardScale = screenWidthDip / boardWidthDip;
      _boardBottom = ((boardHeightDip * _boardScale) - boardHeightDip);
      debugPrint('_boardBottom: $_boardBottom');
    }
  }

  void _updateFoldScreenArgs(Size correctBoardSize) {
    double boardWidthDip = pixelToDip(BoardView.widthPx);
    _boardFoldedDipWidth = correctBoardSize.height * BoardView.ratio;
    _boardScale = _boardFoldedDipWidth / boardWidthDip;
    if (_boardScale >= 1) {
      _boardRight = ((boardWidthDip * _boardScale) - boardWidthDip);
    }

    debugPrint('_boardRight: $_boardRight');
  }

  Widget _boardScaleExpand() {
    if (_isPortrait) {
      return Container(
        width: double.infinity,
        height: _boardBottom,
        //color: Colors.black12,
      );
    }
    return Container(
      width: _boardRight,
      height: double.infinity,
      //color: Colors.black12,
    );
  }

  /// Transform BoardView to fit screen
  Widget _boardView() {
    if (_isPortrait) {
      // ui for portrait layout
      _boardFoldedDipWidth = 0;
      return _transformBoardView();
    }
    // ui for fold layout
    if (_boardFoldedDipWidth > 0) {
      return _transformBoardView();
    }
    return WidgetSizeOffsetWrapper(
      onSizeChange: (Size size) {
        if (_boardFoldedDipWidth == 0) {
          setState(() {
            _updateFoldScreenArgs(size);
          });
        }
      },
      child: Container(key: _widgetKey),
    );
  }

  Widget _transformBoardView() {
    return Transform.scale(
      scale: _boardScale,
      alignment: Alignment.topLeft,
      child: Screenshot(
        controller: screenshotController,
        child: BoardView(
          data: widget.board,
          controller: _boardController,
        ),
      ),
    );
  }

  Widget _removeButton() {
    return imageButton(
        icon: Icons.delete,
        onPressed: () {
          _boardController.removeSelectedItem();
        });
  }

  Widget _bringToFrontButton() {
    return imageButton(
        icon: Icons.arrow_upward,
        onPressed: () {
          _boardController.bringToFront();
        });
  }

  Widget _putToBackButton() {
    return imageButton(
        icon: Icons.arrow_downward,
        onPressed: () {
          _boardController.putToBackButton();
        });
  }

  Widget _colorPickerWidget() {
    return colorPickerWidget(
        isPortrait: _isPortrait,
        onTap: (color) {
          _boardController.setColor(color);
        });
  }

  Widget _dynamicToolWidget() {
    return ValueListenableBuilder(
      valueListenable: _actionBarController,
      builder: (
        BuildContext context,
        ActionItem value,
        Widget? child,
      ) {
        if (value == ActionItem.textItem) {
          return _textToolWidget();
        }
        if (value == ActionItem.imageItem || value == ActionItem.stickerItem) {
          return _imageToolWidget();
        }
        if (value == ActionItem.drawItem) {
          return _drawToolWidget();
        }
        return const SizedBox();
      },
    );
  }

  Widget _backgroundButton() {
    return RowIfPortraitElseCol(
      isPortrait: _isPortrait,
      children: [
        const Expanded(child: SizedBox()),
        imageButton(
            icon: Icons.aspect_ratio,
            onPressed: () {
              _pickBackground();
            }),
      ],
    );
  }

  Future<void> _pickBackground() async {
    Map<String, dynamic>? result =
        await push(BackgroundPage(), fullscreenDialog: true);
    if (result == null) return;
    String? image = result['image'];
    if (!image.isNullOrEmpty) {
      _boardController.setBackgroundImage(image!);
      return;
    }
    String? color = result['color'];
    if (!color.isNullOrEmpty) {
      _boardController.setBackgroundColor(color!);
      return;
    }
  }

  /// Text
  Widget _textToolWidget() {
    return ColumnIfPortraitElseRow(
      isPortrait: _isPortrait,
      children: [
        RowIfPortraitElseCol(
          isPortrait: _isPortrait,
          children: [
            _removeButton(),
            imageButton(
                icon: Icons.edit,
                onPressed: () {
                  _pickText(_boardController.selectedItem);
                }),
            _bringToFrontButton(),
            _putToBackButton(),
          ],
        ),
        _colorPickerWidget(),
      ],
    );
  }

  Future<void> _pickText(BoardItem selectedItem) async {
    pickText(
      currentText: selectedItem.text!,
      onResult: (text, font) {
        if (selectedItem == BoardItem.none) {
          _boardController.addNewItem((item) {
            item.text = text;
            item.font = font;
          });
        } else {
          selectedItem.text = text;
          _boardController.notifyListeners();
        }
        _actionBarController.value = ActionItem.textItem;
      },
    );
  }

  /// Image
  Future<void> _pickGalleryImage() async {
    final file = await pickImage();
    if (file == null) return;
    _boardController.addNewItem((item) {
      item.storageImagePath = file.path;
    });
    _actionBarController.value = ActionItem.imageItem;
  }

  Future<void> _pickStickerImage() async {
    Map<String, dynamic>? result =
        await push(StickerPage(), fullscreenDialog: true);
    String? sticker = result?['sticker'];
    if (sticker.isNullOrEmpty) return;
    _boardController.addNewItem((item) {
      item.sticker = sticker;
    });
    _actionBarController.value = ActionItem.stickerItem;
  }

  Widget _imageToolWidget() {
    return ColumnIfPortraitElseRow(
      isPortrait: _isPortrait,
      children: [
        RowIfPortraitElseCol(
          isPortrait: _isPortrait,
          children: [
            _removeButton(),
            _bringToFrontButton(),
            _putToBackButton(),
          ],
        ),
      ],
    );
  }

  /// Draw
  Widget _drawToolWidget() {
    return ColumnIfPortraitElseRow(
      isPortrait: _isPortrait,
      children: [
        RowIfPortraitElseCol(
          isPortrait: _isPortrait,
          children: [
            imageButton(
                icon: Icons.undo,
                onPressed: () {
                  _boardController.undoDraw();
                }),
          ],
        ),
        _colorPickerWidget(),
      ],
    );
  }

  /// Bottom action bar
  Widget _actionBar() {
    return ActionBar(
      controller: _actionBarController,
      onItemTap: (item, isSelected) {
        if (item == ActionItem.textItem) {
          _pickText(BoardItem.none);
          return;
        }
        if (item == ActionItem.imageItem) {
          _pickGalleryImage();
          return;
        }
        if (item == ActionItem.stickerItem) {
          _pickStickerImage();
          return;
        }
        if (item == ActionItem.drawItem) {
          if (isSelected) {
            _boardController.deselectItem();
            _boardController.startDraw();
          } else {
            _boardController.stopDraw();
          }
          return;
        }
      },
    );
  }

  Future<bool> saveBoard() async {
    BoardController con = _boardController;
    BoardData board = widget.board;
    Directory packageDir = await getApplicationDocumentsDirectory();
    String packagePath = packageDir.path;
    String boardDir = '$packagePath/boards/${board.id}';
    String thumbPath = '$packagePath/thumbnails/${board.id}.jpg';

    board
      ..color = con.boardColor
      ..image = con.boardImage
      ..items = con.items
      ..thumbnail = thumbPath;

    // Create board thumbnail
    Uint8List? imageBytes = await screenshotController.capture();
    FileHelper.save(thumbPath, imageBytes);

    saveBoardResources(con.items, boardDir);

    await editBoardsData((Box<BoardData> box){
      box.put(board.id.toString(), board);
      debugPrint('box boards values ${box.values.length}');
      for (BoardData element in box.values) {
        debugPrint('box board item instance: ${element.id}');
      }
    });
    return true;
  }


  /// Copy used resources (images..) from storage to package directory
  /// and save resource path for reload saved boards
  void saveBoardResources(List<BoardItem> items, String dir) {
    Map<String, String?> pathMap = {};
    for (BoardItem item in items) {
      if (item.isImageItem) {
        String storageImagePath = item.storageImagePath!;
        String imageName = path.basename(storageImagePath);
        String? existPath = pathMap[storageImagePath];
        if (existPath == null) {
          String saveFilePath = '$dir/$imageName';
          File(storageImagePath).copy(saveFilePath);
          pathMap[storageImagePath] = saveFilePath;
          item.savedImagePath = saveFilePath;
        } else {
          item.savedImagePath = existPath;
        }
      }
    }
  }
}
