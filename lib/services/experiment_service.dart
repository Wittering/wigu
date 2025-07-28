import 'dart:math';
import '../models/career_experiment.dart';
import '../models/experiment_result.dart';
import '../models/career_insight.dart';
import '../models/career_synthesis.dart';
import '../models/five_insights_model.dart';
// import '../models/advisor_response.dart';
import '../models/career_response.dart';
import '../utils/logger.dart';
import 'career_ai_service.dart';
import 'career_synthesis_engine.dart';
import 'career_persistence_service.dart';

/// Comprehensive service for managing career micro-experiments
/// Generates AI-powered experiment suggestions and tracks user progress
class ExperimentService {
  final CareerAIService _aiService;
  final CareerSynthesisEngine _synthesisEngine;
  final CareerPersistenceService _persistenceService;

  ExperimentService({
    required CareerAIService aiService,
    required CareerSynthesisEngine synthesisEngine,
    required CareerPersistenceService persistenceService,
  }) : _aiService = aiService,
       _synthesisEngine = synthesisEngine,
       _persistenceService = persistenceService;

  /// Generate personalized micro-experiments based on career insights
  Future<List<CareerExperiment>> generatePersonalizedExperiments({
    required List<CareerInsight> insights,
    required String sessionId,
    int maxExperiments = 5,
    ExperimentPriority? priorityFilter,
  }) async {
    AppLogger.info('Generating personalized experiments for session: $sessionId');
    final stopwatch = Stopwatch()..start();

    try {
      final experiments = <CareerExperiment>[];
      
      // Categorize insights for targeted experiment generation
      final strengthInsights = insights.where((i) => i.type == InsightType.strength).toList();
      final developmentInsights = insights.where((i) => i.type == InsightType.development).toList();
      final interestInsights = insights.where((i) => i.type == InsightType.interest).toList();
      final valueInsights = insights.where((i) => i.type == InsightType.value).toList();

      // Generate visibility experiments for strengths
      for (final insight in strengthInsights.take(2)) {
        final experiment = await _generateVisibilityExperiment(insight);
        if (experiment != null && _meetsPriorityFilter(experiment, priorityFilter)) {
          experiments.add(experiment);
        }
      }

      // Generate skill building experiments for development areas
      for (final insight in developmentInsights.take(2)) {
        final experiment = await _generateSkillBuildingExperiment(insight);
        if (experiment != null && _meetsPriorityFilter(experiment, priorityFilter)) {
          experiments.add(experiment);
        }
      }

      // Generate exploration experiments for interests
      for (final insight in interestInsights.take(1)) {
        final experiment = await _generateExplorationExperiment(insight);
        if (experiment != null && _meetsPriorityFilter(experiment, priorityFilter)) {
          experiments.add(experiment);
        }
      }

      // Generate value alignment experiments
      for (final insight in valueInsights.take(1)) {
        final experiment = await _generateValueAlignmentExperiment(insight);
        if (experiment != null && _meetsPriorityFilter(experiment, priorityFilter)) {
          experiments.add(experiment);
        }
      }

      // Generate networking experiments based on patterns
      final networkingExperiment = await _generateNetworkingExperiment(insights);
      if (networkingExperiment != null && _meetsPriorityFilter(networkingExperiment, priorityFilter)) {
        experiments.add(networkingExperiment);
      }

      stopwatch.stop();
      AppLogger.performance('Generated ${experiments.length} experiments', stopwatch.elapsed, {
        'session_id': sessionId,
        'insight_count': insights.length,
        'priority_filter': priorityFilter?.name,
      });

      // Sort by priority and strategic impact
      experiments.sort((a, b) {
        final priorityComparison = _getPriorityScore(b.priority).compareTo(_getPriorityScore(a.priority));
        if (priorityComparison != 0) return priorityComparison;
        return _calculateStrategicImpact(b).compareTo(_calculateStrategicImpact(a));
      });

      return experiments.take(maxExperiments).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error generating personalized experiments', e, stackTrace);
      return _generateFallbackExperiments(sessionId);
    }
  }

