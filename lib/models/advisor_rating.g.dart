// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advisor_rating.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AdvisorRatingAdapter extends TypeAdapter<AdvisorRating> {
  @override
  final int typeId = 26;

  @override
  AdvisorRating read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdvisorRating(
      id: fields[0] as String,
      invitationId: fields[1] as String,
      overallRating: fields[2] as int,
      insightfulness: fields[3] as int,
      specificity: fields[4] as int,
      helpfulness: fields[5] as int,
      positiveAspects: fields[6] as String?,
      improvementAreas: fields[7] as String?,
      ratedAt: fields[8] as DateTime,
      wouldRecommendAdvisor: fields[9] as bool,
      advisorStrengths: (fields[10] as List?)?.cast<AdvisorStrengthArea>(),
      additionalFeedback: fields[11] as String?,
      isAnonymousFeedback: fields[12] as bool,
      responseTimeliness: fields[13] as AdvisorResponseTimeliness,
      questionSpecificRatings: (fields[14] as Map?)?.cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, AdvisorRating obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.invitationId)
      ..writeByte(2)
      ..write(obj.overallRating)
      ..writeByte(3)
      ..write(obj.insightfulness)
      ..writeByte(4)
      ..write(obj.specificity)
      ..writeByte(5)
      ..write(obj.helpfulness)
      ..writeByte(6)
      ..write(obj.positiveAspects)
      ..writeByte(7)
      ..write(obj.improvementAreas)
      ..writeByte(8)
      ..write(obj.ratedAt)
      ..writeByte(9)
      ..write(obj.wouldRecommendAdvisor)
      ..writeByte(10)
      ..write(obj.advisorStrengths)
      ..writeByte(11)
      ..write(obj.additionalFeedback)
      ..writeByte(12)
      ..write(obj.isAnonymousFeedback)
      ..writeByte(13)
      ..write(obj.responseTimeliness)
      ..writeByte(14)
      ..write(obj.questionSpecificRatings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdvisorRatingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AdvisorStrengthAreaAdapter extends TypeAdapter<AdvisorStrengthArea> {
  @override
  final int typeId = 27;

  @override
  AdvisorStrengthArea read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AdvisorStrengthArea.specificExamples;
      case 1:
        return AdvisorStrengthArea.honestFeedback;
      case 2:
        return AdvisorStrengthArea.insightfulObservations;
      case 3:
        return AdvisorStrengthArea.constructiveCriticism;
      case 4:
        return AdvisorStrengthArea.detailedResponses;
      case 5:
        return AdvisorStrengthArea.contextualUnderstanding;
      case 6:
        return AdvisorStrengthArea.balancedPerspective;
      case 7:
        return AdvisorStrengthArea.actionableAdvice;
      case 8:
        return AdvisorStrengthArea.supportiveApproach;
      case 9:
        return AdvisorStrengthArea.professionalInsight;
      default:
        return AdvisorStrengthArea.specificExamples;
    }
  }

  @override
  void write(BinaryWriter writer, AdvisorStrengthArea obj) {
    switch (obj) {
      case AdvisorStrengthArea.specificExamples:
        writer.writeByte(0);
        break;
      case AdvisorStrengthArea.honestFeedback:
        writer.writeByte(1);
        break;
      case AdvisorStrengthArea.insightfulObservations:
        writer.writeByte(2);
        break;
      case AdvisorStrengthArea.constructiveCriticism:
        writer.writeByte(3);
        break;
      case AdvisorStrengthArea.detailedResponses:
        writer.writeByte(4);
        break;
      case AdvisorStrengthArea.contextualUnderstanding:
        writer.writeByte(5);
        break;
      case AdvisorStrengthArea.balancedPerspective:
        writer.writeByte(6);
        break;
      case AdvisorStrengthArea.actionableAdvice:
        writer.writeByte(7);
        break;
      case AdvisorStrengthArea.supportiveApproach:
        writer.writeByte(8);
        break;
      case AdvisorStrengthArea.professionalInsight:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdvisorStrengthAreaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AdvisorResponseTimelinessAdapter
    extends TypeAdapter<AdvisorResponseTimeliness> {
  @override
  final int typeId = 28;

  @override
  AdvisorResponseTimeliness read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AdvisorResponseTimeliness.veryPrompt;
      case 1:
        return AdvisorResponseTimeliness.prompt;
      case 2:
        return AdvisorResponseTimeliness.reasonable;
      case 3:
        return AdvisorResponseTimeliness.slow;
      case 4:
        return AdvisorResponseTimeliness.verySlow;
      default:
        return AdvisorResponseTimeliness.veryPrompt;
    }
  }

  @override
  void write(BinaryWriter writer, AdvisorResponseTimeliness obj) {
    switch (obj) {
      case AdvisorResponseTimeliness.veryPrompt:
        writer.writeByte(0);
        break;
      case AdvisorResponseTimeliness.prompt:
        writer.writeByte(1);
        break;
      case AdvisorResponseTimeliness.reasonable:
        writer.writeByte(2);
        break;
      case AdvisorResponseTimeliness.slow:
        writer.writeByte(3);
        break;
      case AdvisorResponseTimeliness.verySlow:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdvisorResponseTimelinessAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
