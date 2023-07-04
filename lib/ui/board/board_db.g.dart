// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board_db.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BoardDataDBOAdapter extends TypeAdapter<BoardDataDBO> {
  @override
  final int typeId = 1;

  @override
  BoardDataDBO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BoardDataDBO(
      id: fields[0] as int,
      name: fields[1] as String,
      color: fields[3] as String?,
      image: fields[4] as String?,
      thumbnail: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BoardDataDBO obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.thumbnail)
      ..writeByte(3)
      ..write(obj.color)
      ..writeByte(4)
      ..write(obj.image);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardDataDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BoardItemDBOAdapter extends TypeAdapter<BoardItemDBO> {
  @override
  final int typeId = 2;

  @override
  BoardItemDBO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BoardItemDBO(
      id: fields[0] as int,
    )
      ..lastUpdate = fields[1] as int
      ..text = fields[2] as String?
      ..font = fields[3] as String?
      ..textColor = fields[4] as String?
      ..imagePath = fields[5] as String?
      ..sticker = fields[6] as String?
      ..drawColor = fields[7] as String?
      ..matrix = fields[8] as String?;
  }

  @override
  void write(BinaryWriter writer, BoardItemDBO obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.lastUpdate)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.font)
      ..writeByte(4)
      ..write(obj.textColor)
      ..writeByte(5)
      ..write(obj.imagePath)
      ..writeByte(6)
      ..write(obj.sticker)
      ..writeByte(7)
      ..write(obj.drawColor)
      ..writeByte(8)
      ..write(obj.matrix);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardItemDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
