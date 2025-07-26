import 'package:hive/hive.dart';
import 'career_insight.dart';
import 'career_response.dart';
import 'advisor_response.dart';

part 'insight_analysis.g.dart';

/// Detailed analysis of career insights including patterns, trends, and correlations
/// Provides meta-analysis of the insight generation process
@HiveType(typeId: 34)
class InsightAnalysis extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String sessionId;

  @HiveField(2)
  final DateTime analysedAt;

  @HiveField(3)
  final List<String> analysedInsightIds;

  @HiveField(4)
  final Map<String, int> themeFrequency; // How often each theme appears

  @HiveField(5)
  final Map<String, double> themeConfidence; // Average confidence per theme

  @HiveField(6)
  final List<InsightPattern> identifiedPatterns;

  @HiveField(7)
  final List<InsightCorrelation> correlations;

  @HiveField(8)
  final InsightTrendAnalysis trendAnalysis;

  @HiveField(9)
  final Map<InsightType, InsightTypeStats> typeDistribution;

  @HiveField(10)
  final List<String> emergingThemes; // Themes appearing more recently

  @HiveField(11)
  final List<String> consistentThemes; // Themes appearing consistently over time

  @HiveField(12)
  final double overallInsightQuality; // 0.0 to 1.0

  @HiveField(13)
  final List<String> analyticalRecommendations;

  @HiveField(14)
  final Map<String, dynamic>? metadata;

  InsightAnalysis({
    required this.id,
    required this.sessionId,
    required this.analysedAt,
    required this.analysedInsightIds,
    required this.themeFrequency,
    required this.themeConfidence,
    required this.identifiedPatterns,
    required this.correlations,
    required this.trendAnalysis,
    required this.typeDistribution,
    required this.emergingThemes,
    required this.consistentThemes,
    required this.overallInsightQuality,
    required this.analyticalRecommendations,
    this.metadata,
  });

  InsightAnalysis copyWith({
    String? id,
    String? sessionId,
    DateTime? analysedAt,
    List<String>? analysedInsightIds,
    Map<String, int>? themeFrequency,
    Map<String, double>? themeConfidence,
    List<InsightPattern>? identifiedPatterns,
    List<InsightCorrelation>? correlations,
    InsightTrendAnalysis? trendAnalysis,
    Map<InsightType, InsightTypeStats>? typeDistribution,
    List<String>? emergingThemes,
    List<String>? consistentThemes,
    double? overallInsightQuality,
    List<String>? analyticalRecommendations,
    Map<String, dynamic>? metadata,
  }) {
    return InsightAnalysis(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      analysedAt: analysedAt ?? this.analysedAt,
      analysedInsightIds: analysedInsightIds ?? this.analysedInsightIds,
      themeFrequency: themeFrequency ?? this.themeFrequency,
      themeConfidence: themeConfidence ?? this.themeConfidence,
      identifiedPatterns: identifiedPatterns ?? this.identifiedPatterns,
      correlations: correlations ?? this.correlations,
      trendAnalysis: trendAnalysis ?? this.trendAnalysis,
      typeDistribution: typeDistribution ?? this.typeDistribution,
      emergingThemes: emergingThemes ?? this.emergingThemes,
      consistentThemes: consistentThemes ?? this.consistentThemes,
      overallInsightQuality: overallInsightQuality ?? this.overallInsightQuality,
      analyticalRecommendations: analyticalRecommendations ?? this.analyticalRecommendations,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get the most frequently occurring themes
  List<String> get topThemes {
    final sortedThemes = themeFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedThemes.take(10).map((e) => e.key).toList();
  }

  /// Get themes with the highest confidence
  List<String> get highConfidenceThemes {
    return themeConfidence.entries
        .where((entry) => entry.value >= 0.8)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get the dominant insight type
  InsightType? get dominantInsightType {
    if (typeDistribution.isEmpty) return null;
    
    final sortedTypes = typeDistribution.entries.toList()
      ..sort((a, b) => b.value.count.compareTo(a.value.count));
    
    return sortedTypes.first.key;
  }

  /// Check if insights show strong consistency
  bool get showsStrongConsistency {
    return consistentThemes.length >= 3 && 
           overallInsightQuality >= 0.7;
  }

  /// Get insights into career trajectory based on trends
  String get careerTrajectoryInsight {
    final buffer = StringBuffer();
    
    if (trendAnalysis.isImproving) {
      buffer.writeln('Your career insights show positive development trends:');
      if (emergingThemes.isNotEmpty) {
        buffer.writeln('• Emerging strengths: ${emergingThemes.take(3).join(', ')}');
      }
    } else if (trendAnalysis.isStagnating) {
      buffer.writeln('Your career insights suggest areas that may need fresh focus:');
      if (consistentThemes.isNotEmpty) {
        buffer.writeln('• Consistent areas: ${consistentThemes.take(3).join(', ')}');
      }
    }
    
    if (identifiedPatterns.isNotEmpty) {
      final strongPatterns = identifiedPatterns
          .where((p) => p.strength >= 0.7)
          .take(2);
      
      if (strongPatterns.isNotEmpty) {
        buffer.writeln('• Strong patterns: ${strongPatterns.map((p) => p.description).join('; ')}');
      }
    }
    
    return buffer.toString().trim();
  }

  /// Generate insight quality report
  String generateQualityReport() {
    final buffer = StringBuffer();
    
    buffer.writeln('Insight Quality Analysis Report');
    buffer.writeln('=====================================');
    buffer.writeln('');
    buffer.writeln('Overall Quality Score: ${(overallInsightQuality * 100).round()}%');
    buffer.writeln('Total Insights Analysed: ${analysedInsightIds.length}');
    buffer.writeln('');
    
    buffer.writeln('Theme Analysis:');
    buffer.writeln('• Most Common Themes: ${topThemes.take(5).join(', ')}');
    buffer.writeln('• High Confidence Themes: ${highConfidenceThemes.join(', ')}');
    buffer.writeln('• Emerging Themes: ${emergingThemes.join(', ')}');
    buffer.writeln('• Consistent Themes: ${consistentThemes.join(', ')}');
    buffer.writeln('');
    
    if (dominantInsightType != null) {
      buffer.writeln('Dominant Insight Type: ${dominantInsightType!.displayName}');
      buffer.writeln('');
    }
    
    buffer.writeln('Pattern Analysis:');
    for (final pattern in identifiedPatterns.take(3)) {
      buffer.writeln('• ${pattern.description} (Strength: ${(pattern.strength * 100).round()}%)');
    }
    buffer.writeln('');
    
    buffer.writeln('Trend Analysis:');
    buffer.writeln('• Quality Trend: ${trendAnalysis.qualityTrend.displayName}');
    buffer.writeln('• Theme Diversity: ${trendAnalysis.themeDiversityTrend.displayName}');
    buffer.writeln('');
    
    buffer.writeln('Recommendations:');
    for (final recommendation in analyticalRecommendations) {
      buffer.writeln('• $recommendation');
    }
    
    return buffer.toString();
  }

  /// Export analysis data to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'analysedAt': analysedAt.toIso8601String(),
      'analysedInsightIds': analysedInsightIds,
      'themeFrequency': themeFrequency,
      'themeConfidence': themeConfidence,
      'identifiedPatterns': identifiedPatterns.map((p) => p.toJson()).toList(),
      'correlations': correlations.map((c) => c.toJson()).toList(),
      'trendAnalysis': trendAnalysis.toJson(),
      'typeDistribution': typeDistribution.map((key, value) => 
          MapEntry(key.name, value.toJson())),
      'emergingThemes': emergingThemes,
      'consistentThemes': consistentThemes,
      'overallInsightQuality': overallInsightQuality,
      'analyticalRecommendations': analyticalRecommendations,
      'metadata': metadata,
      'summary': {
        'topThemes': topThemes,
        'highConfidenceThemes': highConfidenceThemes,
        'dominantInsightType': dominantInsightType?.name,
        'showsStrongConsistency': showsStrongConsistency,
        'careerTrajectoryInsight': careerTrajectoryInsight,
      },
    };
  }

  /// Create a new insight analysis
  static InsightAnalysis create({
    required String sessionId,
    required List<String> analysedInsightIds,
    required Map<String, int> themeFrequency,
    required Map<String, double> themeConfidence,
    required List<InsightPattern> identifiedPatterns,
    required List<InsightCorrelation> correlations,
    required InsightTrendAnalysis trendAnalysis,
    required Map<InsightType, InsightTypeStats> typeDistribution,
    required List<String> emergingThemes,
    required List<String> consistentThemes,
    required double overallInsightQuality,
    required List<String> analyticalRecommendations,
    Map<String, dynamic>? metadata,
  }) {
    return InsightAnalysis(
      id: 'analysis_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: sessionId,
      analysedAt: DateTime.now(),
      analysedInsightIds: analysedInsightIds,
      themeFrequency: themeFrequency,
      themeConfidence: themeConfidence,
      identifiedPatterns: identifiedPatterns,
      correlations: correlations,
      trendAnalysis: trendAnalysis,
      typeDistribution: typeDistribution,
      emergingThemes: emergingThemes,
      consistentThemes: consistentThemes,
      overallInsightQuality: overallInsightQuality,
      analyticalRecommendations: analyticalRecommendations,
      metadata: metadata,
    );
  }

  @override
  String toString() {
    return 'InsightAnalysis{id: $id, session: $sessionId, '
           'insights: ${analysedInsightIds.length}, quality: ${(overallInsightQuality * 100).round()}%}';
  }
}

