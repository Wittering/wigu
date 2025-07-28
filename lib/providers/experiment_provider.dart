import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/career_experiment.dart';
import '../models/experiment_result.dart';
import '../models/career_insight.dart';
import '../models/career_synthesis.dart';
import '../models/five_insights_model.dart';
import '../services/experiment_service.dart';
import '../services/career_ai_service.dart';
import '../services/career_synthesis_engine.dart';
import '../services/career_persistence_service.dart';
import '../utils/logger.dart';

/// Provider for managing career micro-experiments
/// Handles experiment generation, tracking, and completion workflows
class ExperimentProvider extends ChangeNotifier {
  final ExperimentService _experimentService;
  
  // Current state
  List<CareerExperiment> _experiments = [];
  List<ExperimentResult> _results = [];
  CareerExperiment? _activeExperiment;
  String? _currentSessionId;
  
  // UI state
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _errorMessage;
  
  // Filters and preferences
  ExperimentPriority? _priorityFilter;
  ExperimentType? _typeFilter;
  ExperimentStatus? _statusFilter;
  
  // Progress tracking
  Map<String, Map<String, dynamic>> _experimentProgress = {};
  Map<String, List<String>> _experimentNotes = {};

  ExperimentProvider({
    required ExperimentService experimentService,
  }) : _experimentService = experimentService {
    _initialize();
  }

  // Getters
  List<CareerExperiment> get experiments => List.unmodifiable(_experiments);
  List<ExperimentResult> get results => List.unmodifiable(_results);
  CareerExperiment? get activeExperiment => _activeExperiment;
  String? get currentSessionId => _currentSessionId;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  String? get errorMessage => _errorMessage;
  
  // Filters
  ExperimentPriority? get priorityFilter => _priorityFilter;
  ExperimentType? get typeFilter => _typeFilter;
  ExperimentStatus? get statusFilter => _statusFilter;

  /// Get filtered experiments based on current filters
  List<CareerExperiment> get filteredExperiments {
    var filtered = _experiments.toList();
    
    if (_priorityFilter != null) {
      filtered = filtered.where((e) => e.priority == _priorityFilter).toList();
    }
    
    if (_typeFilter != null) {
      filtered = filtered.where((e) => e.type == _typeFilter).toList();
    }
    
    if (_statusFilter != null) {
      filtered = filtered.where((e) => e.status == _statusFilter).toList();
    }
    
    return filtered;
  }

  /// Get experiments by status
  List<CareerExperiment> get plannedExperiments => 
      _experiments.where((e) => e.status == ExperimentStatus.planned).toList();
  
  List<CareerExperiment> get activeExperiments => 
      _experiments.where((e) => e.status == ExperimentStatus.active).toList();
  
  List<CareerExperiment> get completedExperiments => 
      _experiments.where((e) => e.status == ExperimentStatus.completed).toList();

  /// Get experiment statistics
  Map<String, dynamic> get experimentStats {
    final total = _experiments.length;
    final completed = completedExperiments.length;
    final active = activeExperiments.length;
    final planned = plannedExperiments.length;
    
    final successfulResults = _results.where((r) => r.wasSuccessful).length;
    final successRate = _results.isEmpty ? 0.0 : successfulResults / _results.length;
    
    return {
      'total': total,
      'completed': completed,
      'active': active,
      'planned': planned,
      'success_rate': successRate,
      'total_learnings': _results.fold<int>(0, (sum, r) => sum + r.keyLearnings.length),
    };
  }

  /// Initialize the provider
  Future<void> _initialize() async {
    try {
      AppLogger.info('Initializing ExperimentProvider');
      // Load experiments and results when session is available
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize ExperimentProvider', e, stackTrace);
      _setError('Failed to initialize experiment system');
    }
  }

  /// Load experiments for a session
  Future<void> loadExperimentsForSession(String sessionId) async {
    try {
      _setLoading(true);
      _clearError();
      _currentSessionId = sessionId;
      
      final experiments = await _experimentService.getExperimentsForSession(sessionId);
      final results = await _experimentService.getExperimentResults(sessionId);
      
      _experiments = experiments;
      _results = results;
      
      // Load progress data
      await _loadExperimentProgress();
      
      AppLogger.info('Loaded ${experiments.length} experiments and ${results.length} results for session: $sessionId');
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load experiments for session', e, stackTrace);
      _setError('Failed to load experiments');
    } finally {
      _setLoading(false);
    }
  }

