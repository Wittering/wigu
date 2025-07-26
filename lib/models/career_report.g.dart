// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'career_report.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CareerReportAdapter extends TypeAdapter<CareerReport> {
  @override
  final int typeId = 70;

  @override
  CareerReport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CareerReport(
      id: fields[0] as String,
      sessionId: fields[1] as String,
      title: fields[2] as String,
      type: fields[3] as ReportType,
      generatedAt: fields[4] as DateTime,
      includedInsightIds: (fields[5] as List).cast<String>(),
      synthesisId: fields[6] as String?,
      experimentResultIds: (fields[7] as List?)?.cast<String>(),
      format: fields[8] as ReportFormat,
      executiveSummary: fields[9] as String,
      sections: (fields[10] as List).cast<ReportSection>(),
      keyFindings: (fields[11] as List).cast<String>(),
      strategicRecommendations: (fields[12] as List).cast<String>(),
      nextSteps: (fields[13] as List).cast<String>(),
      visualisationData: (fields[14] as Map?)?.cast<String, dynamic>(),
      confidence: fields[15] as ReportConfidence,
      customBranding: fields[16] as String?,
      metadata: (fields[17] as Map?)?.cast<String, String>(),
      lastUpdated: fields[18] as DateTime?,
      isShareable: fields[19] as bool,
      sharingToken: fields[20] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CareerReport obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sessionId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.generatedAt)
      ..writeByte(5)
      ..write(obj.includedInsightIds)
      ..writeByte(6)
      ..write(obj.synthesisId)
      ..writeByte(7)
      ..write(obj.experimentResultIds)
      ..writeByte(8)
      ..write(obj.format)
      ..writeByte(9)
      ..write(obj.executiveSummary)
      ..writeByte(10)
      ..write(obj.sections)
      ..writeByte(11)
      ..write(obj.keyFindings)
      ..writeByte(12)
      ..write(obj.strategicRecommendations)
      ..writeByte(13)
      ..write(obj.nextSteps)
      ..writeByte(14)
      ..write(obj.visualisationData)
      ..writeByte(15)
      ..write(obj.confidence)
      ..writeByte(16)
      ..write(obj.customBranding)
      ..writeByte(17)
      ..write(obj.metadata)
      ..writeByte(18)
      ..write(obj.lastUpdated)
      ..writeByte(19)
      ..write(obj.isShareable)
      ..writeByte(20)
      ..write(obj.sharingToken);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareerReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReportSectionAdapter extends TypeAdapter<ReportSection> {
  @override
  final int typeId = 71;

  @override
  ReportSection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReportSection(
      id: fields[0] as String,
      title: fields[1] as String,
      subtitle: fields[2] as String?,
      content: fields[3] as String,
      type: fields[4] as SectionType,
      keyPoints: (fields[5] as List).cast<String>(),
      orderIndex: fields[6] as int,
      sectionData: (fields[7] as Map?)?.cast<String, dynamic>(),
      includeVisualisations: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ReportSection obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.subtitle)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.keyPoints)
      ..writeByte(6)
      ..write(obj.orderIndex)
      ..writeByte(7)
      ..write(obj.sectionData)
      ..writeByte(8)
      ..write(obj.includeVisualisations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportSectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReportTypeAdapter extends TypeAdapter<ReportType> {
  @override
  final int typeId = 72;

  @override
  ReportType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReportType.comprehensive;
      case 1:
        return ReportType.strengthsFocus;
      case 2:
        return ReportType.developmentPlan;
      case 3:
        return ReportType.synthesisReport;
      case 4:
        return ReportType.experimentSummary;
      case 5:
        return ReportType.executiveBrief;
      case 6:
        return ReportType.coachingReport;
      default:
        return ReportType.comprehensive;
    }
  }

  @override
  void write(BinaryWriter writer, ReportType obj) {
    switch (obj) {
      case ReportType.comprehensive:
        writer.writeByte(0);
        break;
      case ReportType.strengthsFocus:
        writer.writeByte(1);
        break;
      case ReportType.developmentPlan:
        writer.writeByte(2);
        break;
      case ReportType.synthesisReport:
        writer.writeByte(3);
        break;
      case ReportType.experimentSummary:
        writer.writeByte(4);
        break;
      case ReportType.executiveBrief:
        writer.writeByte(5);
        break;
      case ReportType.coachingReport:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReportFormatAdapter extends TypeAdapter<ReportFormat> {
  @override
  final int typeId = 73;

  @override
  ReportFormat read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReportFormat.markdown;
      case 1:
        return ReportFormat.pdf;
      case 2:
        return ReportFormat.word;
      case 3:
        return ReportFormat.html;
      case 4:
        return ReportFormat.json;
      default:
        return ReportFormat.markdown;
    }
  }

  @override
  void write(BinaryWriter writer, ReportFormat obj) {
    switch (obj) {
      case ReportFormat.markdown:
        writer.writeByte(0);
        break;
      case ReportFormat.pdf:
        writer.writeByte(1);
        break;
      case ReportFormat.word:
        writer.writeByte(2);
        break;
      case ReportFormat.html:
        writer.writeByte(3);
        break;
      case ReportFormat.json:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportFormatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SectionTypeAdapter extends TypeAdapter<SectionType> {
  @override
  final int typeId = 74;

  @override
  SectionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SectionType.overview;
      case 1:
        return SectionType.insights;
      case 2:
        return SectionType.strengths;
      case 3:
        return SectionType.development;
      case 4:
        return SectionType.synthesis;
      case 5:
        return SectionType.experiments;
      case 6:
        return SectionType.recommendations;
      case 7:
        return SectionType.action;
      case 8:
        return SectionType.appendix;
      default:
        return SectionType.overview;
    }
  }

  @override
  void write(BinaryWriter writer, SectionType obj) {
    switch (obj) {
      case SectionType.overview:
        writer.writeByte(0);
        break;
      case SectionType.insights:
        writer.writeByte(1);
        break;
      case SectionType.strengths:
        writer.writeByte(2);
        break;
      case SectionType.development:
        writer.writeByte(3);
        break;
      case SectionType.synthesis:
        writer.writeByte(4);
        break;
      case SectionType.experiments:
        writer.writeByte(5);
        break;
      case SectionType.recommendations:
        writer.writeByte(6);
        break;
      case SectionType.action:
        writer.writeByte(7);
        break;
      case SectionType.appendix:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SectionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReportConfidenceAdapter extends TypeAdapter<ReportConfidence> {
  @override
  final int typeId = 75;

  @override
  ReportConfidence read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReportConfidence.high;
      case 1:
        return ReportConfidence.medium;
      case 2:
        return ReportConfidence.low;
      default:
        return ReportConfidence.high;
    }
  }

  @override
  void write(BinaryWriter writer, ReportConfidence obj) {
    switch (obj) {
      case ReportConfidence.high:
        writer.writeByte(0);
        break;
      case ReportConfidence.medium:
        writer.writeByte(1);
        break;
      case ReportConfidence.low:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportConfidenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
