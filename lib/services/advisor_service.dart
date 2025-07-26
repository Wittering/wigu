import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/advisor_invitation.dart';
import '../models/advisor_response.dart';
import '../models/advisor_rating.dart';
import '../models/career_session.dart';
import '../models/career_response.dart';
import '../services/career_ai_service.dart';
import '../services/advisor_email_service.dart';
import '../utils/logger.dart';
import '../utils/error_handler.dart';

/// Comprehensive service for managing advisor invitations, responses, and analytics
/// Handles the complete advisor feedback collection process with Australian context
class AdvisorService {
  static const String _advisorInvitationBoxName = 'advisor_invitations';
  static const String _advisorResponseBoxName = 'advisor_responses';
  static const String _advisorRatingBoxName = 'advisor_ratings';
  static const Duration _invitationTimeout = Duration(days: 30);
  static const int _maxAdvisorsPerSession = 4;
  static const int _minAdvisorsRecommended = 3;
  
  late Box<AdvisorInvitation> _invitationBox;
  late Box<AdvisorResponse> _responseBox;
  late Box<AdvisorRating> _ratingBox;
  final CareerAIService _aiService;
  final AdvisorEmailService _emailService;
  
  AdvisorService({CareerAIService? aiService, AdvisorEmailService? emailService}) 
      : _aiService = aiService ?? CareerAIService(),
        _emailService = emailService ?? AdvisorEmailService();

  /// Initialise the advisor service and open required storage boxes
  Future<void> initialise() async {
    try {
      // Register Hive adapters if not already registered
      if (!Hive.isAdapterRegistered(20)) {
        Hive.registerAdapter(AdvisorInvitationAdapter());
      }
      if (!Hive.isAdapterRegistered(21)) {
        Hive.registerAdapter(AdvisorRelationshipAdapter());
      }
      if (!Hive.isAdapterRegistered(22)) {
        Hive.registerAdapter(InvitationStatusAdapter());
      }
      if (!Hive.isAdapterRegistered(23)) {
        Hive.registerAdapter(AdvisorResponseAdapter());
      }
      if (!Hive.isAdapterRegistered(24)) {
        Hive.registerAdapter(AdvisorObservationPeriodAdapter());
      }
      if (!Hive.isAdapterRegistered(25)) {
        Hive.registerAdapter(AdvisorConfidenceContextAdapter());
      }
      if (!Hive.isAdapterRegistered(26)) {
        Hive.registerAdapter(AdvisorRatingAdapter());
      }
      if (!Hive.isAdapterRegistered(27)) {
        Hive.registerAdapter(AdvisorStrengthAreaAdapter());
      }
      if (!Hive.isAdapterRegistered(28)) {
        Hive.registerAdapter(AdvisorResponseTimelinessAdapter());
      }

      // Open storage boxes
      _invitationBox = await Hive.openBox<AdvisorInvitation>(_advisorInvitationBoxName);
      _responseBox = await Hive.openBox<AdvisorResponse>(_advisorResponseBoxName);
      _ratingBox = await Hive.openBox<AdvisorRating>(_advisorRatingBoxName);
      
      AppLogger.info('AdvisorService initialised successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialise AdvisorService', e, stackTrace);
      rethrow;
    }
  }

