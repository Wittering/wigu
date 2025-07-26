// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experiment_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExperimentResultAdapter extends TypeAdapter<ExperimentResult> {
  @override
  final int typeId = 60;

  @override
  ExperimentResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExperimentResult(
      id: fields[0] as String,
      experimentId: fields[1] as String,
      completedAt: fields[2] as DateTime,
      outcome: fields[3] as ExperimentOutcome,
      metricResults: (fields[4] as List).cast<MetricResult>(),
      executiveSummary: fields[5] as String,
      keyLearnings: (fields[6] as List).cast<String>(),
      unexpectedOutcomes: (fields[7] as List).cast<String>(),
      hypothesisValidation: fields[8] as String,
      successScore: fields[9] as double,
      challengesFaced: (fields[10] as List).cast<String>(),
      successFactors: (fields[11] as List).cast<String>(),
      nextSteps: (fields[12] as List).cast<String>(),
      futureExperimentIdeas: (fields[13] as List).cast<String>(),
      confidence: fields[14] as ResultConfidence,
      stakeholderFeedback: (fields[15] as Map?)?.cast<String, String>(),
      evidenceFiles: (fields[16] as List?)?.cast<String>(),
      personalReflection: fields[17] as String?,
      metadata: (fields[18] as Map?)?.cast<String, dynamic>(),
      lastUpdated: fields[19] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ExperimentResult obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.experimentId)
      ..writeByte(2)
      ..write(obj.completedAt)
      ..writeByte(3)
      ..write(obj.outcome)
      ..writeByte(4)
      ..write(obj.metricResults)
      ..writeByte(5)
      ..write(obj.executiveSummary)
      ..writeByte(6)
      ..write(obj.keyLearnings)
      ..writeByte(7)
      ..write(obj.unexpectedOutcomes)
      ..writeByte(8)
      ..write(obj.hypothesisValidation)
      ..writeByte(9)
      ..write(obj.successScore)
      ..writeByte(10)
      ..write(obj.challengesFaced)
      ..writeByte(11)
      ..write(obj.successFactors)
      ..writeByte(12)
      ..write(obj.nextSteps)
      ..writeByte(13)
      ..write(obj.futureExperimentIdeas)
      ..writeByte(14)
      ..write(obj.confidence)
      ..writeByte(15)
      ..write(obj.stakeholderFeedback)
      ..writeByte(16)
      ..write(obj.evidenceFiles)
      ..writeByte(17)
      ..write(obj.personalReflection)
      ..writeByte(18)
      ..write(obj.metadata)
      ..writeByte(19)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExperimentResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MetricResultAdapter extends TypeAdapter<MetricResult> {
  @override
  final int typeId = 61;

  @override
  MetricResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MetricResult(
      metricName: fields[0] as String,
      expectedValue: fields[1] as String,
      actualValue: fields[2] as String,
      metTarget: fields[3] as bool,
      commentary: fields[4] as String?,
      resultType: fields[5] as MetricResultType,
      quantitativeScore: fields[6] as double?,
      improvementSuggestion: fields[7] as String?,
      supportingEvidence: (fields[8] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, MetricResult obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.metricName)
      ..writeByte(1)
      ..write(obj.expectedValue)
      ..writeByte(2)
      ..write(obj.actualValue)
      ..writeByte(3)
      ..write(obj.metTarget)
      ..writeByte(4)
      ..write(obj.commentary)
      ..writeByte(5)
      ..write(obj.resultType)
      ..writeByte(6)
      ..write(obj.quantitativeScore)
      ..writeByte(7)
      ..write(obj.improvementSuggestion)
      ..writeByte(8)
      ..write(obj.supportingEvidence);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetricResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExperimentOutcomeAdapter extends TypeAdapter<ExperimentOutcome> {
  @override
  final int typeId = 62;

  @override
  ExperimentOutcome read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExperimentOutcome.successful;
      case 1:
        return ExperimentOutcome.partiallySuccessful;
      case 2:
        return ExperimentOutcome.unsuccessful;
      case 3:
        return ExperimentOutcome.inconclusive;
      case 4:
        return ExperimentOutcome.unexpectedSuccess;
      default:
        return ExperimentOutcome.successful;
    }
  }

  @override
  void write(BinaryWriter writer, ExperimentOutcome obj) {
    switch (obj) {
      case ExperimentOutcome.successful:
        writer.writeByte(0);
        break;
      case ExperimentOutcome.partiallySuccessful:
        writer.writeByte(1);
        break;
      case ExperimentOutcome.unsuccessful:
        writer.writeByte(2);
        break;
      case ExperimentOutcome.inconclusive:
        writer.writeByte(3);
        break;
      case ExperimentOutcome.unexpectedSuccess:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExperimentOutcomeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ResultConfidenceAdapter extends TypeAdapter<ResultConfidence> {
  @override
  final int typeId = 63;

  @override
  ResultConfidence read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ResultConfidence.high;
      case 1:
        return ResultConfidence.medium;
      case 2:
        return ResultConfidence.low;
      default:
        return ResultConfidence.high;
    }
  }

  @override
  void write(BinaryWriter writer, ResultConfidence obj) {
    switch (obj) {
      case ResultConfidence.high:
        writer.writeByte(0);
        break;
      case ResultConfidence.medium:
        writer.writeByte(1);
        break;
      case ResultConfidence.low:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultConfidenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ResultRatingAdapter extends TypeAdapter<ResultRating> {
  @override
  final int typeId = 64;

  @override
  ResultRating read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ResultRating.excellent;
      case 1:
        return ResultRating.good;
      case 2:
        return ResultRating.mixed;
      case 3:
        return ResultRating.poor;
      case 4:
        return ResultRating.failed;
      default:
        return ResultRating.excellent;
    }
  }

  @override
  void write(BinaryWriter writer, ResultRating obj) {
    switch (obj) {
      case ResultRating.excellent:
        writer.writeByte(0);
        break;
      case ResultRating.good:
        writer.writeByte(1);
        break;
      case ResultRating.mixed:
        writer.writeByte(2);
        break;
      case ResultRating.poor:
        writer.writeByte(3);
        break;
      case ResultRating.failed:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultRatingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MetricResultTypeAdapter extends TypeAdapter<MetricResultType> {
  @override
  final int typeId = 65;

  @override
  MetricResultType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MetricResultType.exceeded;
      case 1:
        return MetricResultType.met;
      case 2:
        return MetricResultType.nearlyMet;
      case 3:
        return MetricResultType.missed;
      case 4:
        return MetricResultType.significantlyMissed;
      default:
        return MetricResultType.exceeded;
    }
  }

  @override
  void write(BinaryWriter writer, MetricResultType obj) {
    switch (obj) {
      case MetricResultType.exceeded:
        writer.writeByte(0);
        break;
      case MetricResultType.met:
        writer.writeByte(1);
        break;
      case MetricResultType.nearlyMet:
        writer.writeByte(2);
        break;
      case MetricResultType.missed:
        writer.writeByte(3);
        break;
      case MetricResultType.significantlyMissed:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetricResultTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
