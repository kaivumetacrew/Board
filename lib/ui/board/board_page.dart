import 'dart:io';

import 'package:board/util/state.dart';
import 'package:board/util/string.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../util/widget.dart';
import '../board_background.dart';
import '../board_stickers.dart';
import '../board_text.dart';
import 'board_actionbar.dart';
import 'board_controller.dart';
import 'board_model.dart';
import 'board_view.dart';
import 'board_widget.dart';

class BoardPage extends StatefulWidget {
  BoardData data;

  BoardPage({
    super.key,
    required this.data,
  });

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage>
    with TickerProviderStateMixin
{
  double _boardFoldedDipWidth = 0;
  double _boardBottom = 1;
  double _boardRight = 1;
  double _boardScale = 1;
  bool _isPortrait = true;

  final GlobalKey _widgetKey = GlobalKey();

  final BoardController _boardController = BoardController(items: []);
  final ActionBarController _actionBarController =
      ActionBarController(ActionItem.none);

  _BoardPageState();

  @override
  void initState() {
    super.initState();
    lockPortrait();
    _boardController.boardColor = widget.data.color;
    _boardController.onItemTap = (item) {
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
        title: Text(widget.data.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              showSnackBar('on development');
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

  Widget _boardView() {
    if (_isPortrait) {
      // ui for portrait layout
      _boardFoldedDipWidth = 0;
      return Transform.scale(
        scale: _boardScale,
        alignment: Alignment.topLeft,
        child: BoardView(
          data: widget.data,
          controller: _boardController,
        ),
      );
    }
    // ui for fold layout
    if (_boardFoldedDipWidth > 0) {
      return Transform.scale(
        scale: _boardScale,
        alignment: Alignment.topLeft,
        child: BoardView(
          data: widget.data,
          controller: _boardController,
        ),
      );
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
    var page = TextPage(text: selectedItem.text);
    Map<String, dynamic>? result = await push(page, fullscreenDialog: true);
    if (result == null) return;
    String? text = result['text'];
    String? font = result['font'];
    if (text.isNullOrEmpty || font.isNullOrEmpty) return;
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
  }

  /// Image
  Future<void> _pickGalleryImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 6000,
        maxHeight: 6000,
        imageQuality: 100,
      );
      var file = File(pickedFile!.path!);

      _boardController.addNewItem((item) {
        item.file = file;
      });
      _actionBarController.value = ActionItem.imageItem;
    } catch (e) {
      setState(() {});
    }
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

  void saveBoard() {}
}
