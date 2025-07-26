import 'package:hive/hive.dart';
import 'career_session.dart';
import 'model_validation.dart';

part 'career_response.g.dart';

/// A response to a career exploration question
/// Stores the user's thoughtful responses to career-related prompts
@HiveType(typeId: 11)
class CareerResponse extends HiveObject {
  @HiveField(0)
  final String questionId;

  @HiveField(1)
  final String questionText;

  @HiveField(2)
  final String response;

  @HiveField(3)
  final DateTime answeredAt;

  @HiveField(4)
  final CareerDomain domain;

  @HiveField(5)
  final int? confidenceLevel; // 1-5 scale, optional

  @HiveField(6)
  final List<String>? tags; // Optional tags for categorisation

  @HiveField(7)
  final bool? isReflectionComplete; // Whether the user feels they've fully reflected

  CareerResponse({
    required this.questionId,
    required this.questionText,
    required this.response,
    required this.answeredAt,
    required this.domain,
    this.confidenceLevel,
    this.tags,
    this.isReflectionComplete,
  });

  CareerResponse copyWith({
    String? questionId,
    String? questionText,
    String? response,
    DateTime? answeredAt,
    CareerDomain? domain,
    int? confidenceLevel,
    List<String>? tags,
    bool? isReflectionComplete,
  }) {
    return CareerResponse(
      questionId: questionId ?? this.questionId,
      questionText: questionText ?? this.questionText,
      response: response ?? this.response,
      answeredAt: answeredAt ?? this.answeredAt,
      domain: domain ?? this.domain,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      tags: tags ?? this.tags,
      isReflectionComplete: isReflectionComplete ?? this.isReflectionComplete,
    );
  }

  /// Validate this career response
  ValidationResult validate() {
    final results = [
      questionId.validateRequired('Question ID'),
      questionText.validateRequired('Question text'),
      response.validateRequired('Response'),
    ];
    
    if (confidenceLevel != null) {
      results.add(confidenceLevel.validateRating('Confidence level'));
    }
    
    return ModelValidation.combineResults(results);
  }

  /// Check if this is a substantial response (more than just a few words)
  bool get isSubstantive {
    final cleanResponse = response.trim();
    return cleanResponse.length > 20 && 
           cleanResponse.split(' ').length > 5;
  }

  /// Get word count of the response
  int get wordCount {
    return response.trim().split(RegExp(r'\s+')).length;
  }

  /// Get character count (excluding whitespace)
  int get characterCount {
    return response.replaceAll(RegExp(r'\s+'), '').length;
  }

  /// Estimate reading time in minutes
  double get estimatedReadingTime {
    const averageWordsPerMinute = 200;
    return wordCount / averageWordsPerMinute;
  }

  /// Check if response indicates high engagement
  bool get showsHighEngagement {
    return isSubstantive && 
           (confidenceLevel ?? 0) >= 4 && 
           (isReflectionComplete ?? false);
  }

  /// Get reflection quality score (0.0 to 1.0)
  double get reflectionQualityScore {
    double score = 0.0;
    
    // Base score from response length and substance
    if (isSubstantive) score += 0.3;
    if (wordCount > 50) score += 0.2;
    if (wordCount > 100) score += 0.1;
    
    // Confidence level contribution
    if (confidenceLevel != null) {
      score += (confidenceLevel! / 5.0) * 0.2;
    }
    
    // Reflection completeness
    if (isReflectionComplete == true) score += 0.2;
    
    return score.clamp(0.0, 1.0);
  }

  /// Get Australian English formatted response summary
  String get australianSummary {
    final buffer = StringBuffer();
    
    buffer.writeln('Response to: ${questionText}');
    buffer.writeln('Domain: ${domain.displayName}');
    buffer.writeln('Answered: ${_formatAustralianDate(answeredAt)}');
    buffer.writeln('');
    
    buffer.writeln('Word Count: $wordCount words');
    buffer.writeln('Reading Time: ${estimatedReadingTime.toStringAsFixed(1)} minutes');
    
    if (confidenceLevel != null) {
      buffer.writeln('Confidence: $confidenceLevel/5');
    }
    
    if (isReflectionComplete == true) {
      buffer.writeln('✓ Reflection marked as complete');
    }
    
    buffer.writeln('Quality Score: ${(reflectionQualityScore * 100).round()}%');
    
    if (keyThemes.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Key Themes: ${keyThemes.join(', ')}');
    }
    
    return buffer.toString();
  }
  
  /// Format date in Australian format
  String _formatAustralianDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  
  /// Get engagement level in Australian English
  String get engagementLevelAustralian {
    if (showsHighEngagement) return 'Highly engaged response';
    if (reflectionQualityScore >= 0.7) return 'Well-considered response';
    if (reflectionQualityScore >= 0.5) return 'Thoughtful response';
    if (reflectionQualityScore >= 0.3) return 'Basic response';
    return 'Limited response';
  }
  
