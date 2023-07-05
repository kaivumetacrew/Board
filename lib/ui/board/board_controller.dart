import 'package:board/util/color.dart';
import 'package:flutter/material.dart';

import 'board_draw.dart';
import 'board_model.dart';

class BoardController extends ValueNotifier<List<BoardItem>> {
  List<BoardItem> items;
  BoardItem selectedItem = BoardItem.none;
  Function(BoardItem) onItemTap = (item) {};
  String currentDrawColor = '#000000';
  String currentTextColor = '#000000';
  String? currentFont;
  String? boardImage;
  String? boardColor;
  DrawController drawController = DrawController();
  ValueNotifier<bool> isDrawingNotifier = ValueNotifier(false);
  ValueNotifier<bool> isChangeBackgroundNotifier = ValueNotifier(false);

  bool get isDrawing => isDrawingNotifier.value;
  double portraitWidth = 0;
  double portraitHeight = 0;
  double landscapeWidth = 0;
  double landscapeHeight = 0;

  BoardController(this.items) : super(items);

  @override
  void dispose() {
    drawController.dispose();
    isDrawingNotifier.dispose();
    isChangeBackgroundNotifier.dispose();
    super.dispose();
  }

  void removeSelectedItem() {
    remove(selectedItem);
  }

  void remove(BoardItem item) {
    value.removeWhere((element) => element == selectedItem);
    notifyListeners();
  }

  void notifyItemsChanged() {
    value.sort((a, b) => a.lastUpdate.compareTo(b.lastUpdate));
    notifyListeners();
  }

  void bringToFront() {
    int index = value.indexWhere((element) => element == selectedItem);
    int nextIndex = index + 1;
    if (index >= 0 && nextIndex < value.length) {
      BoardItem nextItem = value[nextIndex];
      int tempId = selectedItem.lastUpdate;
      selectedItem.lastUpdate = nextItem.lastUpdate;
      nextItem.lastUpdate = tempId;
      notifyItemsChanged();
    }
  }

  void putToBackButton() {
    int index = value.indexWhere((element) => element == selectedItem);
    int prevIndex = index - 1;
    if (index >= 0 && prevIndex < value.length) {
      final prevItem = value[prevIndex];
      int tempId = selectedItem.lastUpdate;
      selectedItem.lastUpdate = prevItem.lastUpdate;
      prevItem.lastUpdate = tempId;
      notifyItemsChanged();
    }
  }

  void setColor(String color) {
    if (isDrawing) {
      currentDrawColor = color;
      drawController.penColor = fromHex(color);
      drawController.notifyListeners();
      return;
    }
    if (selectedItem.isTextItem) {
      currentTextColor = color;
      selectedItem.textColor = color;
      notifyListeners();
    }
  }

  void setBackgroundColor(String color) {
    boardColor = color;
    boardImage = null;
    isChangeBackgroundNotifier.notifyListeners();
  }

  void setBackgroundImage(String image) {
    boardColor = null;
    boardImage = image;
    isChangeBackgroundNotifier.notifyListeners();
  }

  void select(BoardItem item) {
    selectedItem = item;
    notifyListeners();
  }

  void deselectItem() {
    selectedItem = BoardItem.none;
    notifyListeners();
  }

  void startDraw() {
    isDrawingNotifier.value = true;
  }

  void stopDraw() {
    isDrawingNotifier.value = false;
  }

  void addNewItem(Function(BoardItem) block) {
    BoardItem item = BoardItem(
      id: value.length,
    );
    item.lastUpdate = DateTime.now().millisecondsSinceEpoch;
    block(item);
    if (item.isDrawItem) {
      item.drawColor = currentDrawColor;
    } else {
      stopDraw();
    }
    if (item.isTextItem) {
      item.textColor = currentTextColor;
    }

    if (!item.isDrawItem) {
      stopDraw();
    }
    selectedItem = item;
    value.add(item);
    notifyListeners();
  }

  void undoDraw() {
    final item = value.reversed
        .firstWhere((element) => (element.drawPoints?.length ?? 0) > 0);
    value.removeWhere((element) => element.id == item.id);
    notifyListeners();
  }
}
