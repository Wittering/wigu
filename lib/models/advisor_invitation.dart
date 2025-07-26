import 'package:hive/hive.dart';

part 'advisor_invitation.g.dart';

/// Represents an invitation sent to a career advisor/mentor
/// Used to gather external perspectives on the user's career journey
@HiveType(typeId: 20)
class AdvisorInvitation extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String advisorName;

  @HiveField(2)
  final String advisorEmail;

  @HiveField(3)
  final String? advisorPhone;

  @HiveField(4)
  final AdvisorRelationship relationshipType;

  @HiveField(5)
  final String personalMessage;

  @HiveField(6)
  final DateTime sentAt;

  @HiveField(7)
  final InvitationStatus status;

  @HiveField(8)
  final DateTime? respondedAt;

  @HiveField(9)
  final DateTime? remindedAt;

  @HiveField(10)
  final int reminderCount;

  @HiveField(11)
  final String sessionId;

  @HiveField(12)
  final bool includePersonalMessage;

  @HiveField(13)
  final Map<String, String>? customQuestions;

  @HiveField(14)
  final String? declineReason;

  AdvisorInvitation({
    required this.id,
    required this.advisorName,
    required this.advisorEmail,
    this.advisorPhone,
    required this.relationshipType,
    required this.personalMessage,
    required this.sentAt,
    required this.status,
    this.respondedAt,
    this.remindedAt,
    this.reminderCount = 0,
    required this.sessionId,
    this.includePersonalMessage = true,
    this.customQuestions,
    this.declineReason,
  });

  AdvisorInvitation copyWith({
    String? id,
    String? advisorName,
    String? advisorEmail,
    String? advisorPhone,
    AdvisorRelationship? relationshipType,
    String? personalMessage,
    DateTime? sentAt,
    InvitationStatus? status,
    DateTime? respondedAt,
    DateTime? remindedAt,
    int? reminderCount,
    String? sessionId,
    bool? includePersonalMessage,
    Map<String, String>? customQuestions,
    String? declineReason,
  }) {
    return AdvisorInvitation(
      id: id ?? this.id,
      advisorName: advisorName ?? this.advisorName,
      advisorEmail: advisorEmail ?? this.advisorEmail,
      advisorPhone: advisorPhone ?? this.advisorPhone,
      relationshipType: relationshipType ?? this.relationshipType,
      personalMessage: personalMessage ?? this.personalMessage,
      sentAt: sentAt ?? this.sentAt,
      status: status ?? this.status,
      respondedAt: respondedAt ?? this.respondedAt,
      remindedAt: remindedAt ?? this.remindedAt,
      reminderCount: reminderCount ?? this.reminderCount,
      sessionId: sessionId ?? this.sessionId,
      includePersonalMessage: includePersonalMessage ?? this.includePersonalMessage,
      customQuestions: customQuestions ?? this.customQuestions,
      declineReason: declineReason ?? this.declineReason,
    );
  }

  /// Get the number of days since the invitation was sent
  int get daysSinceSent {
    return DateTime.now().difference(sentAt).inDays;
  }

  /// Check if the invitation is overdue (more than 7 days without response)
  bool get isOverdue {
    return status == InvitationStatus.sent && daysSinceSent > 7;
  }

  /// Check if the invitation can be reminded (less than 3 reminders and not responded)
  bool get canSendReminder {
    return status == InvitationStatus.sent && 
           reminderCount < 3 && 
           daysSinceSent >= 3;
  }

  /// Check if this is a high-priority advisor relationship
  bool get isHighPriorityAdvisor {
    return relationshipType == AdvisorRelationship.manager ||
           relationshipType == AdvisorRelationship.mentor ||
           relationshipType == AdvisorRelationship.sponsor;
  }

  /// Get a user-friendly status description
  String get statusDescription {
    switch (status) {
      case InvitationStatus.draft:
        return 'Draft - not yet sent';
      case InvitationStatus.sent:
        return isOverdue 
            ? 'Sent ${daysSinceSent} days ago - overdue'
            : 'Sent ${daysSinceSent} days ago';
      case InvitationStatus.viewed:
        return 'Viewed by advisor';
      case InvitationStatus.completed:
        return 'Completed by advisor';
      case InvitationStatus.declined:
        return 'Declined by advisor';
      case InvitationStatus.expired:
        return 'Invitation expired';
    }
  }

  /// Generate the invitation URL for the advisor
  String generateInvitationUrl({String baseUrl = 'https://wigu.career'}) {
    return '$baseUrl/advisor-response/$id';
  }

  /// Create a personalised email message for the advisor
  String generateEmailMessage({required String userName}) {
    final greeting = _getGreeting();
    final relationshipContext = _getRelationshipContext();
    final invitationUrl = generateInvitationUrl();
    
    return '''
$greeting $advisorName,

$relationshipContext

I'm currently undertaking some career exploration and reflection, and your perspective would be incredibly valuable to me. I've been working through a comprehensive career insight process, and I'd love to understand how you see my strengths, capabilities, and potential career directions.

${includePersonalMessage && personalMessage.isNotEmpty ? '$personalMessage\n\n' : ''}The process involves answering a few thoughtful questions about what you've observed in my work and capabilities. It should take about 10-15 minutes, and your honest insights will help me gain a clearer picture of how others perceive my professional strengths and potential.

You can access the questions here: $invitationUrl

Your input will be kept confidential and used solely to help me better understand my career direction. Thank you so much for taking the time to help me with this important reflection.

With appreciation,
$userName

P.S. If you have any questions about this process, please don't hesitate to reach out to me directly.
''';
  }

  /// Get appropriate greeting based on relationship
  String _getGreeting() {
    switch (relationshipType) {
      case AdvisorRelationship.manager:
        return 'Hi';
      case AdvisorRelationship.colleague:
        return 'Hi';
      case AdvisorRelationship.mentor:
        return 'Dear';
      case AdvisorRelationship.friend:
        return 'Hi';
      case AdvisorRelationship.family:
        return 'Hi';
      case AdvisorRelationship.client:
        return 'Dear';
      case AdvisorRelationship.sponsor:
        return 'Dear';
      case AdvisorRelationship.peer:
        return 'Hi';
      case AdvisorRelationship.other:
        return 'Hi';
    }
  }

  /// Get relationship context for the invitation
  String _getRelationshipContext() {
    switch (relationshipType) {
      case AdvisorRelationship.manager:
        return 'As my manager, you\'ve had great insight into my work style, strengths, and professional development.';
      case AdvisorRelationship.colleague:
        return 'As a colleague, you\'ve worked alongside me and seen my contributions firsthand.';
      case AdvisorRelationship.mentor:
        return 'You\'ve been such a valuable mentor to me, and your guidance has been instrumental in my professional growth.';
      case AdvisorRelationship.friend:
        return 'You know me well both personally and professionally, which gives you a unique perspective on my capabilities.';
      case AdvisorRelationship.family:
        return 'As someone who knows me so well, you have insights into my natural talents and what motivates me.';
      case AdvisorRelationship.client:
        return 'Working with you as a client has given you visibility into my professional capabilities and approach.';
      case AdvisorRelationship.sponsor:
        return 'Your sponsorship and support of my career has given you valuable insights into my potential and areas for growth.';
      case AdvisorRelationship.peer:
        return 'As a peer in our field, you understand the industry context and have observed my professional contributions.';
      case AdvisorRelationship.other:
        return 'Your perspective on my professional capabilities would be incredibly valuable.';
    }
  }

  /// Mark the invitation as viewed
  AdvisorInvitation markAsViewed() {
    return copyWith(
      status: InvitationStatus.viewed,
    );
  }

  /// Mark the invitation as completed
  AdvisorInvitation markAsCompleted() {
    return copyWith(
      status: InvitationStatus.completed,
      respondedAt: DateTime.now(),
    );
  }

  /// Mark the invitation as declined
  AdvisorInvitation markAsDeclined({String? reason}) {
    return copyWith(
      status: InvitationStatus.declined,
      respondedAt: DateTime.now(),
      declineReason: reason,
    );
  }

  /// Send a reminder for this invitation
  AdvisorInvitation sendReminder() {
    return copyWith(
      remindedAt: DateTime.now(),
      reminderCount: reminderCount + 1,
    );
  }

  /// Export invitation data to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'advisorName': advisorName,
      'advisorEmail': advisorEmail,
      'advisorPhone': advisorPhone,
      'relationshipType': relationshipType.name,
      'personalMessage': personalMessage,
      'sentAt': sentAt.toIso8601String(),
      'status': status.name,
      'respondedAt': respondedAt?.toIso8601String(),
      'remindedAt': remindedAt?.toIso8601String(),
      'reminderCount': reminderCount,
      'sessionId': sessionId,
      'includePersonalMessage': includePersonalMessage,
      'customQuestions': customQuestions,
      'declineReason': declineReason,
      'stats': {
        'daysSinceSent': daysSinceSent,
        'isOverdue': isOverdue,
        'canSendReminder': canSendReminder,
        'isHighPriorityAdvisor': isHighPriorityAdvisor,
        'statusDescription': statusDescription,
      },
    };
  }

  /// Create a new invitation
  static AdvisorInvitation create({
    required String advisorName,
    required String advisorEmail,
    String? advisorPhone,
    required AdvisorRelationship relationshipType,
    required String personalMessage,
    required String sessionId,
    bool includePersonalMessage = true,
    Map<String, String>? customQuestions,
  }) {
    return AdvisorInvitation(
      id: 'invitation_${DateTime.now().millisecondsSinceEpoch}',
      advisorName: advisorName,
      advisorEmail: advisorEmail,
      advisorPhone: advisorPhone,
      relationshipType: relationshipType,
      personalMessage: personalMessage,
      sentAt: DateTime.now(),
      status: InvitationStatus.sent,
      sessionId: sessionId,
      includePersonalMessage: includePersonalMessage,
      customQuestions: customQuestions,
    );
  }

  @override
  String toString() {
    return 'AdvisorInvitation{id: $id, advisor: $advisorName, relationship: ${relationshipType.name}, status: ${status.name}}';
  }
}

