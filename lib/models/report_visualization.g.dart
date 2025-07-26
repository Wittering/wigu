// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_visualization.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportVisualizationAdapter extends TypeAdapter<ReportVisualization> {
  @override
  final int typeId = 80;

  @override
  ReportVisualization read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReportVisualization(
      id: fields[0] as String,
      title: fields[1] as String,
      subtitle: fields[2] as String?,
      type: fields[3] as VisualizationType,
      data: (fields[4] as Map).cast<String, dynamic>(),
      config: fields[5] as VisualizationConfig,
      description: fields[6] as String?,
      insights: (fields[7] as List).cast<String>(),
      orderIndex: fields[8] as int,
      isInteractive: fields[9] as bool,
      reportSectionId: fields[10] as String?,
      createdAt: fields[11] as DateTime,
      colorScheme: (fields[12] as Map?)?.cast<String, String>(),
      size: fields[13] as VisualizationSize,
    );
  }

  @override
  void write(BinaryWriter writer, ReportVisualization obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.subtitle)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.data)
      ..writeByte(5)
      ..write(obj.config)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.insights)
      ..writeByte(8)
      ..write(obj.orderIndex)
      ..writeByte(9)
      ..write(obj.isInteractive)
      ..writeByte(10)
      ..write(obj.reportSectionId)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.colorScheme)
      ..writeByte(13)
      ..write(obj.size);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportVisualizationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VisualizationConfigAdapter extends TypeAdapter<VisualizationConfig> {
  @override
  final int typeId = 81;

  @override
  VisualizationConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VisualizationConfig(
      showLegend: fields[0] as bool,
      showGridLines: fields[1] as bool,
      showLabels: fields[2] as bool,
      isResponsive: fields[3] as bool,
      customSettings: (fields[4] as Map?)?.cast<String, dynamic>(),
      showTooltips: fields[5] as bool,
      enableAnimation: fields[6] as bool,
      animationDuration: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, VisualizationConfig obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.showLegend)
      ..writeByte(1)
      ..write(obj.showGridLines)
      ..writeByte(2)
      ..write(obj.showLabels)
      ..writeByte(3)
      ..write(obj.isResponsive)
      ..writeByte(4)
      ..write(obj.customSettings)
      ..writeByte(5)
      ..write(obj.showTooltips)
      ..writeByte(6)
      ..write(obj.enableAnimation)
      ..writeByte(7)
      ..write(obj.animationDuration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisualizationConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VisualizationSizeAdapter extends TypeAdapter<VisualizationSize> {
  @override
  final int typeId = 82;

  @override
  VisualizationSize read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VisualizationSize(
      width: fields[0] as double,
      height: fields[1] as double,
      preset: fields[2] as SizePreset,
    );
  }

  @override
  void write(BinaryWriter writer, VisualizationSize obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.width)
      ..writeByte(1)
      ..write(obj.height)
      ..writeByte(2)
      ..write(obj.preset);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisualizationSizeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VisualizationTypeAdapter extends TypeAdapter<VisualizationType> {
  @override
  final int typeId = 83;

  @override
  VisualizationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return VisualizationType.strengthsRadar;
      case 1:
        return VisualizationType.insightDistribution;
      case 2:
        return VisualizationType.progressTracking;
      case 3:
        return VisualizationType.themeNetwork;
      case 4:
        return VisualizationType.timelineDevelopment;
      case 5:
        return VisualizationType.competencyMatrix;
      case 6:
        return VisualizationType.valueAlignment;
      case 7:
        return VisualizationType.experimentResults;
      default:
        return VisualizationType.strengthsRadar;
    }
  }

  @override
  void write(BinaryWriter writer, VisualizationType obj) {
    switch (obj) {
      case VisualizationType.strengthsRadar:
        writer.writeByte(0);
        break;
      case VisualizationType.insightDistribution:
        writer.writeByte(1);
        break;
      case VisualizationType.progressTracking:
        writer.writeByte(2);
        break;
      case VisualizationType.themeNetwork:
        writer.writeByte(3);
        break;
      case VisualizationType.timelineDevelopment:
        writer.writeByte(4);
        break;
      case VisualizationType.competencyMatrix:
        writer.writeByte(5);
        break;
      case VisualizationType.valueAlignment:
        writer.writeByte(6);
        break;
      case VisualizationType.experimentResults:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisualizationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SizePresetAdapter extends TypeAdapter<SizePreset> {
  @override
  final int typeId = 84;

  @override
  SizePreset read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SizePreset.small;
      case 1:
        return SizePreset.medium;
      case 2:
        return SizePreset.large;
      case 3:
        return SizePreset.fullWidth;
      default:
        return SizePreset.small;
    }
  }

  @override
  void write(BinaryWriter writer, SizePreset obj) {
    switch (obj) {
      case SizePreset.small:
        writer.writeByte(0);
        break;
      case SizePreset.medium:
        writer.writeByte(1);
        break;
      case SizePreset.large:
        writer.writeByte(2);
        break;
      case SizePreset.fullWidth:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SizePresetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
