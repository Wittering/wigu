import 'package:hive/hive.dart';
import 'career_response.dart';
import 'advisor_response.dart';
import 'career_insight.dart';

part 'career_synthesis.g.dart';

/// Synthesis comparing self-perception with external advisor perspectives
/// Identifies alignment, blind spots, and opportunities for career development
@HiveType(typeId: 30)
class CareerSynthesis extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String sessionId;

  @HiveField(2)
  final DateTime generatedAt;

  @HiveField(3)
  final List<String> selfResponseIds;

  @HiveField(4)
  final List<String> advisorResponseIds;

  @HiveField(5)
  final List<SynthesisInsight> alignmentAreas;

  @HiveField(6)
  final List<SynthesisInsight> hiddenStrengths;

  @HiveField(7)
  final List<SynthesisInsight> overestimatedAreas;

  @HiveField(8)
  final List<SynthesisInsight> developmentOpportunities;

  @HiveField(9)
  final List<SynthesisInsight> repositioningPotential;

  @HiveField(10)
  final String executiveSummary;

  @HiveField(11)
  final List<String> strategicRecommendations;

  @HiveField(12)
  final double alignmentScore; // 0.0 to 1.0 - how well self and advisor views align

  @HiveField(13)
  final SynthesisConfidence confidenceLevel;

  @HiveField(14)
  final Map<String, dynamic>? analysisMetadata;

  @HiveField(15)
  final DateTime? lastUpdated;

  CareerSynthesis({
    required this.id,
    required this.sessionId,
    required this.generatedAt,
    required this.selfResponseIds,
    required this.advisorResponseIds,
    required this.alignmentAreas,
    required this.hiddenStrengths,
    required this.overestimatedAreas,
    required this.developmentOpportunities,
    required this.repositioningPotential,
    required this.executiveSummary,
    required this.strategicRecommendations,
    required this.alignmentScore,
    required this.confidenceLevel,
    this.analysisMetadata,
    this.lastUpdated,
  });

  CareerSynthesis copyWith({
    String? id,
    String? sessionId,
    DateTime? generatedAt,
    List<String>? selfResponseIds,
    List<String>? advisorResponseIds,
    List<SynthesisInsight>? alignmentAreas,
    List<SynthesisInsight>? hiddenStrengths,
    List<SynthesisInsight>? overestimatedAreas,
    List<SynthesisInsight>? developmentOpportunities,
    List<SynthesisInsight>? repositioningPotential,
    String? executiveSummary,
    List<String>? strategicRecommendations,
    double? alignmentScore,
    SynthesisConfidence? confidenceLevel,
    Map<String, dynamic>? analysisMetadata,
    DateTime? lastUpdated,
  }) {
    return CareerSynthesis(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      generatedAt: generatedAt ?? this.generatedAt,
      selfResponseIds: selfResponseIds ?? this.selfResponseIds,
      advisorResponseIds: advisorResponseIds ?? this.advisorResponseIds,
      alignmentAreas: alignmentAreas ?? this.alignmentAreas,
      hiddenStrengths: hiddenStrengths ?? this.hiddenStrengths,
      overestimatedAreas: overestimatedAreas ?? this.overestimatedAreas,
      developmentOpportunities: developmentOpportunities ?? this.developmentOpportunities,
      repositioningPotential: repositioningPotential ?? this.repositioningPotential,
      executiveSummary: executiveSummary ?? this.executiveSummary,
      strategicRecommendations: strategicRecommendations ?? this.strategicRecommendations,
      alignmentScore: alignmentScore ?? this.alignmentScore,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      analysisMetadata: analysisMetadata ?? this.analysisMetadata,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Total number of insights across all categories
  int get totalInsights {
    return alignmentAreas.length + 
           hiddenStrengths.length + 
           overestimatedAreas.length + 
           developmentOpportunities.length + 
           repositioningPotential.length;
  }

  /// Get the most impactful insights (high confidence and strategic value)
  List<SynthesisInsight> get highImpactInsights {
    final allInsights = [
      ...alignmentAreas,
      ...hiddenStrengths,
      ...overestimatedAreas,
      ...developmentOpportunities,
      ...repositioningPotential,
    ];

    return allInsights
        .where((insight) => insight.strategicImportance >= 4)
        .toList()
        ..sort((a, b) => b.strategicImportance.compareTo(a.strategicImportance));
  }

  /// Get insights that suggest immediate action
  List<SynthesisInsight> get actionableInsights {
    final allInsights = [
      ...hiddenStrengths,
      ...developmentOpportunities,
      ...repositioningPotential,
    ];

    return allInsights
        .where((insight) => insight.actionableAdvice != null && 
                          insight.actionableAdvice!.isNotEmpty)
        .toList();
  }

  /// Calculate overall synthesis quality based on various factors
  double get synthesisQuality {
    double quality = 0.0;

    // Base quality from number of insights
    quality += (totalInsights / 20.0).clamp(0.0, 0.3);

    // Alignment score contribution
    quality += alignmentScore * 0.2;

    // Confidence level contribution
    switch (confidenceLevel) {
      case SynthesisConfidence.high:
        quality += 0.3;
        break;
      case SynthesisConfidence.medium:
        quality += 0.2;
        break;
      case SynthesisConfidence.low:
        quality += 0.1;
        break;
    }

    // Executive summary quality
    if (executiveSummary.length > 100) quality += 0.1;

    // Strategic recommendations
    quality += (strategicRecommendations.length / 10.0).clamp(0.0, 0.1);

    return quality.clamp(0.0, 1.0);
  }

  /// Get the primary areas where self and advisor views differ significantly
  List<String> get keyPerceptionGaps {
    final gaps = <String>[];
    
    // Hidden strengths represent things others see that the person doesn't
    gaps.addAll(hiddenStrengths.map((insight) => 
        'Hidden strength: ${insight.title}'));
    
    // Overestimated areas represent self-perception exceeding external view
    gaps.addAll(overestimatedAreas.map((insight) => 
        'Possible overestimation: ${insight.title}'));
    
    return gaps.take(5).toList();
  }

  /// Generate a concise synthesis summary for quick review
  String get quickSummary {
    final buffer = StringBuffer();
    
    buffer.writeln('Synthesis Summary:');
    buffer.writeln('• Alignment Score: ${(alignmentScore * 100).round()}%');
    buffer.writeln('• Total Insights: $totalInsights');
    buffer.writeln('• Hidden Strengths: ${hiddenStrengths.length}');
    buffer.writeln('• Development Areas: ${developmentOpportunities.length}');
    
    if (highImpactInsights.isNotEmpty) {
      buffer.writeln('• Top Priority: ${highImpactInsights.first.title}');
    }
    
    return buffer.toString();
  }

  /// Generate career positioning statement based on synthesis
  String generatePositioningStatement() {
    final strengths = alignmentAreas
        .where((insight) => insight.category == SynthesisCategory.strength)
        .take(3);
    
    final hidden = hiddenStrengths.take(2);
    
    final buffer = StringBuffer();
    buffer.writeln('Career Positioning Statement:');
    buffer.writeln('');
    
    if (strengths.isNotEmpty) {
      buffer.writeln('Core Strengths (recognised by self and others):');
      for (final strength in strengths) {
        buffer.writeln('• ${strength.title}');
      }
      buffer.writeln('');
    }
    
    if (hidden.isNotEmpty) {
      buffer.writeln('Underutilised Assets (opportunities for greater impact):');
      for (final asset in hidden) {
        buffer.writeln('• ${asset.title}');
      }
      buffer.writeln('');
    }
    
    buffer.writeln('Strategic Focus Areas:');
    for (final recommendation in strategicRecommendations.take(3)) {
      buffer.writeln('• $recommendation');
    }
    
    return buffer.toString();
  }

  /// Export synthesis data to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'generatedAt': generatedAt.toIso8601String(),
      'selfResponseIds': selfResponseIds,
      'advisorResponseIds': advisorResponseIds,
      'alignmentAreas': alignmentAreas.map((insight) => insight.toJson()).toList(),
      'hiddenStrengths': hiddenStrengths.map((insight) => insight.toJson()).toList(),
      'overestimatedAreas': overestimatedAreas.map((insight) => insight.toJson()).toList(),
      'developmentOpportunities': developmentOpportunities.map((insight) => insight.toJson()).toList(),
      'repositioningPotential': repositioningPotential.map((insight) => insight.toJson()).toList(),
      'executiveSummary': executiveSummary,
      'strategicRecommendations': strategicRecommendations,
      'alignmentScore': alignmentScore,
      'confidenceLevel': confidenceLevel.name,
      'analysisMetadata': analysisMetadata,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'analysis': {
        'totalInsights': totalInsights,
        'synthesisQuality': synthesisQuality,
        'keyPerceptionGaps': keyPerceptionGaps,
        'quickSummary': quickSummary,
        'highImpactInsights': highImpactInsights.length,
        'actionableInsights': actionableInsights.length,
      },
    };
  }

  /// Create a new career synthesis
  static CareerSynthesis create({
    required String sessionId,
    required List<String> selfResponseIds,
    required List<String> advisorResponseIds,
    required List<SynthesisInsight> alignmentAreas,
    required List<SynthesisInsight> hiddenStrengths,
    required List<SynthesisInsight> overestimatedAreas,
    required List<SynthesisInsight> developmentOpportunities,
    required List<SynthesisInsight> repositioningPotential,
    required String executiveSummary,
    required List<String> strategicRecommendations,
    required double alignmentScore,
    required SynthesisConfidence confidenceLevel,
    Map<String, dynamic>? analysisMetadata,
  }) {
    return CareerSynthesis(
      id: 'synthesis_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: sessionId,
      generatedAt: DateTime.now(),
      selfResponseIds: selfResponseIds,
      advisorResponseIds: advisorResponseIds,
      alignmentAreas: alignmentAreas,
      hiddenStrengths: hiddenStrengths,
      overestimatedAreas: overestimatedAreas,
      developmentOpportunities: developmentOpportunities,
      repositioningPotential: repositioningPotential,
      executiveSummary: executiveSummary,
      strategicRecommendations: strategicRecommendations,
      alignmentScore: alignmentScore,
      confidenceLevel: confidenceLevel,
      analysisMetadata: analysisMetadata,
    );
  }

  @override
  String toString() {
    return 'CareerSynthesis{id: $id, session: $sessionId, '
           'insights: $totalInsights, alignment: ${(alignmentScore * 100).round()}%, '
           'quality: ${synthesisQuality.toStringAsFixed(2)}}';
  }
}

