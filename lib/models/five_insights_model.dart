import 'package:hive/hive.dart';
import 'career_insight.dart';

part 'five_insights_model.g.dart';

/// Comprehensive model for the 5 career insight types framework
/// Organises insights into categories for strategic career development
@HiveType(typeId: 90)
class FiveInsightsModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String sessionId;

  @HiveField(2)
  final DateTime generatedAt;

  @HiveField(3)
  final List<EnergisrengStrength> energisingStrengths;

  @HiveField(4)
  final List<HiddenStrength> hiddenStrengths;

  @HiveField(5)
  final List<OverusedTalent> overusedTalents;

  @HiveField(6)
  final List<AspirationalStrength> aspirationalStrengths;

  @HiveField(7)
  final List<MisalignedEnergy> misalignedEnergies;

  @HiveField(8)
  final String? executiveSummary;

  @HiveField(9)
  final double balanceScore; // How balanced the profile is (0.0 to 1.0)

  @HiveField(10)
  final List<String> keyRecommendations;

  @HiveField(11)
  final Map<String, dynamic>? metadata;

  @HiveField(12)
  final DateTime? lastUpdated;

  FiveInsightsModel({
    required this.id,
    required this.sessionId,
    required this.generatedAt,
    required this.energisingStrengths,
    required this.hiddenStrengths,
    required this.overusedTalents,
    required this.aspirationalStrengths,
    required this.misalignedEnergies,
    this.executiveSummary,
    required this.balanceScore,
    required this.keyRecommendations,
    this.metadata,
    this.lastUpdated,
  });

  FiveInsightsModel copyWith({
    String? id,
    String? sessionId,
    DateTime? generatedAt,
    List<EnergisrengStrength>? energisingStrengths,
    List<HiddenStrength>? hiddenStrengths,
    List<OverusedTalent>? overusedTalents,
    List<AspirationalStrength>? aspirationalStrengths,
    List<MisalignedEnergy>? misalignedEnergies,
    String? executiveSummary,
    double? balanceScore,
    List<String>? keyRecommendations,
    Map<String, dynamic>? metadata,
    DateTime? lastUpdated,
  }) {
    return FiveInsightsModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      generatedAt: generatedAt ?? this.generatedAt,
      energisingStrengths: energisingStrengths ?? this.energisingStrengths,
      hiddenStrengths: hiddenStrengths ?? this.hiddenStrengths,
      overusedTalents: overusedTalents ?? this.overusedTalents,
      aspirationalStrengths: aspirationalStrengths ?? this.aspirationalStrengths,
      misalignedEnergies: misalignedEnergies ?? this.misalignedEnergies,
      executiveSummary: executiveSummary ?? this.executiveSummary,
      balanceScore: balanceScore ?? this.balanceScore,
      keyRecommendations: keyRecommendations ?? this.keyRecommendations,
      metadata: metadata ?? this.metadata,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Get total number of insights across all categories
  int get totalInsights {
    return energisingStrengths.length + 
           hiddenStrengths.length + 
           overusedTalents.length + 
           aspirationalStrengths.length + 
           misalignedEnergies.length;
  }

  /// Get the most populated category
  InsightCategory get dominantCategory {
    final counts = getCategoryCounts();
    final maxCount = counts.values.reduce((a, b) => a > b ? a : b);
    
    return counts.entries
        .firstWhere((entry) => entry.value == maxCount)
        .key;
  }

  /// Get count for each category
  Map<InsightCategory, int> getCategoryCounts() {
    return {
      InsightCategory.energising: energisingStrengths.length,
      InsightCategory.hidden: hiddenStrengths.length,
      InsightCategory.overused: overusedTalents.length,
      InsightCategory.aspirational: aspirationalStrengths.length,
      InsightCategory.misaligned: misalignedEnergies.length,
    };
  }

  /// Check if the profile is well-balanced
  bool get isWellBalanced {
    final counts = getCategoryCounts().values.toList();
    if (counts.isEmpty) return false;
    
    final maxCount = counts.reduce((a, b) => a > b ? a : b);
    final minCount = counts.reduce((a, b) => a < b ? a : b);
    
    // Balanced if the difference between max and min is <= 2
    return (maxCount - minCount) <= 2 && balanceScore >= 0.6;
  }

  /// Get priority actions based on the insights
  List<String> getPriorityActions() {
    final actions = <String>[];
    
    // Actions for energising strengths (leverage)
    if (energisingStrengths.isNotEmpty) {
      final topEnergising = energisingStrengths
          .where((s) => s.leverageability >= 4)
          .take(2);
      for (final strength in topEnergising) {
        if (strength.actionableAdvice != null) {
          actions.add('Leverage: ${strength.actionableAdvice}');
        }
      }
    }
    
    // Actions for hidden strengths (develop/showcase)
    if (hiddenStrengths.isNotEmpty) {
      final topHidden = hiddenStrengths
          .where((s) => s.potentialImpact >= 4)
          .take(2);
      for (final strength in topHidden) {
        if (strength.developmentStrategy != null) {
          actions.add('Develop: ${strength.developmentStrategy}');
        }
      }
    }
    
    // Actions for overused talents (rebalance)
    if (overusedTalents.isNotEmpty) {
      final highRisk = overusedTalents
          .where((t) => t.burnoutRisk >= 4)
          .take(1);
      for (final talent in highRisk) {
        if (talent.rebalancingStrategy != null) {
          actions.add('Rebalance: ${talent.rebalancingStrategy}');
        }
      }
    }
    
    // Actions for aspirational strengths (build)
    if (aspirationalStrengths.isNotEmpty) {
      final highPotential = aspirationalStrengths
          .where((s) => s.developmentPotential >= 4)
          .take(2);
      for (final strength in highPotential) {
        if (strength.developmentPlan != null) {
          actions.add('Build: ${strength.developmentPlan}');
        }
      }
    }
    
    // Actions for misaligned energies (address)
    if (misalignedEnergies.isNotEmpty) {
      final highDrain = misalignedEnergies
          .where((e) => e.energyDrainLevel >= 4)
          .take(1);
      for (final energy in highDrain) {
        if (energy.mitigationStrategy != null) {
          actions.add('Address: ${energy.mitigationStrategy}');
        }
      }
    }
    
    return actions.take(8).toList();
  }

  /// Generate a comprehensive summary
  String generateComprehensiveSummary() {
    final buffer = StringBuffer();
    
    buffer.writeln('Five Insights Career Profile');
    buffer.writeln('===========================');
    buffer.writeln('');
    buffer.writeln('Generated: ${generatedAt.toIso8601String().split('T')[0]}');
    buffer.writeln('Total Insights: $totalInsights');
    buffer.writeln('Balance Score: ${(balanceScore * 100).round()}%');
    buffer.writeln('Is Well Balanced: ${isWellBalanced ? "Yes" : "No"}');
    buffer.writeln('Dominant Category: ${dominantCategory.displayName}');
    buffer.writeln('');
    
    if (executiveSummary != null && executiveSummary!.isNotEmpty) {
      buffer.writeln('Executive Summary:');
      buffer.writeln(executiveSummary);
      buffer.writeln('');
    }
    
    // Category breakdown
    final counts = getCategoryCounts();
    buffer.writeln('Category Breakdown:');
    for (final entry in counts.entries) {
      buffer.writeln('• ${entry.key.displayName}: ${entry.value} insights');
    }
    buffer.writeln('');
    
    // Top energising strengths
    if (energisingStrengths.isNotEmpty) {
      buffer.writeln('🚀 Top Energising Strengths:');
      for (final strength in energisingStrengths.take(3)) {
        buffer.writeln('• ${strength.title} (Energy: ${strength.energyLevel}/5)');
      }
      buffer.writeln('');
    }
    
    // Critical hidden strengths
    if (hiddenStrengths.isNotEmpty) {
      buffer.writeln('💎 Key Hidden Strengths:');
      for (final strength in hiddenStrengths.take(3)) {
        buffer.writeln('• ${strength.title} (Impact: ${strength.potentialImpact}/5)');
      }
      buffer.writeln('');
    }
    
    // High-risk overused talents
    final highRiskTalents = overusedTalents.where((t) => t.burnoutRisk >= 4);
    if (highRiskTalents.isNotEmpty) {
      buffer.writeln('⚠️  High-Risk Overused Talents:');
      for (final talent in highRiskTalents.take(2)) {
        buffer.writeln('• ${talent.title} (Burnout Risk: ${talent.burnoutRisk}/5)');
      }
      buffer.writeln('');
    }
    
    // Priority actions
    final priorityActions = getPriorityActions();
    if (priorityActions.isNotEmpty) {
      buffer.writeln('🎯 Priority Actions:');
      for (final action in priorityActions.take(5)) {
        buffer.writeln('• $action');
      }
      buffer.writeln('');
    }
    
    // Key recommendations
    if (keyRecommendations.isNotEmpty) {
      buffer.writeln('📋 Strategic Recommendations:');
      for (final recommendation in keyRecommendations) {
        buffer.writeln('• $recommendation');
      }
    }
    
    return buffer.toString();
  }

  /// Export to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'generatedAt': generatedAt.toIso8601String(),
      'energisingStrengths': energisingStrengths.map((e) => e.toJson()).toList(),
      'hiddenStrengths': hiddenStrengths.map((h) => h.toJson()).toList(),
      'overusedTalents': overusedTalents.map((o) => o.toJson()).toList(),
      'aspirationalStrengths': aspirationalStrengths.map((a) => a.toJson()).toList(),
      'misalignedEnergies': misalignedEnergies.map((m) => m.toJson()).toList(),
      'executiveSummary': executiveSummary,
      'balanceScore': balanceScore,
      'keyRecommendations': keyRecommendations,
      'metadata': metadata,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'analysis': {
        'totalInsights': totalInsights,
        'dominantCategory': dominantCategory.name,
        'categoryCounts': getCategoryCounts().map((k, v) => MapEntry(k.name, v)),
        'isWellBalanced': isWellBalanced,
        'priorityActions': getPriorityActions(),
      },
    };
  }

  /// Create a new five insights model
  static FiveInsightsModel create({
    required String sessionId,
    required List<EnergisrengStrength> energisingStrengths,
    required List<HiddenStrength> hiddenStrengths,
    required List<OverusedTalent> overusedTalents,
    required List<AspirationalStrength> aspirationalStrengths,
    required List<MisalignedEnergy> misalignedEnergies,
    String? executiveSummary,
    required double balanceScore,
    required List<String> keyRecommendations,
    Map<String, dynamic>? metadata,
  }) {
    return FiveInsightsModel(
      id: 'five_insights_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: sessionId,
      generatedAt: DateTime.now(),
      energisingStrengths: energisingStrengths,
      hiddenStrengths: hiddenStrengths,
      overusedTalents: overusedTalents,
      aspirationalStrengths: aspirationalStrengths,
      misalignedEnergies: misalignedEnergies,
      executiveSummary: executiveSummary,
      balanceScore: balanceScore,
      keyRecommendations: keyRecommendations,
      metadata: metadata,
    );
  }

  @override
  String toString() {
    return 'FiveInsightsModel{id: $id, session: $sessionId, '
           'total: $totalInsights, balance: ${(balanceScore * 100).round()}%}';
  }
}