/// Types of relationships with advisors
@HiveType(typeId: 21)
enum AdvisorRelationship {
  @HiveField(0)
  manager('Manager', 'Your current or former manager who knows your work performance'),
  
  @HiveField(1)
  colleague('Colleague', 'A colleague who works closely with you'),
  
  @HiveField(2)
  mentor('Mentor', 'Someone who has guided your career development'),
  
  @HiveField(3)
  friend('Friend', 'A personal friend who knows your professional side'),
  
  @HiveField(4)
  family('Family Member', 'A family member who understands your work life'),
  
  @HiveField(5)
  client('Client', 'A client who has experienced your professional services'),
  
  @HiveField(6)
  sponsor('Sponsor', 'Someone who actively champions your career'),
  
  @HiveField(7)
  peer('Industry Peer', 'A peer in your profession or industry'),
  
  @HiveField(8)
  other('Other', 'Another type of professional relationship');

  const AdvisorRelationship(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// Status of advisor invitations
@HiveType(typeId: 22)
enum InvitationStatus {
  @HiveField(0)
  draft('Draft', 'Invitation created but not yet sent'),
  
  @HiveField(1)
  sent('Sent', 'Invitation sent to advisor'),
  
  @HiveField(2)
  viewed('Viewed', 'Advisor has opened the invitation'),
  
  @HiveField(3)
  completed('Completed', 'Advisor has completed their responses'),
  
  @HiveField(4)
  declined('Declined', 'Advisor has declined to participate'),
  
  @HiveField(5)
  expired('Expired', 'Invitation has expired without response');

  const InvitationStatus(this.displayName, this.description);
  
  final String displayName;
  final String description;
}