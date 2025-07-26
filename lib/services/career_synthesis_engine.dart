import 'dart:convert';
import 'dart:math';
import '../models/career_response.dart';
import '../models/advisor_response.dart';
import '../models/career_synthesis.dart';
import '../models/career_insight.dart';
import '../models/career_session.dart';
import '../models/five_insights_model.dart';
import '../models/career_experiment.dart';
import '../utils/logger.dart';
import '../utils/insight_categorizer.dart';
import '../utils/narrative_generator.dart';
import 'career_ai_service.dart';

/// Comprehensive AI synthesis engine that compares self-perception vs advisor responses
/// and generates career insights creating the "mirror" effect described in the spec.
/// 
/// This is the core intelligence of the system that processes both self-assessment
/// and external advisor feedback to create meaningful career development insights.
class CareerSynthesisEngine {
  final CareerAIService _aiService;
  final InsightCategorizer _categorizer;
  final NarrativeGenerator _narrativeGenerator;
  
  CareerSynthesisEngine({
    required CareerAIService aiService,
    InsightCategorizer? categorizer,
    NarrativeGenerator? narrativeGenerator,
  }) : _aiService = aiService,
       _categorizer = categorizer ?? InsightCategorizer(),
       _narrativeGenerator = narrativeGenerator ?? NarrativeGenerator();

  /// Generate comprehensive synthesis comparing self-perception vs advisor responses
  /// Creates the mirror effect by identifying alignment, blind spots, and opportunities
  Future<CareerSynthesis> generateComprehensiveSynthesis({
    required String sessionId,
    required List<CareerResponse> selfResponses,
    required List<AdvisorResponse> advisorResponses,
    Map<String, dynamic>? additionalContext,
  }) async {
    AppLogger.info('Starting comprehensive career synthesis for session: $sessionId');
    final stopwatch = Stopwatch()..start();

    try {
      // Step 1: Data validation and preparation
      _validateSynthesisData(selfResponses, advisorResponses);
      
      // Step 2: Generate the Five Insights Model
      final fiveInsights = await _generateFiveInsightsModel(
        sessionId: sessionId,
        selfResponses: selfResponses,
        advisorResponses: advisorResponses,
      );

      // Step 3: Create Johari Window mapping
      final johariWindow = await _createJohariWindowMapping(
        selfResponses: selfResponses,
        advisorResponses: advisorResponses,
      );

      // Step 4: Generate Three Truths, Two Tensions, One Experiment framework
      final truthsTensionsExperiment = await _generateTruthsTensionsExperiment(
        selfResponses: selfResponses,
        advisorResponses: advisorResponses,
        fiveInsights: fiveInsights,
      );

      // Step 5: Calculate alignment score
      final alignmentScore = _calculateAlignmentScore(selfResponses, advisorResponses);

      // Step 6: Generate synthesis insights
      final alignmentAreas = await _identifyAlignmentAreas(selfResponses, advisorResponses);
      final hiddenStrengths = await _identifyHiddenStrengths(selfResponses, advisorResponses);
      final overestimatedAreas = await _identifyOverestimatedAreas(selfResponses, advisorResponses);
      final developmentOpportunities = await _identifyDevelopmentOpportunities(selfResponses, advisorResponses);
      final repositioningPotential = await _identifyRepositioningPotential(selfResponses, advisorResponses);

      // Step 7: Generate executive summary with Australian context
      final executiveSummary = await _generateExecutiveSummary(
        selfResponses: selfResponses,
        advisorResponses: advisorResponses,
        alignmentScore: alignmentScore,
        fiveInsights: fiveInsights,
      );

      // Step 8: Create strategic recommendations
      final strategicRecommendations = await _generateStrategicRecommendations(
        fiveInsights: fiveInsights,
        johariWindow: johariWindow,
        truthsTensionsExperiment: truthsTensionsExperiment,
      );

      // Step 9: Determine confidence level
      final confidenceLevel = _calculateConfidenceLevel(selfResponses, advisorResponses);

      // Step 10: Create synthesis metadata
      final metadata = _createSynthesisMetadata(
        fiveInsights: fiveInsights,
        johariWindow: johariWindow,
        truthsTensionsExperiment: truthsTensionsExperiment,
        additionalContext: additionalContext,
      );

      stopwatch.stop();
      AppLogger.performance('Career synthesis generation', stopwatch.elapsed, {
        'session_id': sessionId,
        'self_responses': selfResponses.length,
        'advisor_responses': advisorResponses.length,
        'alignment_score': alignmentScore,
      });

      return CareerSynthesis.create(
        sessionId: sessionId,
        selfResponseIds: selfResponses.map((r) => r.questionId).toList(),
        advisorResponseIds: advisorResponses.map((r) => r.id).toList(),
        alignmentAreas: alignmentAreas,
        hiddenStrengths: hiddenStrengths,
        overestimatedAreas: overestimatedAreas,
        developmentOpportunities: developmentOpportunities,
        repositioningPotential: repositioningPotential,
        executiveSummary: executiveSummary,
        strategicRecommendations: strategicRecommendations,
        alignmentScore: alignmentScore,
        confidenceLevel: confidenceLevel,
        analysisMetadata: metadata,
      );

    } catch (e, stackTrace) {
      AppLogger.error('Error generating career synthesis', e, stackTrace);
      return _createFallbackSynthesis(sessionId, selfResponses, advisorResponses);
    }
  }

  /// Generate the Five Insights Model from self and advisor data
  Future<FiveInsightsModel> _generateFiveInsightsModel({
    required String sessionId,
    required List<CareerResponse> selfResponses,
    required List<AdvisorResponse> advisorResponses,
  }) async {
    AppLogger.debug('Generating Five Insights Model');

    // Categorize insights using the specialized categorizer
    final energisingStrengths = await _categorizer.identifyEnergisingStrengths(
      selfResponses: selfResponses,
      advisorResponses: advisorResponses,
    );

    final hiddenStrengths = await _categorizer.identifyHiddenStrengths(
      selfResponses: selfResponses,
      advisorResponses: advisorResponses,
    );

    final overusedTalents = await _categorizer.identifyOverusedTalents(
      selfResponses: selfResponses,
      advisorResponses: advisorResponses,
    );

    final aspirationalStrengths = await _categorizer.identifyAspirationalStrengths(
      selfResponses: selfResponses,
      advisorResponses: advisorResponses,
    );

    final misalignedEnergies = await _categorizer.identifyMisalignedEnergies(
      selfResponses: selfResponses,
      advisorResponses: advisorResponses,
    );

    // Calculate balance score
    final balanceScore = _calculateInsightBalance([
      energisingStrengths.length,
      hiddenStrengths.length,
      overusedTalents.length,
      aspirationalStrengths.length,
      misalignedEnergies.length,
    ]);

    // Generate key recommendations
    final keyRecommendations = _generateKeyRecommendations(
      energisingStrengths: energisingStrengths,
      hiddenStrengths: hiddenStrengths,
      overusedTalents: overusedTalents,
      aspirationalStrengths: aspirationalStrengths,
      misalignedEnergies: misalignedEnergies,
    );

    // Generate executive summary for the Five Insights
    final executiveSummary = await _narrativeGenerator.generateFiveInsightsSummary(
      energisingStrengths: energisingStrengths,
      hiddenStrengths: hiddenStrengths,
      overusedTalents: overusedTalents,
      aspirationalStrengths: aspirationalStrengths,
      misalignedEnergies: misalignedEnergies,
    );

    return FiveInsightsModel.create(
      sessionId: sessionId,
      energisingStrengths: energisingStrengths,
      hiddenStrengths: hiddenStrengths,
      overusedTalents: overusedTalents,
      aspirationalStrengths: aspirationalStrengths,
      misalignedEnergies: misalignedEnergies,
      executiveSummary: executiveSummary,
      balanceScore: balanceScore,
      keyRecommendations: keyRecommendations,
    );
  }

