import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/advisor_invitation.dart';
import '../models/advisor_response.dart';
import '../models/advisor_rating.dart';
import '../services/advisor_service.dart';
import '../utils/logger.dart';

/// Provider for the advisor service instance
final advisorServiceProvider = Provider<AdvisorService>((ref) {
  return AdvisorService();
});

/// Provider for advisor invitations for a specific session
final advisorInvitationsProvider = FutureProvider.family<List<AdvisorInvitation>, String>((ref, sessionId) async {
  final advisorService = ref.watch(advisorServiceProvider);
  try {
    await advisorService.initialise();
    return advisorService.getInvitationsForSession(sessionId);
  } catch (e, stackTrace) {
    AppLogger.error('Failed to load advisor invitations for session $sessionId', e, stackTrace);
    return [];
  }
});

/// Provider for advisor responses for a specific session
final advisorResponsesProvider = FutureProvider.family<List<AdvisorResponse>, String>((ref, sessionId) async {
  final advisorService = ref.watch(advisorServiceProvider);
  try {
    await advisorService.initialise();
    return advisorService.getResponsesForSession(sessionId);
  } catch (e, stackTrace) {
    AppLogger.error('Failed to load advisor responses for session $sessionId', e, stackTrace);
    return [];
  }
});

/// Provider for advisor feedback summary for a specific session
final advisorFeedbackSummaryProvider = FutureProvider.family<AdvisorFeedbackSummary, String>((ref, sessionId) async {
  final advisorService = ref.watch(advisorServiceProvider);
  try {
    await advisorService.initialise();
    return await advisorService.generateFeedbackSummary(sessionId);
  } catch (e, stackTrace) {
    AppLogger.error('Failed to generate feedback summary for session $sessionId', e, stackTrace);
    return AdvisorFeedbackSummary.empty(sessionId);
  }
});

/// Provider for advisor analytics for a specific session
final advisorAnalyticsProvider = FutureProvider.family<AdvisorAnalytics, String?>((ref, sessionId) async {
  final advisorService = ref.watch(advisorServiceProvider);
  try {
    await advisorService.initialise();
    return advisorService.getAdvisorAnalytics(sessionId: sessionId);
  } catch (e, stackTrace) {
    AppLogger.error('Failed to load advisor analytics', e, stackTrace);
    return AdvisorAnalytics.empty();
  }
});

/// Provider for a specific advisor invitation by ID
final advisorInvitationProvider = FutureProvider.family<AdvisorInvitation?, String>((ref, invitationId) async {
  final advisorService = ref.watch(advisorServiceProvider);
  try {
    await advisorService.initialise();
    return await advisorService.getInvitationById(invitationId);
  } catch (e, stackTrace) {
    AppLogger.error('Failed to load advisor invitation $invitationId', e, stackTrace);
    return null;
  }
});

/// Provider for responses to a specific invitation
final invitationResponsesProvider = FutureProvider.family<List<AdvisorResponse>, String>((ref, invitationId) async {
  final advisorService = ref.watch(advisorServiceProvider);
  try {
    await advisorService.initialise();
    return advisorService.getResponsesForInvitation(invitationId);
  } catch (e, stackTrace) {
    AppLogger.error('Failed to load responses for invitation $invitationId', e, stackTrace);
    return [];
  }
});

/// State notifier for managing advisor operations
class AdvisorNotifier extends StateNotifier<AsyncValue<void>> {
  final AdvisorService _advisorService;
  final Ref _ref;

  AdvisorNotifier(this._advisorService, this._ref) : super(const AsyncValue.data(null));

