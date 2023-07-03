import 'package:board/ui/board/board_model.dart';
import 'package:hive/hive.dart';


class BoardDB {
  Map<String, dynamic?> boardItemDbo(BoardItem i) {
    return {
      'id': i.id,
      'text': i.text,
      'font': i.font,
      'textColor': i.textColor,
      'image': i.savedImagePath,
      'sticker': i.sticker,
      'drawColor': i.drawColor,
      'drawPoints': i.drawPoints,
    };
  }
}

// class BoardAdapter extends TypeAdapter<BoardData> {
//   @override
//   final typeId = 0;
//
//   @override
//   BoardData read(BinaryReader reader) {
//     return BoardData(reader.r);
//   }
//
//   @override
//   void write(BinaryWriter writer, BoardData obj) {
//     writer.write(obj.name);
//     writer.write(obj.name);
//     writer.write(obj.name);
//     writer.write(obj.name);
//     writer.write(obj.name);
//   }
// }