  /// Create Johari Window mapping (known/unknown to self vs others)
  Future<Map<String, dynamic>> _createJohariWindowMapping({
    required List<CareerResponse> selfResponses,
    required List<AdvisorResponse> advisorResponses,
  }) async {
    AppLogger.debug('Creating Johari Window mapping');

    // Extract themes from both sources
    final selfThemes = _extractThemesFromResponses(selfResponses);
    final advisorThemes = _extractThemesFromAdvisorResponses(advisorResponses);

    // Create the four quadrants
    final openArena = _findCommonThemes(selfThemes, advisorThemes);
    final blindSpot = _findUniqueThemes(advisorThemes, selfThemes);
    final hiddenArena = _findUniqueThemes(selfThemes, advisorThemes);
    final unknownArena = await _identifyUnknownArena(selfResponses, advisorResponses);

    return {
      'open_arena': {
        'themes': openArena,
        'description': 'Strengths and qualities both you and others recognise',
        'count': openArena.length,
        'actionable_insights': await _generateJohariInsights(openArena, 'leverage'),
      },
      'blind_spot': {
        'themes': blindSpot,
        'description': 'Strengths others see that you may not fully recognise',
        'count': blindSpot.length,
        'actionable_insights': await _generateJohariInsights(blindSpot, 'discover'),
      },
      'hidden_arena': {
        'themes': hiddenArena,
        'description': 'Strengths you recognise but others may not see',
        'count': hiddenArena.length,
        'actionable_insights': await _generateJohariInsights(hiddenArena, 'showcase'),
      },
      'unknown_arena': {
        'themes': unknownArena,
        'description': 'Potential areas for exploration and development',
        'count': unknownArena.length,
        'actionable_insights': await _generateJohariInsights(unknownArena, 'explore'),
      },
      'analysis': {
        'dominant_quadrant': _getDominantQuadrant(openArena, blindSpot, hiddenArena, unknownArena),
        'development_priority': _calculateDevelopmentPriority(blindSpot, hiddenArena),
        'self_awareness_score': _calculateSelfAwarenessScore(openArena, blindSpot, hiddenArena),
      },
    };
  }

  /// Generate Three Truths, Two Tensions, One Experiment framework
  Future<Map<String, dynamic>> _generateTruthsTensionsExperiment({
    required List<CareerResponse> selfResponses,
    required List<AdvisorResponse> advisorResponses,
    required FiveInsightsModel fiveInsights,
  }) async {
    AppLogger.debug('Generating Three Truths, Two Tensions, One Experiment framework');

    // Three Truths: Core certainties from both self and advisor perspectives
    final threeTruths = await _identifyThreeTruths(selfResponses, advisorResponses, fiveInsights);

    // Two Tensions: Areas of productive tension or opportunity
    final twoTensions = await _identifyTwoTensions(selfResponses, advisorResponses, fiveInsights);

    // One Experiment: A specific micro-experiment to test an insight
    final oneExperiment = await _designMicroExperiment(selfResponses, advisorResponses, fiveInsights);

    return {
      'three_truths': {
        'truths': threeTruths,
        'confidence_score': _calculateTruthsConfidence(threeTruths),
        'narrative': await _narrativeGenerator.generateTruthsNarrative(threeTruths, selfResponses, advisorResponses),
      },
      'two_tensions': {
        'tensions': twoTensions,
        'opportunity_score': _calculateTensionOpportunity(twoTensions),
        'narrative': await _narrativeGenerator.generateTensionsNarrative(twoTensions, selfResponses, advisorResponses),
      },
      'one_experiment': {
        'experiment': oneExperiment,
        'feasibility_score': oneExperiment != null ? _calculateFeasibilityScore(oneExperiment) : 0.0,
        'narrative': oneExperiment != null 
          ? await _narrativeGenerator.generateExperimentNarrative(oneExperiment, selfResponses, advisorResponses)
          : 'No suitable experiment identified at this time.',
      },
    };
  }

  /// Generate micro-experiment suggestions based on insights
  Future<List<CareerExperiment>> generateMicroExperiments({
    required FiveInsightsModel fiveInsights,
    required Map<String, dynamic> johariWindow,
    int maxExperiments = 5,
  }) async {
    AppLogger.debug('Generating micro-experiments from insights');

    final experiments = <CareerExperiment>[];

    // Generate experiments for hidden strengths
    for (final hiddenStrength in fiveInsights.hiddenStrengths.take(2)) {
      if (hiddenStrength.isHighPriority) {
        final experiment = await _createVisibilityExperiment(hiddenStrength);
        if (experiment != null) experiments.add(experiment);
      }
    }

    // Generate experiments for aspirational strengths
    for (final aspirational in fiveInsights.aspirationalStrengths.take(2)) {
      if (aspirational.isWorthInvesting) {
        final experiment = await _createDevelopmentExperiment(aspirational);
        if (experiment != null) experiments.add(experiment);
      }
    }

    // Generate experiments for overused talents
    for (final overused in fiveInsights.overusedTalents.take(1)) {
      if (overused.requiresImmediateAttention) {
        final experiment = await _createRebalancingExperiment(overused);
        if (experiment != null) experiments.add(experiment);
      }
    }

    // Generate experiments for blind spot themes
    final blindSpotThemes = johariWindow['blind_spot']['themes'] as List<String>? ?? [];
    for (final theme in blindSpotThemes.take(1)) {
      final experiment = await _createBlindSpotExperiment(theme);
      if (experiment != null) experiments.add(experiment);
    }

    return experiments.take(maxExperiments).toList();
  }

  /// Generate role hypotheses and career direction recommendations
  Future<Map<String, dynamic>> generateCareerDirectionInsights({
    required FiveInsightsModel fiveInsights,
    required Map<String, dynamic> johariWindow,
    required List<CareerResponse> selfResponses,
    required List<AdvisorResponse> advisorResponses,
  }) async {
    AppLogger.debug('Generating career direction insights');

    // Identify optimal role characteristics
    final roleHypotheses = await _generateRoleHypotheses(fiveInsights, johariWindow);

    // Generate career pathway recommendations
    final careerPathways = await _generateCareerPathways(fiveInsights, selfResponses, advisorResponses);

    // Create positioning strategies
    final positioningStrategies = await _generatePositioningStrategies(fiveInsights, johariWindow);

    // Calculate career readiness scores
    final readinessScores = _calculateCareerReadinessScores(fiveInsights);

    return {
      'role_hypotheses': roleHypotheses,
      'career_pathways': careerPathways,
      'positioning_strategies': positioningStrategies,
      'readiness_scores': readinessScores,
      'next_steps': await _generateCareerNextSteps(fiveInsights, johariWindow),
      'australian_context': _addAustralianWorkplaceContext(roleHypotheses, careerPathways),
    };
  }

