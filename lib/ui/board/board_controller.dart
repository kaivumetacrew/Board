import 'package:flutter/material.dart';

import 'board_draw.dart';
import 'board_model.dart';

class BoardController extends ValueNotifier<List<BoardItem>> {
  BoardController({
    required this.items,
    this.boardColor,
    this.boardImage,
  }) : super(items);

  List<BoardItem> items;
  BoardItem selectedItem = BoardItem.none;
  Function(BoardItem) onItemTap = (item) {};
  Color currentDrawColor = Colors.black;
  Color currentTextColor = Colors.black;
  String? boardImage;
  String? boardColor;
  DrawController drawController = DrawController();
  ValueNotifier<bool> isDrawingNotifier = ValueNotifier(false);
  ValueNotifier<bool> isChangeBackgroundNotifier = ValueNotifier(false);

  bool get isDrawing => isDrawingNotifier.value;

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
      var prevItem = value[prevIndex];
      int tempId = selectedItem.lastUpdate;
      selectedItem.lastUpdate = prevItem.lastUpdate;
      prevItem.lastUpdate = tempId;
      notifyItemsChanged();
    }
  }

  void setColor(Color color) {
    if (isDrawing) {
      currentDrawColor = color;
      drawController.penColor = color;
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
    isDrawingNotifier.notifyListeners();
  }

  void stopDraw() {
    isDrawingNotifier.value = false;
    isDrawingNotifier.notifyListeners();
  }

  void addNewItem(Function(BoardItem) block) {
    BoardItem item = BoardItem(
      id: value.length,
      textColor: currentTextColor,
      strokeColor: currentDrawColor,
    );
    item.lastUpdate = DateTime.now().millisecondsSinceEpoch;
    block(item);
    if (!item.isDrawItem) {
      stopDraw();
    }
    selectedItem = item;
    value.add(item);
    notifyListeners();
  }

  void undoDraw() {
    var item =
        value.reversed.firstWhere((element) => element.points.isNotEmpty);
    value.removeWhere((element) => element.id == item.id);
    notifyListeners();
  }
}
