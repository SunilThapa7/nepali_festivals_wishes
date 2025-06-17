// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_wish.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteWishAdapter extends TypeAdapter<FavoriteWish> {
  @override
  final int typeId = 1;

  @override
  FavoriteWish read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteWish(
      id: fields[0] as String,
      festivalId: fields[1] as String,
      festivalName: fields[2] as String,
      wishText: fields[3] as String,
      isNepali: fields[4] as bool,
      dateSaved: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteWish obj) {
    writer.writeByte(6);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.festivalId);
    writer.writeByte(2);
    writer.write(obj.festivalName);
    writer.writeByte(3);
    writer.write(obj.wishText);
    writer.writeByte(4);
    writer.write(obj.isNepali);
    writer.writeByte(5);
    writer.write(obj.dateSaved);
  }
}