/// Energising Strength: High skill + high energy + recognised by others
@HiveType(typeId: 91)
class EnergisrengStrength extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int skillLevel; // 1-5 scale

  @HiveField(4)
  final int energyLevel; // 1-5 scale

  @HiveField(5)
  final int recognitionLevel; // 1-5 scale

  @HiveField(6)
  final int leverageability; // 1-5 scale - how much this can be leveraged

  @HiveField(7)
  final List<String> evidenceFromSelf;

  @HiveField(8)
  final List<String> evidenceFromOthers;

  @HiveField(9)
  final String? actionableAdvice;

  @HiveField(10)
  final List<String> applicationAreas;

  @HiveField(11)
  final double confidence; // 0.0 to 1.0

  EnergisrengStrength({
    required this.id,
    required this.title,
    required this.description,
    required this.skillLevel,
    required this.energyLevel,
    required this.recognitionLevel,
    required this.leverageability,
    required this.evidenceFromSelf,
    required this.evidenceFromOthers,
    this.actionableAdvice,
    required this.applicationAreas,
    required this.confidence,
  });

  /// Calculate the overall strength score
  double get overallScore {
    return (skillLevel + energyLevel + recognitionLevel + leverageability) / 4.0;
  }

  /// Check if this is a signature strength (all dimensions high)
  bool get isSignatureStrength {
    return skillLevel >= 4 && energyLevel >= 4 && recognitionLevel >= 4;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'skillLevel': skillLevel,
      'energyLevel': energyLevel,
      'recognitionLevel': recognitionLevel,
      'leverageability': leverageability,
      'evidenceFromSelf': evidenceFromSelf,
      'evidenceFromOthers': evidenceFromOthers,
      'actionableAdvice': actionableAdvice,
      'applicationAreas': applicationAreas,
      'confidence': confidence,
      'overallScore': overallScore,
      'isSignatureStrength': isSignatureStrength,
    };
  }

  @override
  String toString() {
    return 'EnergisrengStrength{title: $title, score: ${overallScore.toStringAsFixed(1)}}';
  }
}

