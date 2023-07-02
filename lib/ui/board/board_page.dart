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

class _BoardPageState extends State<BoardPage> with TickerProviderStateMixin{

  BoardController boardController = BoardController(items: []);

  ActionBarController actionBarController = ActionBarController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    boardController.onItemTap = (item) {
      if (item.isTextItem) {
        actionBarController.value = (ActionItem.textItem);
        return;
      }
      if (item.isImageItem) {
        actionBarController.value = (ActionItem.imageItem);
        return;
      }
      if (item.isStickerItem) {
        actionBarController.value = (ActionItem.stickerItem);
        return;
      }
      if (item.isDrawItem) {
        actionBarController.value = (ActionItem.drawItem);
        return;
      }
      boardController.deselectItem();
      actionBarController.value = ActionItem.none;
    };
  }

  @override
  void dispose() {
    boardController.dispose();
    actionBarController.dispose();
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
    return ValueListenableBuilder(
      valueListenable: actionBarController,
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
    actionBarController.value = ActionItem.textItem;
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
      actionBarController.value = ActionItem.imageItem;
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
    actionBarController.value = ActionItem.stickerItem;
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

  /// Bottom action bar
  Widget _actionBar() {
    return ActionBar(
      controller: actionBarController,
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
            boardController.deselectItem();
            boardController.startDraw();
          } else {
            boardController.stopDraw();
          }
          return;
        }
      },
    );
  }

}