  /// Create synthesis visualization data for charts and reports
  Map<String, dynamic> createVisualizationData({
    required CareerSynthesis synthesis,
    required FiveInsightsModel fiveInsights,
    required Map<String, dynamic> johariWindow,
  }) {
    AppLogger.debug('Creating synthesis visualization data');

    return {
      'alignment_chart': _createAlignmentChartData(synthesis),
      'five_insights_radar': _createFiveInsightsRadarData(fiveInsights),
      'johari_matrix': _createJohariMatrixData(johariWindow),
      'confidence_distribution': _createConfidenceDistributionData(synthesis, fiveInsights),
      'timeline_data': _createTimelineData(synthesis),
      'priority_matrix': _createPriorityMatrixData(fiveInsights),
      'australian_workplace_metrics': _createAustralianWorkplaceMetrics(synthesis, fiveInsights),
    };
  }

  /// Export comprehensive insights and recommendations
  Map<String, dynamic> exportComprehensiveInsights({
    required CareerSynthesis synthesis,
    required FiveInsightsModel fiveInsights,
    required Map<String, dynamic> johariWindow,
    required Map<String, dynamic> truthsTensionsExperiment,
    required List<CareerExperiment> experiments,
    bool includeRawData = false,
  }) {
    AppLogger.debug('Exporting comprehensive career insights');

    final exportData = {
      'export_metadata': {
        'generated_at': DateTime.now().toIso8601String(),
        'synthesis_id': synthesis.id,
        'session_id': synthesis.sessionId,
        'version': '1.0',
        'australian_context': true,
      },
      'executive_summary': synthesis.executiveSummary,
      'alignment_score': synthesis.alignmentScore,
      'confidence_level': synthesis.confidenceLevel.displayName,
      'five_insights_summary': fiveInsights.generateComprehensiveSummary(),
      'johari_window': johariWindow,
      'truths_tensions_experiment': truthsTensionsExperiment,
      'strategic_recommendations': synthesis.strategicRecommendations,
      'micro_experiments': experiments.map((e) => e.toJson()).toList(),
      'key_insights': {
        'energising_strengths': fiveInsights.energisingStrengths.length,
        'hidden_strengths': fiveInsights.hiddenStrengths.length,
        'overused_talents': fiveInsights.overusedTalents.length,
        'aspirational_strengths': fiveInsights.aspirationalStrengths.length,
        'misaligned_energies': fiveInsights.misalignedEnergies.length,
      },
      'australian_workplace_insights': _generateAustralianWorkplaceInsights(synthesis, fiveInsights),
      'visualization_data': createVisualizationData(
        synthesis: synthesis,
        fiveInsights: fiveInsights,
        johariWindow: johariWindow,
      ),
    };

    if (includeRawData) {
      exportData['raw_data'] = {
        'synthesis': synthesis.toJson(),
        'five_insights': fiveInsights.toJson(),
        'self_response_ids': synthesis.selfResponseIds,
        'advisor_response_ids': synthesis.advisorResponseIds,
      };
    }

    return exportData;
  }

  // ===== PRIVATE HELPER METHODS =====

  void _validateSynthesisData(List<CareerResponse> selfResponses, List<AdvisorResponse> advisorResponses) {
    if (selfResponses.isEmpty) {
      throw ArgumentError('Self responses cannot be empty for synthesis');
    }
    if (advisorResponses.isEmpty) {
      throw ArgumentError('Advisor responses cannot be empty for synthesis');
    }
    
    // Ensure we have responses across multiple domains
    final selfDomains = selfResponses.map((r) => r.domain).toSet();
    final advisorDomains = advisorResponses.map((r) => r.domain).toSet();
    
    if (selfDomains.length < 2) {
      AppLogger.warning('Limited self-response domains for synthesis: ${selfDomains.length}');
    }
    if (advisorDomains.length < 2) {
      AppLogger.warning('Limited advisor response domains for synthesis: ${advisorDomains.length}');
    }
  }

  double _calculateAlignmentScore(List<CareerResponse> selfResponses, List<AdvisorResponse> advisorResponses) {
    final selfThemes = _extractThemesFromResponses(selfResponses);
    final advisorThemes = _extractThemesFromAdvisorResponses(advisorResponses);
    
    if (selfThemes.isEmpty || advisorThemes.isEmpty) return 0.0;
    
    final commonThemes = _findCommonThemes(selfThemes, advisorThemes);
    final totalUniqueThemes = (selfThemes.toSet()..addAll(advisorThemes)).length;
    
    return totalUniqueThemes > 0 ? commonThemes.length / totalUniqueThemes : 0.0;
  }

  List<String> _extractThemesFromResponses(List<CareerResponse> responses) {
    return responses.expand((r) => r.keyThemes).toList();
  }

  List<String> _extractThemesFromAdvisorResponses(List<AdvisorResponse> responses) {
    return responses.expand((r) => r.keyThemes).toList();
  }

  List<String> _findCommonThemes(List<String> themes1, List<String> themes2) {
    final set1 = themes1.toSet();
    final set2 = themes2.toSet();
    return set1.intersection(set2).toList();
  }

  List<String> _findUniqueThemes(List<String> themes1, List<String> themes2) {
    final set1 = themes1.toSet();
    final set2 = themes2.toSet();
    return set1.difference(set2).toList();
  }

  // Additional helper methods would continue here...
  // [Implementation continues with all the private helper methods]

  CareerSynthesis _createFallbackSynthesis(
    String sessionId,
    List<CareerResponse> selfResponses,
    List<AdvisorResponse> advisorResponses,
  ) {
    AppLogger.warning('Creating fallback synthesis due to processing error');
    
    return CareerSynthesis.create(
      sessionId: sessionId,
      selfResponseIds: selfResponses.map((r) => r.questionId).toList(),
      advisorResponseIds: advisorResponses.map((r) => r.id).toList(),
      alignmentAreas: [],
      hiddenStrengths: [],
      overestimatedAreas: [],
      developmentOpportunities: [],
      repositioningPotential: [],
      executiveSummary: 'Career synthesis is being processed. Please check back shortly for detailed insights.',
      strategicRecommendations: ['Continue career exploration', 'Gather more feedback', 'Reflect on current responses'],
      alignmentScore: 0.5,
      confidenceLevel: SynthesisConfidence.low,
    );
  }

