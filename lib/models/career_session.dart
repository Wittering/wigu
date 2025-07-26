import 'package:hive/hive.dart';
import 'career_response.dart';
import 'career_insight.dart';
import 'model_validation.dart';

part 'career_session.g.dart';

/// Career exploration session data
/// Stores all responses, insights, and progress for a career exploration journey
@HiveType(typeId: 10)
class CareerSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime createdAt;

  @HiveField(2)
  final DateTime lastModified;

  @HiveField(3)
  final Map<String, CareerResponse> responses;

  @HiveField(4)
  final List<CareerInsight> insights;

  @HiveField(5)
  final String sessionName;

  @HiveField(6)
  final List<CareerDomain> completedDomains;

  @HiveField(7)
  final ExplorationType preferredExplorationType;

  CareerSession({
    required this.id,
    required this.createdAt,
    required this.lastModified,
    required this.responses,
    required this.insights,
    required this.sessionName,
    required this.completedDomains,
    required this.preferredExplorationType,
  });

  CareerSession copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? lastModified,
    Map<String, CareerResponse>? responses,
    List<CareerInsight>? insights,
    String? sessionName,
    List<CareerDomain>? completedDomains,
    ExplorationType? preferredExplorationType,
  }) {
    return CareerSession(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      responses: responses ?? this.responses,
      insights: insights ?? this.insights,
      sessionName: sessionName ?? this.sessionName,
      completedDomains: completedDomains ?? this.completedDomains,
      preferredExplorationType: preferredExplorationType ?? this.preferredExplorationType,
    );
  }

  /// Validate this career session
  ValidationResult validate() {
    final results = [
      id.validateRequired('Session ID'),
      sessionName.validateRequired('Session name'),
    ];
    
    // Validate that we have at least some responses or insights
    if (responses.isEmpty && insights.isEmpty) {
      results.add(ValidationResult.error('Session must have at least one response or insight'));
    }
    
    return ModelValidation.combineResults(results);
  }

  /// Calculate completion percentage for the session
  double get completionPercentage {
    final totalDomains = CareerDomain.values.length;
    final completed = completedDomains.length;
    return totalDomains > 0 ? completed / totalDomains : 0.0;
  }

  /// Get the total number of responses recorded
  int get totalResponses => responses.length;

  /// Get the total number of insights generated
  int get totalInsights => insights.length;

  /// Check if the session has responses for a specific domain
  bool hasDomainResponses(CareerDomain domain) {
    return responses.values.any((response) => response.domain == domain);
  }

  /// Get responses for a specific domain
  List<CareerResponse> getResponsesForDomain(CareerDomain domain) {
    return responses.values
        .where((response) => response.domain == domain)
        .toList()
      ..sort((a, b) => a.answeredAt.compareTo(b.answeredAt));
  }

  /// Get insights for a specific domain
  List<CareerInsight> getInsightsForDomain(CareerDomain domain) {
    return insights
        .where((insight) => insight.domain == domain)
        .toList()
      ..sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
  }

  /// Get the most recent insight
  CareerInsight? get latestInsight {
    if (insights.isEmpty) return null;
    
    final sortedInsights = List<CareerInsight>.from(insights)
      ..sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    
    return sortedInsights.first;
  }

  /// Get Australian English formatted session summary
  String get australianSummary {
    final buffer = StringBuffer();
    
    buffer.writeln('Career Exploration Session: $sessionName');
    buffer.writeln('Started: ${_formatAustralianDate(createdAt)}');
    buffer.writeln('Last Updated: ${_formatAustralianDate(lastModified)}');
    buffer.writeln('');
    
    buffer.writeln('Progress: ${(completionPercentage * 100).round()}% complete');
    buffer.writeln('Responses: $totalResponses recorded');
    buffer.writeln('Insights: $totalInsights generated');
    buffer.writeln('Domains Explored: ${completedDomains.length}/${CareerDomain.values.length}');
    buffer.writeln('Exploration Style: ${preferredExplorationType.displayName}');
    
    if (completedDomains.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Completed Domains:');
      for (final domain in completedDomains) {
        buffer.writeln('  ✓ ${domain.displayName}');
      }
    }
    
    final remainingDomains = CareerDomain.values.where((d) => !completedDomains.contains(d)).toList();
    if (remainingDomains.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Remaining Domains:');
      for (final domain in remainingDomains) {
        buffer.writeln('  ○ ${domain.displayName}');
      }
    }
    
    return buffer.toString();
  }
  
  /// Format date in Australian format
  String _formatAustralianDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  
  /// Get session duration in Australian English
  String get durationAustralian {
    final duration = lastModified.difference(createdAt);
    
    if (duration.inDays > 0) {
      final days = duration.inDays;
      if (days == 1) return '1 day';
      if (days <= 7) return '$days days';
      if (days <= 14) return '1 week';
      final weeks = (days / 7).round();
      return '$weeks weeks';
    }
    
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      return hours == 1 ? '1 hour' : '$hours hours';
    }
    
    final minutes = duration.inMinutes;
    return minutes <= 1 ? 'Just started' : '$minutes minutes';
  }
  
  /// Get next recommended domain in Australian English
  String? get nextRecommendedDomainAustralian {
    final remaining = CareerDomain.values.where((d) => !completedDomains.contains(d)).toList();
    if (remaining.isEmpty) return null;
    
    // Recommend based on exploration type
    switch (preferredExplorationType) {
      case ExplorationType.reflective:
        // Suggest introspective domains first
        for (final domain in [CareerDomain.social, CareerDomain.creative, CareerDomain.analytical]) {
          if (remaining.contains(domain)) return 'Consider exploring ${domain.displayName} next - it aligns well with reflective exploration.';
        }
        break;
      case ExplorationType.structured:
        // Suggest systematic progression
        return 'Next up: ${remaining.first.displayName} - let\'s work through this systematically.';
      case ExplorationType.experimental:
        // Suggest action-oriented domains
        for (final domain in [CareerDomain.entrepreneurial, CareerDomain.leadership, CareerDomain.technical]) {
          if (remaining.contains(domain)) return 'Try ${domain.displayName} next - perfect for experimental learning.';
        }
        break;
      case ExplorationType.collaborative:
        // Suggest people-focused domains
        for (final domain in [CareerDomain.social, CareerDomain.leadership, CareerDomain.traditional]) {
          if (remaining.contains(domain)) return '${domain.displayName} would be great to explore next, especially with input from others.';
        }
        break;
    }
    
    return 'Consider exploring ${remaining.first.displayName} next.';
  }

  /// Export session data to JSON for backup/sharing
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionName': sessionName,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'preferredExplorationType': preferredExplorationType.name,
      'completedDomains': completedDomains.map((d) => d.name).toList(),
      'responses': responses.map((key, value) => MapEntry(key, value.toJson())),
      'insights': insights.map((insight) => insight.toJson()).toList(),
      'stats': {
        'totalResponses': totalResponses,
        'totalInsights': totalInsights,
        'completionPercentage': completionPercentage,
      },
    };
  }
}