  /// Create and send an advisor invitation
  Future<AdvisorInvitation> createInvitation({
    required String sessionId,
    required String advisorName,
    required String advisorEmail,
    String? advisorPhone,
    required AdvisorRelationship relationshipType,
    required String personalMessage,
    bool includePersonalMessage = true,
    Map<String, String>? customQuestions,
  }) async {
    try {
      // Validate advisor limit per session
      final existingCount = getInvitationsForSession(sessionId).length;
      if (existingCount >= _maxAdvisorsPerSession) {
        throw AdvisorServiceException(
          'Maximum of $_maxAdvisorsPerSession advisors allowed per session',
          AdvisorServiceErrorType.advisorLimitExceeded,
        );
      }

      // Check for duplicate email in this session
      final existingInvitations = getInvitationsForSession(sessionId);
      final duplicateEmail = existingInvitations.any(
        (inv) => inv.advisorEmail.toLowerCase() == advisorEmail.toLowerCase(),
      );
      
      if (duplicateEmail) {
        throw AdvisorServiceException(
          'An advisor with this email address has already been invited for this session',
          AdvisorServiceErrorType.duplicateAdvisor,
        );
      }

      // Create the invitation
      final invitation = AdvisorInvitation.create(
        advisorName: advisorName,
        advisorEmail: advisorEmail,
        advisorPhone: advisorPhone,
        relationshipType: relationshipType,
        personalMessage: personalMessage,
        sessionId: sessionId,
        includePersonalMessage: includePersonalMessage,
        customQuestions: customQuestions,
      );

      // Store the invitation
      await _invitationBox.put(invitation.id, invitation);
      
      AppLogger.info('Created advisor invitation for ${invitation.advisorName} (${invitation.advisorEmail})');
      return invitation;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create advisor invitation', e, stackTrace);
      rethrow;
    }
  }

  /// Send invitation email to advisor
  Future<void> sendInvitationEmail({
    required String invitationId,
    required String userName,
    String? userTitle,
    String? companyName,
  }) async {
    try {
      final invitation = _invitationBox.get(invitationId);
      if (invitation == null) {
        throw AdvisorServiceException(
          'Invitation not found: $invitationId',
          AdvisorServiceErrorType.invitationNotFound,
        );
      }

      // Send email using email service
      final emailSent = await _emailService.sendInvitationEmail(
        invitation: invitation,
        userName: userName,
        userTitle: userTitle,
        companyName: companyName,
      );
      
      if (!emailSent) {
        throw AdvisorServiceException(
          'Failed to send email to ${invitation.advisorEmail}',
          AdvisorServiceErrorType.emailServiceUnavailable,
        );
      }
      
      // Update invitation status
      final updatedInvitation = invitation.copyWith(
        status: InvitationStatus.sent,
        sentAt: DateTime.now(),
      );
      
      await _invitationBox.put(invitationId, updatedInvitation);
      
      AppLogger.info('Invitation sent to ${invitation.advisorName}');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to send invitation email', e, stackTrace);
      rethrow;
    }
  }

  /// Generate the advisor response link
  String generateAdvisorResponseUrl(String invitationId, {String? baseUrl}) {
    final base = baseUrl ?? 'https://wigu.career';
    return '$base/advisor-response/$invitationId';
  }

