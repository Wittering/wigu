// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advisor_response.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AdvisorResponseAdapter extends TypeAdapter<AdvisorResponse> {
  @override
  final int typeId = 23;

  @override
  AdvisorResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdvisorResponse(
      id: fields[0] as String,
      invitationId: fields[1] as String,
      questionId: fields[2] as String,
      questionText: fields[3] as String,
      response: fields[4] as String,
      answeredAt: fields[5] as DateTime,
      domain: fields[6] as CareerDomain,
      confidenceLevel: fields[7] as int?,
      observationPeriod: fields[8] as AdvisorObservationPeriod,
      specificExamples: (fields[9] as List?)?.cast<String>(),
      confidenceContext: fields[10] as AdvisorConfidenceContext,
      additionalContext: fields[11] as String?,
      isAnonymous: fields[12] as bool,
      metadata: (fields[13] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, AdvisorResponse obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.invitationId)
      ..writeByte(2)
      ..write(obj.questionId)
      ..writeByte(3)
      ..write(obj.questionText)
      ..writeByte(4)
      ..write(obj.response)
      ..writeByte(5)
      ..write(obj.answeredAt)
      ..writeByte(6)
      ..write(obj.domain)
      ..writeByte(7)
      ..write(obj.confidenceLevel)
      ..writeByte(8)
      ..write(obj.observationPeriod)
      ..writeByte(9)
      ..write(obj.specificExamples)
      ..writeByte(10)
      ..write(obj.confidenceContext)
      ..writeByte(11)
      ..write(obj.additionalContext)
      ..writeByte(12)
      ..write(obj.isAnonymous)
      ..writeByte(13)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdvisorResponseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AdvisorObservationPeriodAdapter
    extends TypeAdapter<AdvisorObservationPeriod> {
  @override
  final int typeId = 24;

  @override
  AdvisorObservationPeriod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AdvisorObservationPeriod.lessThanMonth;
      case 1:
        return AdvisorObservationPeriod.oneToSixMonths;
      case 2:
        return AdvisorObservationPeriod.sixMonthsToYear;
      case 3:
        return AdvisorObservationPeriod.oneToThreeYears;
      case 4:
        return AdvisorObservationPeriod.moreThanThreeYears;
      default:
        return AdvisorObservationPeriod.lessThanMonth;
    }
  }

  @override
  void write(BinaryWriter writer, AdvisorObservationPeriod obj) {
    switch (obj) {
      case AdvisorObservationPeriod.lessThanMonth:
        writer.writeByte(0);
        break;
      case AdvisorObservationPeriod.oneToSixMonths:
        writer.writeByte(1);
        break;
      case AdvisorObservationPeriod.sixMonthsToYear:
        writer.writeByte(2);
        break;
      case AdvisorObservationPeriod.oneToThreeYears:
        writer.writeByte(3);
        break;
      case AdvisorObservationPeriod.moreThanThreeYears:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdvisorObservationPeriodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AdvisorConfidenceContextAdapter
    extends TypeAdapter<AdvisorConfidenceContext> {
  @override
  final int typeId = 25;

  @override
  AdvisorConfidenceContext read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AdvisorConfidenceContext.veryConfident;
      case 1:
        return AdvisorConfidenceContext.confident;
      case 2:
        return AdvisorConfidenceContext.somewhatConfident;
      case 3:
        return AdvisorConfidenceContext.limitedObservation;
      case 4:
        return AdvisorConfidenceContext.uncertain;
      default:
        return AdvisorConfidenceContext.veryConfident;
    }
  }

  @override
  void write(BinaryWriter writer, AdvisorConfidenceContext obj) {
    switch (obj) {
      case AdvisorConfidenceContext.veryConfident:
        writer.writeByte(0);
        break;
      case AdvisorConfidenceContext.confident:
        writer.writeByte(1);
        break;
      case AdvisorConfidenceContext.somewhatConfident:
        writer.writeByte(2);
        break;
      case AdvisorConfidenceContext.limitedObservation:
        writer.writeByte(3);
        break;
      case AdvisorConfidenceContext.uncertain:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdvisorConfidenceContextAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