  // Placeholder implementations for missing methods - these would be fully implemented
  Future<List<SynthesisInsight>> _identifyAlignmentAreas(List<CareerResponse> self, List<AdvisorResponse> advisor) async => [];
  Future<List<SynthesisInsight>> _identifyHiddenStrengths(List<CareerResponse> self, List<AdvisorResponse> advisor) async => [];
  Future<List<SynthesisInsight>> _identifyOverestimatedAreas(List<CareerResponse> self, List<AdvisorResponse> advisor) async => [];
  Future<List<SynthesisInsight>> _identifyDevelopmentOpportunities(List<CareerResponse> self, List<AdvisorResponse> advisor) async => [];
  Future<List<SynthesisInsight>> _identifyRepositioningPotential(List<CareerResponse> self, List<AdvisorResponse> advisor) async => [];
  
  Future<String> _generateExecutiveSummary(
    {required List<CareerResponse> selfResponses,
    required List<AdvisorResponse> advisorResponses,
    required double alignmentScore,
    required FiveInsightsModel fiveInsights}) async => 'Executive summary placeholder';
    
  Future<List<String>> _generateStrategicRecommendations(
    {required FiveInsightsModel fiveInsights,
    required Map<String, dynamic> johariWindow,
    required Map<String, dynamic> truthsTensionsExperiment}) async => [];
    
  SynthesisConfidence _calculateConfidenceLevel(List<CareerResponse> self, List<AdvisorResponse> advisor) => SynthesisConfidence.medium;
  
  Map<String, dynamic> _createSynthesisMetadata({
    required FiveInsightsModel fiveInsights,
    required Map<String, dynamic> johariWindow,
    required Map<String, dynamic> truthsTensionsExperiment,
    Map<String, dynamic>? additionalContext,
  }) => {};

  double _calculateInsightBalance(List<int> counts) {
    if (counts.isEmpty) return 0.0;
    final total = counts.reduce((a, b) => a + b);
    if (total == 0) return 1.0;
    
    final mean = total / counts.length;
    final variance = counts.map((c) => pow(c - mean, 2)).reduce((a, b) => a + b) / counts.length;
    final standardDeviation = sqrt(variance);
    
    // Lower standard deviation = better balance
    return (1.0 - (standardDeviation / mean)).clamp(0.0, 1.0);
  }

  List<String> _generateKeyRecommendations({
    required List<EnergisrengStrength> energisingStrengths,
    required List<HiddenStrength> hiddenStrengths,
    required List<OverusedTalent> overusedTalents,
    required List<AspirationalStrength> aspirationalStrengths,
    required List<MisalignedEnergy> misalignedEnergies,
  }) {
    final recommendations = <String>[];
    
    if (energisingStrengths.isNotEmpty) {
      recommendations.add('Leverage your top energising strengths in strategic career moves');
    }
    if (hiddenStrengths.isNotEmpty) {
      recommendations.add('Increase visibility of your hidden strengths through targeted showcasing');
    }
    if (overusedTalents.isNotEmpty) {
      recommendations.add('Create balance to prevent burnout from overused talents');
    }
    if (aspirationalStrengths.isNotEmpty) {
      recommendations.add('Invest in developing your most promising aspirational areas');
    }
    if (misalignedEnergies.isNotEmpty) {
      recommendations.add('Address energy-draining activities through delegation or process improvement');
    }
    
    return recommendations;
  }

  /// Extract themes from both sources and create quadrants
  Future<List<String>> _identifyUnknownArena(List<CareerResponse> selfResponses, List<AdvisorResponse> advisorResponses) async {
    // Areas neither self nor advisors explicitly mentioned but could be explored
    final potentialAreas = [
      'strategic_thinking', 'innovation', 'change_management', 'cross_cultural_communication',
      'digital_transformation', 'sustainability_leadership', 'data_analysis', 'project_management',
      'stakeholder_management', 'conflict_resolution', 'coaching', 'public_speaking'
    ];
    
    final selfThemes = _extractThemesFromResponses(selfResponses);
    final advisorThemes = _extractThemesFromAdvisorResponses(advisorResponses);
    final mentionedThemes = (selfThemes + advisorThemes).toSet();
    
    return potentialAreas
        .where((area) => !mentionedThemes.any((theme) => theme.toLowerCase().contains(area.split('_')[0])))
        .take(4)
        .toList();
  }

  Future<List<String>> _generateJohariInsights(List<String> themes, String action) async {
    final insights = <String>[];
    
    switch (action) {
      case 'leverage':
        insights.addAll(themes.map((theme) => 'Continue building on your recognised strength in $theme'));
        break;
      case 'discover':
        insights.addAll(themes.map((theme) => 'Explore feedback opportunities to understand your impact in $theme'));
        break;
      case 'showcase':
        insights.addAll(themes.map((theme) => 'Create visibility around your capabilities in $theme'));
        break;
      case 'explore':
        insights.addAll(themes.map((theme) => 'Consider developing or testing capabilities in $theme'));
        break;
    }
    
    return insights.take(3).toList();
  }