/// Represents a pattern identified across multiple insights
@HiveType(typeId: 35)
class InsightPattern extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double strength; // 0.0 to 1.0

  @HiveField(4)
  final List<String> supportingInsightIds;

  @HiveField(5)
  final PatternType type;

  @HiveField(6)
  final String? implication;

  InsightPattern({
    required this.id,
    required this.name,
    required this.description,
    required this.strength,
    required this.supportingInsightIds,
    required this.type,
    this.implication,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'strength': strength,
      'supportingInsightIds': supportingInsightIds,
      'type': type.name,
      'implication': implication,
    };
  }

  @override
  String toString() {
    return 'InsightPattern{name: $name, strength: ${strength.toStringAsFixed(2)}, type: ${type.name}}';
  }
}

/// Represents a correlation between different themes or insights
@HiveType(typeId: 36)
class InsightCorrelation extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String theme1;

  @HiveField(2)
  final String theme2;

  @HiveField(3)
  final double correlation; // -1.0 to 1.0

  @HiveField(4)
  final CorrelationType type;

  @HiveField(5)
  final String interpretation;

  InsightCorrelation({
    required this.id,
    required this.theme1,
    required this.theme2,
    required this.correlation,
    required this.type,
    required this.interpretation,
  });

  bool get isStrongCorrelation => correlation.abs() >= 0.7;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'theme1': theme1,
      'theme2': theme2,
      'correlation': correlation,
      'type': type.name,
      'interpretation': interpretation,
      'isStrongCorrelation': isStrongCorrelation,
    };
  }

  @override
  String toString() {
    return 'InsightCorrelation{$theme1 <-> $theme2: ${correlation.toStringAsFixed(2)}}';
  }
}

