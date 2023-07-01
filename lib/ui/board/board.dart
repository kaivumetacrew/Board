import 'dart:io';

import 'package:board/ui/board/board_view.dart';
import 'package:board/util/state.dart';
import 'package:board/util/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../board_background.dart';
import '../board_stickers.dart';
import '../board_text.dart';
import 'board_actionbar.dart';
import 'board_controller.dart';
import 'board_model.dart';
import 'board_widget.dart';

class BoardPage extends StatefulWidget {
  BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> with TickerProviderStateMixin {
  ActionItem _selectedAction = ActionItem.none;

  BoardController boardController = BoardController(items: []);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    boardController.addListener(() {});
    boardController.onItemTap = (item) {
      if (item.isTextItem) {
        selectAction(ActionItem.textItem);
      } else if (item.isImageItem) {
        selectAction(ActionItem.imageItem);
      } else if (item.isStickerItem) {
        selectAction(ActionItem.stickerItem);
      } else if (item.isDrawItem) {
        selectAction(ActionItem.drawItem);
      }
    };
  }

  @override
  void dispose() {
    boardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Board")),
      body: SafeArea(
        child: Column(
          children: [
            BoardView(
              boardController: boardController,
            ),
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
        ),
      ),
    );
  }

  Widget _removeButton() {
    return imageButton(
        icon: Icons.delete,
        onPressed: () {
          boardController.removeSelectedItem();
        });
  }

  Widget _bringToFrontButton() {
    return imageButton(
        icon: Icons.arrow_upward,
        onPressed: () {
          boardController.bringToFront();
        });
  }

  Widget _putToBackButton() {
    return imageButton(
        icon: Icons.arrow_downward,
        onPressed: () {
          boardController.putToBackButton();
        });
  }

  Widget _colorPickerWidget() {
    return colorPickerWidget((color) {
      boardController.setColor(color);
    });
  }

  Widget _dynamicToolWidget() {
    if (_selectedAction == ActionItem.textItem) {
      return _textToolWidget();
    }
    if (_selectedAction == ActionItem.imageItem ||
        _selectedAction == ActionItem.stickerItem) {
      return _imageToolWidget();
    }
    if (_selectedAction == ActionItem.drawItem) {
      return _drawToolWidget();
    }
    return const SizedBox();
  }

  Widget _backgroundButton() {
    return Row(
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
      boardController.setBackgroundImage(image!);
      return;
    }
    String? color = result['color'];
    if (!color.isNullOrEmpty) {
      boardController.setBackgroundColor(color!);
      return;
    }
  }

  /// Text
  Widget _textToolWidget() {
    var row1 = Row(
      children: [
        _removeButton(),
        imageButton(
            icon: Icons.edit,
            onPressed: () {
              _pickText(boardController.selectedItem);
            }),
        _bringToFrontButton(),
        _putToBackButton(),
      ],
    );
    return Column(children: [
      row1,
      _colorPickerWidget(),
    ]);
  }

  Future<void> _pickText(BoardItem selectedItem) async {
    var page = TextPage(text: selectedItem.text);
    Map<String, dynamic>? result = await push(page, fullscreenDialog: true);
    if (result == null) return;
    String? text = result['text'];
    String? font = result['font'];
    if (text.isNullOrEmpty || font.isNullOrEmpty) return;
    if (selectedItem == BoardItem.none) {
      boardController.addNewItem((item) {
        item.text = text;
        item.font = font;
      });
    } else {
      selectedItem.text = text;
      boardController.notifyListeners();
    }
    selectAction(ActionItem.textItem);
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

      boardController.addNewItem((item) {
        item.file = file;
      });
      selectAction(ActionItem.imageItem);
    } catch (e) {
      setState(() {});
    }
  }

  Future<void> _pickStickerImage() async {
    Map<String, dynamic>? result =
        await push(StickerPage(), fullscreenDialog: true);
    String? sticker = result?['sticker'];
    if (sticker.isNullOrEmpty) return;
    boardController.addNewItem((item) {
      item.sticker = sticker;
    });
    selectAction(ActionItem.stickerItem);
  }

  Widget _imageToolWidget() {
    return Column(
      children: [
        Row(
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
    return Column(
      children: [
        Row(
          children: [
            imageButton(
                icon: Icons.undo,
                onPressed: () {
                  boardController.undoDraw();
                }),
          ],
        ),
        _colorPickerWidget(),
      ],
    );
  }

  ///
  Widget _actionBar() {
    return Container(
      color: Colors.white,
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _actionButton(ActionItem.textItem, (isSelected) {
            _pickText(BoardItem.none);
          }),
          _actionButton(ActionItem.imageItem, (isSelected) {
            _pickGalleryImage();
          }),
          _actionButton(ActionItem.stickerItem, (isSelected) {
            _pickStickerImage();
          }),
          _actionButton(ActionItem.drawItem, (isSelected) {
            if (isSelected) {
              boardController.deselectItem();
              boardController.startDraw();
            } else {
              boardController.stopDraw();
            }
          })
        ],
      ),
    );
  }

  Widget _actionButton(
    ActionItem item,
    Function(bool isSelected) callback,
  ) {
    Color iconColor = (item.selectable && _selectedAction == item)
        ? Colors.blue
        : Colors.grey;
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
            style: TextStyle(
              color: iconColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void selectAction(ActionItem actionItem) {
    setState(() {
      _selectedAction = actionItem;
    });
  }
}
