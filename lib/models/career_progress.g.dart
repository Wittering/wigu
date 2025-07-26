// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'career_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CareerProgressAdapter extends TypeAdapter<CareerProgress> {
  @override
  final int typeId = 100;

  @override
  CareerProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CareerProgress(
      id: fields[0] as String,
      sessionId: fields[1] as String,
      startedAt: fields[2] as DateTime,
      lastUpdated: fields[3] as DateTime,
      overallCompletion: fields[4] as double,
      domainProgress: (fields[5] as Map).cast<CareerDomain, DomainProgress>(),
      milestones: (fields[6] as List).cast<ProgressMilestone>(),
      currentPhase: fields[7] as ProgressPhase,
      engagementMetrics: (fields[8] as Map).cast<String, int>(),
      completedQuestionIds: (fields[9] as List).cast<String>(),
      skippedQuestionIds: (fields[10] as List).cast<String>(),
      totalTimeSpentMinutes: fields[11] as int,
      qualityAssessment: fields[12] as ProgressQuality,
      insights: (fields[13] as List).cast<String>(),
      metadata: (fields[14] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, CareerProgress obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sessionId)
      ..writeByte(2)
      ..write(obj.startedAt)
      ..writeByte(3)
      ..write(obj.lastUpdated)
      ..writeByte(4)
      ..write(obj.overallCompletion)
      ..writeByte(5)
      ..write(obj.domainProgress)
      ..writeByte(6)
      ..write(obj.milestones)
      ..writeByte(7)
      ..write(obj.currentPhase)
      ..writeByte(8)
      ..write(obj.engagementMetrics)
      ..writeByte(9)
      ..write(obj.completedQuestionIds)
      ..writeByte(10)
      ..write(obj.skippedQuestionIds)
      ..writeByte(11)
      ..write(obj.totalTimeSpentMinutes)
      ..writeByte(12)
      ..write(obj.qualityAssessment)
      ..writeByte(13)
      ..write(obj.insights)
      ..writeByte(14)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareerProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DomainProgressAdapter extends TypeAdapter<DomainProgress> {
  @override
  final int typeId = 101;

  @override
  DomainProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DomainProgress(
      domain: fields[0] as CareerDomain,
      completion: fields[1] as double,
      questionsCompleted: fields[2] as int,
      totalQuestions: fields[3] as int,
      lastActivity: fields[4] as DateTime?,
      timeSpentMinutes: fields[5] as int,
      engagement: fields[6] as DomainEngagement,
      keyInsights: (fields[7] as List).cast<String>(),
      qualityScore: fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, DomainProgress obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.domain)
      ..writeByte(1)
      ..write(obj.completion)
      ..writeByte(2)
      ..write(obj.questionsCompleted)
      ..writeByte(3)
      ..write(obj.totalQuestions)
      ..writeByte(4)
      ..write(obj.lastActivity)
      ..writeByte(5)
      ..write(obj.timeSpentMinutes)
      ..writeByte(6)
      ..write(obj.engagement)
      ..writeByte(7)
      ..write(obj.keyInsights)
      ..writeByte(8)
      ..write(obj.qualityScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DomainProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProgressMilestoneAdapter extends TypeAdapter<ProgressMilestone> {
  @override
  final int typeId = 102;

  @override
  ProgressMilestone read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgressMilestone(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as MilestoneType,
      priority: fields[4] as MilestonePriority,
      isCompleted: fields[5] as bool,
      completedAt: fields[6] as DateTime?,
      targetDate: fields[7] as DateTime?,
      successCriteria: (fields[8] as List).cast<String>(),
      notes: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProgressMilestone obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.completedAt)
      ..writeByte(7)
      ..write(obj.targetDate)
      ..writeByte(8)
      ..write(obj.successCriteria)
      ..writeByte(9)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressMilestoneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProgressPhaseAdapter extends TypeAdapter<ProgressPhase> {
  @override
  final int typeId = 103;

  @override
  ProgressPhase read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProgressPhase.setup;
      case 1:
        return ProgressPhase.exploration;
      case 2:
        return ProgressPhase.deepening;
      case 3:
        return ProgressPhase.synthesis;
      case 4:
        return ProgressPhase.planning;
      case 5:
        return ProgressPhase.implementation;
      case 6:
        return ProgressPhase.review;
      default:
        return ProgressPhase.setup;
    }
  }

  @override
  void write(BinaryWriter writer, ProgressPhase obj) {
    switch (obj) {
      case ProgressPhase.setup:
        writer.writeByte(0);
        break;
      case ProgressPhase.exploration:
        writer.writeByte(1);
        break;
      case ProgressPhase.deepening:
        writer.writeByte(2);
        break;
      case ProgressPhase.synthesis:
        writer.writeByte(3);
        break;
      case ProgressPhase.planning:
        writer.writeByte(4);
        break;
      case ProgressPhase.implementation:
        writer.writeByte(5);
        break;
      case ProgressPhase.review:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressPhaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProgressQualityAdapter extends TypeAdapter<ProgressQuality> {
  @override
  final int typeId = 104;

  @override
  ProgressQuality read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProgressQuality.poor;
      case 1:
        return ProgressQuality.fair;
      case 2:
        return ProgressQuality.good;
      case 3:
        return ProgressQuality.excellent;
      default:
        return ProgressQuality.poor;
    }
  }

  @override
  void write(BinaryWriter writer, ProgressQuality obj) {
    switch (obj) {
      case ProgressQuality.poor:
        writer.writeByte(0);
        break;
      case ProgressQuality.fair:
        writer.writeByte(1);
        break;
      case ProgressQuality.good:
        writer.writeByte(2);
        break;
      case ProgressQuality.excellent:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressQualityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DomainEngagementAdapter extends TypeAdapter<DomainEngagement> {
  @override
  final int typeId = 105;

  @override
  DomainEngagement read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DomainEngagement.low;
      case 1:
        return DomainEngagement.moderate;
      case 2:
        return DomainEngagement.high;
      case 3:
        return DomainEngagement.exceptional;
      default:
        return DomainEngagement.low;
    }
  }

  @override
  void write(BinaryWriter writer, DomainEngagement obj) {
    switch (obj) {
      case DomainEngagement.low:
        writer.writeByte(0);
        break;
      case DomainEngagement.moderate:
        writer.writeByte(1);
        break;
      case DomainEngagement.high:
        writer.writeByte(2);
        break;
      case DomainEngagement.exceptional:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DomainEngagementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MilestoneTypeAdapter extends TypeAdapter<MilestoneType> {
  @override
  final int typeId = 106;

  @override
  MilestoneType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MilestoneType.exploration;
      case 1:
        return MilestoneType.insight;
      case 2:
        return MilestoneType.synthesis;
      case 3:
        return MilestoneType.experiment;
      case 4:
        return MilestoneType.planning;
      case 5:
        return MilestoneType.reflection;
      default:
        return MilestoneType.exploration;
    }
  }

  @override
  void write(BinaryWriter writer, MilestoneType obj) {
    switch (obj) {
      case MilestoneType.exploration:
        writer.writeByte(0);
        break;
      case MilestoneType.insight:
        writer.writeByte(1);
        break;
      case MilestoneType.synthesis:
        writer.writeByte(2);
        break;
      case MilestoneType.experiment:
        writer.writeByte(3);
        break;
      case MilestoneType.planning:
        writer.writeByte(4);
        break;
      case MilestoneType.reflection:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MilestoneTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MilestonePriorityAdapter extends TypeAdapter<MilestonePriority> {
  @override
  final int typeId = 107;

  @override
  MilestonePriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MilestonePriority.low;
      case 1:
        return MilestonePriority.medium;
      case 2:
        return MilestonePriority.high;
      case 3:
        return MilestonePriority.urgent;
      default:
        return MilestonePriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, MilestonePriority obj) {
    switch (obj) {
      case MilestonePriority.low:
        writer.writeByte(0);
        break;
      case MilestonePriority.medium:
        writer.writeByte(1);
        break;
      case MilestonePriority.high:
        writer.writeByte(2);
        break;
      case MilestonePriority.urgent:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MilestonePriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