/// Hidden Strength: High competence but underrecognised or underutilised
@HiveType(typeId: 92)
class HiddenStrength extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int competenceLevel; // 1-5 scale

  @HiveField(4)
  final int currentRecognition; // 1-5 scale

  @HiveField(5)
  final int potentialImpact; // 1-5 scale if properly leveraged

  @HiveField(6)
  final List<String> hiddenFactors; // Why it's hidden

  @HiveField(7)
  final String? developmentStrategy;

  @HiveField(8)
  final List<String> visibilityOpportunities;

  @HiveField(9)
  final double confidence; // 0.0 to 1.0

  HiddenStrength({
    required this.id,
    required this.title,
    required this.description,
    required this.competenceLevel,
    required this.currentRecognition,
    required this.potentialImpact,
    required this.hiddenFactors,
    this.developmentStrategy,
    required this.visibilityOpportunities,
    required this.confidence,
  });

  /// Calculate the gap between competence and recognition
  int get recognitionGap {
    return competenceLevel - currentRecognition;
  }

  /// Check if this is a high-priority hidden strength
  bool get isHighPriority {
    return competenceLevel >= 4 && recognitionGap >= 2 && potentialImpact >= 4;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'competenceLevel': competenceLevel,
      'currentRecognition': currentRecognition,
      'potentialImpact': potentialImpact,
      'hiddenFactors': hiddenFactors,
      'developmentStrategy': developmentStrategy,
      'visibilityOpportunities': visibilityOpportunities,
      'confidence': confidence,
      'recognitionGap': recognitionGap,
      'isHighPriority': isHighPriority,
    };
  }

  @override
  String toString() {
    return 'HiddenStrength{title: $title, gap: $recognitionGap, impact: $potentialImpact}';
  }
}

