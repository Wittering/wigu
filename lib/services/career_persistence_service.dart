import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import '../models/career_session.dart';
import '../models/career_response.dart';
import '../models/career_insight.dart';

/// Service for persisting career exploration data locally
/// Adapted from AI_assess persistence service for career-specific data
class CareerPersistenceService {
  static const String _careerSessionBoxName = 'career_sessions';
  static const String _currentSessionKey = 'current_career_session'; 
  static const String _settingsBoxName = 'career_settings';
  
  late Box<CareerSession> _careerSessionBox;
  late Box<String> _settingsBox;
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

      // Open storage boxes
      _careerSessionBox = await Hive.openBox<CareerSession>(_careerSessionBoxName);
      _settingsBox = await Hive.openBox<String>(_settingsBoxName);
      
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

  /// Close the service and release resources
  Future<void> close() async {
    try {
      await _careerSessionBox.close();
      await _settingsBox.close();
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