// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'career_experiment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CareerExperimentAdapter extends TypeAdapter<CareerExperiment> {
  @override
  final int typeId = 50;

  @override
  CareerExperiment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CareerExperiment(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as ExperimentType,
      hypothesis: fields[4] as String,
      relatedInsightIds: (fields[5] as List).cast<String>(),
      createdAt: fields[6] as DateTime,
      startedAt: fields[7] as DateTime?,
      completedAt: fields[8] as DateTime?,
      status: fields[9] as ExperimentStatus,
      scope: fields[10] as ExperimentScope,
      estimatedDurationDays: fields[11] as int,
      successCriteria: (fields[12] as List).cast<String>(),
      metrics: (fields[13] as List).cast<ExperimentMetric>(),
      requiredResources: (fields[14] as List).cast<String>(),
      potentialBarriers: (fields[15] as List).cast<String>(),
      priority: fields[16] as ExperimentPriority,
      sessionId: fields[17] as String?,
      metadata: (fields[18] as Map?)?.cast<String, dynamic>(),
      tags: (fields[19] as List?)?.cast<String>(),
      preparationNotes: fields[20] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CareerExperiment obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.hypothesis)
      ..writeByte(5)
      ..write(obj.relatedInsightIds)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.startedAt)
      ..writeByte(8)
      ..write(obj.completedAt)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.scope)
      ..writeByte(11)
      ..write(obj.estimatedDurationDays)
      ..writeByte(12)
      ..write(obj.successCriteria)
      ..writeByte(13)
      ..write(obj.metrics)
      ..writeByte(14)
      ..write(obj.requiredResources)
      ..writeByte(15)
      ..write(obj.potentialBarriers)
      ..writeByte(16)
      ..write(obj.priority)
      ..writeByte(17)
      ..write(obj.sessionId)
      ..writeByte(18)
      ..write(obj.metadata)
      ..writeByte(19)
      ..write(obj.tags)
      ..writeByte(20)
      ..write(obj.preparationNotes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareerExperimentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExperimentMetricAdapter extends TypeAdapter<ExperimentMetric> {
  @override
  final int typeId = 51;

  @override
  ExperimentMetric read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExperimentMetric(
      name: fields[0] as String,
      description: fields[1] as String,
      type: fields[2] as MetricType,
      measurementMethod: fields[3] as String,
      targetValue: fields[4] as String?,
      baseline: fields[5] as String?,
      frequency: fields[6] as MetricFrequency,
    );
  }

  @override
  void write(BinaryWriter writer, ExperimentMetric obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.measurementMethod)
      ..writeByte(4)
      ..write(obj.targetValue)
      ..writeByte(5)
      ..write(obj.baseline)
      ..writeByte(6)
      ..write(obj.frequency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExperimentMetricAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExperimentTypeAdapter extends TypeAdapter<ExperimentType> {
  @override
  final int typeId = 52;

  @override
  ExperimentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExperimentType.skillBuilding;
      case 1:
        return ExperimentType.roleExploration;
      case 2:
        return ExperimentType.networking;
      case 3:
        return ExperimentType.visibilityBuilding;
      case 4:
        return ExperimentType.leadershipDevelopment;
      case 5:
        return ExperimentType.workEnvironment;
      case 6:
        return ExperimentType.industryExploration;
      case 7:
        return ExperimentType.valueAlignment;
      case 8:
        return ExperimentType.creativityExpression;
      case 9:
        return ExperimentType.mentoring;
      default:
        return ExperimentType.skillBuilding;
    }
  }

  @override
  void write(BinaryWriter writer, ExperimentType obj) {
    switch (obj) {
      case ExperimentType.skillBuilding:
        writer.writeByte(0);
        break;
      case ExperimentType.roleExploration:
        writer.writeByte(1);
        break;
      case ExperimentType.networking:
        writer.writeByte(2);
        break;
      case ExperimentType.visibilityBuilding:
        writer.writeByte(3);
        break;
      case ExperimentType.leadershipDevelopment:
        writer.writeByte(4);
        break;
      case ExperimentType.workEnvironment:
        writer.writeByte(5);
        break;
      case ExperimentType.industryExploration:
        writer.writeByte(6);
        break;
      case ExperimentType.valueAlignment:
        writer.writeByte(7);
        break;
      case ExperimentType.creativityExpression:
        writer.writeByte(8);
        break;
      case ExperimentType.mentoring:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExperimentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExperimentStatusAdapter extends TypeAdapter<ExperimentStatus> {
  @override
  final int typeId = 53;

  @override
  ExperimentStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExperimentStatus.planned;
      case 1:
        return ExperimentStatus.active;
      case 2:
        return ExperimentStatus.paused;
      case 3:
        return ExperimentStatus.completed;
      case 4:
        return ExperimentStatus.cancelled;
      default:
        return ExperimentStatus.planned;
    }
  }

  @override
  void write(BinaryWriter writer, ExperimentStatus obj) {
    switch (obj) {
      case ExperimentStatus.planned:
        writer.writeByte(0);
        break;
      case ExperimentStatus.active:
        writer.writeByte(1);
        break;
      case ExperimentStatus.paused:
        writer.writeByte(2);
        break;
      case ExperimentStatus.completed:
        writer.writeByte(3);
        break;
      case ExperimentStatus.cancelled:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExperimentStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExperimentScopeAdapter extends TypeAdapter<ExperimentScope> {
  @override
  final int typeId = 54;

  @override
  ExperimentScope read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExperimentScope.personal;
      case 1:
        return ExperimentScope.team;
      case 2:
        return ExperimentScope.organisational;
      case 3:
        return ExperimentScope.external;
      default:
        return ExperimentScope.personal;
    }
  }

  @override
  void write(BinaryWriter writer, ExperimentScope obj) {
    switch (obj) {
      case ExperimentScope.personal:
        writer.writeByte(0);
        break;
      case ExperimentScope.team:
        writer.writeByte(1);
        break;
      case ExperimentScope.organisational:
        writer.writeByte(2);
        break;
      case ExperimentScope.external:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExperimentScopeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExperimentPriorityAdapter extends TypeAdapter<ExperimentPriority> {
  @override
  final int typeId = 55;

  @override
  ExperimentPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExperimentPriority.low;
      case 1:
        return ExperimentPriority.medium;
      case 2:
        return ExperimentPriority.high;
      case 3:
        return ExperimentPriority.urgent;
      default:
        return ExperimentPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, ExperimentPriority obj) {
    switch (obj) {
      case ExperimentPriority.low:
        writer.writeByte(0);
        break;
      case ExperimentPriority.medium:
        writer.writeByte(1);
        break;
      case ExperimentPriority.high:
        writer.writeByte(2);
        break;
      case ExperimentPriority.urgent:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExperimentPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExperimentComplexityAdapter extends TypeAdapter<ExperimentComplexity> {
  @override
  final int typeId = 56;

  @override
  ExperimentComplexity read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExperimentComplexity.low;
      case 1:
        return ExperimentComplexity.medium;
      case 2:
        return ExperimentComplexity.high;
      default:
        return ExperimentComplexity.low;
    }
  }

  @override
  void write(BinaryWriter writer, ExperimentComplexity obj) {
    switch (obj) {
      case ExperimentComplexity.low:
        writer.writeByte(0);
        break;
      case ExperimentComplexity.medium:
        writer.writeByte(1);
        break;
      case ExperimentComplexity.high:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExperimentComplexityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MetricTypeAdapter extends TypeAdapter<MetricType> {
  @override
  final int typeId = 57;

  @override
  MetricType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MetricType.quantitative;
      case 1:
        return MetricType.qualitative;
      case 2:
        return MetricType.behavioral;
      case 3:
        return MetricType.feedback;
      case 4:
        return MetricType.outcome;
      default:
        return MetricType.quantitative;
    }
  }

  @override
  void write(BinaryWriter writer, MetricType obj) {
    switch (obj) {
      case MetricType.quantitative:
        writer.writeByte(0);
        break;
      case MetricType.qualitative:
        writer.writeByte(1);
        break;
      case MetricType.behavioral:
        writer.writeByte(2);
        break;
      case MetricType.feedback:
        writer.writeByte(3);
        break;
      case MetricType.outcome:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetricTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MetricFrequencyAdapter extends TypeAdapter<MetricFrequency> {
  @override
  final int typeId = 58;

  @override
  MetricFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MetricFrequency.daily;
      case 1:
        return MetricFrequency.weekly;
      case 2:
        return MetricFrequency.biweekly;
      case 3:
        return MetricFrequency.monthly;
      case 4:
        return MetricFrequency.atCompletion;
      default:
        return MetricFrequency.daily;
    }
  }

  @override
  void write(BinaryWriter writer, MetricFrequency obj) {
    switch (obj) {
      case MetricFrequency.daily:
        writer.writeByte(0);
        break;
      case MetricFrequency.weekly:
        writer.writeByte(1);
        break;
      case MetricFrequency.biweekly:
        writer.writeByte(2);
        break;
      case MetricFrequency.monthly:
        writer.writeByte(3);
        break;
      case MetricFrequency.atCompletion:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetricFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