  /// Generate experiments based on synthesis results
  Future<List<CareerExperiment>> generateSynthesisBasedExperiments({
    required CareerSynthesis synthesis,
    required FiveInsightsModel? fiveInsights,
    int maxExperiments = 3,
  }) async {
    AppLogger.info('Generating synthesis-based experiments for session: ${synthesis.sessionId}');

    try {
      final experiments = <CareerExperiment>[];

      // Generate experiments for hidden strengths (highest priority)
      for (final hiddenStrength in synthesis.hiddenStrengths.take(2)) {
        final experiment = await _generateHiddenStrengthExperiment(hiddenStrength);
        if (experiment != null) experiments.add(experiment);
      }

      // Generate experiments for development opportunities
      for (final devOpportunity in synthesis.developmentOpportunities.take(1)) {
        final experiment = await _generateDevelopmentOpportunityExperiment(devOpportunity);
        if (experiment != null) experiments.add(experiment);
      }

      // Generate positioning experiments for repositioning potential
      for (final reposition in synthesis.repositioningPotential.take(1)) {
        final experiment = await _generateRepositioningExperiment(reposition);
        if (experiment != null) experiments.add(experiment);
      }

      // Generate experiments from Five Insights if available
      if (fiveInsights != null) {
        final fiveInsightsExperiments = await _synthesisEngine.generateMicroExperiments(
          fiveInsights: fiveInsights,
          johariWindow: {}, // Would come from synthesis metadata
          maxExperiments: 2,
        );
        experiments.addAll(fiveInsightsExperiments);
      }

      return experiments.take(maxExperiments).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error generating synthesis-based experiments', e, stackTrace);
      return [];
    }
  }