  /// Create and send an advisor invitation
  Future<AdvisorInvitation?> createAndSendInvitation({
    required String sessionId,
    required String advisorName,
    required String advisorEmail,
    String? advisorPhone,
    required AdvisorRelationship relationshipType,
    required String personalMessage,
    bool includePersonalMessage = true,
    Map<String, String>? customQuestions,
    required String userName,
    String? userTitle,
    String? companyName,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await _advisorService.initialise();
      
      // Create the invitation
      final invitation = await _advisorService.createInvitation(
        sessionId: sessionId,
        advisorName: advisorName,
        advisorEmail: advisorEmail,
        advisorPhone: advisorPhone,
        relationshipType: relationshipType,
        personalMessage: personalMessage,
        includePersonalMessage: includePersonalMessage,
        customQuestions: customQuestions,
      );
      
      // Send the invitation email
      await _advisorService.sendInvitationEmail(
        invitationId: invitation.id,
        userName: userName,
        userTitle: userTitle,
        companyName: companyName,
      );
      
      // Invalidate related providers to refresh data
      _ref.invalidate(advisorInvitationsProvider(sessionId));
      _ref.invalidate(advisorFeedbackSummaryProvider(sessionId));
      _ref.invalidate(advisorAnalyticsProvider(sessionId));
      
      state = const AsyncValue.data(null);
      AppLogger.info('Successfully created and sent advisor invitation to $advisorEmail');
      return invitation;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create advisor invitation', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  /// Submit advisor responses
  Future<bool> submitAdvisorResponses({
    required String invitationId,
    required Map<String, String> responses,
    required Map<String, int> confidenceLevels,
    required AdvisorObservationPeriod observationPeriod,
    required AdvisorConfidenceContext confidenceContext,
    Map<String, List<String>>? specificExamples,
    String? additionalContext,
    bool isAnonymous = false,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await _advisorService.initialise();
      
      await _advisorService.submitAdvisorResponses(
        invitationId: invitationId,
        responses: responses,
        confidenceLevels: confidenceLevels,
        observationPeriod: observationPeriod,
        confidenceContext: confidenceContext,
        specificExamples: specificExamples,
        additionalContext: additionalContext,
        isAnonymous: isAnonymous,
      );
      
      // Invalidate related providers to refresh data
      final invitation = await _advisorService.getInvitationById(invitationId);
      if (invitation != null) {
        _ref.invalidate(advisorInvitationsProvider(invitation.sessionId));
        _ref.invalidate(advisorResponsesProvider(invitation.sessionId));
        _ref.invalidate(advisorFeedbackSummaryProvider(invitation.sessionId));
        _ref.invalidate(advisorAnalyticsProvider(invitation.sessionId));
        _ref.invalidate(invitationResponsesProvider(invitationId));
      }
      
      state = const AsyncValue.data(null);
      AppLogger.info('Successfully submitted advisor responses for invitation $invitationId');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to submit advisor responses', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  /// Send a reminder for an invitation
  Future<bool> sendReminder(String invitationId, String userName) async {
    state = const AsyncValue.loading();
    
    try {
      await _advisorService.initialise();
      await _advisorService.sendReminderEmail(invitationId, userName);
      
      // Invalidate invitation data to refresh reminder status
      final invitation = await _advisorService.getInvitationById(invitationId);
      if (invitation != null) {
        _ref.invalidate(advisorInvitationsProvider(invitation.sessionId));
        _ref.invalidate(advisorInvitationProvider(invitationId));
      }
      
      state = const AsyncValue.data(null);
      AppLogger.info('Successfully sent reminder for invitation $invitationId');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to send reminder', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  /// Mark an invitation as viewed
  Future<void> markInvitationViewed(String invitationId) async {
    try {
      await _advisorService.initialise();
      await _advisorService.markInvitationViewed(invitationId);
      
      // Invalidate invitation data to refresh status
      final invitation = await _advisorService.getInvitationById(invitationId);
      if (invitation != null) {
        _ref.invalidate(advisorInvitationsProvider(invitation.sessionId));
        _ref.invalidate(advisorInvitationProvider(invitationId));
      }
      
      AppLogger.info('Marked invitation as viewed: $invitationId');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to mark invitation as viewed', e, stackTrace);
    }
  }

  /// Decline an invitation
  Future<bool> declineInvitation(String invitationId, {String? reason}) async {
    state = const AsyncValue.loading();
    
    try {
      await _advisorService.initialise();
      await _advisorService.declineInvitation(invitationId, reason: reason);
      
      // Invalidate invitation data to refresh status
      final invitation = await _advisorService.getInvitationById(invitationId);
      if (invitation != null) {
        _ref.invalidate(advisorInvitationsProvider(invitation.sessionId));
        _ref.invalidate(advisorInvitationProvider(invitationId));
        _ref.invalidate(advisorAnalyticsProvider(invitation.sessionId));
      }
      
      state = const AsyncValue.data(null);
      AppLogger.info('Successfully declined invitation $invitationId');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to decline invitation', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  /// Rate an advisor's contribution
  Future<bool> rateAdvisor({
    required String invitationId,
    required int overallRating,
    required int insightfulness,
    required int specificity,
    required int helpfulness,
    String? positiveAspects,
    String? improvementAreas,
    required bool wouldRecommendAdvisor,
    List<AdvisorStrengthArea>? advisorStrengths,
    String? additionalFeedback,
    bool isAnonymousFeedback = false,
    required AdvisorResponseTimeliness responseTimeliness,
    Map<String, int>? questionSpecificRatings,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await _advisorService.initialise();
      
      await _advisorService.rateAdvisor(
        invitationId: invitationId,
        overallRating: overallRating,
        insightfulness: insightfulness,
        specificity: specificity,
        helpfulness: helpfulness,
        positiveAspects: positiveAspects,
        improvementAreas: improvementAreas,
        wouldRecommendAdvisor: wouldRecommendAdvisor,
        advisorStrengths: advisorStrengths,
        additionalFeedback: additionalFeedback,
        isAnonymousFeedback: isAnonymousFeedback,
        responseTimeliness: responseTimeliness,
        questionSpecificRatings: questionSpecificRatings,
      );
      
      // Invalidate analytics data to refresh ratings
      final invitation = await _advisorService.getInvitationById(invitationId);
      if (invitation != null) {
        _ref.invalidate(advisorAnalyticsProvider(invitation.sessionId));
      }
      
      state = const AsyncValue.data(null);
      AppLogger.info('Successfully rated advisor for invitation $invitationId');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to rate advisor', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  /// Cleanup expired invitations
  Future<void> cleanupExpiredInvitations() async {
    try {
      await _advisorService.initialise();
      await _advisorService.cleanupExpiredInvitations();
      
      // Invalidate all invitation-related data
      _ref.invalidateAll();
      
      AppLogger.info('Cleaned up expired invitations');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to cleanup expired invitations', e, stackTrace);
    }
  }
}

/// Provider for the advisor notifier
final advisorNotifierProvider = StateNotifierProvider<AdvisorNotifier, AsyncValue<void>>((ref) {
  final advisorService = ref.watch(advisorServiceProvider);
  return AdvisorNotifier(advisorService, ref);
});

/// Convenience providers for commonly used advisor operations

/// Provider for advisor questions
final advisorQuestionsProvider = Provider<Map<String, Map<String, dynamic>>>((ref) {
  final advisorService = ref.watch(advisorServiceProvider);
  return advisorService.getAdvisorQuestions();
});

/// Provider for checking if a session has any advisor invitations
final hasAdvisorInvitationsProvider = FutureProvider.family<bool, String>((ref, sessionId) async {
  final invitations = await ref.watch(advisorInvitationsProvider(sessionId).future);
  return invitations.isNotEmpty;
});

/// Provider for checking if a session has completed advisor responses
final hasCompletedAdvisorResponsesProvider = FutureProvider.family<bool, String>((ref, sessionId) async {
  final invitations = await ref.watch(advisorInvitationsProvider(sessionId).future);
  return invitations.any((invitation) => invitation.status == InvitationStatus.completed);
});

/// Provider for getting the count of completed advisor responses for a session
final completedAdvisorResponsesCountProvider = FutureProvider.family<int, String>((ref, sessionId) async {
  final invitations = await ref.watch(advisorInvitationsProvider(sessionId).future);
  return invitations.where((invitation) => invitation.status == InvitationStatus.completed).length;
});

/// Provider for getting pending advisor invitations count for a session
final pendingAdvisorInvitationsCountProvider = FutureProvider.family<int, String>((ref, sessionId) async {
  final invitations = await ref.watch(advisorInvitationsProvider(sessionId).future);
  return invitations.where((invitation) => invitation.status == InvitationStatus.sent).length;
});