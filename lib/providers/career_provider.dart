import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/career_session.dart';
import '../models/career_response.dart';
import '../models/career_insight.dart';
import '../services/career_persistence_service.dart';
import '../utils/logger.dart';

/// State management for career exploration functionality
/// Provides reactive state management for career sessions, responses, and insights

/// Provider for the current active career session
final activeCareerSessionProvider = StateNotifierProvider<ActiveCareerSessionNotifier, AsyncValue<CareerSession?>>((ref) {
  final persistenceService = ref.watch(careerPersistenceServiceProvider);
  return ActiveCareerSessionNotifier(persistenceService);
});

/// State notifier for managing the active career session
class ActiveCareerSessionNotifier extends StateNotifier<AsyncValue<CareerSession?>> {
  final CareerPersistenceService _persistenceService;

  ActiveCareerSessionNotifier(this._persistenceService) : super(const AsyncValue.loading()) {
    _loadCurrentSession();
  }

  /// Load the current active session
  Future<void> _loadCurrentSession() async {
    try {
      final session = _persistenceService.getCurrentCareerSession();
      state = AsyncValue.data(session);
      AppLogger.debug('Loaded current career session: ${session?.id}');
    } catch (error, stackTrace) {
      AppLogger.error('Failed to load current career session', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Create a new career session
  Future<void> createNewSession({String? name}) async {
    try {
      state = const AsyncValue.loading();
      final sessionId = await _persistenceService.createNewCareerSession(name: name);
      final newSession = _persistenceService.getCurrentCareerSession();
      state = AsyncValue.data(newSession);
      
      AppLogger.careerEvent('session_created', {
        'sessionId': sessionId,
        'sessionName': name ?? 'Untitled Session',
      });
    } catch (error, stackTrace) {
      AppLogger.error('Failed to create new career session', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Switch to a different session
  Future<void> switchToSession(String sessionId) async {
    try {
      await _persistenceService.setCurrentSession(sessionId);
      final session = _persistenceService.getCurrentCareerSession();
      state = AsyncValue.data(session);
      
      AppLogger.careerEvent('session_switched', {
        'sessionId': sessionId,
      });
    } catch (error, stackTrace) {
      AppLogger.error('Failed to switch to career session', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Save a career response
  Future<void> saveResponse({
    required String questionId,
    required String questionText,
    required String response,
    required CareerDomain domain,
  }) async {
    final currentSession = state.valueOrNull;
    if (currentSession == null) return;

    try {
      await _persistenceService.saveCareerResponse(
        sessionId: currentSession.id,
        questionId: questionId,
        questionText: questionText,
        response: response,
        domain: domain,
      );
      
      // Reload the session to reflect changes
      await _loadCurrentSession();
      
      AppLogger.careerEvent('response_saved', {
        'sessionId': currentSession.id,
        'questionId': questionId,
        'domain': domain.name,
        'responseLength': response.length,
      });
    } catch (error, stackTrace) {
      AppLogger.error('Failed to save career response', error, stackTrace);
    }
  }

  /// Save a career insight
  Future<void> saveInsight(CareerInsight insight) async {
    final currentSession = state.valueOrNull;
    if (currentSession == null) return;

    try {
      await _persistenceService.saveCareerInsight(
        sessionId: currentSession.id,
        insight: insight,
      );
      
      // Reload the session to reflect changes
      await _loadCurrentSession();
      
      AppLogger.careerEvent('insight_saved', {
        'sessionId': currentSession.id,
        'insightId': insight.id,
        'insightType': insight.type.name,
        'domain': insight.domain.name,
      });
    } catch (error, stackTrace) {
      AppLogger.error('Failed to save career insight', error, stackTrace);
    }
  }

  /// Mark a domain as completed
  Future<void> markDomainCompleted(CareerDomain domain) async {
    final currentSession = state.valueOrNull;
    if (currentSession == null) return;

    try {
      await _persistenceService.markDomainCompleted(
        sessionId: currentSession.id,
        domain: domain,
      );
      
      // Reload the session to reflect changes
      await _loadCurrentSession();
      
      AppLogger.careerEvent('domain_completed', {
        'sessionId': currentSession.id,
        'domain': domain.name,
      });
    } catch (error, stackTrace) {
      AppLogger.error('Failed to mark domain completed', error, stackTrace);
    }
  }

  /// Update session exploration type
  Future<void> updateExplorationType(ExplorationType explorationType) async {
    final currentSession = state.valueOrNull;
    if (currentSession == null) return;

    try {
      await _persistenceService.updateExplorationType(
        sessionId: currentSession.id,
        explorationType: explorationType,
      );
      
      // Reload the session to reflect changes
      await _loadCurrentSession();
      
      AppLogger.careerEvent('exploration_type_updated', {
        'sessionId': currentSession.id,
        'explorationType': explorationType.name,
      });
    } catch (error, stackTrace) {
      AppLogger.error('Failed to update exploration type', error, stackTrace);
    }
  }

  /// Refresh the current session from storage
  Future<void> refresh() async {
    await _loadCurrentSession();
  }
}

/// Provider for all career sessions
final allCareerSessionsProvider = FutureProvider<List<CareerSession>>((ref) async {
  final persistenceService = ref.watch(careerPersistenceServiceProvider);
  try {
    final sessions = persistenceService.getAllCareerSessions();
    AppLogger.debug('Loaded ${sessions.length} career sessions');
    return sessions;
  } catch (error, stackTrace) {
    AppLogger.error('Failed to load all career sessions', error, stackTrace);
    return [];
  }
});

/// Provider for responses in a specific domain
final domainResponsesProvider = Provider.family<List<CareerResponse>, CareerDomain>((ref, domain) {
  final activeSession = ref.watch(activeCareerSessionProvider);
  return activeSession.maybeWhen(
    data: (session) => session?.getResponsesForDomain(domain) ?? [],
    orElse: () => [],
  );
});

/// Provider for insights in a specific domain  
final domainInsightsProvider = Provider.family<List<CareerInsight>, CareerDomain>((ref, domain) {
  final activeSession = ref.watch(activeCareerSessionProvider);
  return activeSession.maybeWhen(
    data: (session) => session?.getInsightsForDomain(domain) ?? [],
    orElse: () => [],
  );
});

/// Provider for session completion statistics
final sessionStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final activeSession = ref.watch(activeCareerSessionProvider);
  return activeSession.maybeWhen(
    data: (session) {
      if (session == null) return <String, dynamic>{};
      
      return {
        'totalResponses': session.totalResponses,
        'totalInsights': session.totalInsights,
        'completedDomains': session.completedDomains.length,
        'totalDomains': CareerDomain.values.length,
        'completionPercentage': session.completionPercentage,
        'lastModified': session.lastModified,
        'preferredExplorationType': session.preferredExplorationType,
      };
    },
    orElse: () => <String, dynamic>{},
  );
});