  /// Get feedback suggestions in Australian English
  List<String> get feedbackSuggestionsAustralian {
    final suggestions = <String>[];
    
    if (!isSubstantive) {
      suggestions.add('Consider adding more detail and specific examples to help us understand your experience better.');
    }
    
    if (keyThemes.isEmpty) {
      suggestions.add('Try to include what aspects of this area particularly interest or energise you.');
    }
    
    if (confidenceLevel == null || confidenceLevel! < 3) {
      suggestions.add('If you\'re not confident about this area, that\'s completely normal - share what you do know or wonder about.');
    }
    
    if (isReflectionComplete != true && reflectionQualityScore < 0.6) {
      suggestions.add('Take your time to reflect deeply - the more thoughtful your responses, the better insights we can provide.');
    }
    
    if (suggestions.isEmpty) {
      suggestions.add('Great response! This level of detail helps us provide meaningful insights.');
    }
    
    return suggestions;
  }

  /// Extract key themes from the response using simple keyword analysis
  List<String> get keyThemes {
    final themes = <String>[];
    final lowerResponse = response.toLowerCase();
    
    // Career-related theme keywords
    final themeKeywords = {
      'passion': ['passion', 'love', 'enjoy', 'excited', 'enthusiastic', 'keen', 'motivated'],
      'growth': ['learn', 'grow', 'develop', 'improve', 'progress', 'upskill', 'advance'],
      'challenge': ['challenge', 'difficult', 'complex', 'problem', 'solve', 'tackle'],
      'collaboration': ['team', 'collaborate', 'together', 'group', 'partnership', 'teamwork'],
      'leadership': ['lead', 'manage', 'direct', 'guide', 'mentor', 'coordinate'],
      'creativity': ['creative', 'innovative', 'design', 'artistic', 'imagination', 'original'],
      'impact': ['impact', 'difference', 'change', 'influence', 'contribute', 'meaningful'],
      'stability': ['stable', 'secure', 'consistent', 'reliable', 'steady', 'dependable'],
      'flexibility': ['flexible', 'adaptable', 'varied', 'diverse', 'change', 'versatile'],
      'recognition': ['recognition', 'achievement', 'success', 'accomplishment', 'reward', 'acknowledgement'],
      'autonomy': ['independent', 'autonomy', 'freedom', 'self-directed', 'control'],
      'helping': ['help', 'support', 'assist', 'service', 'care', 'contribute'],
      'australian_context': ['aussie', 'australia', 'local', 'community', 'multicultural', 'fair dinkum'],
    };
    
    for (final entry in themeKeywords.entries) {
      if (entry.value.any((keyword) => lowerResponse.contains(keyword))) {
        themes.add(entry.key);
      }
    }
    
    return themes;
  }

  /// Export response data to JSON
  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'response': response,
      'answeredAt': answeredAt.toIso8601String(),
      'domain': domain.name,
      'confidenceLevel': confidenceLevel,
      'tags': tags,
      'isReflectionComplete': isReflectionComplete,
      'stats': {
        'wordCount': wordCount,
        'characterCount': characterCount,
        'isSubstantive': isSubstantive,
        'reflectionQualityScore': reflectionQualityScore,
        'keyThemes': keyThemes,
        'estimatedReadingTime': estimatedReadingTime,
      },
    };
  }

  /// Create a CareerResponse from a simple question and answer
  static CareerResponse create({
    required String questionId,
    required String questionText,
    required String response,
    required CareerDomain domain,
    int? confidenceLevel,
    List<String>? tags,
    bool? isReflectionComplete,
  }) {
    return CareerResponse(
      questionId: questionId,
      questionText: questionText,
      response: response,
      answeredAt: DateTime.now(),
      domain: domain,
      confidenceLevel: confidenceLevel,
      tags: tags,
      isReflectionComplete: isReflectionComplete,
    );
  }

  /// Check if response shows Australian cultural values
  bool get showsAustralianValues {
    final lowerResponse = response.toLowerCase();
    final australianValues = [
      'fair', 'equality', 'mateship', 'community', 'multicultural',
      'work-life balance', 'laid back', 'straightforward', 'honest',
      'inclusive', 'diverse', 'supportive'
    ];
    return australianValues.any((value) => lowerResponse.contains(value));
  }

  @override
  String toString() {
    return 'CareerResponse{questionId: $questionId, domain: ${domain.name}, '
           'wordCount: $wordCount, quality: ${reflectionQualityScore.toStringAsFixed(2)}}';
  }
}