/// Individual insight within a synthesis
@HiveType(typeId: 31)
class SynthesisInsight extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final SynthesisCategory category;

  @HiveField(4)
  final List<String> supportingEvidence;

  @HiveField(5)
  final int strategicImportance; // 1-5 scale

  @HiveField(6)
  final String? actionableAdvice;

  @HiveField(7)
  final List<String> relatedThemes;

  @HiveField(8)
  final double confidence; // 0.0 to 1.0

  SynthesisInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.supportingEvidence,
    required this.strategicImportance,
    this.actionableAdvice,
    this.relatedThemes = const [],
    this.confidence = 0.5,
  });

  SynthesisInsight copyWith({
    String? id,
    String? title,
    String? description,
    SynthesisCategory? category,
    List<String>? supportingEvidence,
    int? strategicImportance,
    String? actionableAdvice,
    List<String>? relatedThemes,
    double? confidence,
  }) {
    return SynthesisInsight(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      supportingEvidence: supportingEvidence ?? this.supportingEvidence,
      strategicImportance: strategicImportance ?? this.strategicImportance,
      actionableAdvice: actionableAdvice ?? this.actionableAdvice,
      relatedThemes: relatedThemes ?? this.relatedThemes,
      confidence: confidence ?? this.confidence,
    );
  }

  /// Check if this insight is high priority for action
  bool get isHighPriority {
    return strategicImportance >= 4 && confidence >= 0.7;
  }

  /// Export insight to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'supportingEvidence': supportingEvidence,
      'strategicImportance': strategicImportance,
      'actionableAdvice': actionableAdvice,
      'relatedThemes': relatedThemes,
      'confidence': confidence,
      'isHighPriority': isHighPriority,
    };
  }

  @override
  String toString() {
    return 'SynthesisInsight{title: $title, category: ${category.name}, '
           'importance: $strategicImportance, confidence: ${confidence.toStringAsFixed(2)}}';
  }
}

/// Categories of synthesis insights
@HiveType(typeId: 32)
enum SynthesisCategory {
  @HiveField(0)
  strength('Strength', 'An area of clear capability and performance'),
  
  @HiveField(1)
  opportunity('Opportunity', 'An area with potential for development or leverage'),
  
  @HiveField(2)
  blindspot('Blind Spot', 'Something not recognised by self but seen by others'),
  
  @HiveField(3)
  overestimation('Overestimation', 'Area where self-view may exceed external perception'),
  
  @HiveField(4)
  positioning('Positioning', 'How to better present or leverage capabilities'),
  
  @HiveField(5)
  development('Development', 'Specific area for growth and improvement');

  const SynthesisCategory(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// Confidence level in the synthesis
@HiveType(typeId: 33)
enum SynthesisConfidence {
  @HiveField(0)
  high('High', 'Strong data from multiple advisors with consistent themes'),
  
  @HiveField(1)
  medium('Medium', 'Good data but some gaps or inconsistencies'),
  
  @HiveField(2)
  low('Low', 'Limited data or significant inconsistencies');

  const SynthesisConfidence(this.displayName, this.description);
  
  final String displayName;
  final String description;
}