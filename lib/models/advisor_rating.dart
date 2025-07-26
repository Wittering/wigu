import 'package:hive/hive.dart';
import 'advisor_invitation.dart';

part 'advisor_rating.g.dart';

/// Rating and feedback about an advisor's contribution to the career insight process
/// Helps improve the advisor system and provides feedback to advisors
@HiveType(typeId: 26)
class AdvisorRating extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String invitationId;

  @HiveField(2)
  final int overallRating; // 1-5 scale

  @HiveField(3)
  final int insightfulness; // How insightful were their responses (1-5)

  @HiveField(4)
  final int specificity; // How specific and detailed were their responses (1-5)

  @HiveField(5)
  final int helpfulness; // How helpful was their perspective (1-5)

  @HiveField(6)
  final String? positiveAspects; // What was most valuable about their input

  @HiveField(7)
  final String? improvementAreas; // What could have been better

  @HiveField(8)
  final DateTime ratedAt;

  @HiveField(9)
  final bool wouldRecommendAdvisor; // Would you recommend them as an advisor to others

  @HiveField(10)
  final List<AdvisorStrengthArea>? advisorStrengths; // What they're particularly good at

  @HiveField(11)
  final String? additionalFeedback; // Any other feedback

  @HiveField(12)
  final bool isAnonymousFeedback; // Whether this feedback can be shared with the advisor

  @HiveField(13)
  final AdvisorResponseTimeliness responseTimeliness;

  @HiveField(14)
  final Map<String, int>? questionSpecificRatings; // Ratings for specific questions

  AdvisorRating({
    required this.id,
    required this.invitationId,
    required this.overallRating,
    required this.insightfulness,
    required this.specificity,
    required this.helpfulness,
    this.positiveAspects,
    this.improvementAreas,
    required this.ratedAt,
    required this.wouldRecommendAdvisor,
    this.advisorStrengths,
    this.additionalFeedback,
    this.isAnonymousFeedback = false,
    required this.responseTimeliness,
    this.questionSpecificRatings,
  });

  AdvisorRating copyWith({
    String? id,
    String? invitationId,
    int? overallRating,
    int? insightfulness,
    int? specificity,
    int? helpfulness,
    String? positiveAspects,
    String? improvementAreas,
    DateTime? ratedAt,
    bool? wouldRecommendAdvisor,
    List<AdvisorStrengthArea>? advisorStrengths,
    String? additionalFeedback,
    bool? isAnonymousFeedback,
    AdvisorResponseTimeliness? responseTimeliness,
    Map<String, int>? questionSpecificRatings,
  }) {
    return AdvisorRating(
      id: id ?? this.id,
      invitationId: invitationId ?? this.invitationId,
      overallRating: overallRating ?? this.overallRating,
      insightfulness: insightfulness ?? this.insightfulness,
      specificity: specificity ?? this.specificity,
      helpfulness: helpfulness ?? this.helpfulness,
      positiveAspects: positiveAspects ?? this.positiveAspects,
      improvementAreas: improvementAreas ?? this.improvementAreas,
      ratedAt: ratedAt ?? this.ratedAt,
      wouldRecommendAdvisor: wouldRecommendAdvisor ?? this.wouldRecommendAdvisor,
      advisorStrengths: advisorStrengths ?? this.advisorStrengths,
      additionalFeedback: additionalFeedback ?? this.additionalFeedback,
      isAnonymousFeedback: isAnonymousFeedback ?? this.isAnonymousFeedback,
      responseTimeliness: responseTimeliness ?? this.responseTimeliness,
      questionSpecificRatings: questionSpecificRatings ?? this.questionSpecificRatings,
    );
  }

  /// Calculate the average rating across all dimensions
  double get averageRating {
    return (overallRating + insightfulness + specificity + helpfulness) / 4.0;
  }

  /// Check if this is a high-quality advisor based on ratings
  bool get isHighQualityAdvisor {
    return averageRating >= 4.0 && wouldRecommendAdvisor;
  }

  /// Check if this advisor provided exceptional feedback
  bool get isExceptionalAdvisor {
    return averageRating >= 4.5 && 
           wouldRecommendAdvisor && 
           responseTimeliness == AdvisorResponseTimeliness.veryPrompt;
  }

  /// Get a summary of the advisor's key strengths
  String get strengthsSummary {
    if (advisorStrengths == null || advisorStrengths!.isEmpty) {
      return 'No specific strengths identified';
    }
    
    return advisorStrengths!
        .map((strength) => strength.displayName)
        .join(', ');
  }

  /// Get an overall assessment of the advisor
  String get overallAssessment {
    if (averageRating >= 4.5) {
      return 'Exceptional advisor - highly recommended';
    } else if (averageRating >= 4.0) {
      return 'Excellent advisor - recommended';
    } else if (averageRating >= 3.0) {
      return 'Good advisor - satisfactory';
    } else if (averageRating >= 2.0) {
      return 'Fair advisor - some limitations';
    } else {
      return 'Poor advisor - not recommended';
    }
  }

  /// Get detailed breakdown of ratings
  Map<String, dynamic> get ratingBreakdown {
    return {
      'overall': overallRating,
      'insightfulness': insightfulness,
      'specificity': specificity,
      'helpfulness': helpfulness,
      'average': averageRating,
      'timeliness': responseTimeliness.displayName,
    };
  }

  /// Generate feedback summary for sharing with the advisor (if not anonymous)
  String? generateAdvisorFeedback() {
    if (isAnonymousFeedback) return null;
    
    final buffer = StringBuffer();
    buffer.writeln('Thank you for participating in the career insight process!');
    buffer.writeln('');
    buffer.writeln('Here\'s some feedback on your contribution:');
    buffer.writeln('');
    buffer.writeln('Overall Rating: $overallRating/5 stars');
    buffer.writeln('- Insightfulness: $insightfulness/5');
    buffer.writeln('- Specificity: $specificity/5');
    buffer.writeln('- Helpfulness: $helpfulness/5');
    buffer.writeln('');
    
    if (positiveAspects != null && positiveAspects!.isNotEmpty) {
      buffer.writeln('What was most valuable:');
      buffer.writeln(positiveAspects);
      buffer.writeln('');
    }
    
    if (improvementAreas != null && improvementAreas!.isNotEmpty) {
      buffer.writeln('Areas for potential improvement:');
      buffer.writeln(improvementAreas);
      buffer.writeln('');
    }
    
    if (advisorStrengths != null && advisorStrengths!.isNotEmpty) {
      buffer.writeln('Your key strengths as an advisor:');
      buffer.writeln('- ${strengthsSummary}');
      buffer.writeln('');
    }
    
    if (additionalFeedback != null && additionalFeedback!.isNotEmpty) {
      buffer.writeln('Additional feedback:');
      buffer.writeln(additionalFeedback);
      buffer.writeln('');
    }
    
    buffer.writeln('Would recommend as advisor: ${wouldRecommendAdvisor ? "Yes" : "No"}');
    buffer.writeln('');
    buffer.writeln('Overall assessment: $overallAssessment');
    
    return buffer.toString();
  }

  /// Export rating data to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invitationId': invitationId,
      'overallRating': overallRating,
      'insightfulness': insightfulness,
      'specificity': specificity,
      'helpfulness': helpfulness,
      'positiveAspects': positiveAspects,
      'improvementAreas': improvementAreas,
      'ratedAt': ratedAt.toIso8601String(),
      'wouldRecommendAdvisor': wouldRecommendAdvisor,
      'advisorStrengths': advisorStrengths?.map((s) => s.name).toList(),
      'additionalFeedback': additionalFeedback,
      'isAnonymousFeedback': isAnonymousFeedback,
      'responseTimeliness': responseTimeliness.name,
      'questionSpecificRatings': questionSpecificRatings,
      'analysis': {
        'averageRating': averageRating,
        'isHighQualityAdvisor': isHighQualityAdvisor,
        'isExceptionalAdvisor': isExceptionalAdvisor,
        'strengthsSummary': strengthsSummary,
        'overallAssessment': overallAssessment,
        'ratingBreakdown': ratingBreakdown,
      },
    };
  }

  /// Create a new advisor rating
  static AdvisorRating create({
    required String invitationId,
    required int overallRating,
    required int insightfulness,
    required int specificity,
    required int helpfulness,
    String? positiveAspects,
    String? improvementAreas,
    required bool wouldRecommendAdvisor,
    List<AdvisorStrengthArea>? advisorStrengths,
    String? additionalFeedback,
    bool isAnonymousFeedback = false,
    required AdvisorResponseTimeliness responseTimeliness,
    Map<String, int>? questionSpecificRatings,
  }) {
    return AdvisorRating(
      id: 'advisor_rating_${DateTime.now().millisecondsSinceEpoch}',
      invitationId: invitationId,
      overallRating: overallRating,
      insightfulness: insightfulness,
      specificity: specificity,
      helpfulness: helpfulness,
      positiveAspects: positiveAspects,
      improvementAreas: improvementAreas,
      ratedAt: DateTime.now(),
      wouldRecommendAdvisor: wouldRecommendAdvisor,
      advisorStrengths: advisorStrengths,
      additionalFeedback: additionalFeedback,
      isAnonymousFeedback: isAnonymousFeedback,
      responseTimeliness: responseTimeliness,
      questionSpecificRatings: questionSpecificRatings,
    );
  }

  @override
  String toString() {
    return 'AdvisorRating{id: $id, invitationId: $invitationId, '
           'average: ${averageRating.toStringAsFixed(1)}/5, recommend: $wouldRecommendAdvisor}';
  }
}

