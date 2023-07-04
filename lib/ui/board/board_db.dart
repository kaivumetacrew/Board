import 'dart:typed_data';

import 'package:board/ui/board/board_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'board_draw.dart';


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

  // @HiveField(5)
  // List<BoardItemDBO> items = [];

  BoardDataDBO({
    required this.id,
    required this.name,
    //required this.items,
    this.color,
    this.image,
    this.thumbnail,
  });

  static BoardDataDBO map(BoardData data) {
    final dbo = BoardDataDBO(
        id: data.id,
        name: data.name,
        //items: [],
        color: data.color,
        image: data.image);
    return dbo;
  }

  BoardData getUiData() {
    //final boardItems = items.map((e) => e.getUiItem()).toList(growable: true);
    final data = BoardData(
      id: id,
      name: name,
      items: [],
    );
    data.color = color;
    data.image = image;
    return data;
  }
}

class BoardItemDBO {
  int id;
  int lastUpdate = 0;
  String? text;
  String? font;
  String? textColor;
  String? imagePath;
  String? sticker;
  String? drawColor;
  List<Point>? drawPoints;
  Float64List? matrix; //Matrix4.fromFloat64List(this._m4storage);

  BoardItemDBO({required this.id});

  static BoardItemDBO map(BoardItem item) {
    final data = BoardItemDBO(id: item.id)
      ..lastUpdate = item.lastUpdate
      ..text = item.text
      ..font = item.font
      ..textColor = item.textColor
      ..imagePath = item.imagePath
      ..sticker = item.sticker
      ..drawColor = item.drawColor
      ..drawPoints = item.drawPoints
      ..matrix = item.matrix.storage;

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
      ..drawColor = drawColor
      ..drawPoints = drawPoints;
    final mt =
    matrix != null ? Matrix4.fromFloat64List(matrix!) : Matrix4.identity();
    item.matrixNotifier = ValueNotifier(mt);
    return item;
  }
}

Future<void> editBoardsData(Function(Box<BoardDataDBO> box) block) async {
  var box = await Hive.openBox<BoardDataDBO>('boards');
  block(box);
  box.close();
}
