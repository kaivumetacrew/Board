// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BoardDataAdapter extends TypeAdapter<BoardData> {
  @override
  final int typeId = 1;

  @override
  BoardData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BoardData(
      id: fields[0] as int,
      name: fields[1] as String,
      color: fields[3] as String?,
      image: fields[4] as String?,
      thumbnail: fields[2] as String?,
      items: [],
    );
  }

  @override
  void write(BinaryWriter writer, BoardData obj) {
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
      other is BoardDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
