import 'package:board/ui/board/board_draw.dart';
import 'package:flutter/material.dart';

import '../../util/color.dart';
import 'package:hive/hive.dart';

part 'board_model.g.dart';

Future<void> editBoardsData(Function(Box<BoardData> box) block) async{
  final box  = await Hive.openBox<BoardData>('boards');
  block(box);
  box.close();
}

@HiveType(typeId: 1)
class BoardData {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? thumbnail;

  @HiveField(3)
  String? color;

  @HiveField(4)
  String? image;

  @HiveField(5)
  List<BoardItem> items;

  BoardData({
    required this.id,
    required this.name,
    required this.items,
    this.color,
    this.image,
    this.thumbnail,
  });
}

class BoardItem {
  int id;

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
  List<Point> drawPoints = [];
  String? drawColor;

  Color get uiDrawColor =>
      drawColor == null ? Colors.black : fromHex(drawColor!);

  double drawWidth = 3;
  StrokeCap strokeCap = StrokeCap.round;
  StrokeJoin strokeJoin = StrokeJoin.round;

  /// Position
  ValueNotifier<Matrix4> matrixNotifier = ValueNotifier(Matrix4.identity());
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

  bool get isImageItem => imagePath != null;

  bool get isStickerItem => sticker != null;

  bool get isDrawItem => drawPoints.isNotEmpty;
}
