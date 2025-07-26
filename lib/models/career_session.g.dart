// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'career_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CareerSessionAdapter extends TypeAdapter<CareerSession> {
  @override
  final int typeId = 10;

  @override
  CareerSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CareerSession(
      id: fields[0] as String,
      createdAt: fields[1] as DateTime,
      lastModified: fields[2] as DateTime,
      responses: (fields[3] as Map).cast<String, CareerResponse>(),
      insights: (fields[4] as List).cast<CareerInsight>(),
      sessionName: fields[5] as String,
      completedDomains: (fields[6] as List).cast<CareerDomain>(),
      preferredExplorationType: fields[7] as ExplorationType,
    );
  }

  @override
  void write(BinaryWriter writer, CareerSession obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.lastModified)
      ..writeByte(3)
      ..write(obj.responses)
      ..writeByte(4)
      ..write(obj.insights)
      ..writeByte(5)
      ..write(obj.sessionName)
      ..writeByte(6)
      ..write(obj.completedDomains)
      ..writeByte(7)
      ..write(obj.preferredExplorationType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareerSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CareerDomainAdapter extends TypeAdapter<CareerDomain> {
  @override
  final int typeId = 13;

  @override
  CareerDomain read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CareerDomain.technical;
      case 1:
        return CareerDomain.leadership;
      case 2:
        return CareerDomain.creative;
      case 3:
        return CareerDomain.analytical;
      case 4:
        return CareerDomain.social;
      case 5:
        return CareerDomain.entrepreneurial;
      case 6:
        return CareerDomain.traditional;
      case 7:
        return CareerDomain.investigative;
      default:
        return CareerDomain.technical;
    }
  }

  @override
  void write(BinaryWriter writer, CareerDomain obj) {
    switch (obj) {
      case CareerDomain.technical:
        writer.writeByte(0);
        break;
      case CareerDomain.leadership:
        writer.writeByte(1);
        break;
      case CareerDomain.creative:
        writer.writeByte(2);
        break;
      case CareerDomain.analytical:
        writer.writeByte(3);
        break;
      case CareerDomain.social:
        writer.writeByte(4);
        break;
      case CareerDomain.entrepreneurial:
        writer.writeByte(5);
        break;
      case CareerDomain.traditional:
        writer.writeByte(6);
        break;
      case CareerDomain.investigative:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareerDomainAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExplorationTypeAdapter extends TypeAdapter<ExplorationType> {
  @override
  final int typeId = 14;

  @override
  ExplorationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExplorationType.reflective;
      case 1:
        return ExplorationType.structured;
      case 2:
        return ExplorationType.experimental;
      case 3:
        return ExplorationType.collaborative;
      default:
        return ExplorationType.reflective;
    }
  }

  @override
  void write(BinaryWriter writer, ExplorationType obj) {
    switch (obj) {
      case ExplorationType.reflective:
        writer.writeByte(0);
        break;
      case ExplorationType.structured:
        writer.writeByte(1);
        break;
      case ExplorationType.experimental:
        writer.writeByte(2);
        break;
      case ExplorationType.collaborative:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExplorationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
