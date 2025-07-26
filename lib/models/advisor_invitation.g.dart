// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advisor_invitation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AdvisorInvitationAdapter extends TypeAdapter<AdvisorInvitation> {
  @override
  final int typeId = 20;

  @override
  AdvisorInvitation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdvisorInvitation(
      id: fields[0] as String,
      advisorName: fields[1] as String,
      advisorEmail: fields[2] as String,
      advisorPhone: fields[3] as String?,
      relationshipType: fields[4] as AdvisorRelationship,
      personalMessage: fields[5] as String,
      sentAt: fields[6] as DateTime,
      status: fields[7] as InvitationStatus,
      respondedAt: fields[8] as DateTime?,
      remindedAt: fields[9] as DateTime?,
      reminderCount: fields[10] as int,
      sessionId: fields[11] as String,
      includePersonalMessage: fields[12] as bool,
      customQuestions: (fields[13] as Map?)?.cast<String, String>(),
      declineReason: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AdvisorInvitation obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.advisorName)
      ..writeByte(2)
      ..write(obj.advisorEmail)
      ..writeByte(3)
      ..write(obj.advisorPhone)
      ..writeByte(4)
      ..write(obj.relationshipType)
      ..writeByte(5)
      ..write(obj.personalMessage)
      ..writeByte(6)
      ..write(obj.sentAt)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.respondedAt)
      ..writeByte(9)
      ..write(obj.remindedAt)
      ..writeByte(10)
      ..write(obj.reminderCount)
      ..writeByte(11)
      ..write(obj.sessionId)
      ..writeByte(12)
      ..write(obj.includePersonalMessage)
      ..writeByte(13)
      ..write(obj.customQuestions)
      ..writeByte(14)
      ..write(obj.declineReason);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdvisorInvitationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AdvisorRelationshipAdapter extends TypeAdapter<AdvisorRelationship> {
  @override
  final int typeId = 21;

  @override
  AdvisorRelationship read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AdvisorRelationship.manager;
      case 1:
        return AdvisorRelationship.colleague;
      case 2:
        return AdvisorRelationship.mentor;
      case 3:
        return AdvisorRelationship.friend;
      case 4:
        return AdvisorRelationship.family;
      case 5:
        return AdvisorRelationship.client;
      case 6:
        return AdvisorRelationship.sponsor;
      case 7:
        return AdvisorRelationship.peer;
      case 8:
        return AdvisorRelationship.other;
      default:
        return AdvisorRelationship.manager;
    }
  }

  @override
  void write(BinaryWriter writer, AdvisorRelationship obj) {
    switch (obj) {
      case AdvisorRelationship.manager:
        writer.writeByte(0);
        break;
      case AdvisorRelationship.colleague:
        writer.writeByte(1);
        break;
      case AdvisorRelationship.mentor:
        writer.writeByte(2);
        break;
      case AdvisorRelationship.friend:
        writer.writeByte(3);
        break;
      case AdvisorRelationship.family:
        writer.writeByte(4);
        break;
      case AdvisorRelationship.client:
        writer.writeByte(5);
        break;
      case AdvisorRelationship.sponsor:
        writer.writeByte(6);
        break;
      case AdvisorRelationship.peer:
        writer.writeByte(7);
        break;
      case AdvisorRelationship.other:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdvisorRelationshipAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InvitationStatusAdapter extends TypeAdapter<InvitationStatus> {
  @override
  final int typeId = 22;

  @override
  InvitationStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InvitationStatus.draft;
      case 1:
        return InvitationStatus.sent;
      case 2:
        return InvitationStatus.viewed;
      case 3:
        return InvitationStatus.completed;
      case 4:
        return InvitationStatus.declined;
      case 5:
        return InvitationStatus.expired;
      default:
        return InvitationStatus.draft;
    }
  }

  @override
  void write(BinaryWriter writer, InvitationStatus obj) {
    switch (obj) {
      case InvitationStatus.draft:
        writer.writeByte(0);
        break;
      case InvitationStatus.sent:
        writer.writeByte(1);
        break;
      case InvitationStatus.viewed:
        writer.writeByte(2);
        break;
      case InvitationStatus.completed:
        writer.writeByte(3);
        break;
      case InvitationStatus.declined:
        writer.writeByte(4);
        break;
      case InvitationStatus.expired:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvitationStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
