import 'package:hive/hive.dart';
import 'career_session.dart';
import 'model_validation.dart';

part 'career_insight.g.dart';

/// Insights generated from career exploration responses
/// Represents patterns, themes, and guidance derived from user's reflections
@HiveType(typeId: 12)
class CareerInsight extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final CareerDomain domain;

  @HiveField(4)
  final InsightType type;

  @HiveField(5)
  final DateTime generatedAt;

  @HiveField(6)
  final double confidence; // 0.0 to 1.0

  @HiveField(7)
  final List<String> sourceQuestionIds; // Questions that contributed to this insight

  @HiveField(8)
  final List<String> keyThemes; // Main themes identified

  @HiveField(9)
  final String? actionSuggestion; // Optional actionable advice

  @HiveField(10)
  final bool isUserValidated; // Whether user has confirmed this insight resonates

  @HiveField(11)
  final int? userRating; // User's rating of insight relevance (1-5)

  CareerInsight({
    required this.id,
    required this.title,
    required this.content,
    required this.domain,
    required this.type,
    required this.generatedAt,
    required this.confidence,
    required this.sourceQuestionIds,
    required this.keyThemes,
    this.actionSuggestion,
    this.isUserValidated = false,
    this.userRating,
  });

  CareerInsight copyWith({
    String? id,
    String? title,
    String? content,
    CareerDomain? domain,
    InsightType? type,
    DateTime? generatedAt,
    double? confidence,
    List<String>? sourceQuestionIds,
    List<String>? keyThemes,
    String? actionSuggestion,
    bool? isUserValidated,
    int? userRating,
  }) {
    return CareerInsight(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      domain: domain ?? this.domain,
      type: type ?? this.type,
      generatedAt: generatedAt ?? this.generatedAt,
      confidence: confidence ?? this.confidence,
      sourceQuestionIds: sourceQuestionIds ?? this.sourceQuestionIds,
      keyThemes: keyThemes ?? this.keyThemes,
      actionSuggestion: actionSuggestion ?? this.actionSuggestion,
      isUserValidated: isUserValidated ?? this.isUserValidated,
      userRating: userRating ?? this.userRating,
    );
  }

  /// Validate this career insight
  ValidationResult validate() {
    final results = [
      id.validateRequired('Insight ID'),
      title.validateRequired('Insight title'),
      content.validateRequired('Insight content'),
      confidence.validateConfidence(),
      sourceQuestionIds.validateList('Source question IDs', minSize: 1),
      keyThemes.validateList('Key themes', minSize: 1),
    ];
    
    if (userRating != null) {
      results.add(userRating.validateRating('User rating'));
    }
    
    return ModelValidation.combineResults(results);
  }

  /// Get the overall quality score of this insight
  double get qualityScore {
    double score = confidence * 0.4; // Base confidence
    
    // Source diversity bonus
    if (sourceQuestionIds.length > 2) score += 0.2;
    if (sourceQuestionIds.length > 4) score += 0.1;
    
    // Theme richness bonus
    if (keyThemes.length > 2) score += 0.1;
    if (keyThemes.length > 4) score += 0.1;
    
    // Actionability bonus
    if (actionSuggestion != null && actionSuggestion!.isNotEmpty) score += 0.1;
    
    // User validation bonus
    if (isUserValidated) score += 0.2;
    if (userRating != null && userRating! >= 4) score += 0.1;
    
    return score.clamp(0.0, 1.0);
  }

  /// Check if this insight is considered high-quality
  bool get isHighQuality => qualityScore >= 0.7;

  /// Get age of insight in days
  int get ageInDays {
    return DateTime.now().difference(generatedAt).inDays;
  }

  /// Check if insight is recent (within last 7 days)
  bool get isRecent => ageInDays <= 7;

  /// Get the primary theme (first in the list)
  String? get primaryTheme => keyThemes.isNotEmpty ? keyThemes.first : null;

  /// Get a shortened version of the content for previews
  String get preview {
    if (content.length <= 100) return content;
    return '${content.substring(0, 97)}...';
  }

  /// Get Australian English formatted description
  String get formattedDescription {
    final buffer = StringBuffer();
    buffer.writeln('Career Insight: $title');
    buffer.writeln('Domain: ${domain.displayName}');
    buffer.writeln('Type: ${type.displayName}');
    buffer.writeln('Generated: ${_formatAustralianDate(generatedAt)}');
    buffer.writeln('Quality Score: ${(qualityScore * 100).round()}%');
    
    if (isUserValidated) {
      buffer.writeln('✓ Validated by you');
    }
    
    if (userRating != null) {
      buffer.writeln('Your Rating: $userRating/5 stars');
    }
    
    return buffer.toString();
  }

  /// Format date in Australian format (DD/MM/YYYY)
  String _formatAustralianDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Get Australian English formatted time ago
  String get timeAgoAustralian {
    final now = DateTime.now();
    final difference = now.difference(generatedAt);
    
    if (difference.inDays > 0) {
      final days = difference.inDays;
      if (days == 1) return '1 day ago';
      if (days <= 7) return '$days days ago';
      if (days <= 14) return '1 week ago';
      if (days <= 28) return '${(days / 7).round()} weeks ago';
      final months = (days / 30).round();
      if (months == 1) return '1 month ago';
      if (months < 12) return '$months months ago';
      final years = (days / 365).round();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
    
    if (difference.inHours > 0) {
      final hours = difference.inHours;
      return hours == 1 ? '1 hour ago' : '$hours hours ago';
    }
    
    if (difference.inMinutes > 0) {
      final minutes = difference.inMinutes;
      return minutes == 1 ? '1 minute ago' : '$minutes minutes ago';
    }
    
    return 'Just now';
  }

  /// Get insight impact level in Australian English
  String get impactLevelAustralian {
    if (qualityScore >= 0.9) return 'Transformational insight';
    if (qualityScore >= 0.8) return 'High-impact insight';
    if (qualityScore >= 0.7) return 'Valuable insight';
    if (qualityScore >= 0.6) return 'Useful insight';
    if (qualityScore >= 0.5) return 'Moderate insight';
    return 'Basic insight';
  }

  /// Generate Australian English summary
  String generateAustralianSummary() {
    final buffer = StringBuffer();
    
    buffer.writeln('📊 ${impactLevelAustralian} • ${timeAgoAustralian}');
    buffer.writeln('');
    buffer.writeln('This insight focuses on ${domain.displayName.toLowerCase()} and identifies ${type.displayName.toLowerCase()}. ');
    
    if (keyThemes.isNotEmpty) {
      buffer.writeln('Key themes include: ${keyThemes.take(3).join(', ')}.');
    }
    
    if (actionSuggestion != null && actionSuggestion!.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('💡 Action suggestion: $actionSuggestion');
    }
    
    return buffer.toString();
  }

  /// Check if insight needs follow-up in Australian context
  bool get needsFollowUpAustralian {
    return !isUserValidated && 
           ageInDays <= 30 && 
           qualityScore >= 0.7 && 
           actionSuggestion != null;
  }

  /// Export insight to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'domain': domain.name,
      'type': type.name,
      'generatedAt': generatedAt.toIso8601String(),
      'confidence': confidence,
      'sourceQuestionIds': sourceQuestionIds,
      'keyThemes': keyThemes,
      'actionSuggestion': actionSuggestion,
      'isUserValidated': isUserValidated,
      'userRating': userRating,
      'stats': {
        'qualityScore': qualityScore,
        'isHighQuality': isHighQuality,
        'ageInDays': ageInDays,
        'isRecent': isRecent,
        'primaryTheme': primaryTheme,
      },
    };
  }

  /// Create a basic insight from analysis
  static CareerInsight create({
    required String title,
    required String content,
    required CareerDomain domain,
    required InsightType type,
    required List<String> sourceQuestionIds,
    required List<String> keyThemes,
    double confidence = 0.5,
    String? actionSuggestion,
  }) {
    return CareerInsight(
      id: 'insight_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: content,
      domain: domain,
      type: type,
      generatedAt: DateTime.now(),
      confidence: confidence,
      sourceQuestionIds: sourceQuestionIds,
      keyThemes: keyThemes,
      actionSuggestion: actionSuggestion,
    );
  }

  @override
  String toString() {
    return 'CareerInsight{id: $id, title: $title, domain: ${domain.name}, '
           'type: ${type.name}, quality: ${qualityScore.toStringAsFixed(2)}}';
  }
}