  /// Get the 5 advisor questions corresponding to self-assessment domains
  Map<String, Map<String, dynamic>> getAdvisorQuestions() {
    return {
      'strengths_observed': {
        'id': 'strengths_observed',
        'domain': CareerDomain.technical,
        'question': 'What do you see as this person\'s key strengths and natural talents? Please provide specific examples of when you\'ve observed these strengths in action.',
        'placeholder': 'Think about their natural abilities, skills that come easily to them, and what they excel at...',
        'followUpPrompts': [
          'Can you describe a specific situation where you saw these strengths?',
          'What makes these strengths particularly notable?',
          'How do these strengths benefit their work or those around them?',
        ],
      },
      'value_reputation': {
        'id': 'value_reputation',
        'domain': CareerDomain.social,
        'question': 'What do people (including yourself) typically seek this person out for? What problems do they solve or what expertise do they provide to others?',
        'placeholder': 'Consider what they\'re known for, what others ask their help with, their reputation...',
        'followUpPrompts': [
          'What specific situations have you seen others come to them for help?',
          'What makes people trust them with certain challenges?',
          'How would you describe their professional reputation?',
        ],
      },
      'growth_potential': {
        'id': 'growth_potential',
        'domain': CareerDomain.leadership,
        'question': 'Where do you see the greatest opportunities for this person\'s professional growth and development? What potential do you see in them?',
        'placeholder': 'Think about areas they could develop, untapped potential, future opportunities...',
        'followUpPrompts': [
          'What skills or areas could they develop further?',
          'What opportunities would suit them well?',
          'What potential do you see that they might not recognise themselves?',
        ],
      },
      'working_style': {
        'id': 'working_style',
        'domain': CareerDomain.analytical,
        'question': 'How would you describe this person\'s working style and what type of work environment or role would suit them best?',
        'placeholder': 'Consider their approach to work, team dynamics, preferred environments...',
        'followUpPrompts': [
          'How do they work best - independently or in teams?',
          'What kind of environment brings out their best work?',
          'What role characteristics would suit their style?',
        ],
      },
      'career_direction': {
        'id': 'career_direction',
        'domain': CareerDomain.entrepreneurial,
        'question': 'Based on what you know about this person, what career directions or opportunities do you think would align well with their abilities and interests?',
        'placeholder': 'Think about career paths, industries, or roles that would suit them...',
        'followUpPrompts': [
          'What career paths do you think would energise them?',
          'What industries or sectors might suit them well?',
          'What type of role would make the most of their abilities?',
        ],
      },
    };
  }

  /// Submit advisor responses for a given invitation
  Future<List<AdvisorResponse>> submitAdvisorResponses({
    required String invitationId,
    required Map<String, String> responses,
    required Map<String, int> confidenceLevels,
    required AdvisorObservationPeriod observationPeriod,
    required AdvisorConfidenceContext confidenceContext,
    Map<String, List<String>>? specificExamples,
    String? additionalContext,
    bool isAnonymous = false,
  }) async {
    try {
      final invitation = _invitationBox.get(invitationId);
      if (invitation == null) {
        throw AdvisorServiceException(
          'Invitation not found: $invitationId',
          AdvisorServiceErrorType.invitationNotFound,
        );
      }

      if (invitation.status == InvitationStatus.completed) {
        throw AdvisorServiceException(
          'This invitation has already been completed',
          AdvisorServiceErrorType.invitationAlreadyCompleted,
        );
      }

      if (invitation.status == InvitationStatus.expired) {
        throw AdvisorServiceException(
          'This invitation has expired',
          AdvisorServiceErrorType.invitationExpired,
        );
      }

      final advisorQuestions = getAdvisorQuestions();
      final submittedResponses = <AdvisorResponse>[];

      // Create advisor responses for each question
      for (final entry in responses.entries) {
        final questionId = entry.key;
        final responseText = entry.value;
        final questionData = advisorQuestions[questionId];
        
        if (questionData == null) {
          AppLogger.warning('Unknown question ID: $questionId');
          continue;
        }

        final advisorResponse = AdvisorResponse.create(
          invitationId: invitationId,
          questionId: questionId,
          questionText: questionData['question'] as String,
          response: responseText,
          domain: questionData['domain'] as CareerDomain,
          confidenceLevel: confidenceLevels[questionId],
          observationPeriod: observationPeriod,
          specificExamples: specificExamples?[questionId],
          confidenceContext: confidenceContext,
          additionalContext: additionalContext,
          isAnonymous: isAnonymous,
        );

        await _responseBox.put(advisorResponse.id, advisorResponse);
        submittedResponses.add(advisorResponse);
      }

      // Update invitation status
      final updatedInvitation = invitation.markAsCompleted();
      await _invitationBox.put(invitationId, updatedInvitation);

      AppLogger.info('Submitted ${submittedResponses.length} advisor responses for invitation $invitationId');
      return submittedResponses;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to submit advisor responses', e, stackTrace);
      rethrow;
    }
  }

  /// Get invitation by ID
  Future<AdvisorInvitation?> getInvitationById(String invitationId) async {
    try {
      return _invitationBox.get(invitationId);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get invitation by ID', e, stackTrace);
      return null;
    }
  }