/// Overused Talent: Strong skill but potentially overused, leading to fatigue
@HiveType(typeId: 93)
class OverusedTalent extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int talentLevel; // 1-5 scale

  @HiveField(4)
  final int usageFrequency; // 1-5 scale

  @HiveField(5)
  final int burnoutRisk; // 1-5 scale

  @HiveField(6)
  final List<String> overuseIndicators;

  @HiveField(7)
  final String? rebalancingStrategy;

  @HiveField(8)
  final List<String> alternativeApplications;

  @HiveField(9)
  final double confidence; // 0.0 to 1.0

  OverusedTalent({
    required this.id,
    required this.title,
    required this.description,
    required this.talentLevel,
    required this.usageFrequency,
    required this.burnoutRisk,
    required this.overuseIndicators,
    this.rebalancingStrategy,
    required this.alternativeApplications,
    required this.confidence,
  });

  /// Check if this requires immediate attention
  bool get requiresImmediateAttention {
    return burnoutRisk >= 4 && usageFrequency >= 4;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'talentLevel': talentLevel,
      'usageFrequency': usageFrequency,
      'burnoutRisk': burnoutRisk,
      'overuseIndicators': overuseIndicators,
      'rebalancingStrategy': rebalancingStrategy,
      'alternativeApplications': alternativeApplications,
      'confidence': confidence,
      'requiresImmediateAttention': requiresImmediateAttention,
    };
  }

  @override
  String toString() {
    return 'OverusedTalent{title: $title, risk: $burnoutRisk, usage: $usageFrequency}';
  }
}

