import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import '../models/career_session.dart';
import '../models/career_response.dart';
import '../models/career_insight.dart';
import '../models/career_experiment.dart';
import '../models/experiment_result.dart';

/// Service for persisting career exploration data locally
/// Adapted from AI_assess persistence service for career-specific data
class CareerPersistenceService {
  static const String _careerSessionBoxName = 'career_sessions';
  static const String _currentSessionKey = 'current_career_session'; 
  static const String _settingsBoxName = 'career_settings';
  static const String _experimentsBoxName = 'career_experiments';
  static const String _experimentResultsBoxName = 'experiment_results';
  
  late Box<CareerSession> _careerSessionBox;
  late Box<String> _settingsBox;
  late Box<CareerExperiment> _experimentsBox;
  late Box<ExperimentResult> _experimentResultsBox;
  final Logger _logger = Logger();

  /// Initialise the persistence service with proper error handling
  Future<void> initialise() async {
    try {
      await Hive.initFlutter();
      
      // Register Hive adapters for career data models
      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(CareerSessionAdapter());
      }
      if (!Hive.isAdapterRegistered(11)) {
        Hive.registerAdapter(CareerResponseAdapter());
      }
      if (!Hive.isAdapterRegistered(12)) {
        Hive.registerAdapter(CareerInsightAdapter());
      }
      if (!Hive.isAdapterRegistered(13)) {
        Hive.registerAdapter(CareerDomainAdapter());
      }
      if (!Hive.isAdapterRegistered(14)) {
        Hive.registerAdapter(ExplorationTypeAdapter());
      }
      
      // Register experiment-related adapters
      if (!Hive.isAdapterRegistered(50)) {
        Hive.registerAdapter(CareerExperimentAdapter());
      }
      if (!Hive.isAdapterRegistered(51)) {
        Hive.registerAdapter(ExperimentMetricAdapter());
      }
      if (!Hive.isAdapterRegistered(52)) {
        Hive.registerAdapter(ExperimentTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(53)) {
        Hive.registerAdapter(ExperimentStatusAdapter());
      }
      if (!Hive.isAdapterRegistered(54)) {
        Hive.registerAdapter(ExperimentScopeAdapter());
      }
      if (!Hive.isAdapterRegistered(55)) {
        Hive.registerAdapter(ExperimentPriorityAdapter());
      }
      if (!Hive.isAdapterRegistered(56)) {
        Hive.registerAdapter(ExperimentComplexityAdapter());
      }
      if (!Hive.isAdapterRegistered(57)) {
        Hive.registerAdapter(MetricTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(58)) {
        Hive.registerAdapter(MetricFrequencyAdapter());
      }
      if (!Hive.isAdapterRegistered(60)) {
        Hive.registerAdapter(ExperimentResultAdapter());
      }
      if (!Hive.isAdapterRegistered(61)) {
        Hive.registerAdapter(MetricResultAdapter());
      }
      if (!Hive.isAdapterRegistered(62)) {
        Hive.registerAdapter(ExperimentOutcomeAdapter());
      }
      if (!Hive.isAdapterRegistered(63)) {
        Hive.registerAdapter(ResultConfidenceAdapter());
      }
      if (!Hive.isAdapterRegistered(64)) {
        Hive.registerAdapter(ResultRatingAdapter());
      }
      if (!Hive.isAdapterRegistered(65)) {
        Hive.registerAdapter(MetricResultTypeAdapter());
      }

      // Open storage boxes
      _careerSessionBox = await Hive.openBox<CareerSession>(_careerSessionBoxName);
      _settingsBox = await Hive.openBox<String>(_settingsBoxName);
      _experimentsBox = await Hive.openBox<CareerExperiment>(_experimentsBoxName);
      _experimentResultsBox = await Hive.openBox<ExperimentResult>(_experimentResultsBoxName);
      
      _logger.i('Career persistence service initialised successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialise career persistence service', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Create a new career exploration session
  Future<String> createNewCareerSession({String? name}) async {
    try {
      final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      final session = CareerSession(
        id: sessionId,
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
        responses: {},
        insights: [],
        sessionName: name ?? 'Career Exploration ${DateTime.now().toString().split(' ')[0]}',
        completedDomains: [],
        preferredExplorationType: ExplorationType.reflective,
      );

      await _careerSessionBox.put(sessionId, session);
      await _settingsBox.put(_currentSessionKey, sessionId);
      
      _logger.i('Created new career session: $sessionId');
      return sessionId;
    } catch (e, stackTrace) {
      _logger.e('Failed to create new career session', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Save a career response to the current session
  Future<void> saveCareerResponse({
    required String sessionId,
    required String questionId,
    required String questionText,
    required String response,
    required CareerDomain domain,
  }) async {
    try {
      final session = _careerSessionBox.get(sessionId);
      if (session == null) {
        _logger.w('Attempted to save response to non-existent session: $sessionId');
        return;
      }

      final careerResponse = CareerResponse(
        questionId: questionId,
        questionText: questionText,
        response: response,
        answeredAt: DateTime.now(),
        domain: domain,
      );

      final updatedResponses = Map<String, CareerResponse>.from(session.responses);
      updatedResponses[questionId] = careerResponse;

      final updatedSession = session.copyWith(
        responses: updatedResponses,
        lastModified: DateTime.now(),
      );

      await _careerSessionBox.put(sessionId, updatedSession);
      _logger.d('Saved career response for question: $questionId');
    } catch (e, stackTrace) {
      _logger.e('Failed to save career response', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Save a career insight generated from responses
  Future<void> saveCareerInsight({
    required String sessionId,
    required CareerInsight insight,
  }) async {
    try {
      final session = _careerSessionBox.get(sessionId);
      if (session == null) {
        _logger.w('Attempted to save insight to non-existent session: $sessionId');
        return;
      }

      final updatedInsights = List<CareerInsight>.from(session.insights);
      
      // Check if insight already exists and update it
      final existingIndex = updatedInsights.indexWhere(
        (existing) => existing.id == insight.id,
      );

      if (existingIndex >= 0) {
        updatedInsights[existingIndex] = insight;
      } else {
        updatedInsights.add(insight);
      }

      final updatedSession = session.copyWith(
        insights: updatedInsights,
        lastModified: DateTime.now(),
      );

      await _careerSessionBox.put(sessionId, updatedSession);
      _logger.d('Saved career insight: ${insight.id}');
    } catch (e, stackTrace) {
      _logger.e('Failed to save career insight', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Mark a career domain as completed
  Future<void> markDomainCompleted({
    required String sessionId,
    required CareerDomain domain,
  }) async {
    try {
      final session = _careerSessionBox.get(sessionId);
      if (session == null) {
        _logger.w('Attempted to mark domain completed in non-existent session: $sessionId');
        return;
      }

      final updatedCompletedDomains = List<CareerDomain>.from(session.completedDomains);
      
      if (!updatedCompletedDomains.contains(domain)) {
        updatedCompletedDomains.add(domain);
      }

      final updatedSession = session.copyWith(
        completedDomains: updatedCompletedDomains,
        lastModified: DateTime.now(),
      );

      await _careerSessionBox.put(sessionId, updatedSession);
      _logger.d('Marked domain completed: ${domain.name}');
    } catch (e, stackTrace) {
      _logger.e('Failed to mark domain completed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get the current career session
  CareerSession? getCurrentCareerSession() {
    try {
      final currentSessionId = _settingsBox.get(_currentSessionKey);
      if (currentSessionId == null) return null;
      
      return _careerSessionBox.get(currentSessionId);
    } catch (e, stackTrace) {
      _logger.e('Failed to get current career session', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Get the current session ID
  String? getCurrentSessionId() {
    try {
      return _settingsBox.get(_currentSessionKey);
    } catch (e, stackTrace) {
      _logger.e('Failed to get current session ID', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Set the current active session
  Future<void> setCurrentSession(String sessionId) async {
    try {
      await _settingsBox.put(_currentSessionKey, sessionId);
      _logger.d('Set current session: $sessionId');
    } catch (e, stackTrace) {
      _logger.e('Failed to set current session', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get all career sessions, sorted by last modified
  List<CareerSession> getAllCareerSessions() {
    try {
      return _careerSessionBox.values.toList()
        ..sort((a, b) => b.lastModified.compareTo(a.lastModified));
    } catch (e, stackTrace) {
      _logger.e('Failed to get all career sessions', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Get all sessions (alias for compatibility)
  Future<List<CareerSession>> getAllSessions() async {
    return getAllCareerSessions();
  }

  /// Save a career session
  Future<void> saveSession(CareerSession session) async {
    try {
      await _careerSessionBox.put(session.id, session);
      _logger.d('Saved career session: ${session.id}');
    } catch (e, stackTrace) {
      _logger.e('Failed to save career session', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get a specific session by ID
  Future<CareerSession?> getSession(String sessionId) async {
    try {
      return _careerSessionBox.get(sessionId);
    } catch (e, stackTrace) {
      _logger.e('Failed to get session', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Delete a session (alias for compatibility)
  Future<void> deleteSession(String sessionId) async {
    return deleteCareerSession(sessionId);
  }

  /// Delete a career session
  Future<void> deleteCareerSession(String sessionId) async {
    try {
      await _careerSessionBox.delete(sessionId);
      
      // Clear current session if it was the deleted one
      final currentSessionId = _settingsBox.get(_currentSessionKey);
      if (currentSessionId == sessionId) {
        await _settingsBox.delete(_currentSessionKey);
      }
      
      _logger.i('Deleted career session: $sessionId');
    } catch (e, stackTrace) {
      _logger.e('Failed to delete career session', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Rename a career session
  Future<void> renameCareerSession(String sessionId, String newName) async {
    try {
      final session = _careerSessionBox.get(sessionId);
      if (session == null) {
        _logger.w('Attempted to rename non-existent session: $sessionId');
        return;
      }

      final updatedSession = session.copyWith(
        sessionName: newName,
        lastModified: DateTime.now(),
      );

      await _careerSessionBox.put(sessionId, updatedSession);
      _logger.d('Renamed session $sessionId to: $newName');
    } catch (e, stackTrace) {
      _logger.e('Failed to rename career session', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Restore career responses for a session
  Future<Map<String, String>> restoreCareerResponses(String sessionId) async {
    try {
      final session = _careerSessionBox.get(sessionId);
      if (session == null) return {};

      final responses = <String, String>{};
      for (final entry in session.responses.entries) {
        responses[entry.key] = entry.value.response;
      }
      
      _logger.d('Restored ${responses.length} responses for session: $sessionId');
      return responses;
    } catch (e, stackTrace) {
      _logger.e('Failed to restore career responses', error: e, stackTrace: stackTrace);
      return {};
    }
  }

  /// Get insights for a specific career domain
  List<CareerInsight> getInsightsForDomain(String sessionId, CareerDomain domain) {
    try {
      final session = _careerSessionBox.get(sessionId);
      if (session == null) return [];

      return session.insights
          .where((insight) => insight.domain == domain)
          .toList();
    } catch (e, stackTrace) {
      _logger.e('Failed to get insights for domain', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Update session exploration type preference
  Future<void> updateExplorationType({
    required String sessionId,
    required ExplorationType explorationType,
  }) async {
    try {
      final session = _careerSessionBox.get(sessionId);
      if (session == null) {
        _logger.w('Attempted to update exploration type for non-existent session: $sessionId');
        return;
      }

      final updatedSession = session.copyWith(
        preferredExplorationType: explorationType,
        lastModified: DateTime.now(),
      );

      await _careerSessionBox.put(sessionId, updatedSession);
      _logger.d('Updated exploration type to: ${explorationType.name}');
    } catch (e, stackTrace) {
      _logger.e('Failed to update exploration type', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Export session data as JSON for backup/sharing
  Future<Map<String, dynamic>> exportSessionData(String sessionId) async {
    try {
      final session = _careerSessionBox.get(sessionId);
      if (session == null) {
        throw Exception('Session not found: $sessionId');
      }

      return session.toJson();
    } catch (e, stackTrace) {
      _logger.e('Failed to export session data', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Clear all career data (use with caution)
  Future<void> clearAllData() async {
    try {
      await _careerSessionBox.clear();
      await _settingsBox.clear();
      _logger.w('Cleared all career data');
    } catch (e, stackTrace) {
      _logger.e('Failed to clear all data', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // ===== EXPERIMENT PERSISTENCE METHODS =====

  /// Save a career experiment
  Future<void> saveExperiment(CareerExperiment experiment) async {
    try {
      await _experimentsBox.put(experiment.id, experiment);
      _logger.d('Saved career experiment: ${experiment.id}');
    } catch (e, stackTrace) {
      _logger.e('Failed to save career experiment', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get a specific experiment by ID
  Future<CareerExperiment?> getExperiment(String experimentId) async {
    try {
      return _experimentsBox.get(experimentId);
    } catch (e, stackTrace) {
      _logger.e('Failed to get experiment', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Get all experiments for a specific session
  Future<List<CareerExperiment>> getExperimentsBySession(String sessionId) async {
    try {
      return _experimentsBox.values
          .where((experiment) => experiment.sessionId == sessionId)
          .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e, stackTrace) {
      _logger.e('Failed to get experiments by session', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Get all experiments
  Future<List<CareerExperiment>> getAllExperiments() async {
    try {
      return _experimentsBox.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e, stackTrace) {
      _logger.e('Failed to get all experiments', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Delete an experiment
  Future<void> deleteExperiment(String experimentId) async {
    try {
      await _experimentsBox.delete(experimentId);
      _logger.i('Deleted experiment: $experimentId');
    } catch (e, stackTrace) {
      _logger.e('Failed to delete experiment', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get experiments by status
  Future<List<CareerExperiment>> getExperimentsByStatus(ExperimentStatus status) async {
    try {
      return _experimentsBox.values
          .where((experiment) => experiment.status == status)
          .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e, stackTrace) {
      _logger.e('Failed to get experiments by status', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Get experiments by priority
  Future<List<CareerExperiment>> getExperimentsByPriority(ExperimentPriority priority) async {
    try {
      return _experimentsBox.values
          .where((experiment) => experiment.priority == priority)
          .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e, stackTrace) {
      _logger.e('Failed to get experiments by priority', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Save an experiment result
  Future<void> saveExperimentResult(ExperimentResult result) async {
    try {
      await _experimentResultsBox.put(result.id, result);
      _logger.d('Saved experiment result: ${result.id}');
    } catch (e, stackTrace) {
      _logger.e('Failed to save experiment result', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get a specific experiment result by ID
  Future<ExperimentResult?> getExperimentResult(String resultId) async {
    try {
      return _experimentResultsBox.get(resultId);
    } catch (e, stackTrace) {
      _logger.e('Failed to get experiment result', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Get experiment result by experiment ID
  Future<ExperimentResult?> getExperimentResultByExperimentId(String experimentId) async {
    try {
      return _experimentResultsBox.values
          .firstWhere((result) => result.experimentId == experimentId);
    } catch (e, stackTrace) {
      _logger.e('Failed to get experiment result by experiment ID', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Get all experiment results for a specific session
  Future<List<ExperimentResult>> getExperimentResultsBySession(String sessionId) async {
    try {
      // First get all experiments for the session, then find their results
      final sessionExperiments = await getExperimentsBySession(sessionId);
      final sessionExperimentIds = sessionExperiments.map((e) => e.id).toSet();
      
      return _experimentResultsBox.values
          .where((result) => sessionExperimentIds.contains(result.experimentId))
          .toList()
          ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    } catch (e, stackTrace) {
      _logger.e('Failed to get experiment results by session', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Get all experiment results
  Future<List<ExperimentResult>> getAllExperimentResults() async {
    try {
      return _experimentResultsBox.values.toList()
        ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    } catch (e, stackTrace) {
      _logger.e('Failed to get all experiment results', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Delete an experiment result
  Future<void> deleteExperimentResult(String resultId) async {
    try {
      await _experimentResultsBox.delete(resultId);
      _logger.i('Deleted experiment result: $resultId');
    } catch (e, stackTrace) {
      _logger.e('Failed to delete experiment result', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Delete all experiments and results for a session
  Future<void> deleteExperimentsForSession(String sessionId) async {
    try {
      // Get all experiments for the session
      final sessionExperiments = await getExperimentsBySession(sessionId);
      final sessionExperimentIds = sessionExperiments.map((e) => e.id).toList();
      
      // Delete all experiments for the session
      for (final experimentId in sessionExperimentIds) {
        await _experimentsBox.delete(experimentId);
      }
      
      // Delete all results for these experiments
      final resultsToDelete = _experimentResultsBox.values
          .where((result) => sessionExperimentIds.contains(result.experimentId))
          .map((result) => result.id)
          .toList();
      
      for (final resultId in resultsToDelete) {
        await _experimentResultsBox.delete(resultId);
      }
      
      _logger.i('Deleted ${sessionExperimentIds.length} experiments and ${resultsToDelete.length} results for session: $sessionId');
    } catch (e, stackTrace) {
      _logger.e('Failed to delete experiments for session', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Export experiment data for a session
  Future<Map<String, dynamic>> exportExperimentData(String sessionId) async {
    try {
      final experiments = await getExperimentsBySession(sessionId);
      final results = await getExperimentResultsBySession(sessionId);
      
      return {
        'session_id': sessionId,
        'export_timestamp': DateTime.now().toIso8601String(),
        'experiments': experiments.map((e) => e.toJson()).toList(),
        'results': results.map((r) => r.toJson()).toList(),
        'summary': {
          'total_experiments': experiments.length,
          'completed_experiments': experiments.where((e) => e.status == ExperimentStatus.completed).length,
          'total_results': results.length,
          'successful_results': results.where((r) => r.wasSuccessful).length,
        },
      };
    } catch (e, stackTrace) {
      _logger.e('Failed to export experiment data', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get experiment statistics
  Future<Map<String, dynamic>> getExperimentStatistics() async {
    try {
      final allExperiments = await getAllExperiments();
      final allResults = await getAllExperimentResults();
      
      final plannedCount = allExperiments.where((e) => e.status == ExperimentStatus.planned).length;
      final activeCount = allExperiments.where((e) => e.status == ExperimentStatus.active).length;
      final completedCount = allExperiments.where((e) => e.status == ExperimentStatus.completed).length;
      final cancelledCount = allExperiments.where((e) => e.status == ExperimentStatus.cancelled).length;
      
      final successfulResults = allResults.where((r) => r.wasSuccessful).length;
      final successRate = allResults.isEmpty ? 0.0 : successfulResults / allResults.length;
      
      final totalLearnings = allResults.fold<int>(0, (sum, r) => sum + r.keyLearnings.length);
      final avgLearningsPerExperiment = allResults.isEmpty ? 0.0 : totalLearnings / allResults.length;
      
      return {
        'total_experiments': allExperiments.length,
        'status_breakdown': {
          'planned': plannedCount,
          'active': activeCount,
          'completed': completedCount,
          'cancelled': cancelledCount,
        },
        'results_summary': {
          'total_results': allResults.length,
          'successful_results': successfulResults,
          'success_rate': successRate,
          'total_learnings': totalLearnings,
          'avg_learnings_per_experiment': avgLearningsPerExperiment,
        },
        'type_distribution': _calculateTypeDistribution(allExperiments),
        'priority_distribution': _calculatePriorityDistribution(allExperiments),
      };
    } catch (e, stackTrace) {
      _logger.e('Failed to get experiment statistics', error: e, stackTrace: stackTrace);
      return {};
    }
  }

  /// Calculate experiment type distribution
  Map<String, int> _calculateTypeDistribution(List<CareerExperiment> experiments) {
    final distribution = <String, int>{};
    for (final experiment in experiments) {
      final typeName = experiment.type.name;
      distribution[typeName] = (distribution[typeName] ?? 0) + 1;
    }
    return distribution;
  }

  /// Calculate experiment priority distribution
  Map<String, int> _calculatePriorityDistribution(List<CareerExperiment> experiments) {
    final distribution = <String, int>{};
    for (final experiment in experiments) {
      final priorityName = experiment.priority.name;
      distribution[priorityName] = (distribution[priorityName] ?? 0) + 1;
    }
    return distribution;
  }

  /// Close the service and release resources
  Future<void> close() async {
    try {
      await _careerSessionBox.close();
      await _settingsBox.close();
      await _experimentsBox.close();
      await _experimentResultsBox.close();
      _logger.i('Career persistence service closed');
    } catch (e, stackTrace) {
      _logger.e('Error closing career persistence service', error: e, stackTrace: stackTrace);
    }
  }
}

// Riverpod providers for dependency injection
final careerPersistenceServiceProvider = Provider<CareerPersistenceService>((ref) {
  return CareerPersistenceService();
});

final currentCareerSessionProvider = StreamProvider<CareerSession?>((ref) async* {
  final persistenceService = ref.read(careerPersistenceServiceProvider);
  
  // Initial value
  yield persistenceService.getCurrentCareerSession();
  
  // Listen for changes - in production, consider using a more efficient change detection
  await for (final _ in Stream.periodic(const Duration(milliseconds: 500))) {
    yield persistenceService.getCurrentCareerSession();
  }
});

final allCareerSessionsProvider = FutureProvider<List<CareerSession>>((ref) async {
  final persistenceService = ref.read(careerPersistenceServiceProvider);
  return persistenceService.getAllCareerSessions();
});