  /// Generate personalized experiments based on insights
  Future<void> generatePersonalizedExperiments({
    required List<CareerInsight> insights,
    int maxExperiments = 5,
  }) async {
    if (_currentSessionId == null) {
      _setError('No active session. Please load a session first.');
      return;
    }

    try {
      _setGenerating(true);
      _clearError();
      
      final newExperiments = await _experimentService.generatePersonalizedExperiments(
        insights: insights,
        sessionId: _currentSessionId!,
        maxExperiments: maxExperiments,
        priorityFilter: _priorityFilter,
      );
      
      _experiments.addAll(newExperiments);
      
      AppLogger.info('Generated ${newExperiments.length} personalized experiments');
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to generate personalized experiments', e, stackTrace);
      _setError('Failed to generate experiments');
    } finally {
      _setGenerating(false);
    }
  }

  /// Generate experiments based on synthesis results
  Future<void> generateSynthesisBasedExperiments({
    required CareerSynthesis synthesis,
    FiveInsightsModel? fiveInsights,
    int maxExperiments = 3,
  }) async {
    try {
      _setGenerating(true);
      _clearError();
      
      final newExperiments = await _experimentService.generateSynthesisBasedExperiments(
        synthesis: synthesis,
        fiveInsights: fiveInsights,
        maxExperiments: maxExperiments,
      );
      
      _experiments.addAll(newExperiments);
      
      AppLogger.info('Generated ${newExperiments.length} synthesis-based experiments');
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to generate synthesis-based experiments', e, stackTrace);
      _setError('Failed to generate synthesis experiments');
    } finally {
      _setGenerating(false);
    }
  }

  /// Generate AI experiment suggestions
  Future<List<Map<String, dynamic>>> generateAIExperimentSuggestions({
    required String careerGoal,
    required List<dynamic> userResponses, // CareerResponse objects
  }) async {
    if (_currentSessionId == null) {
      _setError('No active session available');
      return [];
    }

    try {
      _setGenerating(true);
      _clearError();
      
      final suggestions = await _experimentService.generateAIExperimentSuggestions(
        careerGoal: careerGoal,
        userResponses: userResponses.cast(), // Cast to proper type
        sessionId: _currentSessionId!,
      );
      
      AppLogger.info('Generated ${suggestions.length} AI experiment suggestions');
      return suggestions;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to generate AI experiment suggestions', e, stackTrace);
      _setError('Failed to generate AI suggestions');
      return [];
    } finally {
      _setGenerating(false);
    }
  }

