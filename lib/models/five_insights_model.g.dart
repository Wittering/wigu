// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'five_insights_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FiveInsightsModelAdapter extends TypeAdapter<FiveInsightsModel> {
  @override
  final int typeId = 90;

  @override
  FiveInsightsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FiveInsightsModel(
      id: fields[0] as String,
      sessionId: fields[1] as String,
      generatedAt: fields[2] as DateTime,
      energisingStrengths: (fields[3] as List).cast<EnergisrengStrength>(),
      hiddenStrengths: (fields[4] as List).cast<HiddenStrength>(),
      overusedTalents: (fields[5] as List).cast<OverusedTalent>(),
      aspirationalStrengths: (fields[6] as List).cast<AspirationalStrength>(),
      misalignedEnergies: (fields[7] as List).cast<MisalignedEnergy>(),
      executiveSummary: fields[8] as String?,
      balanceScore: fields[9] as double,
      keyRecommendations: (fields[10] as List).cast<String>(),
      metadata: (fields[11] as Map?)?.cast<String, dynamic>(),
      lastUpdated: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, FiveInsightsModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sessionId)
      ..writeByte(2)
      ..write(obj.generatedAt)
      ..writeByte(3)
      ..write(obj.energisingStrengths)
      ..writeByte(4)
      ..write(obj.hiddenStrengths)
      ..writeByte(5)
      ..write(obj.overusedTalents)
      ..writeByte(6)
      ..write(obj.aspirationalStrengths)
      ..writeByte(7)
      ..write(obj.misalignedEnergies)
      ..writeByte(8)
      ..write(obj.executiveSummary)
      ..writeByte(9)
      ..write(obj.balanceScore)
      ..writeByte(10)
      ..write(obj.keyRecommendations)
      ..writeByte(11)
      ..write(obj.metadata)
      ..writeByte(12)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FiveInsightsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EnergisrengStrengthAdapter extends TypeAdapter<EnergisrengStrength> {
  @override
  final int typeId = 91;

  @override
  EnergisrengStrength read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EnergisrengStrength(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      skillLevel: fields[3] as int,
      energyLevel: fields[4] as int,
      recognitionLevel: fields[5] as int,
      leverageability: fields[6] as int,
      evidenceFromSelf: (fields[7] as List).cast<String>(),
      evidenceFromOthers: (fields[8] as List).cast<String>(),
      actionableAdvice: fields[9] as String?,
      applicationAreas: (fields[10] as List).cast<String>(),
      confidence: fields[11] as double,
    );
  }

  @override
  void write(BinaryWriter writer, EnergisrengStrength obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.skillLevel)
      ..writeByte(4)
      ..write(obj.energyLevel)
      ..writeByte(5)
      ..write(obj.recognitionLevel)
      ..writeByte(6)
      ..write(obj.leverageability)
      ..writeByte(7)
      ..write(obj.evidenceFromSelf)
      ..writeByte(8)
      ..write(obj.evidenceFromOthers)
      ..writeByte(9)
      ..write(obj.actionableAdvice)
      ..writeByte(10)
      ..write(obj.applicationAreas)
      ..writeByte(11)
      ..write(obj.confidence);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnergisrengStrengthAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiddenStrengthAdapter extends TypeAdapter<HiddenStrength> {
  @override
  final int typeId = 92;

  @override
  HiddenStrength read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiddenStrength(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      competenceLevel: fields[3] as int,
      currentRecognition: fields[4] as int,
      potentialImpact: fields[5] as int,
      hiddenFactors: (fields[6] as List).cast<String>(),
      developmentStrategy: fields[7] as String?,
      visibilityOpportunities: (fields[8] as List).cast<String>(),
      confidence: fields[9] as double,
    );
  }

  @override
  void write(BinaryWriter writer, HiddenStrength obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.competenceLevel)
      ..writeByte(4)
      ..write(obj.currentRecognition)
      ..writeByte(5)
      ..write(obj.potentialImpact)
      ..writeByte(6)
      ..write(obj.hiddenFactors)
      ..writeByte(7)
      ..write(obj.developmentStrategy)
      ..writeByte(8)
      ..write(obj.visibilityOpportunities)
      ..writeByte(9)
      ..write(obj.confidence);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiddenStrengthAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OverusedTalentAdapter extends TypeAdapter<OverusedTalent> {
  @override
  final int typeId = 93;

  @override
  OverusedTalent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OverusedTalent(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      talentLevel: fields[3] as int,
      usageFrequency: fields[4] as int,
      burnoutRisk: fields[5] as int,
      overuseIndicators: (fields[6] as List).cast<String>(),
      rebalancingStrategy: fields[7] as String?,
      alternativeApplications: (fields[8] as List).cast<String>(),
      confidence: fields[9] as double,
    );
  }

  @override
  void write(BinaryWriter writer, OverusedTalent obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.talentLevel)
      ..writeByte(4)
      ..write(obj.usageFrequency)
      ..writeByte(5)
      ..write(obj.burnoutRisk)
      ..writeByte(6)
      ..write(obj.overuseIndicators)
      ..writeByte(7)
      ..write(obj.rebalancingStrategy)
      ..writeByte(8)
      ..write(obj.alternativeApplications)
      ..writeByte(9)
      ..write(obj.confidence);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverusedTalentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AspirationalStrengthAdapter extends TypeAdapter<AspirationalStrength> {
  @override
  final int typeId = 94;

  @override
  AspirationalStrength read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AspirationalStrength(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      currentLevel: fields[3] as int,
      interestLevel: fields[4] as int,
      developmentPotential: fields[5] as int,
      developmentPlan: fields[6] as String?,
      requiredResources: (fields[7] as List).cast<String>(),
      timeframe: fields[8] as int,
      confidence: fields[9] as double,
    );
  }

  @override
  void write(BinaryWriter writer, AspirationalStrength obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.currentLevel)
      ..writeByte(4)
      ..write(obj.interestLevel)
      ..writeByte(5)
      ..write(obj.developmentPotential)
      ..writeByte(6)
      ..write(obj.developmentPlan)
      ..writeByte(7)
      ..write(obj.requiredResources)
      ..writeByte(8)
      ..write(obj.timeframe)
      ..writeByte(9)
      ..write(obj.confidence);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AspirationalStrengthAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MisalignedEnergyAdapter extends TypeAdapter<MisalignedEnergy> {
  @override
  final int typeId = 95;

  @override
  MisalignedEnergy read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MisalignedEnergy(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      competenceLevel: fields[3] as int,
      energyDrainLevel: fields[4] as int,
      frequency: fields[5] as int,
      drainFactors: (fields[6] as List).cast<String>(),
      mitigationStrategy: fields[7] as String?,
      alternativeApproaches: (fields[8] as List).cast<String>(),
      confidence: fields[9] as double,
    );
  }

  @override
  void write(BinaryWriter writer, MisalignedEnergy obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.competenceLevel)
      ..writeByte(4)
      ..write(obj.energyDrainLevel)
      ..writeByte(5)
      ..write(obj.frequency)
      ..writeByte(6)
      ..write(obj.drainFactors)
      ..writeByte(7)
      ..write(obj.mitigationStrategy)
      ..writeByte(8)
      ..write(obj.alternativeApproaches)
      ..writeByte(9)
      ..write(obj.confidence);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MisalignedEnergyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InsightCategoryAdapter extends TypeAdapter<InsightCategory> {
  @override
  final int typeId = 96;

  @override
  InsightCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InsightCategory.energising;
      case 1:
        return InsightCategory.hidden;
      case 2:
        return InsightCategory.overused;
      case 3:
        return InsightCategory.aspirational;
      case 4:
        return InsightCategory.misaligned;
      default:
        return InsightCategory.energising;
    }
  }

  @override
  void write(BinaryWriter writer, InsightCategory obj) {
    switch (obj) {
      case InsightCategory.energising:
        writer.writeByte(0);
        break;
      case InsightCategory.hidden:
        writer.writeByte(1);
        break;
      case InsightCategory.overused:
        writer.writeByte(2);
        break;
      case InsightCategory.aspirational:
        writer.writeByte(3);
        break;
      case InsightCategory.misaligned:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InsightCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