/// Career domains for exploration
@HiveType(typeId: 13)
enum CareerDomain {
  @HiveField(0)
  technical('Technical & Engineering', 'Skills in technology, engineering, and problem-solving', '💻'),
  
  @HiveField(1)
  leadership('Leadership & Management', 'Leading teams, managing projects, and strategic thinking', '📈'),
  
  @HiveField(2)
  creative('Creative & Design', 'Artistic expression, design thinking, and innovation', '🎨'),
  
  @HiveField(3)
  analytical('Analytical & Research', 'Data analysis, research, and critical thinking', '🔍'),
  
  @HiveField(4)
  social('Social & Communication', 'Working with people, communication, and relationship building', '🤝'),
  
  @HiveField(5)
  entrepreneurial('Entrepreneurial & Business', 'Starting ventures, business development, and risk-taking', '🚀'),
  
  @HiveField(6)
  traditional('Traditional & Service', 'Established professions and service-oriented roles', '🏢'),
  
  @HiveField(7)
  investigative('Investigative & Academic', 'Research, academia, and knowledge discovery', '📚');

  const CareerDomain(this.displayName, this.description, this.icon);
  
  final String displayName;
  final String description;
  final String icon;
  
  /// Get Australian workplace context description
  String get australianContext {
    switch (this) {
      case CareerDomain.technical:
        return 'Technology and engineering roles across Australia\'s growing tech sector, from Sydney startups to mining tech in Perth';
      case CareerDomain.leadership:
        return 'Management and leadership opportunities in Australia\'s diverse economy, from corporate leadership to community organisations';
      case CareerDomain.creative:
        return 'Creative industries thriving in Melbourne\'s arts scene, Sydney\'s design hubs, and Australia\'s growing creative economy';
      case CareerDomain.analytical:
        return 'Research and analytical roles in universities, government agencies, and Australia\'s strong research institutions';
      case CareerDomain.social:
        return 'People-focused roles in Australia\'s service economy, community organisations, and multicultural workplaces';
      case CareerDomain.entrepreneurial:
        return 'Business and startup opportunities in Australia\'s supportive entrepreneurial ecosystem and growing innovation hubs';
      case CareerDomain.traditional:
        return 'Established professions like healthcare, education, and public service that form the backbone of Australian society';
      case CareerDomain.investigative:
        return 'Academic and research opportunities in Australia\'s world-class universities and research institutions';
    }
  }
}

/// Types of career exploration approaches
@HiveType(typeId: 14)
enum ExplorationType {
  @HiveField(0)
  reflective('Reflective', 'Deep self-reflection and contemplative exploration'),
  
  @HiveField(1)
  structured('Structured', 'Step-by-step guided exploration with clear frameworks'),
  
  @HiveField(2)
  experimental('Experimental', 'Try different approaches and learn through experience'),
  
  @HiveField(3)
  collaborative('Collaborative', 'Explore with others through discussion and feedback');

  const ExplorationType(this.displayName, this.description);
  
  final String displayName;
  final String description;
}