import 'package:board/ui/board/board_draw.dart';
import 'package:flutter/material.dart';

import '../../util/color.dart';

class BoardData {
  int id;

  String name;

  String? color;

  String? image;

  List<BoardItem> items;

  BoardData({
    required this.id,
    required this.name,
    required this.items,
    this.color,
    this.image,
  });
}

class BoardItem {
  late int id;
  Key? key;
  int lastUpdate = 0;

  // Text
  String? text;
  String? font;
  String? textColor;

  Color get uiColor => textColor == null ? Colors.black : fromHex(textColor!);

  // Image
  String? storageImagePath;
  String? savedImagePath;

  String? get imagePath => storageImagePath ?? savedImagePath;

  // Sticker
  String? sticker;

  // Draw
  List<Point>? drawPoints;
  String? drawColor;

  Color get uiDrawColor =>
      drawColor == null ? Colors.black : fromHex(drawColor!);
  double drawWidth = 3;
  StrokeCap strokeCap = StrokeCap.round;
  StrokeJoin strokeJoin = StrokeJoin.round;

  /// Transform
  ValueNotifier<Matrix4> matrixNotifier = ValueNotifier(Matrix4.identity());

  Matrix4 get matrix => matrixNotifier.value;

  BoardItem({required this.id, this.key});

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

  static BoardItem none = BoardItem(id: -1);

  bool get isNone => id == -1;

  bool get isTextItem => text != null && text!.isNotEmpty;

  bool get isImageItem => imagePath != null;

  bool get isStickerItem => sticker != null;

  bool get isDrawItem => drawPoints != null && drawPoints!.isNotEmpty;
}