  /// Generate experiment suggestions from AI based on free-form career goals
  Future<List<Map<String, dynamic>>> generateAIExperimentSuggestions({
    required String careerGoal,
    required List<CareerResponse> userResponses,
    required String sessionId,
  }) async {
    AppLogger.info('Generating AI experiment suggestions for goal: ${careerGoal.substring(0, min(50, careerGoal.length))}...');

    if (!_aiService.isAvailable) {
      return _generateFallbackAISuggestions(careerGoal);
    }

    try {
      // final prompt = _buildExperimentSuggestionPrompt(careerGoal, userResponses);
      final suggestions = await _aiService.generateCareerPathSuggestions(
        responses: userResponses,
        sessionId: sessionId,
      );

      // Transform path suggestions into experiment suggestions
      return suggestions.map((suggestion) => _transformToExperimentSuggestion(suggestion)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error generating AI experiment suggestions', e, stackTrace);
      return _generateFallbackAISuggestions(careerGoal);
    }
  }

  /// Start an experiment and set up tracking
  Future<CareerExperiment> startExperiment(CareerExperiment experiment) async {
    AppLogger.info('Starting experiment: ${experiment.title}');

    try {
      final startedExperiment = experiment.start();
      await _persistenceService.saveExperiment(startedExperiment);
      
      AppLogger.info('Experiment started successfully: ${startedExperiment.id}');
      return startedExperiment;
    } catch (e, stackTrace) {
      AppLogger.error('Error starting experiment', e, stackTrace);
      rethrow;
    }
  }

  /// Update experiment progress
  Future<CareerExperiment> updateExperimentProgress({
    required String experimentId,
    Map<String, dynamic>? progressData,
    List<String>? notes,
  }) async {
    AppLogger.info('Updating experiment progress: $experimentId');

    try {
      final experiment = await _persistenceService.getExperiment(experimentId);
      if (experiment == null) {
        throw Exception('Experiment not found: $experimentId');
      }

      final updatedMetadata = Map<String, dynamic>.from(experiment.metadata ?? {});
      if (progressData != null) {
        updatedMetadata['progress'] = progressData;
      }
      if (notes != null) {
        updatedMetadata['notes'] = [...(updatedMetadata['notes'] as List<String>? ?? []), ...notes];
      }
      updatedMetadata['last_updated'] = DateTime.now().toIso8601String();

      final updatedExperiment = experiment.copyWith(metadata: updatedMetadata);
      await _persistenceService.saveExperiment(updatedExperiment);

      return updatedExperiment;
    } catch (e, stackTrace) {
      AppLogger.error('Error updating experiment progress', e, stackTrace);
      rethrow;
    }
  }

  /// Complete experiment and generate results
  Future<ExperimentResult> completeExperiment({
    required String experimentId,
    required double successScore,
    required String executiveSummary,
    required List<String> keyLearnings,
    required List<String> challengesFaced,
    required List<String> successFactors,
    required List<String> nextSteps,
    List<String>? unexpectedOutcomes,
    List<MetricResult>? metricResults,
    String? personalReflection,
    Map<String, String>? stakeholderFeedback,
  }) async {
    AppLogger.info('Completing experiment: $experimentId');

    try {
      final experiment = await _persistenceService.getExperiment(experimentId);
      if (experiment == null) {
        throw Exception('Experiment not found: $experimentId');
      }

      // Complete the experiment
      final completedExperiment = experiment.complete();
      await _persistenceService.saveExperiment(completedExperiment);

      // Determine outcome based on success score
      final outcome = _determineExperimentOutcome(successScore, keyLearnings.length);

      // Generate future experiment ideas based on results
    final futureIdeas = await _generateFutureExperimentIdeas(
      completedExperiment,
      successScore,
      keyLearnings,
    );

      // Create experiment result
      final result = ExperimentResult.create(
        experimentId: experimentId,
        outcome: outcome,
        metricResults: metricResults ?? [],
        executiveSummary: executiveSummary,
        keyLearnings: keyLearnings,
        unexpectedOutcomes: unexpectedOutcomes ?? [],
        hypothesisValidation: _generateHypothesisValidation(completedExperiment, successScore),
        successScore: successScore,
        challengesFaced: challengesFaced,
        successFactors: successFactors,
        nextSteps: nextSteps,
        futureExperimentIdeas: futureIdeas,
        confidence: _calculateResultConfidence(successScore, keyLearnings.length, metricResults?.length ?? 0),
        personalReflection: personalReflection,
        stakeholderFeedback: stakeholderFeedback,
      );

      await _persistenceService.saveExperimentResult(result);

      AppLogger.info('Experiment completed successfully: $experimentId');
      return result;
    } catch (e, stackTrace) {
      AppLogger.error('Error completing experiment', e, stackTrace);
      rethrow;
    }
  }

  /// Get all experiments for a session
  Future<List<CareerExperiment>> getExperimentsForSession(String sessionId) async {
    try {
      return await _persistenceService.getExperimentsBySession(sessionId);
    } catch (e, stackTrace) {
      AppLogger.error('Error getting experiments for session', e, stackTrace);
      return [];
    }
  }

  /// Get experiment results for analysis
  Future<List<ExperimentResult>> getExperimentResults(String sessionId) async {
    try {
      return await _persistenceService.getExperimentResultsBySession(sessionId);
    } catch (e, stackTrace) {
      AppLogger.error('Error getting experiment results', e, stackTrace);
      return [];
    }
  }

  /// Generate experiment suggestions based on completed experiments
  Future<List<CareerExperiment>> generateFollowUpExperiments({
    required List<ExperimentResult> completedResults,
    required String sessionId,
    int maxSuggestions = 3,
  }) async {
    AppLogger.info('Generating follow-up experiments based on ${completedResults.length} completed experiments');

    try {
      final experiments = <CareerExperiment>[];

      // Analyze successful experiments for patterns
      final successfulResults = completedResults.where((r) => r.wasSuccessful).toList();
      final unsuccessfulResults = completedResults.where((r) => !r.wasSuccessful).toList();

      // Generate experiments to build on successes
      for (final result in successfulResults.take(2)) {
        final buildOnExperiment = await _generateBuildOnSuccessExperiment(result);
        if (buildOnExperiment != null) experiments.add(buildOnExperiment);
      }

      // Generate experiments to address failures
      for (final result in unsuccessfulResults.take(1)) {
        final addressFailureExperiment = await _generateAddressFailureExperiment(result);
        if (addressFailureExperiment != null) experiments.add(addressFailureExperiment);
      }

      // Generate experiments from future ideas
      final futureIdeas = completedResults.expand((r) => r.futureExperimentIdeas).toSet().toList();
      for (final idea in futureIdeas.take(2)) {
        final futureExperiment = await _generateExperimentFromIdea(idea, sessionId);
        if (futureExperiment != null) experiments.add(futureExperiment);
      }

      return experiments.take(maxSuggestions).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error generating follow-up experiments', e, stackTrace);
      return [];
    }
  }

  /// Calculate experiment impact on career development
  Map<String, dynamic> calculateExperimentImpact({
    required List<ExperimentResult> results,
    required List<CareerInsight> initialInsights,
  }) {
    AppLogger.info('Calculating experiment impact from ${results.length} experiments');

    try {
      final impactData = <String, dynamic>{};
      
      // Overall success metrics
      final successfulCount = results.where((r) => r.wasSuccessful).length;
      final avgSuccessScore = results.isEmpty ? 0.0 : 
          results.map((r) => r.successScore).reduce((a, b) => a + b) / results.length;
      
      impactData['success_rate'] = results.isEmpty ? 0.0 : successfulCount / results.length;
      impactData['average_success_score'] = avgSuccessScore;
      impactData['total_experiments'] = results.length;
      
      // Learning metrics
      final totalLearnings = results.expand((r) => r.keyLearnings).length;
      final avgLearningsPerExperiment = results.isEmpty ? 0.0 : totalLearnings / results.length;
      impactData['total_learnings'] = totalLearnings;
      impactData['learning_density'] = avgLearningsPerExperiment;
      
      // Time and efficiency metrics
      final completedExperiments = results.where((r) => r.outcome != ExperimentOutcome.inconclusive).toList();
      if (completedExperiments.isNotEmpty) {
        final avgCompletionDays = completedExperiments
            .map((r) => r.completedAt.difference(DateTime.now()).inDays.abs())
            .reduce((a, b) => a + b) / completedExperiments.length;
        impactData['average_completion_days'] = avgCompletionDays;
      }
      
      // Breakthrough insights
      final breakthroughCount = results.where((r) => r.hadSignificantUnexpectedOutcomes).length;
      impactData['breakthrough_experiments'] = breakthroughCount;
      
      // Domain impact analysis
      final domainImpact = <String, int>{};
      for (final result in results) {
        // This would be enhanced with actual domain tracking
        domainImpact['general'] = (domainImpact['general'] ?? 0) + 1;
      }
      impactData['domain_impact'] = domainImpact;
      
      // Confidence development
      final confidenceTrend = results.map((r) => r.confidence.name).toList();
      impactData['confidence_trend'] = confidenceTrend;
      
      // Next steps generation
      final allNextSteps = results.expand((r) => r.nextSteps).toSet().toList();
      impactData['consolidated_next_steps'] = allNextSteps.take(10);
      
      return impactData;
    } catch (e, stackTrace) {
      AppLogger.error('Error calculating experiment impact', e, stackTrace);
      return {'error': 'Failed to calculate impact'};
    }
  }

  // ===== PRIVATE HELPER METHODS =====

  Future<CareerExperiment?> _generateVisibilityExperiment(CareerInsight insight) async {
    return CareerExperiment.create(
      title: 'Showcase ${insight.title}',
      description: 'A 30-day experiment to increase visibility and recognition of your ${insight.title.toLowerCase()} capabilities.',
      type: ExperimentType.visibilityBuilding,
      hypothesis: 'By strategically showcasing my ${insight.title.toLowerCase()}, I can increase recognition and create new opportunities.',
      relatedInsightIds: [insight.id],
      scope: ExperimentScope.team,
      estimatedDurationDays: 30,
      successCriteria: [
        'Receive specific feedback about ${insight.title.toLowerCase()} from at least 2 colleagues',
        'Create 1 visible deliverable that demonstrates this strength',
        'Have 1 conversation with manager about leveraging this capability',
      ],
      metrics: [
        ExperimentMetric(
          name: 'Recognition Feedback',
          description: 'Specific comments about ${insight.title.toLowerCase()} capabilities',
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
        'Opportunities to demonstrate ${insight.title.toLowerCase()}',
        'Feedback collection mechanism',
      ],
      potentialBarriers: [
        'Discomfort with self-promotion',
        'Limited opportunities to showcase this skill',
        'Team too busy to provide feedback',
      ],
      priority: insight.isHighQuality ? ExperimentPriority.high : ExperimentPriority.medium,
      tags: ['visibility', 'strength', insight.primaryTheme ?? 'general'],
    );
  }

  Future<CareerExperiment?> _generateSkillBuildingExperiment(CareerInsight insight) async {
    return CareerExperiment.create(
      title: 'Develop ${insight.title}',
      description: 'A focused skill-building experiment to strengthen your ${insight.title.toLowerCase()} capabilities.',
      type: ExperimentType.skillBuilding,
      hypothesis: 'By investing focused effort in ${insight.title.toLowerCase()}, I can make measurable progress in this development area.',
      relatedInsightIds: [insight.id],
      scope: ExperimentScope.personal,
      estimatedDurationDays: 45,
      successCriteria: [
        'Complete at least 2 significant ${insight.title.toLowerCase()} learning activities',
        'Apply new skills in a real work context',
        'Demonstrate improved capability through specific examples',
      ],
      metrics: [
        ExperimentMetric(
          name: 'Learning Activities',
          description: 'Structured learning and practice completed',
          type: MetricType.quantitative,
          measurementMethod: 'Activity log',
          targetValue: '8',
          frequency: MetricFrequency.weekly,
        ),
        ExperimentMetric(
          name: 'Skill Application',
          description: 'Real-world applications of new skills',
          type: MetricType.behavioral,
          measurementMethod: 'Application tracking',
          targetValue: '3',
          frequency: MetricFrequency.biweekly,
        ),
      ],
      requiredResources: [
        'Learning resources (courses, books, workshops)',
        'Practice opportunities',
        'Mentor or colleague for feedback',
      ],
      potentialBarriers: [
        'Time constraints for learning',
        'Limited practice opportunities',
        'Difficulty measuring progress',
      ],
      priority: ExperimentPriority.medium,
      tags: ['skill_building', 'development', insight.primaryTheme ?? 'general'],
    );
  }

  Future<CareerExperiment?> _generateExplorationExperiment(CareerInsight insight) async {
    return CareerExperiment.create(
      title: 'Explore ${insight.title}',
      description: 'A low-risk exploration experiment to test your interest and aptitude in ${insight.title.toLowerCase()}.',
      type: ExperimentType.roleExploration,
      hypothesis: 'By exploring ${insight.title.toLowerCase()} through practical activities, I can better understand its fit with my career direction.',
      relatedInsightIds: [insight.id],
      scope: ExperimentScope.personal,
      estimatedDurationDays: 21,
      successCriteria: [
        'Complete 3 different ${insight.title.toLowerCase()} exploration activities',
        'Reflect on energy levels and satisfaction',
        'Gather feedback on natural aptitude',
      ],
      metrics: [
        ExperimentMetric(
          name: 'Exploration Activities',
          description: 'Different exploration activities completed',
          type: MetricType.quantitative,
          measurementMethod: 'Activity tracking',
          targetValue: '3',
          frequency: MetricFrequency.weekly,
        ),
        ExperimentMetric(
          name: 'Energy Assessment',
          description: 'Daily energy and satisfaction rating',
          type: MetricType.qualitative,
          measurementMethod: 'Daily reflection (1-5 scale)',
          frequency: MetricFrequency.daily,
        ),
      ],
      requiredResources: [
        'Access to ${insight.title.toLowerCase()} activities',
        'Time for exploration (3-4 hours/week)',
        'Reflection framework',
      ],
      potentialBarriers: [
        'Limited access to exploration opportunities',
        'Uncertainty about where to start',
        'Time constraints',
      ],
      priority: ExperimentPriority.medium,
      tags: ['exploration', 'interest', insight.primaryTheme ?? 'general'],
    );
  }

  Future<CareerExperiment?> _generateValueAlignmentExperiment(CareerInsight insight) async {
    return CareerExperiment.create(
      title: 'Align with ${insight.title}',
      description: 'A 30-day experiment to better align your work with your core value of ${insight.title.toLowerCase()}.',
      type: ExperimentType.valueAlignment,
      hypothesis: 'By actively aligning my work activities with my value of ${insight.title.toLowerCase()}, I will experience greater satisfaction and motivation.',
      relatedInsightIds: [insight.id],
      scope: ExperimentScope.team,
      estimatedDurationDays: 30,
      successCriteria: [
        'Identify 3 ways to incorporate ${insight.title.toLowerCase()} into current work',
        'Implement at least 2 value-aligned changes',
        'Report increased satisfaction in weekly check-ins',
      ],
      metrics: [
        ExperimentMetric(
          name: 'Value Alignment Score',
          description: 'Weekly assessment of work-value alignment (1-5 scale)',
          type: MetricType.qualitative,
          measurementMethod: 'Weekly self-assessment',
          frequency: MetricFrequency.weekly,
        ),
        ExperimentMetric(
          name: 'Alignment Actions',
          description: 'Specific actions taken to align with values',
          type: MetricType.behavioral,
          measurementMethod: 'Action tracking',
          targetValue: '6',
          frequency: MetricFrequency.weekly,
        ),
      ],
      requiredResources: [
        'Clarity on how ${insight.title.toLowerCase()} shows up in work',
        'Flexibility to adjust current activities',
        'Support from team/manager',
      ],
      potentialBarriers: [
        'Limited flexibility in current role',
        'Unclear connection between values and work',
        'Competing priorities',
      ],
      priority: ExperimentPriority.high,
      tags: ['values', 'alignment', insight.primaryTheme ?? 'general'],
    );
  }

  Future<CareerExperiment?> _generateNetworkingExperiment(List<CareerInsight> insights) async {
    final networkingThemes = insights
        .where((i) => i.keyThemes.any((t) => ['networking', 'collaboration', 'leadership'].contains(t.toLowerCase())))
        .map((i) => i.title)
        .take(2)
        .join(' and ');

    return CareerExperiment.create(
      title: 'Strategic Networking for $networkingThemes',
      description: 'A 45-day experiment to build strategic professional connections that support your development in $networkingThemes.',
      type: ExperimentType.networking,
      hypothesis: 'By strategically building my professional network, I can create opportunities for growth and learning in my areas of strength and interest.',
      relatedInsightIds: insights.map((i) => i.id).toList(),
      scope: ExperimentScope.external,
      estimatedDurationDays: 45,
      successCriteria: [
        'Connect with 5 new professionals in relevant areas',
        'Have 3 meaningful professional conversations',
        'Identify 2 potential mentoring or collaboration opportunities',
      ],
      metrics: [
        ExperimentMetric(
          name: 'New Connections',
          description: 'Number of new professional connections made',
          type: MetricType.quantitative,
          measurementMethod: 'Connection tracking',
          targetValue: '5',
          frequency: MetricFrequency.weekly,
        ),
        ExperimentMetric(
          name: 'Quality Conversations',
          description: 'Meaningful professional conversations (>20 minutes)',
          type: MetricType.qualitative,
          measurementMethod: 'Conversation log with insights',
          targetValue: '3',
          frequency: MetricFrequency.biweekly,
        ),
      ],
      requiredResources: [
        'Professional networking platforms or events',
        'Time for networking activities (2 hours/week)',
        'Conversation starters and professional introduction',
      ],
      potentialBarriers: [
        'Discomfort with networking activities',
        'Limited access to relevant professionals',
        'Time constraints',
      ],
      priority: ExperimentPriority.medium,
      tags: ['networking', 'professional_development', 'relationship_building'],
    );
  }

  Future<CareerExperiment?> _generateHiddenStrengthExperiment(SynthesisInsight hiddenStrength) async {
    return CareerExperiment.create(
      title: 'Uncover Hidden Strength: ${hiddenStrength.title}',
      description: 'A 21-day experiment to understand and leverage the hidden strength that others see in you.',
      type: ExperimentType.skillBuilding,
      hypothesis: 'By actively seeking feedback and creating visibility around this strength, I can better understand and leverage it.',
      relatedInsightIds: [],
      scope: ExperimentScope.team,
      estimatedDurationDays: 21,
      successCriteria: [
        'Collect specific examples from 3 colleagues about this strength',
        'Identify concrete situations where this strength was demonstrated',
        'Create 1 opportunity to consciously apply this strength',
      ],
      metrics: [
        ExperimentMetric(
          name: 'Feedback Collection',
          description: 'Specific examples and feedback collected',
          type: MetricType.feedback,
          measurementMethod: 'Structured feedback conversations',
          targetValue: '5',
          frequency: MetricFrequency.weekly,
        ),
      ],
      requiredResources: [
        'List of colleagues to approach for feedback',
        'Structured questions about the strength',
        'Time for feedback conversations',
      ],
      potentialBarriers: [
        'Discomfort asking for specific feedback',
        'Difficulty getting detailed examples',
        'Skepticism about the strength',
      ],
      priority: ExperimentPriority.high,
      tags: ['hidden_strength', 'feedback', 'self_awareness'],
    );
  }

  Future<CareerExperiment?> _generateDevelopmentOpportunityExperiment(SynthesisInsight devOpportunity) async {
    return CareerExperiment.create(
      title: 'Develop: ${devOpportunity.title}',
      description: 'A structured development experiment based on synthesis insights about growth opportunities.',
      type: ExperimentType.skillBuilding,
      hypothesis: 'By focusing development effort on this area identified through synthesis, I can create meaningful career progress.',
      relatedInsightIds: [],
      scope: ExperimentScope.personal,
      estimatedDurationDays: 60,
      successCriteria: [
        'Complete structured learning plan for this area',
        'Apply new skills in at least 2 work contexts',
        'Receive feedback on progress from mentor or manager',
      ],
      metrics: [
        ExperimentMetric(
          name: 'Development Activities',
          description: 'Learning and practice activities completed',
          type: MetricType.quantitative,
          measurementMethod: 'Activity log',
          targetValue: '15',
          frequency: MetricFrequency.weekly,
        ),
      ],
      requiredResources: [
        'Development plan and learning resources',
        'Practice opportunities',
        'Mentor or feedback provider',
      ],
      potentialBarriers: [
        'Time constraints',
        'Limited development resources',
        'Unclear development path',
      ],
      priority: ExperimentPriority.high,
      tags: ['development', 'synthesis_based', 'growth'],
    );
  }

  Future<CareerExperiment?> _generateRepositioningExperiment(SynthesisInsight reposition) async {
    return CareerExperiment.create(
      title: 'Reposition: ${reposition.title}',
      description: 'A strategic positioning experiment to better communicate and leverage your capabilities.',
      type: ExperimentType.visibilityBuilding,
      hypothesis: 'By strategically repositioning how I communicate and demonstrate this capability, I can increase recognition and opportunities.',
      relatedInsightIds: [],
      scope: ExperimentScope.organisational,
      estimatedDurationDays: 30,
      successCriteria: [
        'Update professional communications to reflect stronger positioning',
        'Create 2 high-visibility demonstrations of this capability',
        'Receive feedback on enhanced professional brand',
      ],
      metrics: [
        ExperimentMetric(
          name: 'Positioning Actions',
          description: 'Specific positioning and communication updates',
          type: MetricType.behavioral,
          measurementMethod: 'Action tracking',
          targetValue: '8',
          frequency: MetricFrequency.weekly,
        ),
      ],
      requiredResources: [
        'Professional communication templates',
        'High-visibility opportunities',
        'Brand positioning support',
      ],
      potentialBarriers: [
        'Discomfort with self-promotion',
        'Limited high-visibility opportunities',
        'Unclear positioning strategy',
      ],
      priority: ExperimentPriority.medium,
      tags: ['positioning', 'branding', 'visibility'],
    );
  }

  String _buildExperimentSuggestionPrompt(String careerGoal, List<CareerResponse> responses) {
    final buffer = StringBuffer();
    buffer.writeln('CAREER EXPERIMENT SUGGESTION REQUEST');
    buffer.writeln('GOAL: $careerGoal');
    buffer.writeln('');
    buffer.writeln('USER BACKGROUND:');
    for (final response in responses.take(3)) {
      buffer.writeln('${response.domain.displayName}: ${response.response.substring(0, min(100, response.response.length))}...');
    }
    buffer.writeln('');
    buffer.writeln('Generate 3-5 micro-experiments (2-4 weeks each) to help achieve this career goal.');
    return buffer.toString();
  }

  Map<String, dynamic> _transformToExperimentSuggestion(Map<String, dynamic> pathSuggestion) {
    return {
      'title': pathSuggestion['title'] ?? 'Career Exploration',
      'description': pathSuggestion['description'] ?? 'Explore career opportunities',
      'duration_days': 21,
      'type': 'exploration',
      'success_criteria': pathSuggestion['explorationSteps'] ?? ['Explore and learn'],
      'resources_needed': ['Time', 'Research access', 'Network connections'],
    };
  }

  List<Map<String, dynamic>> _generateFallbackAISuggestions(String careerGoal) {
    return [
      {
        'title': 'Industry Research & Networking',
        'description': 'Research professionals and organizations in your target area and make strategic connections',
        'duration_days': 30,
        'type': 'networking',
        'success_criteria': ['Connect with 3 professionals', 'Conduct 2 informational interviews'],
        'resources_needed': ['LinkedIn Premium', 'Professional networking events', 'Research time'],
      },
      {
        'title': 'Skill Gap Analysis & Development',
        'description': 'Identify and begin addressing key skills needed for your career goal',
        'duration_days': 45,
        'type': 'skill_building',
        'success_criteria': ['Complete skill assessment', 'Begin learning plan', 'Apply new skills'],
        'resources_needed': ['Learning resources', 'Practice opportunities', 'Feedback sources'],
      },
      {
        'title': 'Goal Validation Experiment',
        'description': 'Test your assumptions about your career goal through hands-on experience',
        'duration_days': 21,
        'type': 'exploration',
        'success_criteria': ['Shadow professionals', 'Volunteer in target area', 'Reflect on experience'],
        'resources_needed': ['Access to target environment', 'Volunteer opportunities', 'Reflection time'],
      },
    ];
  }

  List<CareerExperiment> _generateFallbackExperiments(String sessionId) {
    AppLogger.warning('Generating fallback experiments for session: $sessionId');
    
    return [
      CareerExperiment.create(
        title: 'Professional Visibility Building',
        description: 'A general experiment to increase your professional visibility and recognition.',
        type: ExperimentType.visibilityBuilding,
        hypothesis: 'By systematically increasing my professional visibility, I can create new opportunities.',
        relatedInsightIds: [],
        scope: ExperimentScope.organisational,
        estimatedDurationDays: 30,
        successCriteria: [
          'Share expertise through 2 different channels',
          'Engage in 3 strategic conversations',
          'Receive recognition for contributions',
        ],
        metrics: [
          ExperimentMetric(
            name: 'Visibility Activities',
            description: 'Actions taken to increase professional visibility',
            type: MetricType.quantitative,
            measurementMethod: 'Activity tracking',
            targetValue: '6',
            frequency: MetricFrequency.weekly,
          ),
        ],
        requiredResources: ['Time', 'Platform for sharing', 'Professional network'],
        potentialBarriers: ['Time constraints', 'Comfort with visibility'],
        priority: ExperimentPriority.medium,
        tags: ['visibility', 'general', 'fallback'],
      ),
    ];
  }

  bool _meetsPriorityFilter(CareerExperiment experiment, ExperimentPriority? filter) {
    if (filter == null) return true;
    return experiment.priority == filter;
  }

  int _getPriorityScore(ExperimentPriority priority) {
    switch (priority) {
      case ExperimentPriority.urgent: return 4;
      case ExperimentPriority.high: return 3;
      case ExperimentPriority.medium: return 2;
      case ExperimentPriority.low: return 1;
    }
  }

  double _calculateStrategicImpact(CareerExperiment experiment) {
    double impact = 0.5; // Base impact
    
    // Higher impact for certain types
    switch (experiment.type) {
      case ExperimentType.visibilityBuilding:
        impact += 0.3;
        break;
      case ExperimentType.skillBuilding:
        impact += 0.2;
        break;
      case ExperimentType.networking:
        impact += 0.25;
        break;
      case ExperimentType.leadershipDevelopment:
        impact += 0.35;
        break;
      default:
        impact += 0.1;
        break;
    }
    
    // Adjust for scope
    switch (experiment.scope) {
      case ExperimentScope.external:
        impact += 0.2;
        break;
      case ExperimentScope.organisational:
        impact += 0.15;
        break;
      case ExperimentScope.team:
        impact += 0.1;
        break;
      case ExperimentScope.personal:
        // No additional impact
        break;
    }
    
    return impact.clamp(0.0, 1.0);
  }

  ExperimentOutcome _determineExperimentOutcome(double successScore, int learningsCount) {
    if (successScore >= 0.8 && learningsCount >= 3) {
      return ExperimentOutcome.successful;
    } else if (successScore >= 0.6 || learningsCount >= 2) {
      return ExperimentOutcome.partiallySuccessful;
    } else if (successScore >= 0.3 || learningsCount >= 1) {
      return ExperimentOutcome.unsuccessful;
    } else {
      return ExperimentOutcome.inconclusive;
    }
  }

  String _generateHypothesisValidation(CareerExperiment experiment, double successScore) {
    if (successScore >= 0.7) {
      return 'The hypothesis "${experiment.hypothesis}" was largely validated through this experiment. The results support the initial assumption and suggest this approach has merit.';
    } else if (successScore >= 0.4) {
      return 'The hypothesis "${experiment.hypothesis}" was partially validated. Some aspects were confirmed while others require further exploration or refinement.';
    } else {
      return 'The hypothesis "${experiment.hypothesis}" was not validated by this experiment. The results suggest alternative approaches or modified assumptions may be needed.';
    }
  }

  Future<List<String>> _generateFutureExperimentIdeas(
    CareerExperiment experiment,
    double successScore,
    List<String> keyLearnings,
  ) async {
    final ideas = <String>[];
    
    if (successScore >= 0.7) {
      ideas.add('Scale up successful ${experiment.type.displayName.toLowerCase()} approach to broader scope');
      ideas.add('Combine this success with complementary ${_suggestComplementaryType(experiment.type)} experiment');
    } else {
      ideas.add('Address barriers identified: ${experiment.potentialBarriers.take(2).join(", ")}');
      ideas.add('Try modified approach with adjusted success criteria');
    }
    
    // Add learning-based ideas
    for (final learning in keyLearnings.take(2)) {
      if (learning.length > 20) {
        ideas.add('Explore deeper: ${learning.substring(0, 50)}...');
      }
    }
    
    return ideas.take(5).toList();
  }

  String _suggestComplementaryType(ExperimentType currentType) {
    switch (currentType) {
      case ExperimentType.visibilityBuilding:
        return 'skill building';
      case ExperimentType.skillBuilding:
        return 'networking';
      case ExperimentType.networking:
        return 'leadership development';
      case ExperimentType.roleExploration:
        return 'skill building';
      default:
        return 'visibility building';
    }
  }

  ResultConfidence _calculateResultConfidence(double successScore, int learningsCount, int metricsCount) {
    double confidence = 0.0;
    
    // Base confidence from success score
    confidence += successScore * 0.4;
    
    // Confidence from learnings
    confidence += min(1.0, learningsCount / 5.0) * 0.3;
    
    // Confidence from metrics
    confidence += min(1.0, metricsCount / 3.0) * 0.3;
    
    if (confidence >= 0.8) return ResultConfidence.high;
    if (confidence >= 0.6) return ResultConfidence.medium;
    return ResultConfidence.low;
  }

  Future<CareerExperiment?> _generateBuildOnSuccessExperiment(ExperimentResult result) async {
    // This would analyze the successful result and create a follow-up experiment
    return null; // Placeholder for now
  }

  Future<CareerExperiment?> _generateAddressFailureExperiment(ExperimentResult result) async {
    // This would analyze the unsuccessful result and create an experiment to address issues
    return null; // Placeholder for now
  }

  Future<CareerExperiment?> _generateExperimentFromIdea(String idea, String sessionId) async {
    // This would convert a future experiment idea into a concrete experiment
    return null; // Placeholder for now
  }
}