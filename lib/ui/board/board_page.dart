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
  BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage>
    with TickerProviderStateMixin
{
  double _boardFoldedDipWidth = 0;
  double _boardBottom = 0;
  double _boardRight = 0;
  double _boardScale = 1;
  bool _isPortrait = true;

  final GlobalKey _widgetKey = GlobalKey();
  final BoardController _boardController = BoardController(
    items: [],
    boardColor: '#E3E9F2',
  );
  final ActionBarController _actionBarController =
      ActionBarController(ActionItem.none);

  @override
  void initState() {
    super.initState();
    lockPortrait();
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
        title: const Text("Board foldable"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              showSnackBar('Saved');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ColumnIfPortraitElseRow(
          isPortrait: _isPortrait,
          children: [
            _boardView(),
            _boardScaleExpand(),
            _separator(),
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
            _separator(),
            _actionBar()
          ],
        ),
      ),
    );
  }


  void _updateScreenArgs() {
    Size screenSize = MediaQuery.of(context).size;
    var phoneRatio = 10 / 16;
    var deviceRatio = screenSize.width / screenSize.height;
    _isPortrait = phoneRatio > deviceRatio;
    if (_isPortrait) {
      double boardWidthDip = pixelToDip(BoardView.widthPx);
      double boardHeightDip = pixelToDip(BoardView.heightPx);
      _boardScale = screenSize.width / boardWidthDip;
      _boardBottom = ((boardHeightDip * _boardScale) - boardHeightDip);
    }
  }

  void _updateFoldScreenArgs(Size correctBoardSize) {
    double boardWidthDip = pixelToDip(BoardView.widthPx);
    _boardFoldedDipWidth = correctBoardSize.height * BoardView.ratio;
    _boardScale = _boardFoldedDipWidth / boardWidthDip;
    _boardRight = ((boardWidthDip * _boardScale) - boardWidthDip);
  }

  Widget _boardScaleExpand() {
    if (_isPortrait) {
      return SizedBox(width: 5, height: _boardBottom);
    }
    return SizedBox(width: _boardRight, height: 5);
  }

  Widget _boardView() {
    if (_isPortrait) {
      // ui for portrait layout
      _boardFoldedDipWidth = 0;
      return Transform.scale(
        scale: _boardScale,
        alignment: Alignment.topLeft,
        child: BoardView(boardController: _boardController),
      );
    }
    // ui for fold layout
    if (_boardFoldedDipWidth > 0) {
      return Transform.scale(
        scale: _boardScale,
        alignment: Alignment.topLeft,
        child: BoardView(boardController: _boardController),
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

  Widget _separator() {
    return separator(axis: _isPortrait ? Axis.vertical : Axis.horizontal);
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
      isPortrait: this._isPortrait,
      children: [
        RowIfPortraitElseCol(
          isPortrait: this._isPortrait,
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
      axis:  _isPortrait ? Axis.horizontal : Axis.vertical,
      textVisible: _isPortrait,
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

}
