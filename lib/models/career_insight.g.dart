// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'career_insight.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CareerInsightAdapter extends TypeAdapter<CareerInsight> {
  @override
  final int typeId = 12;

  @override
  CareerInsight read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CareerInsight(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      domain: fields[3] as CareerDomain,
      type: fields[4] as InsightType,
      generatedAt: fields[5] as DateTime,
      confidence: fields[6] as double,
      sourceQuestionIds: (fields[7] as List).cast<String>(),
      keyThemes: (fields[8] as List).cast<String>(),
      actionSuggestion: fields[9] as String?,
      isUserValidated: fields[10] as bool,
      userRating: fields[11] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, CareerInsight obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.domain)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.generatedAt)
      ..writeByte(6)
      ..write(obj.confidence)
      ..writeByte(7)
      ..write(obj.sourceQuestionIds)
      ..writeByte(8)
      ..write(obj.keyThemes)
      ..writeByte(9)
      ..write(obj.actionSuggestion)
      ..writeByte(10)
      ..write(obj.isUserValidated)
      ..writeByte(11)
      ..write(obj.userRating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareerInsightAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InsightTypeAdapter extends TypeAdapter<InsightType> {
  @override
  final int typeId = 15;

  @override
  InsightType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InsightType.pattern;
      case 1:
        return InsightType.strength;
      case 2:
        return InsightType.value;
      case 3:
        return InsightType.interest;
      case 4:
        return InsightType.development;
      case 5:
        return InsightType.compatibility;
      case 6:
        return InsightType.barrier;
      case 7:
        return InsightType.nextStep;
      default:
        return InsightType.pattern;
    }
  }

  @override
  void write(BinaryWriter writer, InsightType obj) {
    switch (obj) {
      case InsightType.pattern:
        writer.writeByte(0);
        break;
      case InsightType.strength:
        writer.writeByte(1);
        break;
      case InsightType.value:
        writer.writeByte(2);
        break;
      case InsightType.interest:
        writer.writeByte(3);
        break;
      case InsightType.development:
        writer.writeByte(4);
        break;
      case InsightType.compatibility:
        writer.writeByte(5);
        break;
      case InsightType.barrier:
        writer.writeByte(6);
        break;
      case InsightType.nextStep:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InsightTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