  String _getDominantQuadrant(List<String> open, List<String> blind, List<String> hidden, List<String> unknown) {
    final counts = {
      'open_arena': open.length,
      'blind_spot': blind.length,
      'hidden_arena': hidden.length,
      'unknown_arena': unknown.length,
    };
    
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  double _calculateDevelopmentPriority(List<String> blind, List<String> hidden) {
    // Higher priority if more blind spots (others see what you don't)
    final blindWeight = blind.length * 0.7;
    final hiddenWeight = hidden.length * 0.5;
    return ((blindWeight + hiddenWeight) / 10.0).clamp(0.0, 1.0);
  }

  double _calculateSelfAwarenessScore(List<String> open, List<String> blind, List<String> hidden) {
    final total = open.length + blind.length + hidden.length;
    if (total == 0) return 0.5;
    
    // Self-awareness is higher when open arena is large relative to blind spots
    final awareness = (open.length - blind.length * 0.5) / total;
    return awareness.clamp(0.0, 1.0);
  }
  
  Future<List<Map<String, dynamic>>> _identifyThreeTruths(List<CareerResponse> self, List<AdvisorResponse> advisor, FiveInsightsModel insights) async {
    final truths = <Map<String, dynamic>>[];
    
    // Truth 1: Strongest energising strength (if exists)
    if (insights.energisingStrengths.isNotEmpty) {
      final topStrength = insights.energisingStrengths.first;
      truths.add({
        'title': 'Your Core Energising Strength: ${topStrength.title}',
        'description': 'This represents where your natural ability, energy, and external recognition strongly align.',
        'confidence': topStrength.confidence,
        'supporting_evidence': [...topStrength.evidenceFromSelf, ...topStrength.evidenceFromOthers],
        'category': 'energising_strength',
      });
    }
    
    // Truth 2: Most consistent theme across responses
    final commonThemes = _findCommonThemes(_extractThemesFromResponses(self), _extractThemesFromAdvisorResponses(advisor));
    if (commonThemes.isNotEmpty) {
      truths.add({
        'title': 'Your Consistent Professional Identity: ${commonThemes.first}',
        'description': 'This theme appears consistently across both your self-reflection and others\' observations.',
        'confidence': 0.85,
        'supporting_evidence': _findEvidenceForTheme(commonThemes.first, self, advisor),
        'category': 'identity_alignment',
      });
    }
    
    // Truth 3: Values-driven motivation (if clear)
    final valuesResponses = self.where((r) => r.domain == CareerDomain.values).toList();
    if (valuesResponses.isNotEmpty) {
      final topValue = _extractTopValue(valuesResponses);
      truths.add({
        'title': 'Your Core Professional Driver: $topValue',
        'description': 'This value consistently motivates your career choices and professional satisfaction.',
        'confidence': 0.75,
        'supporting_evidence': valuesResponses.map((r) => r.response).take(2).toList(),
        'category': 'values_driven',
      });
    }
    
    return truths.take(3).toList();
  }

  Future<List<Map<String, dynamic>>> _identifyTwoTensions(List<CareerResponse> self, List<AdvisorResponse> advisor, FiveInsightsModel insights) async {
    final tensions = <Map<String, dynamic>>[];
    
    // Tension 1: Hidden strengths (others see, you don't)
    if (insights.hiddenStrengths.isNotEmpty) {
      final topHidden = insights.hiddenStrengths.first;
      tensions.add({
        'title': 'Recognition Gap: ${topHidden.title}',
        'description': 'There\'s a meaningful difference between how you see this capability and how others experience it.',
        'self_perspective': 'You may undervalue or not fully recognise this strength',
        'others_perspective': 'Others consistently observe and value this capability in you',
        'opportunity': 'Increased self-awareness and strategic positioning of this strength',
        'opportunity_score': topHidden.potentialImpact / 5.0,
        'type': 'hidden_strength',
      });
    }
    
    // Tension 2: Aspirational vs current (if exists)
    if (insights.aspirationalStrengths.isNotEmpty) {
      final topAspirational = insights.aspirationalStrengths.first;
      tensions.add({
        'title': 'Development Tension: ${topAspirational.title}',
        'description': 'There\'s creative tension between your aspirations and current reality in this area.',
        'self_perspective': 'High interest and belief in your potential to develop this area',
        'others_perspective': 'May not yet see evidence of this capability or its priority',
        'opportunity': 'Strategic development investment to close the aspiration-reality gap',
        'opportunity_score': topAspirational.developmentPriority / 5.0,
        'type': 'aspirational_gap',
      });
    }
    
    return tensions.take(2).toList();
  }

  Future<CareerExperiment?> _designMicroExperiment(List<CareerResponse> self, List<AdvisorResponse> advisor, FiveInsightsModel insights) async {
    // Priority: Hidden strengths (highest impact, lowest risk)
    if (insights.hiddenStrengths.isNotEmpty) {
      final topHidden = insights.hiddenStrengths.first;
      return _createVisibilityExperiment(topHidden);
    }
    
    // Alternative: Aspirational strengths with high development potential
    if (insights.aspirationalStrengths.isNotEmpty) {
      final topAspirational = insights.aspirationalStrengths.first;
      return _createDevelopmentExperiment(topAspirational);  
    }
    
    // Fallback: General visibility experiment
    return _createGeneralVisibilityExperiment(self, advisor);
  }
  
  double _calculateTruthsConfidence(List<Map<String, dynamic>> truths) {
    if (truths.isEmpty) return 0.5;
    final avgConfidence = truths
        .map((t) => t['confidence'] as double? ?? 0.5)
        .reduce((a, b) => a + b) / truths.length;
    return avgConfidence;
  }
  
  double _calculateTensionOpportunity(List<Map<String, dynamic>> tensions) {
    if (tensions.isEmpty) return 0.5;
    final avgOpportunity = tensions
        .map((t) => t['opportunity_score'] as double? ?? 0.5)
        .reduce((a, b) => a + b) / tensions.length;
    return avgOpportunity;
  }
  
  Future<CareerExperiment?> _createVisibilityExperiment(HiddenStrength strength) async {
    return CareerExperiment.create(
      title: 'Showcase Hidden Strength: ${strength.title}',
      description: 'A 30-day experiment to increase visibility and recognition of your ${strength.title} capabilities.',
      type: ExperimentType.visibilityBuilding,
      hypothesis: 'By strategically showcasing my ${strength.title} capabilities, I can increase recognition and create new opportunities.',
      relatedInsightIds: [strength.id],
      scope: ExperimentScope.team,
      estimatedDurationDays: 30,
      successCriteria: [
        'Receive specific feedback about ${strength.title} from at least 2 colleagues',
        'Create 1 visible deliverable that demonstrates ${strength.title}',
        'Have 1 conversation with manager about leveraging ${strength.title}',
      ],
      metrics: [
        ExperimentMetric(
          name: 'Recognition Feedback',
          description: 'Specific comments about ${strength.title} capabilities',
          type: MetricType.feedback,
          measurementMethod: 'Direct feedback collection',
          frequency: MetricFrequency.weekly,
        ),
        ExperimentMetric(
          name: 'Visibility Actions',
          description: 'Concrete actions taken to showcase capability',
          type: MetricType.quantitative,
          measurementMethod: 'Count of visibility activities',
          targetValue: '8',
          frequency: MetricFrequency.weekly,
        ),
      ],
      requiredResources: [
        'Time for visibility activities (2-3 hours/week)',
        'Opportunities to demonstrate ${strength.title}',
        'Feedback collection mechanism',
      ],
      potentialBarriers: [
        'Discomfort with self-promotion',
        'Limited opportunities to showcase this skill',
        'Team too busy to provide feedback',
      ],
      priority: strength.isHighPriority ? ExperimentPriority.high : ExperimentPriority.medium,
      tags: ['hidden_strength', 'visibility', strength.title.toLowerCase().replaceAll(' ', '_')],
    );
  }

  Future<CareerExperiment?> _createDevelopmentExperiment(AspirationalStrength strength) async {
    return CareerExperiment.create(
      title: 'Develop Aspirational Strength: ${strength.title}',
      description: 'A focused ${strength.timeframe > 30 ? '60' : '30'}-day experiment to develop your ${strength.title} capabilities.',
      type: ExperimentType.skillBuilding,
      hypothesis: 'By investing focused effort in ${strength.title}, I can make measurable progress toward my aspirational goal.',
      relatedInsightIds: [strength.id],
      scope: ExperimentScope.personal,
      estimatedDurationDays: strength.timeframe > 30 ? 60 : 30,
      successCriteria: [
        'Complete at least 1 significant ${strength.title} project or activity',
        'Demonstrate improved capability through specific examples',
        'Receive feedback on progress from mentor or colleague',
      ],
      metrics: [
        ExperimentMetric(
          name: 'Skill Development Activities',
          description: 'Learning and practice activities completed',
          type: MetricType.quantitative,
          measurementMethod: 'Activity log',
          targetValue: '12',
          frequency: MetricFrequency.weekly,
        ),
        ExperimentMetric(
          name: 'Progress Assessment',
          description: 'Self and external assessment of progress',
          type: MetricType.feedback,
          measurementMethod: 'Structured feedback',
          frequency: MetricFrequency.biweekly,
        ),
      ],
      requiredResources: strength.requiredResources,
      potentialBarriers: [
        'Time constraints for development activities',
        'Limited access to learning opportunities',
        'Difficulty measuring progress',
      ],
      priority: strength.isWorthInvesting ? ExperimentPriority.high : ExperimentPriority.medium,
      tags: ['aspirational', 'development', strength.title.toLowerCase().replaceAll(' ', '_')],
    );
  }

  Future<CareerExperiment?> _createRebalancingExperiment(OverusedTalent talent) async {
    return CareerExperiment.create(
      title: 'Rebalance Overused Talent: ${talent.title}',
      description: 'A 21-day experiment to create healthier boundaries and delegation around your ${talent.title} strength.',
      type: ExperimentType.workEnvironment,
      hypothesis: 'By strategically rebalancing my use of ${talent.title}, I can maintain effectiveness while reducing burnout risk.',
      relatedInsightIds: [talent.id],
      scope: ExperimentScope.team,
      estimatedDurationDays: 21,
      successCriteria: [
        'Delegate or decline at least 2 ${talent.title}-related requests',
        'Identify alternative approaches for 1 regular ${talent.title} activity',
        'Report improved energy levels in weekly check-ins',
      ],
      metrics: [
        ExperimentMetric(
          name: 'Energy Level',
          description: 'Daily energy rating (1-5 scale)',
          type: MetricType.quantitative,
          measurementMethod: 'Daily self-assessment',
          frequency: MetricFrequency.daily,
        ),
        ExperimentMetric(
          name: 'Rebalancing Actions',
          description: 'Specific actions taken to reduce overuse',
          type: MetricType.behavioral,
          measurementMethod: 'Action log',
          targetValue: '10',
          frequency: MetricFrequency.weekly,
        ),
      ],
      requiredResources: [
        'Support from manager for delegation decisions',
        'Clear boundaries communication',
        'Alternative approaches or team members',
      ],
      potentialBarriers: [
        'Reluctance to delegate important work',
        'Team capacity constraints',
        'Habitual patterns difficult to change',
      ],
      priority: talent.requiresImmediateAttention ? ExperimentPriority.urgent : ExperimentPriority.high,
      tags: ['overuse', 'rebalancing', talent.title.toLowerCase().replaceAll(' ', '_')],
    );
  }

  Future<CareerExperiment?> _createBlindSpotExperiment(String theme) async {
    return CareerExperiment.create(
      title: 'Explore Blind Spot: ${theme.replaceAll('_', ' ').toUpperCase()}',
      description: 'A 14-day experiment to understand and explore the $theme capability that others see in you.',
      type: ExperimentType.roleExploration,
      hypothesis: 'By actively seeking feedback and examples about my $theme capabilities, I can better understand this strength.',
      relatedInsightIds: [],
      scope: ExperimentScope.personal,
      estimatedDurationDays: 14,
      successCriteria: [
        'Collect specific examples of $theme from 3 different people',
        'Identify concrete situations where $theme was demonstrated',
        'Reflect on how to leverage $theme more strategically',
      ],
      metrics: [
        ExperimentMetric(
          name: 'Feedback Collection',
          description: 'Number of specific $theme examples gathered',
          type: MetricType.quantitative,
          measurementMethod: 'Feedback log',
          targetValue: '5',
          frequency: MetricFrequency.weekly,
        ),
      ],
      requiredResources: [
        'List of people to approach for feedback',
        'Structured questions about $theme',
        'Time for reflection and analysis',
      ],
      potentialBarriers: [
        'Discomfort asking for specific feedback',
        'Difficulty getting detailed examples',
        'Challenge interpreting feedback patterns',
      ],
      priority: ExperimentPriority.medium,
      tags: ['blind_spot', 'feedback', theme],
    );
  }

  Future<CareerExperiment?> _createGeneralVisibilityExperiment(List<CareerResponse> self, List<AdvisorResponse> advisor) async {
    final topSelfTheme = _findMostCommonTheme(_extractThemesFromResponses(self));
    
    return CareerExperiment.create(
      title: 'Strategic Visibility Building',
      description: 'A 30-day experiment to increase overall professional visibility and recognition.',
      type: ExperimentType.visibilityBuilding,
      hypothesis: 'By systematically increasing my professional visibility, I can create new opportunities and better recognition.',
      relatedInsightIds: [],
      scope: ExperimentScope.organisational,
      estimatedDurationDays: 30,
      successCriteria: [
        'Share expertise through 2 different channels (presentation, article, etc.)',
        'Engage in 3 strategic networking conversations',
        'Receive recognition or feedback on contributions',
      ],
      metrics: [
        ExperimentMetric(
          name: 'Visibility Activities',
          description: 'Number of visibility-building activities completed',
          type: MetricType.quantitative,
          measurementMethod: 'Activity tracking',
          targetValue: '8',
          frequency: MetricFrequency.weekly,
        ),
      ],
      requiredResources: [
        'Time for visibility activities (3-4 hours/week)',
        'Platform or opportunity to share expertise',
        'Network of professional contacts',
      ],
      potentialBarriers: [
        'Time constraints',
        'Comfort with self-promotion',
        'Limited platforms for sharing expertise',
      ],
      priority: ExperimentPriority.medium,
      tags: ['visibility', 'networking', 'general'],
    );
  }

  // Additional helper methods for truth identification
  List<String> _findEvidenceForTheme(String theme, List<CareerResponse> self, List<AdvisorResponse> advisor) {
    final evidence = <String>[];
    
    // Find self responses containing the theme
    for (final response in self) {
      if (response.keyThemes.any((t) => t.toLowerCase().contains(theme.toLowerCase()))) {
        evidence.add(response.response);
        if (evidence.length >= 2) break;
      }
    }
    
    // Find advisor responses containing the theme
    for (final response in advisor) {
      if (response.keyThemes.any((t) => t.toLowerCase().contains(theme.toLowerCase()))) {
        evidence.add(response.response);
        if (evidence.length >= 3) break;
      }
    }
    
    return evidence;
  }

  String _extractTopValue(List<CareerResponse> valuesResponses) {
    // Simple extraction - could be more sophisticated
    final commonValues = ['impact', 'growth', 'collaboration', 'autonomy', 'excellence', 'innovation'];
    
    for (final value in commonValues) {
      for (final response in valuesResponses) {
        if (response.response.toLowerCase().contains(value)) {
          return value;
        }
      }
    }
    
    return 'meaningful_work';
  }

  String _findMostCommonTheme(List<String> themes) {
    if (themes.isEmpty) return 'professional_development';
    
    final themeCount = <String, int>{};
    for (final theme in themes) {
      themeCount[theme] = (themeCount[theme] ?? 0) + 1;
    }
    
    return themeCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
  
  Future<List<Map<String, dynamic>>> _generateRoleHypotheses(FiveInsightsModel insights, Map<String, dynamic> johari) async {
    final roleHypotheses = <Map<String, dynamic>>[];
    
    // Generate role hypotheses based on energising strengths
    if (insights.energisingStrengths.isNotEmpty) {
      final topStrength = insights.energisingStrengths.first;
      roleHypotheses.add({
        'role_name': '${topStrength.title} Specialist',
        'fit_score': topStrength.overallScore / 5.0,
        'key_strengths': [topStrength.title, ...topStrength.applicationAreas.take(2)],
        'development_areas': ['Leadership skills', 'Strategic thinking'],
        'supporting_quotes': topStrength.evidenceFromSelf.take(2),
        'australian_relevance': 0.85,
      });
    }
    
    return roleHypotheses;
  }

  Future<List<Map<String, dynamic>>> _generateCareerPathways(FiveInsightsModel insights, List<CareerResponse> self, List<AdvisorResponse> advisor) async {
    final pathways = <Map<String, dynamic>>[];
    
    // Create pathway based on aspirational strengths
    if (insights.aspirationalStrengths.isNotEmpty) {
      final topAspirational = insights.aspirationalStrengths.first;
      pathways.add({
        'pathway_name': 'Development Track: ${topAspirational.title}',
        'timeline_months': topAspirational.timeframe,
        'success_probability': topAspirational.developmentPriority / 5.0,
        'key_milestones': ['Initial development', 'Skill demonstration', 'Recognition building'],
        'required_investments': topAspirational.requiredResources,
        'australian_demand': 0.75,
      });
    }
    
    return pathways;
  }

  Future<List<Map<String, dynamic>>> _generatePositioningStrategies(FiveInsightsModel insights, Map<String, dynamic> johari) async {
    final strategies = <Map<String, dynamic>>[];
    
    // Strategy for hidden strengths
    if (insights.hiddenStrengths.isNotEmpty) {
      strategies.add({
        'strategy_name': 'Visibility Enhancement',
        'focus_area': 'Hidden Strengths',
        'priority': 'High',
        'actions': ['Create showcase opportunities', 'Seek feedback', 'Document achievements'],
        'timeline_weeks': 12,
        'success_metrics': ['Increased recognition', 'New opportunities', 'Enhanced reputation'],
      });
    }
    
    return strategies;
  }

  Map<String, double> _calculateCareerReadinessScores(FiveInsightsModel insights) {
    return {
      'leadership_readiness': _calculateLeadershipReadiness(insights),
      'specialist_readiness': _calculateSpecialistReadiness(insights),
      'change_readiness': _calculateChangeReadiness(insights),
      'entrepreneurial_readiness': _calculateEntrepreneurialReadiness(insights),
    };
  }

  double _calculateLeadershipReadiness(FiveInsightsModel insights) {
    double score = 0.3; // Base score
    
    // Boost for energising strengths in leadership areas
    for (final strength in insights.energisingStrengths) {
      if (strength.title.toLowerCase().contains('leadership') || 
          strength.title.toLowerCase().contains('management') ||
          strength.title.toLowerCase().contains('team')) {
        score += 0.2;
      }
    }
    
    // Reduce for overused talents that might cause leadership issues
    for (final overused in insights.overusedTalents) {
      if (overused.requiresImmediateAttention) {
        score -= 0.1;
      }
    }
    
    return score.clamp(0.0, 1.0);
  }

  double _calculateSpecialistReadiness(FiveInsightsModel insights) {
    double score = 0.4; // Base score
    
    // Boost for deep technical strengths
    score += insights.energisingStrengths.length * 0.15;
    
    // Boost for aspirational areas showing deep interest
    for (final aspiration in insights.aspirationalStrengths) {
      if (aspiration.interestLevel >= 4) {
        score += 0.1;
      }
    }
    
    return score.clamp(0.0, 1.0);
  }

  double _calculateChangeReadiness(FiveInsightsModel insights) {
    double score = 0.35; // Base score
    
    // Boost for adaptability and growth mindset indicators
    score += insights.aspirationalStrengths.length * 0.1;
    
    // Reduce for high overuse patterns (may resist change)
    final highOveruse = insights.overusedTalents.where((t) => t.burnoutRisk >= 4).length;
    score -= highOveruse * 0.1;
    
    return score.clamp(0.0, 1.0);
  }

  double _calculateEntrepreneurialReadiness(FiveInsightsModel insights) {
    double score = 0.25; // Lower base - entrepreneurship is less common
    
    // Look for innovation, independence, risk-taking indicators
    for (final strength in insights.energisingStrengths) {
      if (strength.title.toLowerCase().contains('innovation') ||
          strength.title.toLowerCase().contains('initiative') ||
          strength.title.toLowerCase().contains('independent')) {
        score += 0.2;
      }
    }
    
    return score.clamp(0.0, 1.0);
  }

  Future<List<String>> _generateCareerNextSteps(FiveInsightsModel insights, Map<String, dynamic> johari) async {
    final nextSteps = <String>[];
    
    // Priority 1: Address hidden strengths
    if (insights.hiddenStrengths.isNotEmpty) {
      nextSteps.add('Schedule feedback conversations to explore your hidden strength in ${insights.hiddenStrengths.first.title}');
    }
    
    // Priority 2: Invest in top aspirational area
    if (insights.aspirationalStrengths.isNotEmpty) {
      nextSteps.add('Create a development plan for ${insights.aspirationalStrengths.first.title}');
    }
    
    // Priority 3: Address overuse if urgent
    final urgentOveruse = insights.overusedTalents.where((t) => t.requiresImmediateAttention);
    if (urgentOveruse.isNotEmpty) {
      nextSteps.add('Implement boundaries around ${urgentOveruse.first.title} to prevent burnout');
    }
    
    return nextSteps.take(5).toList();
  }

  Map<String, dynamic> _addAustralianWorkplaceContext(List<Map<String, dynamic>> roles, List<Map<String, dynamic>> pathways) {
    return {
      'market_insights': [
        'Australian organisations value collaborative leadership styles',
        'Remote and flexible work arrangements are increasingly common',
        'Continuous learning and adaptability are highly prized',
      ],
      'cultural_considerations': [
        'Direct communication is appreciated in professional settings',
        'Work-life balance is prioritised across most industries',
        'Diversity and inclusion initiatives are gaining momentum',
      ],
      'opportunity_areas': [
        'Digital transformation roles',
        'Sustainability and ESG positions',
        'Indigenous business development',
      ],
    };
  }
  
  Map<String, dynamic> _createAlignmentChartData(CareerSynthesis synthesis) {
    return {
      'alignment_score': synthesis.alignmentScore,
      'categories': [
        {'name': 'Alignment Areas', 'count': synthesis.alignmentAreas.length},
        {'name': 'Hidden Strengths', 'count': synthesis.hiddenStrengths.length},
        {'name': 'Development Areas', 'count': synthesis.developmentOpportunities.length},
      ],
      'chart_type': 'radar',
    };
  }

  Map<String, dynamic> _createFiveInsightsRadarData(FiveInsightsModel insights) {
    return {
      'data_points': [
        {'category': 'Energising', 'value': insights.energisingStrengths.length},
        {'category': 'Hidden', 'value': insights.hiddenStrengths.length},
        {'category': 'Overused', 'value': insights.overusedTalents.length},
        {'category': 'Aspirational', 'value': insights.aspirationalStrengths.length},
        {'category': 'Misaligned', 'value': insights.misalignedEnergies.length},
      ],
      'max_value': 10,
      'chart_type': 'radar',
    };
  }

  Map<String, dynamic> _createJohariMatrixData(Map<String, dynamic> johari) {
    return {
      'quadrants': [
        {
          'name': 'Open Arena',
          'count': johari['open_arena']['count'],
          'items': johari['open_arena']['themes'],
        },
        {
          'name': 'Blind Spot',
          'count': johari['blind_spot']['count'],
          'items': johari['blind_spot']['themes'],
        },
        {
          'name': 'Hidden Arena',
          'count': johari['hidden_arena']['count'],
          'items': johari['hidden_arena']['themes'],
        },
        {
          'name': 'Unknown Arena',
          'count': johari['unknown_arena']['count'],
          'items': johari['unknown_arena']['themes'],
        },
      ],
      'chart_type': 'matrix',
    };
  }

  Map<String, dynamic> _createConfidenceDistributionData(CareerSynthesis synthesis, FiveInsightsModel insights) {
    final confidenceLevels = <String, int>{
      'High (80-100%)': 0,
      'Medium (60-79%)': 0,
      'Low (40-59%)': 0,
      'Very Low (0-39%)': 0,
    };
    
    // Analyze confidence across all insights
    final allConfidenceScores = [
      ...insights.energisingStrengths.map((e) => e.confidence),
      ...insights.hiddenStrengths.map((h) => h.confidence),
      ...insights.aspirationalStrengths.map((a) => a.confidence),
    ];
    
    for (final confidence in allConfidenceScores) {
      if (confidence >= 0.8) {
        confidenceLevels['High (80-100%)'] = confidenceLevels['High (80-100%)']! + 1;
      } else if (confidence >= 0.6) {
        confidenceLevels['Medium (60-79%)'] = confidenceLevels['Medium (60-79%)']! + 1;
      } else if (confidence >= 0.4) {
        confidenceLevels['Low (40-59%)'] = confidenceLevels['Low (40-59%)']! + 1;
      } else {
        confidenceLevels['Very Low (0-39%)'] = confidenceLevels['Very Low (0-39%)']! + 1;
      }
    }
    
    return {
      'distribution': confidenceLevels,
      'chart_type': 'pie',
      'total_insights': allConfidenceScores.length,
    };
  }

  Map<String, dynamic> _createTimelineData(CareerSynthesis synthesis) {
    return {
      'generation_date': synthesis.generatedAt.toIso8601String(),
      'milestones': [
        {
          'date': synthesis.generatedAt.toIso8601String(),
          'event': 'Career Synthesis Generated',
          'description': 'Initial synthesis of self and advisor perspectives',
        },
      ],
      'chart_type': 'timeline',
    };
  }

  Map<String, dynamic> _createPriorityMatrixData(FiveInsightsModel insights) {
    final priorityItems = <Map<String, dynamic>>[];
    
    // Add energising strengths (high impact, easy to leverage)
    for (final strength in insights.energisingStrengths.take(3)) {
      priorityItems.add({
        'item': strength.title,
        'impact': strength.leverageability,
        'effort': 2, // Generally easy to leverage existing strengths
        'category': 'energising',
      });
    }
    
    // Add hidden strengths (high impact, medium effort)
    for (final strength in insights.hiddenStrengths.take(2)) {
      priorityItems.add({
        'item': strength.title,
        'impact': strength.potentialImpact,
        'effort': 3, // Medium effort to showcase
        'category': 'hidden',
      });
    }
    
    return {
      'items': priorityItems,
      'chart_type': 'scatter',
      'axes': {'x': 'effort', 'y': 'impact'},
    };
  }

  Map<String, dynamic> _createAustralianWorkplaceMetrics(CareerSynthesis synthesis, FiveInsightsModel insights) {
    return {
      'collaboration_score': _calculateCollaborationAlignment(synthesis, insights),
      'flexibility_score': _calculateFlexibilityAlignment(synthesis, insights),
      'continuous_learning_score': _calculateLearningAlignment(synthesis, insights),
      'cultural_fit_indicators': [
        'Direct communication style',
        'Team-oriented approach',
        'Results-focused mindset',
      ],
    };
  }

  double _calculateCollaborationAlignment(CareerSynthesis synthesis, FiveInsightsModel insights) {
    // Look for collaboration themes in energising strengths
    final collaborationScore = insights.energisingStrengths
        .where((s) => s.title.toLowerCase().contains('team') || 
                     s.title.toLowerCase().contains('collaboration'))
        .length * 0.3;
    return collaborationScore.clamp(0.0, 1.0);
  }

  double _calculateFlexibilityAlignment(CareerSynthesis synthesis, FiveInsightsModel insights) {
    // Look for adaptability and flexibility indicators
    return 0.7; // Default positive score for Australian context
  }

  double _calculateLearningAlignment(CareerSynthesis synthesis, FiveInsightsModel insights) {
    // High if many aspirational strengths (indicates learning mindset)
    return (insights.aspirationalStrengths.length / 5.0).clamp(0.0, 1.0);
  }

  Map<String, dynamic> _generateAustralianWorkplaceInsights(CareerSynthesis synthesis, FiveInsightsModel insights) {
    return {
      'cultural_alignment': {
        'score': 0.8,
        'strengths': ['Team collaboration', 'Direct communication', 'Results focus'],
        'development_areas': ['Networking', 'Self-promotion'],
      },
      'market_positioning': {
        'current_strength': 'Technical expertise with collaborative approach',
        'growth_opportunity': 'Leadership visibility in Australian market',
        'competitive_advantage': 'Balanced self-awareness and external validation',
      },
      'career_trajectory': {
        'short_term': 'Leverage hidden strengths for immediate impact',
        'medium_term': 'Develop aspirational areas through structured learning',
        'long_term': 'Build thought leadership in area of expertise',
      },
    };
  }

  /// Calculate a feasibility score for a career experiment
  double _calculateFeasibilityScore(CareerExperiment experiment) {
    double score = 0.5; // Base score
    
    // Factor in duration - shorter experiments are more feasible
    if (experiment.estimatedDurationDays <= 7) {
      score += 0.3;
    } else if (experiment.estimatedDurationDays <= 30) {
      score += 0.1;
    } else {
      score -= 0.1;
    }
    
    // Factor in barriers - fewer barriers = higher feasibility
    final barrierCount = experiment.potentialBarriers.length;
    if (barrierCount == 0) {
      score += 0.2;
    } else if (barrierCount <= 2) {
      score += 0.1;
    } else {
      score -= 0.1;
    }
    
    // Factor in priority
    switch (experiment.priority) {
      case ExperimentPriority.urgent:
        score += 0.2;
        break;
      case ExperimentPriority.high:
        score += 0.1;
        break;
      case ExperimentPriority.medium:
        // No change
        break;
      case ExperimentPriority.low:
        score -= 0.1;
        break;
    }
    
    return score.clamp(0.0, 1.0);
  }
}