import 'dart:convert';
import '../models/career_session.dart';
import '../models/advisor_invitation.dart';
import '../models/advisor_response.dart';
import '../models/career_synthesis.dart';
import '../utils/logger.dart';

/// Service for resolving data conflicts between local and cloud storage
/// Implements various conflict resolution strategies based on data type and context
class ConflictResolutionService {
  
  /// Resolve conflicts for career sessions
  static CareerSession resolveCareerSessionConflict(
    CareerSession localSession,
    CareerSession cloudSession,
    ConflictResolutionStrategy strategy,
  ) {
    try {
      switch (strategy) {
        case ConflictResolutionStrategy.localWins:
          return localSession;
          
        case ConflictResolutionStrategy.cloudWins:
          return cloudSession;
          
        case ConflictResolutionStrategy.lastModifiedWins:
          return localSession.lastModified.isAfter(cloudSession.lastModified)
              ? localSession
              : cloudSession;
              
        case ConflictResolutionStrategy.merge:
          return _mergeCareerSessions(localSession, cloudSession);
          
        case ConflictResolutionStrategy.manual:
          throw ConflictResolutionException(
            'Manual resolution required for career session: ${localSession.id}',
            ConflictType.careerSession,
            localSession,
            cloudSession,
          );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to resolve career session conflict', e, stackTrace);
      // Default to last modified wins as fallback
      return localSession.lastModified.isAfter(cloudSession.lastModified)
          ? localSession
          : cloudSession;
    }
  }

  /// Resolve conflicts for advisor invitations
  static AdvisorInvitation resolveAdvisorInvitationConflict(
    AdvisorInvitation localInvitation,
    AdvisorInvitation cloudInvitation,
    ConflictResolutionStrategy strategy,
  ) {
    try {
      switch (strategy) {
        case ConflictResolutionStrategy.localWins:
          return localInvitation;
          
        case ConflictResolutionStrategy.cloudWins:
          return cloudInvitation;
          
        case ConflictResolutionStrategy.lastModifiedWins:
          // Use sent date for comparison as invitations don't have lastModified
          return localInvitation.sentAt.isAfter(cloudInvitation.sentAt)
              ? localInvitation
              : cloudInvitation;
              
        case ConflictResolutionStrategy.merge:
          return _mergeAdvisorInvitations(localInvitation, cloudInvitation);
          
        case ConflictResolutionStrategy.manual:
          throw ConflictResolutionException(
            'Manual resolution required for advisor invitation: ${localInvitation.id}',
            ConflictType.advisorInvitation,
            localInvitation,
            cloudInvitation,
          );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to resolve advisor invitation conflict', e, stackTrace);
      // Default to cloud wins for invitations (preserve server state)
      return cloudInvitation;
    }
  }

  /// Resolve conflicts for advisor responses
  static AdvisorResponse resolveAdvisorResponseConflict(
    AdvisorResponse localResponse,
    AdvisorResponse cloudResponse,
    ConflictResolutionStrategy strategy,
  ) {
    try {
      // For advisor responses, we generally want to preserve cloud data
      // as it represents the authoritative advisor input
      switch (strategy) {
        case ConflictResolutionStrategy.localWins:
          return localResponse;
          
        case ConflictResolutionStrategy.cloudWins:
          return cloudResponse;
          
        case ConflictResolutionStrategy.lastModifiedWins:
          return localResponse.answeredAt.isAfter(cloudResponse.answeredAt)
              ? localResponse
              : cloudResponse;
              
        case ConflictResolutionStrategy.merge:
          return _mergeAdvisorResponses(localResponse, cloudResponse);
          
        case ConflictResolutionStrategy.manual:
          throw ConflictResolutionException(
            'Manual resolution required for advisor response: ${localResponse.id}',
            ConflictType.advisorResponse,
            localResponse,
            cloudResponse,
          );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to resolve advisor response conflict', e, stackTrace);
      // Always prefer cloud for advisor responses to maintain data integrity
      return cloudResponse;
    }
  }

  /// Resolve conflicts for career synthesis
  static CareerSynthesis resolveCareerSynthesisConflict(
    CareerSynthesis localSynthesis,
    CareerSynthesis cloudSynthesis,
    ConflictResolutionStrategy strategy,
  ) {
    try {
      switch (strategy) {
        case ConflictResolutionStrategy.localWins:
          return localSynthesis;
          
        case ConflictResolutionStrategy.cloudWins:
          return cloudSynthesis;
          
        case ConflictResolutionStrategy.lastModifiedWins:
          final localTime = localSynthesis.lastUpdated ?? localSynthesis.generatedAt;
          final cloudTime = cloudSynthesis.lastUpdated ?? cloudSynthesis.generatedAt;
          return localTime.isAfter(cloudTime) ? localSynthesis : cloudSynthesis;
          
        case ConflictResolutionStrategy.merge:
          return _mergeCareerSyntheses(localSynthesis, cloudSynthesis);
          
        case ConflictResolutionStrategy.manual:
          throw ConflictResolutionException(
            'Manual resolution required for career synthesis: ${localSynthesis.id}',
            ConflictType.careerSynthesis,
            localSynthesis,
            cloudSynthesis,
          );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to resolve career synthesis conflict', e, stackTrace);
      // Default to most recent synthesis
      final localTime = localSynthesis.lastUpdated ?? localSynthesis.generatedAt;
      final cloudTime = cloudSynthesis.lastUpdated ?? cloudSynthesis.generatedAt;
      return localTime.isAfter(cloudTime) ? localSynthesis : cloudSynthesis;
    }
  }

  /// Merge two career sessions intelligently
  static CareerSession _mergeCareerSessions(
    CareerSession localSession,
    CareerSession cloudSession,
  ) {
    try {
      // Use the most recent session as base
      final baseSession = localSession.lastModified.isAfter(cloudSession.lastModified)
          ? localSession
          : cloudSession;
      final otherSession = baseSession == localSession ? cloudSession : localSession;

      // Merge responses (combine all unique responses)
      final mergedResponses = <String, CareerResponse>{};
      mergedResponses.addAll(baseSession.responses);
      
      for (final entry in otherSession.responses.entries) {
        if (!mergedResponses.containsKey(entry.key) ||
            entry.value.answeredAt.isAfter(mergedResponses[entry.key]!.answeredAt)) {
          mergedResponses[entry.key] = entry.value;
        }
      }

      // Merge insights (combine all unique insights)
      final mergedInsights = <CareerInsight>[];
      final insightIds = <String>{};
      
      // Add base session insights
      for (final insight in baseSession.insights) {
        mergedInsights.add(insight);
        insightIds.add(insight.id);
      }
      
      // Add other session insights if not duplicate
      for (final insight in otherSession.insights) {
        if (!insightIds.contains(insight.id)) {
          mergedInsights.add(insight);
        }
      }

      // Merge completed domains (union of both sets)
      final mergedDomains = <CareerDomain>{};
      mergedDomains.addAll(baseSession.completedDomains);
      mergedDomains.addAll(otherSession.completedDomains);

      return baseSession.copyWith(
        responses: mergedResponses,
        insights: mergedInsights,
        completedDomains: mergedDomains.toList(),
        lastModified: DateTime.now(),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to merge career sessions', e, stackTrace);
      rethrow;
    }
  }

  /// Merge two advisor invitations intelligently
  static AdvisorInvitation _mergeAdvisorInvitations(
    AdvisorInvitation localInvitation,
    AdvisorInvitation cloudInvitation,
  ) {
    try {
      // Use the invitation with more recent status updates
      final localStatusTime = localInvitation.respondedAt ?? localInvitation.sentAt;
      final cloudStatusTime = cloudInvitation.respondedAt ?? cloudInvitation.sentAt;
      
      final baseInvitation = localStatusTime.isAfter(cloudStatusTime)
          ? localInvitation
          : cloudInvitation;
      final otherInvitation = baseInvitation == localInvitation ? cloudInvitation : localInvitation;

      // Merge custom questions if available
      final mergedCustomQuestions = <String, String>{};
      if (baseInvitation.customQuestions != null) {
        mergedCustomQuestions.addAll(baseInvitation.customQuestions!);
      }
      if (otherInvitation.customQuestions != null) {
        mergedCustomQuestions.addAll(otherInvitation.customQuestions!);
      }

      // Use the higher reminder count
      final mergedReminderCount = [localInvitation.reminderCount, cloudInvitation.reminderCount].reduce((a, b) => a > b ? a : b);

      return baseInvitation.copyWith(
        customQuestions: mergedCustomQuestions.isNotEmpty ? mergedCustomQuestions : null,
        reminderCount: mergedReminderCount,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to merge advisor invitations', e, stackTrace);
      rethrow;
    }
  }

  /// Merge two advisor responses intelligently
  static AdvisorResponse _mergeAdvisorResponses(
    AdvisorResponse localResponse,
    AdvisorResponse cloudResponse,
  ) {
    try {
      // For advisor responses, we prefer the cloud version to maintain data integrity
      // But we can merge metadata and examples
      final baseResponse = cloudResponse;
      final otherResponse = localResponse;

      // Merge specific examples if available
      final mergedExamples = <String>[];
      if (baseResponse.specificExamples != null) {
        mergedExamples.addAll(baseResponse.specificExamples!);
      }
      if (otherResponse.specificExamples != null) {
        for (final example in otherResponse.specificExamples!) {
          if (!mergedExamples.contains(example)) {
            mergedExamples.add(example);
          }
        }
      }

      // Merge metadata
      final mergedMetadata = <String, dynamic>{};
      if (baseResponse.metadata != null) {
        mergedMetadata.addAll(baseResponse.metadata!);
      }
      if (otherResponse.metadata != null) {
        mergedMetadata.addAll(otherResponse.metadata!);
      }

      return baseResponse.copyWith(
        specificExamples: mergedExamples.isNotEmpty ? mergedExamples : null,
        metadata: mergedMetadata.isNotEmpty ? mergedMetadata : null,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to merge advisor responses', e, stackTrace);
      rethrow;
    }
  }

  /// Merge two career syntheses intelligently
  static CareerSynthesis _mergeCareerSyntheses(
    CareerSynthesis localSynthesis,
    CareerSynthesis cloudSynthesis,
  ) {
    try {
      // Use the most recently updated synthesis as base
      final localTime = localSynthesis.lastUpdated ?? localSynthesis.generatedAt;
      final cloudTime = cloudSynthesis.lastUpdated ?? cloudSynthesis.generatedAt;
      
      final baseSynthesis = localTime.isAfter(cloudTime) ? localSynthesis : cloudSynthesis;
      final otherSynthesis = baseSynthesis == localSynthesis ? cloudSynthesis : localSynthesis;

      // Merge insights (combine all unique insights from both syntheses)
      final mergedAlignmentAreas = _mergeInsightLists(baseSynthesis.alignmentAreas, otherSynthesis.alignmentAreas);
      final mergedHiddenStrengths = _mergeInsightLists(baseSynthesis.hiddenStrengths, otherSynthesis.hiddenStrengths);
      final mergedOverestimatedAreas = _mergeInsightLists(baseSynthesis.overestimatedAreas, otherSynthesis.overestimatedAreas);
      final mergedDevelopmentOpportunities = _mergeInsightLists(baseSynthesis.developmentOpportunities, otherSynthesis.developmentOpportunities);
      final mergedRepositioningPotential = _mergeInsightLists(baseSynthesis.repositioningPotential, otherSynthesis.repositioningPotential);

      // Merge strategic recommendations
      final mergedRecommendations = <String>[];
      mergedRecommendations.addAll(baseSynthesis.strategicRecommendations);
      for (final recommendation in otherSynthesis.strategicRecommendations) {
        if (!mergedRecommendations.contains(recommendation)) {
          mergedRecommendations.add(recommendation);
        }
      }

      // Merge response IDs
      final mergedSelfResponseIds = <String>{};
      mergedSelfResponseIds.addAll(baseSynthesis.selfResponseIds);
      mergedSelfResponseIds.addAll(otherSynthesis.selfResponseIds);

      final mergedAdvisorResponseIds = <String>{};
      mergedAdvisorResponseIds.addAll(baseSynthesis.advisorResponseIds);
      mergedAdvisorResponseIds.addAll(otherSynthesis.advisorResponseIds);

      // Use the better alignment score (higher score indicates better alignment)
      final mergedAlignmentScore = [baseSynthesis.alignmentScore, otherSynthesis.alignmentScore].reduce((a, b) => a > b ? a : b);

      // Use the higher confidence level
      final mergedConfidenceLevel = _mergeConfidenceLevels(baseSynthesis.confidenceLevel, otherSynthesis.confidenceLevel);

      // Merge analysis metadata
      final mergedMetadata = <String, dynamic>{};
      if (baseSynthesis.analysisMetadata != null) {
        mergedMetadata.addAll(baseSynthesis.analysisMetadata!);
      }
      if (otherSynthesis.analysisMetadata != null) {
        mergedMetadata.addAll(otherSynthesis.analysisMetadata!);
      }

      return baseSynthesis.copyWith(
        alignmentAreas: mergedAlignmentAreas,
        hiddenStrengths: mergedHiddenStrengths,
        overestimatedAreas: mergedOverestimatedAreas,
        developmentOpportunities: mergedDevelopmentOpportunities,
        repositioningPotential: mergedRepositioningPotential,
        strategicRecommendations: mergedRecommendations,
        selfResponseIds: mergedSelfResponseIds.toList(),
        advisorResponseIds: mergedAdvisorResponseIds.toList(),
        alignmentScore: mergedAlignmentScore,
        confidenceLevel: mergedConfidenceLevel,
        analysisMetadata: mergedMetadata.isNotEmpty ? mergedMetadata : null,
        lastUpdated: DateTime.now(),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to merge career syntheses', e, stackTrace);
      rethrow;
    }
  }

  /// Merge two lists of synthesis insights
  static List<SynthesisInsight> _mergeInsightLists(
    List<SynthesisInsight> list1,
    List<SynthesisInsight> list2,
  ) {
    final merged = <SynthesisInsight>[];
    final seenIds = <String>{};

    // Add insights from first list
    for (final insight in list1) {
      merged.add(insight);
      seenIds.add(insight.id);
    }

    // Add unique insights from second list
    for (final insight in list2) {
      if (!seenIds.contains(insight.id)) {
        merged.add(insight);
      }
    }

    // Sort by strategic importance (descending)
    merged.sort((a, b) => b.strategicImportance.compareTo(a.strategicImportance));

    return merged;
  }

  /// Merge confidence levels (use higher confidence)
  static SynthesisConfidence _mergeConfidenceLevels(
    SynthesisConfidence confidence1,
    SynthesisConfidence confidence2,
  ) {
    final confidenceOrder = [
      SynthesisConfidence.low,
      SynthesisConfidence.medium,
      SynthesisConfidence.high,
    ];

    final index1 = confidenceOrder.indexOf(confidence1);
    final index2 = confidenceOrder.indexOf(confidence2);

    return index1 >= index2 ? confidence1 : confidence2;
  }

  /// Generate a conflict summary for manual resolution
  static ConflictSummary generateConflictSummary(
    dynamic localData,
    dynamic cloudData,
    ConflictType type,
  ) {
    try {
      final differences = <String>[];
      
      switch (type) {
        case ConflictType.careerSession:
          final local = localData as CareerSession;
          final cloud = cloudData as CareerSession;
          
          if (local.sessionName != cloud.sessionName) {
            differences.add('Session name: "${local.sessionName}" vs "${cloud.sessionName}"');
          }
          
          if (local.responses.length != cloud.responses.length) {
            differences.add('Response count: ${local.responses.length} vs ${cloud.responses.length}');
          }
          
          if (local.insights.length != cloud.insights.length) {
            differences.add('Insight count: ${local.insights.length} vs ${cloud.insights.length}');
          }
          
          if (local.completedDomains.length != cloud.completedDomains.length) {
            differences.add('Completed domains: ${local.completedDomains.length} vs ${cloud.completedDomains.length}');
          }
          
          break;
          
        case ConflictType.advisorInvitation:
          final local = localData as AdvisorInvitation;
          final cloud = cloudData as AdvisorInvitation;
          
          if (local.status != cloud.status) {
            differences.add('Status: ${local.status.name} vs ${cloud.status.name}');
          }
          
          if (local.reminderCount != cloud.reminderCount) {
            differences.add('Reminder count: ${local.reminderCount} vs ${cloud.reminderCount}');
          }
          
          break;
          
        case ConflictType.advisorResponse:
          final local = localData as AdvisorResponse;
          final cloud = cloudData as AdvisorResponse;
          
          if (local.response != cloud.response) {
            differences.add('Response text differs');
          }
          
          if (local.confidenceLevel != cloud.confidenceLevel) {
            differences.add('Confidence level: ${local.confidenceLevel} vs ${cloud.confidenceLevel}');
          }
          
          break;
          
        case ConflictType.careerSynthesis:
          final local = localData as CareerSynthesis;
          final cloud = cloudData as CareerSynthesis;
          
          if (local.executiveSummary != cloud.executiveSummary) {
            differences.add('Executive summary differs');
          }
          
          if (local.alignmentScore != cloud.alignmentScore) {
            differences.add('Alignment score: ${local.alignmentScore} vs ${cloud.alignmentScore}');
          }
          
          if (local.confidenceLevel != cloud.confidenceLevel) {
            differences.add('Confidence level: ${local.confidenceLevel.name} vs ${cloud.confidenceLevel.name}');
          }
          
          break;
      }

      return ConflictSummary(
        type: type,
        differences: differences,
        localModified: _getModificationTime(localData),
        cloudModified: _getModificationTime(cloudData),
        recommendation: _getRecommendation(type, differences),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to generate conflict summary', e, stackTrace);
      return ConflictSummary(
        type: type,
        differences: ['Unable to analyze differences'],
        localModified: DateTime.now(),
        cloudModified: DateTime.now(),
        recommendation: 'Manual review required',
      );
    }
  }

  /// Get modification time for any data type
  static DateTime _getModificationTime(dynamic data) {
    if (data is CareerSession) {
      return data.lastModified;
    } else if (data is AdvisorInvitation) {
      return data.respondedAt ?? data.sentAt;
    } else if (data is AdvisorResponse) {
      return data.answeredAt;
    } else if (data is CareerSynthesis) {
      return data.lastUpdated ?? data.generatedAt;
    }
    return DateTime.now();
  }

  /// Get recommendation for conflict resolution
  static String _getRecommendation(ConflictType type, List<String> differences) {
    if (differences.isEmpty) {
      return 'No significant differences found - either version can be used';
    }

    switch (type) {
      case ConflictType.careerSession:
        return 'Consider merging to preserve all responses and insights';
      case ConflictType.advisorInvitation:
        return 'Use the version with the most recent status update';
      case ConflictType.advisorResponse:
        return 'Advisor responses should prefer cloud version to maintain integrity';
      case ConflictType.careerSynthesis:
        return 'Merge to combine insights from both versions';
    }
  }
}

/// Exception thrown when manual conflict resolution is required
class ConflictResolutionException implements Exception {
  final String message;
  final ConflictType type;
  final dynamic localData;
  final dynamic cloudData;

  const ConflictResolutionException(this.message, this.type, this.localData, this.cloudData);

  @override
  String toString() => 'ConflictResolutionException: $message';
}

/// Types of data conflicts
enum ConflictType {
  careerSession,
  advisorInvitation,
  advisorResponse,
  careerSynthesis,
}

/// Summary of a data conflict for manual resolution
class ConflictSummary {
  final ConflictType type;
  final List<String> differences;
  final DateTime localModified;
  final DateTime cloudModified;
  final String recommendation;

  const ConflictSummary({
    required this.type,
    required this.differences,
    required this.localModified,
    required this.cloudModified,
    required this.recommendation,
  });

  /// Convert to JSON for UI display
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'differences': differences,
      'localModified': localModified.toIso8601String(),
      'cloudModified': cloudModified.toIso8601String(),
      'recommendation': recommendation,
    };
  }
}

/// Conflict resolution strategies
enum ConflictResolutionStrategy {
  localWins,
  cloudWins,
  lastModifiedWins,
  merge,
  manual,
}