/// Aspirational Strength: Areas of high interest with development potential
@HiveType(typeId: 94)
class AspirationalStrength extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int currentLevel; // 1-5 scale

  @HiveField(4)
  final int interestLevel; // 1-5 scale

  @HiveField(5)
  final int developmentPotential; // 1-5 scale

  @HiveField(6)
  final String? developmentPlan;

  @HiveField(7)
  final List<String> requiredResources;

  @HiveField(8)
  final int timeframe; // Months to develop

  @HiveField(9)
  final double confidence; // 0.0 to 1.0

  AspirationalStrength({
    required this.id,
    required this.title,
    required this.description,
    required this.currentLevel,
    required this.interestLevel,
    required this.developmentPotential,
    this.developmentPlan,
    required this.requiredResources,
    required this.timeframe,
    required this.confidence,
  });

  /// Calculate development priority score
  double get developmentPriority {
    return (interestLevel + developmentPotential) / 2.0;
  }

  /// Check if this is worth investing in
  bool get isWorthInvesting {
    return interestLevel >= 4 && developmentPotential >= 3;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'currentLevel': currentLevel,
      'interestLevel': interestLevel,
      'developmentPotential': developmentPotential,
      'developmentPlan': developmentPlan,
      'requiredResources': requiredResources,
      'timeframe': timeframe,
      'confidence': confidence,
      'developmentPriority': developmentPriority,
      'isWorthInvesting': isWorthInvesting,
    };
  }

  @override
  String toString() {
    return 'AspirationalStrength{title: $title, priority: ${developmentPriority.toStringAsFixed(1)}}';
  }
}

/// Misaligned Energy: Activities that drain energy despite competence
@HiveType(typeId: 95)
class MisalignedEnergy extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int competenceLevel; // 1-5 scale

  @HiveField(4)
  final int energyDrainLevel; // 1-5 scale

  @HiveField(5)
  final int frequency; // 1-5 scale how often this occurs

  @HiveField(6)
  final List<String> drainFactors;

  @HiveField(7)
  final String? mitigationStrategy;

  @HiveField(8)
  final List<String> alternativeApproaches;

  @HiveField(9)
  final double confidence; // 0.0 to 1.0

  MisalignedEnergy({
    required this.id,
    required this.title,
    required this.description,
    required this.competenceLevel,
    required this.energyDrainLevel,
    required this.frequency,
    required this.drainFactors,
    this.mitigationStrategy,
    required this.alternativeApproaches,
    required this.confidence,
  });

  /// Calculate impact priority (higher drain + frequency = higher priority)
  double get impactPriority {
    return (energyDrainLevel + frequency) / 2.0;
  }

  /// Check if this requires urgent attention
  bool get requiresUrgentAttention {
    return energyDrainLevel >= 4 && frequency >= 4;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'competenceLevel': competenceLevel,
      'energyDrainLevel': energyDrainLevel,
      'frequency': frequency,
      'drainFactors': drainFactors,
      'mitigationStrategy': mitigationStrategy,
      'alternativeApproaches': alternativeApproaches,
      'confidence': confidence,
      'impactPriority': impactPriority,
      'requiresUrgentAttention': requiresUrgentAttention,
    };
  }

  @override
  String toString() {
    return 'MisalignedEnergy{title: $title, drain: $energyDrainLevel, frequency: $frequency}';
  }
}

/// Categories for the five insights framework
@HiveType(typeId: 96)
enum InsightCategory {
  @HiveField(0)
  energising('Energising Strength', 'High skill + high energy + recognised by others'),
  
  @HiveField(1)
  hidden('Hidden Strength', 'High competence but underrecognised or underutilised'),
  
  @HiveField(2)
  overused('Overused Talent', 'Strong skill but potentially overused, leading to fatigue'),
  
  @HiveField(3)
  aspirational('Aspirational Strength', 'Areas of high interest with development potential'),
  
  @HiveField(4)
  misaligned('Misaligned Energy', 'Activities that drain energy despite competence');

  const InsightCategory(this.displayName, this.description);
  
  final String displayName;
  final String description;
}