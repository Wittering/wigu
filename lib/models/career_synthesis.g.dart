// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'career_synthesis.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CareerSynthesisAdapter extends TypeAdapter<CareerSynthesis> {
  @override
  final int typeId = 30;

  @override
  CareerSynthesis read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CareerSynthesis(
      id: fields[0] as String,
      sessionId: fields[1] as String,
      generatedAt: fields[2] as DateTime,
      selfResponseIds: (fields[3] as List).cast<String>(),
      advisorResponseIds: (fields[4] as List).cast<String>(),
      alignmentAreas: (fields[5] as List).cast<SynthesisInsight>(),
      hiddenStrengths: (fields[6] as List).cast<SynthesisInsight>(),
      overestimatedAreas: (fields[7] as List).cast<SynthesisInsight>(),
      developmentOpportunities: (fields[8] as List).cast<SynthesisInsight>(),
      repositioningPotential: (fields[9] as List).cast<SynthesisInsight>(),
      executiveSummary: fields[10] as String,
      strategicRecommendations: (fields[11] as List).cast<String>(),
      alignmentScore: fields[12] as double,
      confidenceLevel: fields[13] as SynthesisConfidence,
      analysisMetadata: (fields[14] as Map?)?.cast<String, dynamic>(),
      lastUpdated: fields[15] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CareerSynthesis obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sessionId)
      ..writeByte(2)
      ..write(obj.generatedAt)
      ..writeByte(3)
      ..write(obj.selfResponseIds)
      ..writeByte(4)
      ..write(obj.advisorResponseIds)
      ..writeByte(5)
      ..write(obj.alignmentAreas)
      ..writeByte(6)
      ..write(obj.hiddenStrengths)
      ..writeByte(7)
      ..write(obj.overestimatedAreas)
      ..writeByte(8)
      ..write(obj.developmentOpportunities)
      ..writeByte(9)
      ..write(obj.repositioningPotential)
      ..writeByte(10)
      ..write(obj.executiveSummary)
      ..writeByte(11)
      ..write(obj.strategicRecommendations)
      ..writeByte(12)
      ..write(obj.alignmentScore)
      ..writeByte(13)
      ..write(obj.confidenceLevel)
      ..writeByte(14)
      ..write(obj.analysisMetadata)
      ..writeByte(15)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareerSynthesisAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SynthesisInsightAdapter extends TypeAdapter<SynthesisInsight> {
  @override
  final int typeId = 31;

  @override
  SynthesisInsight read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SynthesisInsight(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as SynthesisCategory,
      supportingEvidence: (fields[4] as List).cast<String>(),
      strategicImportance: fields[5] as int,
      actionableAdvice: fields[6] as String?,
      relatedThemes: (fields[7] as List).cast<String>(),
      confidence: fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SynthesisInsight obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.supportingEvidence)
      ..writeByte(5)
      ..write(obj.strategicImportance)
      ..writeByte(6)
      ..write(obj.actionableAdvice)
      ..writeByte(7)
      ..write(obj.relatedThemes)
      ..writeByte(8)
      ..write(obj.confidence);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SynthesisInsightAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SynthesisCategoryAdapter extends TypeAdapter<SynthesisCategory> {
  @override
  final int typeId = 32;

  @override
  SynthesisCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SynthesisCategory.strength;
      case 1:
        return SynthesisCategory.opportunity;
      case 2:
        return SynthesisCategory.blindspot;
      case 3:
        return SynthesisCategory.overestimation;
      case 4:
        return SynthesisCategory.positioning;
      case 5:
        return SynthesisCategory.development;
      default:
        return SynthesisCategory.strength;
    }
  }

  @override
  void write(BinaryWriter writer, SynthesisCategory obj) {
    switch (obj) {
      case SynthesisCategory.strength:
        writer.writeByte(0);
        break;
      case SynthesisCategory.opportunity:
        writer.writeByte(1);
        break;
      case SynthesisCategory.blindspot:
        writer.writeByte(2);
        break;
      case SynthesisCategory.overestimation:
        writer.writeByte(3);
        break;
      case SynthesisCategory.positioning:
        writer.writeByte(4);
        break;
      case SynthesisCategory.development:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SynthesisCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SynthesisConfidenceAdapter extends TypeAdapter<SynthesisConfidence> {
  @override
  final int typeId = 33;

  @override
  SynthesisConfidence read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SynthesisConfidence.high;
      case 1:
        return SynthesisConfidence.medium;
      case 2:
        return SynthesisConfidence.low;
      default:
        return SynthesisConfidence.high;
    }
  }

  @override
  void write(BinaryWriter writer, SynthesisConfidence obj) {
    switch (obj) {
      case SynthesisConfidence.high:
        writer.writeByte(0);
        break;
      case SynthesisConfidence.medium:
        writer.writeByte(1);
        break;
      case SynthesisConfidence.low:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SynthesisConfidenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
