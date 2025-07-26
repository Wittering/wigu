// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'career_response.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CareerResponseAdapter extends TypeAdapter<CareerResponse> {
  @override
  final int typeId = 11;

  @override
  CareerResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CareerResponse(
      questionId: fields[0] as String,
      questionText: fields[1] as String,
      response: fields[2] as String,
      answeredAt: fields[3] as DateTime,
      domain: fields[4] as CareerDomain,
      confidenceLevel: fields[5] as int?,
      tags: (fields[6] as List?)?.cast<String>(),
      isReflectionComplete: fields[7] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, CareerResponse obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.questionId)
      ..writeByte(1)
      ..write(obj.questionText)
      ..writeByte(2)
      ..write(obj.response)
      ..writeByte(3)
      ..write(obj.answeredAt)
      ..writeByte(4)
      ..write(obj.domain)
      ..writeByte(5)
      ..write(obj.confidenceLevel)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.isReflectionComplete);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareerResponseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