  /// Get all invitations for a specific session
  List<AdvisorInvitation> getInvitationsForSession(String sessionId) {
    try {
      return _invitationBox.values
          .where((invitation) => invitation.sessionId == sessionId)
          .toList()
        ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get invitations for session', e, stackTrace);
      return [];
    }
  }

  /// Get all responses for a specific invitation
  List<AdvisorResponse> getResponsesForInvitation(String invitationId) {
    try {
      return _responseBox.values
          .where((response) => response.invitationId == invitationId)
          .toList()
        ..sort((a, b) => a.answeredAt.compareTo(b.answeredAt));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get responses for invitation', e, stackTrace);
      return [];
    }
  }

  /// Get all responses for a session
  List<AdvisorResponse> getResponsesForSession(String sessionId) {
    try {
      final sessionInvitations = getInvitationsForSession(sessionId);
      final allResponses = <AdvisorResponse>[];
      
      for (final invitation in sessionInvitations) {
        allResponses.addAll(getResponsesForInvitation(invitation.id));
      }
      
      return allResponses..sort((a, b) => a.answeredAt.compareTo(b.answeredAt));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get responses for session', e, stackTrace);
      return [];
    }
  }

  /// Generate advisor feedback summary for a session
  Future<AdvisorFeedbackSummary> generateFeedbackSummary(String sessionId) async {
    try {
      final invitations = getInvitationsForSession(sessionId);
      final responses = getResponsesForSession(sessionId);
      
      if (responses.isEmpty) {
        return AdvisorFeedbackSummary.empty(sessionId);
      }

      // Group responses by question/domain
      final responsesByDomain = <CareerDomain, List<AdvisorResponse>>{};
      final responsesByQuestion = <String, List<AdvisorResponse>>{};
      
      for (final response in responses) {
        responsesByDomain.putIfAbsent(response.domain, () => []).add(response);
        responsesByQuestion.putIfAbsent(response.questionId, () => []).add(response);
      }

      // Calculate aggregate metrics
      final totalResponses = responses.length;
      final completedInvitations = invitations.where((inv) => inv.status == InvitationStatus.completed).length;
      final averageResponseQuality = responses.isNotEmpty 
          ? responses.map((r) => r.responseQualityScore).reduce((a, b) => a + b) / responses.length
          : 0.0;
      final averageCredibilityWeight = responses.isNotEmpty
          ? responses.map((r) => r.credibilityWeight).reduce((a, b) => a + b) / responses.length
          : 0.0;

      // Extract key themes across all responses
      final allThemes = <String>[];
      for (final response in responses) {
        allThemes.addAll(response.keyThemes);
      }
      
      final themeFrequency = <String, int>{};
      for (final theme in allThemes) {
        themeFrequency[theme] = (themeFrequency[theme] ?? 0) + 1;
      }
      
      final topThemes = themeFrequency.entries
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Generate insights using AI if available
      final insights = await _generateAdvisorInsights(responses);

      return AdvisorFeedbackSummary(
        sessionId: sessionId,
        totalInvitations: invitations.length,
        completedResponses: completedInvitations,
        totalResponses: totalResponses,
        averageResponseQuality: averageResponseQuality,
        averageCredibilityWeight: averageCredibilityWeight,
        responsesByDomain: responsesByDomain,
        responsesByQuestion: responsesByQuestion,
        topThemes: topThemes.take(10).map((e) => e.key).toList(),
        insights: insights,
        generatedAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to generate feedback summary', e, stackTrace);
      return AdvisorFeedbackSummary.empty(sessionId);
    }
  }

  /// Generate AI-powered insights from advisor responses
  Future<List<String>> _generateAdvisorInsights(List<AdvisorResponse> responses) async {
    try {
      if (!_aiService.isAvailable || responses.isEmpty) {
        return _getFallbackAdvisorInsights(responses);
      }

      // Use AI service to generate insights from advisor responses
      // This would integrate with the existing CareerAIService
      AppLogger.info('Generating AI insights from ${responses.length} advisor responses');
      
      // For now, return fallback insights
      return _getFallbackAdvisorInsights(responses);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to generate AI advisor insights', e, stackTrace);
      return _getFallbackAdvisorInsights(responses);
    }
  }

  /// Generate fallback insights when AI is unavailable
  List<String> _getFallbackAdvisorInsights(List<AdvisorResponse> responses) {
    final insights = <String>[];
    
    if (responses.isEmpty) return insights;

    // Count responses by domain
    final domainCounts = <CareerDomain, int>{};
    for (final response in responses) {
      domainCounts[response.domain] = (domainCounts[response.domain] ?? 0) + 1;
    }

    // Generate basic insights
    final mostDiscussedDomain = domainCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
    insights.add('Advisors consistently highlighted your ${mostDiscussedDomain.key.displayName.toLowerCase()} capabilities.');

    final highQualityResponses = responses.where((r) => r.responseQualityScore > 0.7).length;
    if (highQualityResponses > responses.length * 0.6) {
      insights.add('Your advisors provided detailed, specific feedback indicating strong familiarity with your work.');
    }

    final commonThemes = _findCommonThemes(responses);
    if (commonThemes.isNotEmpty) {
      insights.add('Common themes across advisor feedback include: ${commonThemes.take(3).join(', ')}.');
    }

    return insights;
  }

  /// Find common themes across advisor responses
  List<String> _findCommonThemes(List<AdvisorResponse> responses) {
    final themeCount = <String, int>{};
    
    for (final response in responses) {
      for (final theme in response.keyThemes) {
        themeCount[theme] = (themeCount[theme] ?? 0) + 1;
      }
    }
    
    final filteredEntries = themeCount.entries
        .where((entry) => entry.value >= 2)
        .toList();
    
    filteredEntries.sort((a, b) => b.value.compareTo(a.value));
    
    return filteredEntries
        .map((entry) => entry.key)
        .toList();
  }

  /// Mark an invitation as viewed
  Future<void> markInvitationViewed(String invitationId) async {
    try {
      final invitation = _invitationBox.get(invitationId);
      if (invitation == null) return;

      final updatedInvitation = invitation.markAsViewed();
      await _invitationBox.put(invitationId, updatedInvitation);
      
      AppLogger.info('Marked invitation as viewed: $invitationId');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to mark invitation as viewed', e, stackTrace);
    }
  }

  /// Decline an invitation
  Future<void> declineInvitation(String invitationId, {String? reason}) async {
    try {
      final invitation = _invitationBox.get(invitationId);
      if (invitation == null) {
        throw AdvisorServiceException(
          'Invitation not found: $invitationId',
          AdvisorServiceErrorType.invitationNotFound,
        );
      }

      final updatedInvitation = invitation.markAsDeclined(reason: reason);
      await _invitationBox.put(invitationId, updatedInvitation);
      
      AppLogger.info('Declined invitation: $invitationId');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to decline invitation', e, stackTrace);
      rethrow;
    }
  }

  /// Send reminder for overdue invitations
  Future<void> sendReminderEmail(String invitationId, String userName) async {
    try {
      final invitation = _invitationBox.get(invitationId);
      if (invitation == null || !invitation.canSendReminder) {
        return;
      }

      // Send reminder email using email service
      final reminderSent = await _emailService.sendReminderEmail(
        invitation: invitation,
        userName: userName,
        reminderNumber: invitation.reminderCount + 1,
      );
      
      if (!reminderSent) {
        AppLogger.warning('Failed to send reminder email to ${invitation.advisorEmail}');
        return;
      }
      
      // Update reminder tracking
      final updatedInvitation = invitation.sendReminder();
      await _invitationBox.put(invitationId, updatedInvitation);
      
      AppLogger.info('Sent reminder for invitation: $invitationId');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to send reminder email', e, stackTrace);
    }
  }

  /// Rate an advisor's contribution
  Future<void> rateAdvisor({
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
    try {
      final rating = AdvisorRating.create(
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

      await _ratingBox.put(rating.id, rating);
      AppLogger.info('Saved advisor rating for invitation: $invitationId');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to rate advisor', e, stackTrace);
      rethrow;
    }
  }

  /// Get advisor analytics and metrics
  AdvisorAnalytics getAdvisorAnalytics({String? sessionId}) {
    try {
      final allInvitations = sessionId != null 
          ? getInvitationsForSession(sessionId)
          : _invitationBox.values.toList();
      
      final allResponses = sessionId != null
          ? getResponsesForSession(sessionId)
          : _responseBox.values.toList();
      
      final allRatings = _ratingBox.values.toList();

      return AdvisorAnalytics(
        totalInvitations: allInvitations.length,
        completedInvitations: allInvitations.where((inv) => inv.status == InvitationStatus.completed).length,
        pendingInvitations: allInvitations.where((inv) => inv.status == InvitationStatus.sent).length,
        declinedInvitations: allInvitations.where((inv) => inv.status == InvitationStatus.declined).length,
        totalResponses: allResponses.length,
        averageResponseQuality: allResponses.isNotEmpty 
            ? allResponses.map((r) => r.responseQualityScore).reduce((a, b) => a + b) / allResponses.length
            : 0.0,
        averageRating: allRatings.isNotEmpty
            ? allRatings.map((r) => r.averageRating).reduce((a, b) => a + b) / allRatings.length
            : 0.0,
        relationshipTypeDistribution: _getRelationshipTypeDistribution(allInvitations),
        responseTimeDistribution: _getResponseTimeDistribution(allInvitations),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get advisor analytics', e, stackTrace);
      return AdvisorAnalytics.empty();
    }
  }

  /// Get distribution of relationship types
  Map<AdvisorRelationship, int> _getRelationshipTypeDistribution(List<AdvisorInvitation> invitations) {
    final distribution = <AdvisorRelationship, int>{};
    
    for (final invitation in invitations) {
      distribution[invitation.relationshipType] = (distribution[invitation.relationshipType] ?? 0) + 1;
    }
    
    return distribution;
  }

  /// Get distribution of response times
  Map<String, int> _getResponseTimeDistribution(List<AdvisorInvitation> invitations) {
    final distribution = <String, int>{};
    
    for (final invitation in invitations.where((inv) => inv.respondedAt != null)) {
      final responseTime = invitation.respondedAt!.difference(invitation.sentAt).inDays;
      
      String category;
      if (responseTime <= 2) {
        category = 'Very Quick (1-2 days)';
      } else if (responseTime <= 5) {
        category = 'Quick (3-5 days)';
      } else if (responseTime <= 7) {
        category = 'Reasonable (6-7 days)';
      } else if (responseTime <= 14) {
        category = 'Slow (1-2 weeks)';
      } else {
        category = 'Very Slow (2+ weeks)';
      }
      
      distribution[category] = (distribution[category] ?? 0) + 1;
    }
    
    return distribution;
  }

  /// Clean up expired invitations
  Future<void> cleanupExpiredInvitations() async {
    try {
      final expiredInvitations = _invitationBox.values.where((invitation) {
        return invitation.status == InvitationStatus.sent &&
               DateTime.now().difference(invitation.sentAt) > _invitationTimeout;
      }).toList();

      for (final invitation in expiredInvitations) {
        final updatedInvitation = invitation.copyWith(status: InvitationStatus.expired);
        await _invitationBox.put(invitation.id, updatedInvitation);
      }

      if (expiredInvitations.isNotEmpty) {
        AppLogger.info('Marked ${expiredInvitations.length} invitations as expired');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to cleanup expired invitations', e, stackTrace);
    }
  }

  /// Close the service and release resources
  Future<void> close() async {
    try {
      await _invitationBox.close();
      await _responseBox.close();
      await _ratingBox.close();
      AppLogger.info('AdvisorService closed successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error closing AdvisorService', e, stackTrace);
    }
  }
}

/// Summary of advisor feedback for a session
class AdvisorFeedbackSummary {
  final String sessionId;
  final int totalInvitations;
  final int completedResponses;
  final int totalResponses;
  final double averageResponseQuality;
  final double averageCredibilityWeight;
  final Map<CareerDomain, List<AdvisorResponse>> responsesByDomain;
  final Map<String, List<AdvisorResponse>> responsesByQuestion;
  final List<String> topThemes;
  final List<String> insights;
  final DateTime generatedAt;

  const AdvisorFeedbackSummary({
    required this.sessionId,
    required this.totalInvitations,
    required this.completedResponses,
    required this.totalResponses,
    required this.averageResponseQuality,
    required this.averageCredibilityWeight,
    required this.responsesByDomain,
    required this.responsesByQuestion,
    required this.topThemes,
    required this.insights,
    required this.generatedAt,
  });

  factory AdvisorFeedbackSummary.empty(String sessionId) {
    return AdvisorFeedbackSummary(
      sessionId: sessionId,
      totalInvitations: 0,
      completedResponses: 0,
      totalResponses: 0,
      averageResponseQuality: 0.0,
      averageCredibilityWeight: 0.0,
      responsesByDomain: {},
      responsesByQuestion: {},
      topThemes: [],
      insights: [],
      generatedAt: DateTime.now(),
    );
  }

  bool get hasResponses => totalResponses > 0;
  double get responseRate => totalInvitations > 0 ? completedResponses / totalInvitations : 0.0;
  bool get hasGoodQuality => averageResponseQuality > 0.6;
  bool get hasHighCredibility => averageCredibilityWeight > 0.7;
}

/// Analytics data for advisor system
class AdvisorAnalytics {
  final int totalInvitations;
  final int completedInvitations;
  final int pendingInvitations;
  final int declinedInvitations;
  final int totalResponses;
  final double averageResponseQuality;
  final double averageRating;
  final Map<AdvisorRelationship, int> relationshipTypeDistribution;
  final Map<String, int> responseTimeDistribution;

  const AdvisorAnalytics({
    required this.totalInvitations,
    required this.completedInvitations,
    required this.pendingInvitations,
    required this.declinedInvitations,
    required this.totalResponses,
    required this.averageResponseQuality,
    required this.averageRating,
    required this.relationshipTypeDistribution,
    required this.responseTimeDistribution,
  });

  factory AdvisorAnalytics.empty() {
    return const AdvisorAnalytics(
      totalInvitations: 0,
      completedInvitations: 0,
      pendingInvitations: 0,
      declinedInvitations: 0,
      totalResponses: 0,
      averageResponseQuality: 0.0,
      averageRating: 0.0,
      relationshipTypeDistribution: {},
      responseTimeDistribution: {},
    );
  }

  double get completionRate => totalInvitations > 0 ? completedInvitations / totalInvitations : 0.0;
  double get declineRate => totalInvitations > 0 ? declinedInvitations / totalInvitations : 0.0;
}

/// Custom exceptions for advisor service operations
class AdvisorServiceException implements Exception {
  final String message;
  final AdvisorServiceErrorType type;
  
  const AdvisorServiceException(this.message, this.type);
  
  @override
  String toString() => 'AdvisorServiceException: $message';
}

/// Types of advisor service errors
enum AdvisorServiceErrorType {
  advisorLimitExceeded,
  duplicateAdvisor,
  invitationNotFound,
  invitationAlreadyCompleted,
  invitationExpired,
  invalidResponseData,
  emailServiceUnavailable,
  persistenceError,
}