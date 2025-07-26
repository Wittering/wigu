import 'package:hive/hive.dart';
import 'career_session.dart';
import 'advisor_invitation.dart';

part 'advisor_response.g.dart';

/// Response from a career advisor/mentor about the user
/// Captures external perspective on strengths, capabilities, and potential
@HiveType(typeId: 23)
class AdvisorResponse extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String invitationId;

  @HiveField(2)
  final String questionId;

  @HiveField(3)
  final String questionText;

  @HiveField(4)
  final String response;

  @HiveField(5)
  final DateTime answeredAt;

  @HiveField(6)
  final CareerDomain domain;

  @HiveField(7)
  final int? confidenceLevel; // How confident the advisor is in their assessment (1-5)

  @HiveField(8)
  final AdvisorObservationPeriod observationPeriod;

  @HiveField(9)
  final List<String>? specificExamples; // Concrete examples they've observed

  @HiveField(10)
  final AdvisorConfidenceContext confidenceContext;

  @HiveField(11)
  final String? additionalContext; // Any extra context they want to provide

  @HiveField(12)
  final bool isAnonymous; // Whether the response is anonymous

  @HiveField(13)
  final Map<String, dynamic>? metadata; // Additional structured data

  AdvisorResponse({
    required this.id,
    required this.invitationId,
    required this.questionId,
    required this.questionText,
    required this.response,
    required this.answeredAt,
    required this.domain,
    this.confidenceLevel,
    required this.observationPeriod,
    this.specificExamples,
    required this.confidenceContext,
    this.additionalContext,
    this.isAnonymous = false,
    this.metadata,
  });

  AdvisorResponse copyWith({
    String? id,
    String? invitationId,
    String? questionId,
    String? questionText,
    String? response,
    DateTime? answeredAt,
    CareerDomain? domain,
    int? confidenceLevel,
    AdvisorObservationPeriod? observationPeriod,
    List<String>? specificExamples,
    AdvisorConfidenceContext? confidenceContext,
    String? additionalContext,
    bool? isAnonymous,
    Map<String, dynamic>? metadata,
  }) {
    return AdvisorResponse(
      id: id ?? this.id,
      invitationId: invitationId ?? this.invitationId,
      questionId: questionId ?? this.questionId,
      questionText: questionText ?? this.questionText,
      response: response ?? this.response,
      answeredAt: answeredAt ?? this.answeredAt,
      domain: domain ?? this.domain,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      observationPeriod: observationPeriod ?? this.observationPeriod,
      specificExamples: specificExamples ?? this.specificExamples,
      confidenceContext: confidenceContext ?? this.confidenceContext,
      additionalContext: additionalContext ?? this.additionalContext,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if this response contains substantial, detailed feedback
  bool get isSubstantiveResponse {
    final cleanResponse = response.trim();
    return cleanResponse.length > 30 && 
           cleanResponse.split(' ').length > 8 &&
           (specificExamples?.isNotEmpty ?? false);
  }

  /// Get word count of the response
  int get wordCount {
    return response.trim().split(RegExp(r'\s+')).length;
  }

  /// Get the credibility weight of this response based on various factors
  double get credibilityWeight {
    double weight = 0.5; // Base weight

    // Observation period weight
    switch (observationPeriod) {
      case AdvisorObservationPeriod.lessThanMonth:
        weight += 0.1;
        break;
      case AdvisorObservationPeriod.oneToSixMonths:
        weight += 0.2;
        break;
      case AdvisorObservationPeriod.sixMonthsToYear:
        weight += 0.3;
        break;
      case AdvisorObservationPeriod.oneToThreeYears:
        weight += 0.4;
        break;
      case AdvisorObservationPeriod.moreThanThreeYears:
        weight += 0.5;
        break;
    }

    // Confidence level weight
    if (confidenceLevel != null) {
      weight += (confidenceLevel! / 5.0) * 0.3;
    }

    // Confidence context weight
    switch (confidenceContext) {
      case AdvisorConfidenceContext.veryConfident:
        weight += 0.2;
        break;
      case AdvisorConfidenceContext.confident:
        weight += 0.15;
        break;
      case AdvisorConfidenceContext.somewhatConfident:
        weight += 0.1;
        break;
      case AdvisorConfidenceContext.limitedObservation:
        weight += 0.05;
        break;
      case AdvisorConfidenceContext.uncertain:
        break; // No additional weight
    }

    // Examples bonus
    if (specificExamples != null && specificExamples!.isNotEmpty) {
      weight += 0.1;
      if (specificExamples!.length > 2) weight += 0.1;
    }

    // Substantive response bonus
    if (isSubstantiveResponse) weight += 0.1;

    return weight.clamp(0.0, 1.0);
  }

  /// Get a quality score for this advisor response
  double get responseQualityScore {
    double score = 0.0;

    // Base score from response length and detail
    if (isSubstantiveResponse) score += 0.3;
    if (wordCount > 50) score += 0.2;
    if (wordCount > 100) score += 0.1;

    // Confidence and credibility
    score += credibilityWeight * 0.3;

    // Specific examples
    if (specificExamples != null && specificExamples!.isNotEmpty) {
      score += 0.2;
    }

    // Additional context
    if (additionalContext != null && additionalContext!.isNotEmpty) {
      score += 0.1;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Extract key themes mentioned by the advisor
  List<String> get keyThemes {
    final themes = <String>[];
    final lowerResponse = response.toLowerCase();
    
    // Professional capability themes
    final themeKeywords = {
      'leadership': ['lead', 'leadership', 'manage', 'guide', 'direct', 'mentor'],
      'technical': ['technical', 'expert', 'skilled', 'proficient', 'competent'],
      'communication': ['communicate', 'explain', 'present', 'articulate', 'discuss'],
      'collaboration': ['team', 'collaborate', 'work together', 'partnership', 'cooperative'],
      'problem_solving': ['solve', 'problem', 'analyse', 'think', 'solution', 'resolve'],
      'reliability': ['reliable', 'dependable', 'consistent', 'trustworthy', 'punctual'],
      'creativity': ['creative', 'innovative', 'original', 'inventive', 'imaginative'],
      'initiative': ['proactive', 'initiative', 'self-starter', 'motivated', 'driven'],
      'adaptability': ['adaptable', 'flexible', 'adjust', 'change', 'versatile'],
      'attention_to_detail': ['detail', 'thorough', 'meticulous', 'careful', 'precise'],
    };
    
    for (final entry in themeKeywords.entries) {
      if (entry.value.any((keyword) => lowerResponse.contains(keyword))) {
        themes.add(entry.key);
      }
    }
    
    return themes;
  }

  /// Get observation period description
  String get observationPeriodDescription {
    switch (observationPeriod) {
      case AdvisorObservationPeriod.lessThanMonth:
        return 'Less than a month';
      case AdvisorObservationPeriod.oneToSixMonths:
        return '1-6 months';
      case AdvisorObservationPeriod.sixMonthsToYear:
        return '6 months to 1 year';
      case AdvisorObservationPeriod.oneToThreeYears:
        return '1-3 years';
      case AdvisorObservationPeriod.moreThanThreeYears:
        return 'More than 3 years';
    }
  }

  /// Get confidence context description
  String get confidenceContextDescription {
    switch (confidenceContext) {
      case AdvisorConfidenceContext.veryConfident:
        return 'Very confident in this assessment';
      case AdvisorConfidenceContext.confident:
        return 'Confident in this assessment';
      case AdvisorConfidenceContext.somewhatConfident:
        return 'Somewhat confident in this assessment';
      case AdvisorConfidenceContext.limitedObservation:
        return 'Limited observation, but confident in what I\'ve seen';
      case AdvisorConfidenceContext.uncertain:
        return 'Uncertain - limited experience to draw from';
    }
  }

  /// Export response data to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invitationId': invitationId,
      'questionId': questionId,
      'questionText': questionText,
      'response': response,
      'answeredAt': answeredAt.toIso8601String(),
      'domain': domain.name,
      'confidenceLevel': confidenceLevel,
      'observationPeriod': observationPeriod.name,
      'specificExamples': specificExamples,
      'confidenceContext': confidenceContext.name,
      'additionalContext': additionalContext,
      'isAnonymous': isAnonymous,
      'metadata': metadata,
      'analysis': {
        'wordCount': wordCount,
        'isSubstantiveResponse': isSubstantiveResponse,
        'credibilityWeight': credibilityWeight,
        'responseQualityScore': responseQualityScore,
        'keyThemes': keyThemes,
        'observationPeriodDescription': observationPeriodDescription,
        'confidenceContextDescription': confidenceContextDescription,
      },
    };
  }

  /// Create a new advisor response
  static AdvisorResponse create({
    required String invitationId,
    required String questionId,
    required String questionText,
    required String response,
    required CareerDomain domain,
    int? confidenceLevel,
    required AdvisorObservationPeriod observationPeriod,
    List<String>? specificExamples,
    required AdvisorConfidenceContext confidenceContext,
    String? additionalContext,
    bool isAnonymous = false,
    Map<String, dynamic>? metadata,
  }) {
    return AdvisorResponse(
      id: 'advisor_response_${DateTime.now().millisecondsSinceEpoch}',
      invitationId: invitationId,
      questionId: questionId,
      questionText: questionText,
      response: response,
      answeredAt: DateTime.now(),
      domain: domain,
      confidenceLevel: confidenceLevel,
      observationPeriod: observationPeriod,
      specificExamples: specificExamples,
      confidenceContext: confidenceContext,
      additionalContext: additionalContext,
      isAnonymous: isAnonymous,
      metadata: metadata,
    );
  }

  @override
  String toString() {
    return 'AdvisorResponse{id: $id, questionId: $questionId, domain: ${domain.name}, '
           'quality: ${responseQualityScore.toStringAsFixed(2)}, credibility: ${credibilityWeight.toStringAsFixed(2)}}';
  }
}

/// Period over which the advisor has observed the user
@HiveType(typeId: 24)
enum AdvisorObservationPeriod {
  @HiveField(0)
  lessThanMonth('Less than a month', 'Limited but recent observation'),
  
  @HiveField(1)
  oneToSixMonths('1-6 months', 'Good short-term observation'),
  
  @HiveField(2)
  sixMonthsToYear('6 months to 1 year', 'Solid medium-term observation'),
  
  @HiveField(3)
  oneToThreeYears('1-3 years', 'Strong long-term observation'),
  
  @HiveField(4)
  moreThanThreeYears('More than 3 years', 'Extensive long-term observation');

  const AdvisorObservationPeriod(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// Context for advisor's confidence in their assessment
@HiveType(typeId: 25)
enum AdvisorConfidenceContext {
  @HiveField(0)
  veryConfident('Very Confident', 'Have worked closely and observed extensively'),
  
  @HiveField(1)
  confident('Confident', 'Have good observation and experience with person'),
  
  @HiveField(2)
  somewhatConfident('Somewhat Confident', 'Have some observation but limited context'),
  
  @HiveField(3)
  limitedObservation('Limited Observation', 'Haven\'t observed much but confident in what I\'ve seen'),
  
  @HiveField(4)
  uncertain('Uncertain', 'Don\'t feel I have enough information to be confident');

  const AdvisorConfidenceContext(this.displayName, this.description);
  
  final String displayName;
  final String description;
}