/// Types of career insights that can be generated
@HiveType(typeId: 15)
enum InsightType {
  @HiveField(0)
  pattern('Pattern Recognition', 'Identifies recurring themes and patterns', '🔍'),
  
  @HiveField(1)
  strength('Strength Identification', 'Highlights natural talents and strengths', '💪'),
  
  @HiveField(2)
  value('Values Clarification', 'Clarifies core values and motivations', '⭐'),
  
  @HiveField(3)
  interest('Interest Discovery', 'Reveals genuine interests and passions', '🎯'),
  
  @HiveField(4)
  development('Development Opportunity', 'Suggests areas for growth and learning', '📈'),
  
  @HiveField(5)
  compatibility('Role Compatibility', 'Assesses fit with specific career paths', '🤝'),
  
  @HiveField(6)
  barrier('Barrier Identification', 'Identifies potential obstacles or concerns', '🚧'),
  
  @HiveField(7)
  nextStep('Next Steps', 'Provides actionable guidance for career exploration', '➡️');

  const InsightType(this.displayName, this.description, this.icon);
  
  final String displayName;
  final String description;
  final String icon;
  
  /// Get Australian English friendly description
  String get australianDescription {
    switch (this) {
      case InsightType.pattern:
        return 'Spots recurring themes and patterns in your career journey';
      case InsightType.strength:
        return 'Highlights your natural talents and areas where you excel';
      case InsightType.value:
        return 'Clarifies what truly matters to you in your work';
      case InsightType.interest:
        return 'Uncovers what genuinely engages and excites you';
      case InsightType.development:
        return 'Suggests areas where you can grow and develop further';
      case InsightType.compatibility:
        return 'Assesses how well you might fit with different career paths';
      case InsightType.barrier:
        return 'Identifies potential challenges or obstacles to consider';
      case InsightType.nextStep:
        return 'Provides practical next steps for your career exploration';
    }
  }
}