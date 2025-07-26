// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completion_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompletionStatusAdapter extends TypeAdapter<CompletionStatus> {
  @override
  final int typeId = 110;

  @override
  CompletionStatus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompletionStatus(
      id: fields[0] as String,
      sessionId: fields[1] as String,
      lastUpdated: fields[2] as DateTime,
      categoryStatus:
          (fields[3] as Map).cast<CompletionCategory, CategoryStatus>(),
      completedItems: (fields[4] as List).cast<CompletionItem>(),
      pendingItems: (fields[5] as List).cast<CompletionItem>(),
      optionalItems: (fields[6] as List).cast<CompletionItem>(),
      overallCompletion: fields[7] as double,
      completionLevel: fields[8] as CompletionLevel,
      nextSteps: (fields[9] as List).cast<String>(),
      blockers: (fields[10] as List).cast<String>(),
      importantDeadlines: (fields[11] as Map).cast<String, DateTime>(),
      readinessAssessment: fields[12] as UserReadiness,
      recommendations: (fields[13] as List).cast<String>(),
      metadata: (fields[14] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, CompletionStatus obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sessionId)
      ..writeByte(2)
      ..write(obj.lastUpdated)
      ..writeByte(3)
      ..write(obj.categoryStatus)
      ..writeByte(4)
      ..write(obj.completedItems)
      ..writeByte(5)
      ..write(obj.pendingItems)
      ..writeByte(6)
      ..write(obj.optionalItems)
      ..writeByte(7)
      ..write(obj.overallCompletion)
      ..writeByte(8)
      ..write(obj.completionLevel)
      ..writeByte(9)
      ..write(obj.nextSteps)
      ..writeByte(10)
      ..write(obj.blockers)
      ..writeByte(11)
      ..write(obj.importantDeadlines)
      ..writeByte(12)
      ..write(obj.readinessAssessment)
      ..writeByte(13)
      ..write(obj.recommendations)
      ..writeByte(14)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CompletionItemAdapter extends TypeAdapter<CompletionItem> {
  @override
  final int typeId = 111;

  @override
  CompletionItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompletionItem(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as CompletionCategory,
      priority: fields[4] as ItemPriority,
      isCompleted: fields[5] as bool,
      completedAt: fields[6] as DateTime?,
      targetDate: fields[7] as DateTime?,
      dependencies: (fields[8] as List).cast<String>(),
      notes: fields[9] as String?,
      estimatedHours: fields[10] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CompletionItem obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.completedAt)
      ..writeByte(7)
      ..write(obj.targetDate)
      ..writeByte(8)
      ..write(obj.dependencies)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.estimatedHours);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CategoryStatusAdapter extends TypeAdapter<CategoryStatus> {
  @override
  final int typeId = 112;

  @override
  CategoryStatus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryStatus(
      category: fields[0] as CompletionCategory,
      completion: fields[1] as double,
      isBehindSchedule: fields[2] as bool,
      expectedCompletionDate: fields[3] as DateTime?,
      statusNotes: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryStatus obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.category)
      ..writeByte(1)
      ..write(obj.completion)
      ..writeByte(2)
      ..write(obj.isBehindSchedule)
      ..writeByte(3)
      ..write(obj.expectedCompletionDate)
      ..writeByte(4)
      ..write(obj.statusNotes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CompletionCategoryAdapter extends TypeAdapter<CompletionCategory> {
  @override
  final int typeId = 113;

  @override
  CompletionCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CompletionCategory.exploration;
      case 1:
        return CompletionCategory.advisorFeedback;
      case 2:
        return CompletionCategory.insightGeneration;
      case 3:
        return CompletionCategory.synthesis;
      case 4:
        return CompletionCategory.experimentation;
      case 5:
        return CompletionCategory.planning;
      case 6:
        return CompletionCategory.reporting;
      default:
        return CompletionCategory.exploration;
    }
  }

  @override
  void write(BinaryWriter writer, CompletionCategory obj) {
    switch (obj) {
      case CompletionCategory.exploration:
        writer.writeByte(0);
        break;
      case CompletionCategory.advisorFeedback:
        writer.writeByte(1);
        break;
      case CompletionCategory.insightGeneration:
        writer.writeByte(2);
        break;
      case CompletionCategory.synthesis:
        writer.writeByte(3);
        break;
      case CompletionCategory.experimentation:
        writer.writeByte(4);
        break;
      case CompletionCategory.planning:
        writer.writeByte(5);
        break;
      case CompletionCategory.reporting:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItemPriorityAdapter extends TypeAdapter<ItemPriority> {
  @override
  final int typeId = 114;

  @override
  ItemPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ItemPriority.low;
      case 1:
        return ItemPriority.medium;
      case 2:
        return ItemPriority.high;
      case 3:
        return ItemPriority.critical;
      default:
        return ItemPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, ItemPriority obj) {
    switch (obj) {
      case ItemPriority.low:
        writer.writeByte(0);
        break;
      case ItemPriority.medium:
        writer.writeByte(1);
        break;
      case ItemPriority.high:
        writer.writeByte(2);
        break;
      case ItemPriority.critical:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CompletionLevelAdapter extends TypeAdapter<CompletionLevel> {
  @override
  final int typeId = 115;

  @override
  CompletionLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CompletionLevel.starting;
      case 1:
        return CompletionLevel.exploring;
      case 2:
        return CompletionLevel.deepening;
      case 3:
        return CompletionLevel.synthesising;
      case 4:
        return CompletionLevel.planning;
      case 5:
        return CompletionLevel.implementing;
      case 6:
        return CompletionLevel.complete;
      default:
        return CompletionLevel.starting;
    }
  }

  @override
  void write(BinaryWriter writer, CompletionLevel obj) {
    switch (obj) {
      case CompletionLevel.starting:
        writer.writeByte(0);
        break;
      case CompletionLevel.exploring:
        writer.writeByte(1);
        break;
      case CompletionLevel.deepening:
        writer.writeByte(2);
        break;
      case CompletionLevel.synthesising:
        writer.writeByte(3);
        break;
      case CompletionLevel.planning:
        writer.writeByte(4);
        break;
      case CompletionLevel.implementing:
        writer.writeByte(5);
        break;
      case CompletionLevel.complete:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserReadinessAdapter extends TypeAdapter<UserReadiness> {
  @override
  final int typeId = 116;

  @override
  UserReadiness read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserReadiness.notReady;
      case 1:
        return UserReadiness.gettingReady;
      case 2:
        return UserReadiness.ready;
      case 3:
        return UserReadiness.veryReady;
      default:
        return UserReadiness.notReady;
    }
  }

  @override
  void write(BinaryWriter writer, UserReadiness obj) {
    switch (obj) {
      case UserReadiness.notReady:
        writer.writeByte(0);
        break;
      case UserReadiness.gettingReady:
        writer.writeByte(1);
        break;
      case UserReadiness.ready:
        writer.writeByte(2);
        break;
      case UserReadiness.veryReady:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserReadinessAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
