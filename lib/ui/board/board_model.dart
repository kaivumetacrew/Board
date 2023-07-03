import 'dart:io';

import 'package:board/ui/board/board_draw.dart';
import 'package:flutter/material.dart';

import '../../util/color.dart';

class BoardData {
  int id;
  String name;
  String? color;
  String? image;
  List<BoardItem> item;

  BoardData({
    required this.id,
    required this.name,
    required this.item,
    this.color,
  });
}

class BoardItem {
  int id;

  // Text

  String? text;
  String? font;
  String? textHexColor;

  Color get textColor =>
      textHexColor == null ? Colors.black : fromHex(textHexColor!);

  // Image
  File? file;

  // Sticker
  String? sticker;

  // Draw
  List<Point> points = [];
  String? strokeHexColor;
  Color get strokeColor => strokeHexColor == null ? Colors.black : fromHex(strokeHexColor!);

  double strokeWidth = 3;
  StrokeCap strokeCap = StrokeCap.round;
  StrokeJoin strokeJoin = StrokeJoin.round;

  //
  // Position
  ValueNotifier<Matrix4> matrixNotifier = ValueNotifier(Matrix4.identity());
  bool isLockRotate = true;
  bool isLockScale = true;
  bool isLockMove = true;
  int lastUpdate = 0;

  //Matrix4 translationDeltaMatrix = Matrix4.identity();
  //Matrix4 scaleDeltaMatrix = Matrix4.identity();
  //Matrix4 rotationDeltaMatrix = Matrix4.identity();
  Matrix4 matrix = Matrix4.identity();

  BoardItem({
    required this.id,
  });

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

  bool get isImageItem => file != null;

  bool get isStickerItem => sticker != null;

  bool get isDrawItem => points.isNotEmpty;
}