  /// Start an experiment
  Future<void> startExperiment(String experimentId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final experimentIndex = _experiments.indexWhere((e) => e.id == experimentId);
      if (experimentIndex == -1) {
        throw Exception('Experiment not found: $experimentId');
      }
      
      final experiment = _experiments[experimentIndex];
      final startedExperiment = await _experimentService.startExperiment(experiment);
      
      _experiments[experimentIndex] = startedExperiment;
      _activeExperiment = startedExperiment;
      
      // Initialize progress tracking
      _experimentProgress[experimentId] = {
        'started_at': DateTime.now().toIso8601String(),
        'progress_percentage': 0.0,
        'milestones_completed': <String>[],
      };
      _experimentNotes[experimentId] = [];
      
      AppLogger.info('Started experiment: ${startedExperiment.title}');
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to start experiment', e, stackTrace);
      _setError('Failed to start experiment');
    } finally {
      _setLoading(false);
    }
  }

  /// Update experiment progress
  Future<void> updateExperimentProgress({
    required String experimentId,
    double? progressPercentage,
    List<String>? milestonesCompleted,
    List<String>? notes,
  }) async {
    try {
      _clearError();
      
      final progressData = <String, dynamic>{};
      if (progressPercentage != null) {
        progressData['progress_percentage'] = progressPercentage;
      }
      if (milestonesCompleted != null) {
        progressData['milestones_completed'] = milestonesCompleted;
      }
      
      final updatedExperiment = await _experimentService.updateExperimentProgress(
        experimentId: experimentId,
        progressData: progressData,
        notes: notes,
      );
      
      // Update local state
      final experimentIndex = _experiments.indexWhere((e) => e.id == experimentId);
      if (experimentIndex != -1) {
        _experiments[experimentIndex] = updatedExperiment;
      }
      
      // Update progress tracking
      final currentProgress = _experimentProgress[experimentId] ?? {};
      if (progressPercentage != null) {
        currentProgress['progress_percentage'] = progressPercentage;
      }
      if (milestonesCompleted != null) {
        currentProgress['milestones_completed'] = milestonesCompleted;
      }
      currentProgress['last_updated'] = DateTime.now().toIso8601String();
      _experimentProgress[experimentId] = currentProgress;
      
      // Add notes
      if (notes != null) {
        _experimentNotes[experimentId] = [
          ...(_experimentNotes[experimentId] ?? []),
          ...notes,
        ];
      }
      
      AppLogger.info('Updated progress for experiment: $experimentId');
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update experiment progress', e, stackTrace);
      _setError('Failed to update progress');
    }
  }

  /// Complete an experiment with results
  Future<void> completeExperiment({
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
    try {
      _setLoading(true);
      _clearError();
      
      final result = await _experimentService.completeExperiment(
        experimentId: experimentId,
        successScore: successScore,
        executiveSummary: executiveSummary,
        keyLearnings: keyLearnings,
        challengesFaced: challengesFaced,
        successFactors: successFactors,
        nextSteps: nextSteps,
        unexpectedOutcomes: unexpectedOutcomes,
        metricResults: metricResults,
        personalReflection: personalReflection,
        stakeholderFeedback: stakeholderFeedback,
      );
      
      // Update experiment status
      final experimentIndex = _experiments.indexWhere((e) => e.id == experimentId);
      if (experimentIndex != -1) {
        _experiments[experimentIndex] = _experiments[experimentIndex].complete();
      }
      
      // Add result to collection
      _results.add(result);
      
      // Clear active experiment if this was it
      if (_activeExperiment?.id == experimentId) {
        _activeExperiment = null;
      }
      
      // Update progress to 100%
      final currentProgress = _experimentProgress[experimentId] ?? {};
      currentProgress['progress_percentage'] = 1.0;
      currentProgress['completed_at'] = DateTime.now().toIso8601String();
      _experimentProgress[experimentId] = currentProgress;
      
      AppLogger.info('Completed experiment: $experimentId with success score: $successScore');
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to complete experiment', e, stackTrace);
      _setError('Failed to complete experiment');
    } finally {
      _setLoading(false);
    }
  }

  /// Generate follow-up experiments based on completed results
  Future<void> generateFollowUpExperiments({int maxSuggestions = 3}) async {
    if (_currentSessionId == null) {
      _setError('No active session available');
      return;
    }

    try {
      _setGenerating(true);
      _clearError();
      
      final followUpExperiments = await _experimentService.generateFollowUpExperiments(
        completedResults: _results,
        sessionId: _currentSessionId!,
        maxSuggestions: maxSuggestions,
      );
      
      _experiments.addAll(followUpExperiments);
      
      AppLogger.info('Generated ${followUpExperiments.length} follow-up experiments');
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to generate follow-up experiments', e, stackTrace);
      _setError('Failed to generate follow-up experiments');
    } finally {
      _setGenerating(false);
    }
  }

  /// Get experiment impact analysis
  Map<String, dynamic> getExperimentImpact({
    required List<dynamic> initialInsights, // CareerInsight objects
  }) {
    try {
      return _experimentService.calculateExperimentImpact(
        results: _results,
        initialInsights: initialInsights.cast(), // Cast to proper type
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to calculate experiment impact', e, stackTrace);
      return {'error': 'Failed to calculate impact'};
    }
  }

  /// Pause an active experiment
  Future<void> pauseExperiment(String experimentId) async {
    try {
      _clearError();
      
      final experimentIndex = _experiments.indexWhere((e) => e.id == experimentId);
      if (experimentIndex == -1) {
        throw Exception('Experiment not found: $experimentId');
      }
      
      _experiments[experimentIndex] = _experiments[experimentIndex].pause();
      
      if (_activeExperiment?.id == experimentId) {
        _activeExperiment = _experiments[experimentIndex];
      }
      
      AppLogger.info('Paused experiment: $experimentId');
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to pause experiment', e, stackTrace);
      _setError('Failed to pause experiment');
    }
  }

  /// Cancel an experiment
  Future<void> cancelExperiment(String experimentId) async {
    try {
      _clearError();
      
      final experimentIndex = _experiments.indexWhere((e) => e.id == experimentId);
      if (experimentIndex == -1) {
        throw Exception('Experiment not found: $experimentId');
      }
      
      _experiments[experimentIndex] = _experiments[experimentIndex].cancel();
      
      if (_activeExperiment?.id == experimentId) {
        _activeExperiment = null;
      }
      
      AppLogger.info('Cancelled experiment: $experimentId');
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to cancel experiment', e, stackTrace);
      _setError('Failed to cancel experiment');
    }
  }

  /// Get experiment progress data
  Map<String, dynamic>? getExperimentProgress(String experimentId) {
    return _experimentProgress[experimentId];
  }

  /// Get experiment notes
  List<String> getExperimentNotes(String experimentId) {
    return _experimentNotes[experimentId] ?? [];
  }

  /// Set filters
  void setPriorityFilter(ExperimentPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void setTypeFilter(ExperimentType? type) {
    _typeFilter = type;
    notifyListeners();
  }

  void setStatusFilter(ExperimentStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _priorityFilter = null;
    _typeFilter = null;
    _statusFilter = null;
    notifyListeners();
  }

  /// Get experiment by ID
  CareerExperiment? getExperiment(String experimentId) {
    try {
      return _experiments.firstWhere((e) => e.id == experimentId);
    } catch (e) {
      return null;
    }
  }

  /// Get result by experiment ID
  ExperimentResult? getResult(String experimentId) {
    try {
      return _results.firstWhere((r) => r.experimentId == experimentId);
    } catch (e) {
      return null;
    }
  }

  /// Load experiment progress from storage
  Future<void> _loadExperimentProgress() async {
    // This would load progress data from persistence
    // For now, initialize empty progress tracking
    _experimentProgress.clear();
    _experimentNotes.clear();
    
    for (final experiment in _experiments) {
      if (experiment.status == ExperimentStatus.active || 
          experiment.status == ExperimentStatus.paused) {
        _experimentProgress[experiment.id] = {
          'started_at': experiment.startedAt?.toIso8601String(),
          'progress_percentage': 0.5, // Default mid-progress
          'milestones_completed': <String>[],
          'last_updated': DateTime.now().toIso8601String(),
        };
        _experimentNotes[experiment.id] = [];
      }
    }
  }

  /// Set active experiment
  void setActiveExperiment(String? experimentId) {
    if (experimentId == null) {
      _activeExperiment = null;
    } else {
      _activeExperiment = getExperiment(experimentId);
    }
    notifyListeners();
  }

  /// Utility methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setGenerating(bool generating) {
    _isGenerating = generating;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    if (error != null) {
      AppLogger.warning('ExperimentProvider error: $error');
    }
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    AppLogger.debug('Disposing ExperimentProvider');
    super.dispose();
  }
}

// Riverpod providers for ExperimentProvider
final experimentServiceProvider = Provider<ExperimentService>((ref) {
  final aiService = CareerAIService();
  final synthesisEngine = CareerSynthesisEngine(aiService: aiService);
  final persistenceService = ref.read(careerPersistenceServiceProvider);
  
  return ExperimentService(
    aiService: aiService,
    synthesisEngine: synthesisEngine,
    persistenceService: persistenceService,
  );
});

final experimentProvider = ChangeNotifierProvider<ExperimentProvider>((ref) {
  final experimentService = ref.read(experimentServiceProvider);
  return ExperimentProvider(experimentService: experimentService);
});

// Additional providers for specific data
final experimentsForSessionProvider = FutureProvider.family<List<CareerExperiment>, String>((ref, sessionId) async {
  final experimentService = ref.read(experimentServiceProvider);
  return experimentService.getExperimentsForSession(sessionId);
});

final experimentResultsProvider = FutureProvider.family<List<ExperimentResult>, String>((ref, sessionId) async {
  final experimentService = ref.read(experimentServiceProvider);
  return experimentService.getExperimentResults(sessionId);
});

final experimentStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final experimentNotifier = ref.watch(experimentProvider);
  return experimentNotifier.experimentStats;
});