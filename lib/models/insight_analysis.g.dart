// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insight_analysis.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InsightAnalysisAdapter extends TypeAdapter<InsightAnalysis> {
  @override
  final int typeId = 34;

  @override
  InsightAnalysis read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InsightAnalysis(
      id: fields[0] as String,
      sessionId: fields[1] as String,
      analysedAt: fields[2] as DateTime,
      analysedInsightIds: (fields[3] as List).cast<String>(),
      themeFrequency: (fields[4] as Map).cast<String, int>(),
      themeConfidence: (fields[5] as Map).cast<String, double>(),
      identifiedPatterns: (fields[6] as List).cast<InsightPattern>(),
      correlations: (fields[7] as List).cast<InsightCorrelation>(),
      trendAnalysis: fields[8] as InsightTrendAnalysis,
      typeDistribution:
          (fields[9] as Map).cast<InsightType, InsightTypeStats>(),
      emergingThemes: (fields[10] as List).cast<String>(),
      consistentThemes: (fields[11] as List).cast<String>(),
      overallInsightQuality: fields[12] as double,
      analyticalRecommendations: (fields[13] as List).cast<String>(),
      metadata: (fields[14] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, InsightAnalysis obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sessionId)
      ..writeByte(2)
      ..write(obj.analysedAt)
      ..writeByte(3)
      ..write(obj.analysedInsightIds)
      ..writeByte(4)
      ..write(obj.themeFrequency)
      ..writeByte(5)
      ..write(obj.themeConfidence)
      ..writeByte(6)
      ..write(obj.identifiedPatterns)
      ..writeByte(7)
      ..write(obj.correlations)
      ..writeByte(8)
      ..write(obj.trendAnalysis)
      ..writeByte(9)
      ..write(obj.typeDistribution)
      ..writeByte(10)
      ..write(obj.emergingThemes)
      ..writeByte(11)
      ..write(obj.consistentThemes)
      ..writeByte(12)
      ..write(obj.overallInsightQuality)
      ..writeByte(13)
      ..write(obj.analyticalRecommendations)
      ..writeByte(14)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InsightAnalysisAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InsightPatternAdapter extends TypeAdapter<InsightPattern> {
  @override
  final int typeId = 35;

  @override
  InsightPattern read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InsightPattern(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      strength: fields[3] as double,
      supportingInsightIds: (fields[4] as List).cast<String>(),
      type: fields[5] as PatternType,
      implication: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InsightPattern obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.strength)
      ..writeByte(4)
      ..write(obj.supportingInsightIds)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.implication);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InsightPatternAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InsightCorrelationAdapter extends TypeAdapter<InsightCorrelation> {
  @override
  final int typeId = 36;

  @override
  InsightCorrelation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InsightCorrelation(
      id: fields[0] as String,
      theme1: fields[1] as String,
      theme2: fields[2] as String,
      correlation: fields[3] as double,
      type: fields[4] as CorrelationType,
      interpretation: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InsightCorrelation obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.theme1)
      ..writeByte(2)
      ..write(obj.theme2)
      ..writeByte(3)
      ..write(obj.correlation)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.interpretation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InsightCorrelationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InsightTrendAnalysisAdapter extends TypeAdapter<InsightTrendAnalysis> {
  @override
  final int typeId = 37;

  @override
  InsightTrendAnalysis read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InsightTrendAnalysis(
      qualityTrend: fields[0] as QualityTrend,
      themeDiversityTrend: fields[1] as DiversityTrend,
      isImproving: fields[2] as bool,
      isStagnating: fields[3] as bool,
      improvingAreas: (fields[4] as List).cast<String>(),
      decliningAreas: (fields[5] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, InsightTrendAnalysis obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.qualityTrend)
      ..writeByte(1)
      ..write(obj.themeDiversityTrend)
      ..writeByte(2)
      ..write(obj.isImproving)
      ..writeByte(3)
      ..write(obj.isStagnating)
      ..writeByte(4)
      ..write(obj.improvingAreas)
      ..writeByte(5)
      ..write(obj.decliningAreas);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InsightTrendAnalysisAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InsightTypeStatsAdapter extends TypeAdapter<InsightTypeStats> {
  @override
  final int typeId = 38;

  @override
  InsightTypeStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InsightTypeStats(
      count: fields[0] as int,
      averageQuality: fields[1] as double,
      averageConfidence: fields[2] as double,
      commonThemes: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, InsightTypeStats obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.count)
      ..writeByte(1)
      ..write(obj.averageQuality)
      ..writeByte(2)
      ..write(obj.averageConfidence)
      ..writeByte(3)
      ..write(obj.commonThemes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InsightTypeStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PatternTypeAdapter extends TypeAdapter<PatternType> {
  @override
  final int typeId = 39;

  @override
  PatternType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PatternType.recurring;
      case 1:
        return PatternType.evolving;
      case 2:
        return PatternType.complementary;
      case 3:
        return PatternType.conflicting;
      case 4:
        return PatternType.emergent;
      default:
        return PatternType.recurring;
    }
  }

  @override
  void write(BinaryWriter writer, PatternType obj) {
    switch (obj) {
      case PatternType.recurring:
        writer.writeByte(0);
        break;
      case PatternType.evolving:
        writer.writeByte(1);
        break;
      case PatternType.complementary:
        writer.writeByte(2);
        break;
      case PatternType.conflicting:
        writer.writeByte(3);
        break;
      case PatternType.emergent:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatternTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CorrelationTypeAdapter extends TypeAdapter<CorrelationType> {
  @override
  final int typeId = 40;

  @override
  CorrelationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CorrelationType.positive;
      case 1:
        return CorrelationType.negative;
      case 2:
        return CorrelationType.causal;
      case 3:
        return CorrelationType.complementary;
      default:
        return CorrelationType.positive;
    }
  }

  @override
  void write(BinaryWriter writer, CorrelationType obj) {
    switch (obj) {
      case CorrelationType.positive:
        writer.writeByte(0);
        break;
      case CorrelationType.negative:
        writer.writeByte(1);
        break;
      case CorrelationType.causal:
        writer.writeByte(2);
        break;
      case CorrelationType.complementary:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CorrelationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QualityTrendAdapter extends TypeAdapter<QualityTrend> {
  @override
  final int typeId = 41;

  @override
  QualityTrend read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QualityTrend.improving;
      case 1:
        return QualityTrend.stable;
      case 2:
        return QualityTrend.declining;
      case 3:
        return QualityTrend.volatile;
      default:
        return QualityTrend.improving;
    }
  }

  @override
  void write(BinaryWriter writer, QualityTrend obj) {
    switch (obj) {
      case QualityTrend.improving:
        writer.writeByte(0);
        break;
      case QualityTrend.stable:
        writer.writeByte(1);
        break;
      case QualityTrend.declining:
        writer.writeByte(2);
        break;
      case QualityTrend.volatile:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QualityTrendAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DiversityTrendAdapter extends TypeAdapter<DiversityTrend> {
  @override
  final int typeId = 42;

  @override
  DiversityTrend read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DiversityTrend.expanding;
      case 1:
        return DiversityTrend.focusing;
      case 2:
        return DiversityTrend.stable;
      case 3:
        return DiversityTrend.cyclical;
      default:
        return DiversityTrend.expanding;
    }
  }

  @override
  void write(BinaryWriter writer, DiversityTrend obj) {
    switch (obj) {
      case DiversityTrend.expanding:
        writer.writeByte(0);
        break;
      case DiversityTrend.focusing:
        writer.writeByte(1);
        break;
      case DiversityTrend.stable:
        writer.writeByte(2);
        break;
      case DiversityTrend.cyclical:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiversityTrendAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
