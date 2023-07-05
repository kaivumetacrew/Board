import 'dart:convert';
import 'dart:typed_data';

import 'package:board/ui/board/board_draw.dart' as draw;
import 'package:board/ui/board/board_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'board_db.g.dart';

///Run build task flutter packages pub run build_runner build
@HiveType(typeId: 1)
class BoardDataDBO {
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

  List<BoardItemDBO>? items;

  BoardDataDBO({
    required this.id,
    required this.name,
    this.items,
    this.color,
    this.image,
    this.thumbnail,
  });

  static BoardDataDBO map(BoardData data) {
    final dbo = BoardDataDBO(
        id: data.id,
        name: data.name,
        items: [],
        color: data.color,
        image: data.image);
    return dbo;
  }

  Future<BoardData> getUiData() async {
    var box = await Hive.openBox<BoardItemDBO>(id.toString());
    items = box.values.toList();
    final boardItems = items?.map((e) => e.getUiItem()).toList(growable: true);
    final data = BoardData(
      id: id,
      name: name,
      items: boardItems ?? [],
    );
    data.color = color;
    data.image = image;
    return data;
  }

}

@HiveType(typeId: 2)
class BoardItemDBO {
  @HiveField(0)
  int id;

  @HiveField(1)
  int lastUpdate = 0;

  @HiveField(2)
  String? text;

  @HiveField(3)
  String? font;

  @HiveField(4)
  String? textColor;

  @HiveField(5)
  String? imagePath;

  @HiveField(6)
  String? sticker;

  @HiveField(7)
  String? drawColor;

  @HiveField(8)
  String? matrix; //Matrix4.fromFloat64List(this._m4storage);

  @HiveField(9)
  String? drawPoints;

  BoardItemDBO({required this.id});

  static BoardItemDBO map(BoardItem item) {
    final data = BoardItemDBO(id: item.id)
      ..lastUpdate = item.lastUpdate
      ..text = item.text
      ..font = item.font
      ..textColor = item.textColor
      ..imagePath = item.imagePath
      ..sticker = item.sticker
      ..drawColor = item.drawColor;

    // convert item.matrix.storage (Float64List) to string
    if (item.isImageItem || item.isTextItem || item.isStickerItem) {
      Float64List matrixStorage = item.matrix.storage;
      String stringList = matrixStorage.join(';');
      data.matrix = stringList;
    }

    // convert item.drawPoints (List<Point>) to string of json array
    if (item.isDrawItem) {
      final pointList = item.drawPoints?.map((e) => e.toJson()).toList();
      final jsonArray = json.encode(pointList);
      data.drawPoints = jsonArray;
    }

    return data;
  }

  BoardItem getUiItem() {
    final item = BoardItem(id: id)
      ..lastUpdate = lastUpdate
      ..text = text
      ..font = font
      ..textColor = textColor
      ..savedImagePath = imagePath
      ..sticker = sticker
      ..drawColor = drawColor;

    // convert string to Float64List
    if (item.isImageItem || item.isTextItem || item.isStickerItem) {
      List<double>? matrixData = matrix?.split(';').map((e) => double.parse(e))?.toList();
      final mt = matrix != null
          ? Matrix4.fromFloat64List(Float64List.fromList(matrixData!!))
          : Matrix4.identity();
      item.matrixNotifier = ValueNotifier(mt);
    }

    // convert string to List<Point>
    if (drawPoints != null) {
      List<dynamic> array = jsonDecode(drawPoints!);
      final list = array.map((e) => draw.Point.fromJson(e)).toList();
      item.drawPoints = list;
    }

    return item;
  }

}

Future<void> openBoardsBox(Function(Box<BoardDataDBO> box) block) async {
  var box = await Hive.openBox<BoardDataDBO>('boards');
  block(box);
  box.close();
}
