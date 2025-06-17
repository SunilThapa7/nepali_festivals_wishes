// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'festival.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FestivalAdapter extends TypeAdapter<Festival> {
  @override
  final int typeId = 0;

  @override
  Festival read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Festival(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      imageUrl: fields[3] as String,
      category: fields[4] as FestivalCategory,
      nepaliWishes: (fields[5] as List).cast<String>(),
      englishWishes: (fields[6] as List).cast<String>(),
      cardImageUrls: (fields[7] as List).cast<String>(),
      date: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Festival obj) {
    writer.writeByte(9);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.name);
    writer.writeByte(2);
    writer.write(obj.description);
    writer.writeByte(3);
    writer.write(obj.imageUrl);
    writer.writeByte(4);
    writer.write(obj.category);
    writer.writeByte(5);
    writer.write(obj.nepaliWishes);
    writer.writeByte(6);
    writer.write(obj.englishWishes);
    writer.writeByte(7);
    writer.write(obj.cardImageUrls);
    writer.writeByte(8);
    writer.write(obj.date);
  }
}