/// Areas where advisors can demonstrate strength
@HiveType(typeId: 27)
enum AdvisorStrengthArea {
  @HiveField(0)
  specificExamples('Providing Specific Examples', 'Gave concrete, detailed examples'),
  
  @HiveField(1)
  honestFeedback('Honest Feedback', 'Provided candid, honest assessment'),
  
  @HiveField(2)
  insightfulObservations('Insightful Observations', 'Offered unique insights and perspectives'),
  
  @HiveField(3)
  constructiveCriticism('Constructive Criticism', 'Provided helpful areas for improvement'),
  
  @HiveField(4)
  detailedResponses('Detailed Responses', 'Gave thorough, comprehensive answers'),
  
  @HiveField(5)
  contextualUnderstanding('Contextual Understanding', 'Showed deep understanding of context'),
  
  @HiveField(6)
  balancedPerspective('Balanced Perspective', 'Provided balanced view of strengths and areas to develop'),
  
  @HiveField(7)
  actionableAdvice('Actionable Advice', 'Gave practical, actionable suggestions'),
  
  @HiveField(8)
  supportiveApproach('Supportive Approach', 'Was encouraging and supportive throughout'),
  
  @HiveField(9)
  professionalInsight('Professional Insight', 'Demonstrated strong professional judgment');

  const AdvisorStrengthArea(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// How timely the advisor was in responding
@HiveType(typeId: 28)
enum AdvisorResponseTimeliness {
  @HiveField(0)
  veryPrompt('Very Prompt', 'Responded within 1-2 days'),
  
  @HiveField(1)
  prompt('Prompt', 'Responded within 3-5 days'),
  
  @HiveField(2)
  reasonable('Reasonable', 'Responded within a week'),
  
  @HiveField(3)
  slow('Slow', 'Took 1-2 weeks to respond'),
  
  @HiveField(4)
  verySlow('Very Slow', 'Took more than 2 weeks to respond');

  const AdvisorResponseTimeliness(this.displayName, this.description);
  
  final String displayName;
  final String description;
}