/// Analysis of trends in insights over time
@HiveType(typeId: 37)
class InsightTrendAnalysis extends HiveObject {
  @HiveField(0)
  final QualityTrend qualityTrend;

  @HiveField(1)
  final DiversityTrend themeDiversityTrend;

  @HiveField(2)
  final bool isImproving;

  @HiveField(3)
  final bool isStagnating;

  @HiveField(4)
  final List<String> improvingAreas;

  @HiveField(5)
  final List<String> decliningAreas;

  InsightTrendAnalysis({
    required this.qualityTrend,
    required this.themeDiversityTrend,
    required this.isImproving,
    required this.isStagnating,
    required this.improvingAreas,
    required this.decliningAreas,
  });

  Map<String, dynamic> toJson() {
    return {
      'qualityTrend': qualityTrend.name,
      'themeDiversityTrend': themeDiversityTrend.name,
      'isImproving': isImproving,
      'isStagnating': isStagnating,
      'improvingAreas': improvingAreas,
      'decliningAreas': decliningAreas,
    };
  }

  @override
  String toString() {
    return 'InsightTrendAnalysis{quality: ${qualityTrend.name}, diversity: ${themeDiversityTrend.name}}';
  }
}

/// Statistics for each insight type
@HiveType(typeId: 38)
class InsightTypeStats extends HiveObject {
  @HiveField(0)
  final int count;

  @HiveField(1)
  final double averageQuality;

  @HiveField(2)
  final double averageConfidence;

  @HiveField(3)
  final List<String> commonThemes;

  InsightTypeStats({
    required this.count,
    required this.averageQuality,
    required this.averageConfidence,
    required this.commonThemes,
  });

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'averageQuality': averageQuality,
      'averageConfidence': averageConfidence,
      'commonThemes': commonThemes,
    };
  }

  @override
  String toString() {
    return 'InsightTypeStats{count: $count, avgQuality: ${averageQuality.toStringAsFixed(2)}}';
  }
}

/// Types of patterns that can be identified
@HiveType(typeId: 39)
enum PatternType {
  @HiveField(0)
  recurring('Recurring', 'Themes that appear consistently'),
  
  @HiveField(1)
  evolving('Evolving', 'Themes that change over time'),
  
  @HiveField(2)
  complementary('Complementary', 'Themes that reinforce each other'),
  
  @HiveField(3)
  conflicting('Conflicting', 'Themes that seem to contradict'),
  
  @HiveField(4)
  emergent('Emergent', 'New themes appearing recently');

  const PatternType(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// Types of correlations between themes
@HiveType(typeId: 40)
enum CorrelationType {
  @HiveField(0)
  positive('Positive', 'Themes that tend to appear together'),
  
  @HiveField(1)
  negative('Negative', 'Themes that rarely appear together'),
  
  @HiveField(2)
  causal('Causal', 'One theme may lead to another'),
  
  @HiveField(3)
  complementary('Complementary', 'Themes that enhance each other');

  const CorrelationType(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// Trend in insight quality over time
@HiveType(typeId: 41)
enum QualityTrend {
  @HiveField(0)
  improving('Improving', 'Quality is getting better over time'),
  
  @HiveField(1)
  stable('Stable', 'Quality remains consistent'),
  
  @HiveField(2)
  declining('Declining', 'Quality is decreasing over time'),
  
  @HiveField(3)
  volatile('Volatile', 'Quality varies significantly');

  const QualityTrend(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// Trend in theme diversity over time
@HiveType(typeId: 42)
enum DiversityTrend {
  @HiveField(0)
  expanding('Expanding', 'More diverse themes emerging'),
  
  @HiveField(1)
  focusing('Focusing', 'Themes becoming more focused'),
  
  @HiveField(2)
  stable('Stable', 'Theme diversity remains consistent'),
  
  @HiveField(3)
  cyclical('Cyclical', 'Theme diversity varies in cycles');

  const DiversityTrend(this.displayName, this.description);
  
  final String displayName;
  final String description;
}