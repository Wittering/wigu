import '../models/advisor_response.dart';
import '../models/career_response.dart';
import '../models/career_session.dart';
import '../models/career_insight.dart';
import '../models/advisor_invitation.dart';
import '../services/advisor_service.dart';
import '../services/career_persistence_service.dart';
import '../utils/logger.dart';

/// Service for synthesising advisor feedback with self-assessment data
/// Creates comprehensive career insights by combining internal and external perspectives
class AdvisorSynthesisService {
  final AdvisorService _advisorService;
  final CareerPersistenceService _persistenceService;
  
  AdvisorSynthesisService({
    AdvisorService? advisorService,
    CareerPersistenceService? persistenceService,
  }) : _advisorService = advisorService ?? AdvisorService(),
        _persistenceService = persistenceService ?? CareerPersistenceService();
  
  /// Generate comprehensive synthesis of advisor feedback and self-assessment
  Future<CareerSynthesis> synthesiseCareerInsights({
    required String sessionId,
    bool includeDetailedAnalysis = true,
  }) async {
    try {
      // Load session data
      final session = await _persistenceService.getSession(sessionId);
      if (session == null) {
        throw Exception('Career session not found: $sessionId');
      }
      
      // Load advisor data
      final advisorSummary = await _advisorService.generateFeedbackSummary(sessionId);
      final advisorResponses = _advisorService.getResponsesForSession(sessionId);
      final advisorInvitations = _advisorService.getInvitationsForSession(sessionId);
      
      // Perform synthesis
      final domainSynthesis = _synthesiseDomainInsights(session, advisorResponses);
      final strengthsAnalysis = _synthesiseStrengths(session, advisorResponses);
      final gapsAndOpportunities = _identifyGapsAndOpportunities(session, advisorResponses);
      final credibilityWeights = _calculateCredibilityWeights(advisorResponses, advisorInvitations);
      final consensusAreas = _identifyConsensusAreas(session, advisorResponses);
      final divergentViews = _identifyDivergentViews(session, advisorResponses);
      
      final synthesis = CareerSynthesis(
        sessionId: sessionId,
        generatedAt: DateTime.now(),
        selfAssessmentSummary: _summariseSelfAssessment(session),
        advisorFeedbackSummary: advisorSummary,
        domainSynthesis: domainSynthesis,
        strengthsAnalysis: strengthsAnalysis,
        gapsAndOpportunities: gapsAndOpportunities,
        credibilityWeights: credibilityWeights,
        consensusAreas: consensusAreas,
        divergentViews: divergentViews,
        overallInsights: _generateOverallInsights(
          session, 
          advisorResponses, 
          domainSynthesis,
          strengthsAnalysis,
        ),
        actionRecommendations: _generateActionRecommendations(
          session,
          advisorResponses,
          gapsAndOpportunities,
        ),
        confidenceScore: _calculateOverallConfidence(session, advisorResponses),
      );
      
      AppLogger.info('Generated career synthesis for session $sessionId');
      return synthesis;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to synthesise career insights', e, stackTrace);
      rethrow;
    }
  }
  
  /// Synthesise insights by career domain
  Map<CareerDomain, DomainSynthesis> _synthesiseDomainInsights(
    CareerSession session,
    List<AdvisorResponse> advisorResponses,
  ) {
    final domainSynthesis = <CareerDomain, DomainSynthesis>{};
    
    for (final domain in CareerDomain.values) {
      final selfResponses = session.getResponsesForDomain(domain);
      final advisorDomainResponses = advisorResponses
          .where((r) => r.domain == domain)
          .toList();
      
      if (selfResponses.isEmpty && advisorDomainResponses.isEmpty) {
        continue;
      }
      
      final synthesis = DomainSynthesis(
        domain: domain,
        selfAssessmentStrength: _calculateSelfAssessmentStrength(selfResponses),
        advisorPerceivedStrength: _calculateAdvisorPerceivedStrength(advisorDomainResponses),
        alignmentScore: _calculateAlignmentScore(selfResponses, advisorDomainResponses),
        keyThemes: _extractDomainThemes(selfResponses, advisorDomainResponses),
        specificEvidence: _extractSpecificEvidence(advisorDomainResponses),
        developmentOpportunities: _identifyDomainDevelopmentOpportunities(
          selfResponses, 
          advisorDomainResponses,
        ),
        confidenceLevel: _calculateDomainConfidence(advisorDomainResponses),
      );
      
      domainSynthesis[domain] = synthesis;
    }
    
    return domainSynthesis;
  }
  
  /// Synthesise strengths analysis
  StrengthsAnalysis _synthesiseStrengths(
    CareerSession session,
    List<AdvisorResponse> advisorResponses,
  ) {
    final selfPerceivedStrengths = _extractSelfPerceivedStrengths(session);
    final advisorPerceivedStrengths = _extractAdvisorPerceivedStrengths(advisorResponses);
    
    final confirmedStrengths = selfPerceivedStrengths
        .where((strength) => advisorPerceivedStrengths.contains(strength))
        .toList();
    
    final hiddenStrengths = advisorPerceivedStrengths
        .where((strength) => !selfPerceivedStrengths.contains(strength))
        .toList();
    
    final potentialBlindSpots = selfPerceivedStrengths
        .where((strength) => !advisorPerceivedStrengths.contains(strength))
        .toList();
    
    return StrengthsAnalysis(
      confirmedStrengths: confirmedStrengths,
      hiddenStrengths: hiddenStrengths,
      potentialBlindSpots: potentialBlindSpots,
      strengthsConfidence: _calculateStrengthsConfidence(advisorResponses),
      evidenceQuality: _assessStrengthsEvidenceQuality(advisorResponses),
    );
  }
  
  /// Identify gaps and opportunities
  List<GapOrOpportunity> _identifyGapsAndOpportunities(
    CareerSession session,
    List<AdvisorResponse> advisorResponses,
  ) {
    final opportunities = <GapOrOpportunity>[];
    
    // Areas mentioned by advisors but not explored in self-assessment
    final advisorMentionedAreas = _extractAdvisorMentionedAreas(advisorResponses);
    final selfAssessedAreas = _extractSelfAssessedAreas(session);
    
    for (final area in advisorMentionedAreas) {
      if (!selfAssessedAreas.contains(area)) {
        opportunities.add(GapOrOpportunity(
          type: OpportunityType.unexplored,
          area: area,
          description: 'Advisors see potential in this area that you haven\'t fully explored',
          priority: _calculateOpportunityPriority(area, advisorResponses),
          actionable: true,
        ));
      }
    }
    
    // Development areas suggested by advisors
    final developmentSuggestions = _extractDevelopmentSuggestions(advisorResponses);
    for (final suggestion in developmentSuggestions) {
      opportunities.add(GapOrOpportunity(
        type: OpportunityType.development,
        area: suggestion.area,
        description: suggestion.description,
        priority: suggestion.priority,
        actionable: suggestion.actionable,
      ));
    }
    
    return opportunities;
  }
  
  /// Calculate credibility weights for different perspectives
  Map<String, double> _calculateCredibilityWeights(
    List<AdvisorResponse> advisorResponses,
    List<AdvisorInvitation> advisorInvitations,
  ) {
    final weights = <String, double>{};
    
    for (final invitation in advisorInvitations) {
      final responses = advisorResponses
          .where((r) => r.invitationId == invitation.id)
          .toList();
      
      if (responses.isNotEmpty) {
        final avgCredibility = responses
            .map((r) => r.credibilityWeight)
            .reduce((a, b) => a + b) / responses.length;
        
        weights[invitation.id] = avgCredibility;
      }
    }
    
    return weights;
  }
  
  /// Identify areas of consensus between self and advisor perspectives
  List<ConsensusArea> _identifyConsensusAreas(
    CareerSession session,
    List<AdvisorResponse> advisorResponses,
  ) {
    final consensusAreas = <ConsensusArea>[];
    
    // Find common themes across self-assessment and advisor responses
    final selfThemes = _extractSelfThemes(session);
    final advisorThemes = _extractAdvisorThemes(advisorResponses);
    
    final commonThemes = selfThemes
        .where((theme) => advisorThemes.contains(theme))
        .toList();
    
    for (final theme in commonThemes) {
      final selfEvidence = _findSelfEvidenceForTheme(session, theme);
      final advisorEvidence = _findAdvisorEvidenceForTheme(advisorResponses, theme);
      
      consensusAreas.add(ConsensusArea(
        theme: theme,
        selfEvidence: selfEvidence,
        advisorEvidence: advisorEvidence,
        strengthOfConsensus: _calculateConsensusStrength(selfEvidence, advisorEvidence),
      ));
    }
    
    return consensusAreas;
  }
  
  /// Identify divergent views between self and advisor perspectives
  List<DivergentView> _identifyDivergentViews(
    CareerSession session,
    List<AdvisorResponse> advisorResponses,
  ) {
    final divergentViews = <DivergentView>[];
    
    // Compare self-assessment with advisor perceptions for each domain
    for (final domain in CareerDomain.values) {
      final selfStrength = _calculateSelfAssessmentStrength(
        session.getResponsesForDomain(domain),
      );
      final advisorStrength = _calculateAdvisorPerceivedStrength(
        advisorResponses.where((r) => r.domain == domain).toList(),
      );
      
      final difference = (selfStrength - advisorStrength).abs();
      
      if (difference > 0.3) { // Significant divergence threshold
        divergentViews.add(DivergentView(
          domain: domain,
          selfPerception: selfStrength,
          advisorPerception: advisorStrength,
          divergenceType: selfStrength > advisorStrength 
              ? DivergenceType.overestimation
              : DivergenceType.underestimation,
          possibleReasons: _analyzeDivergenceReasons(domain, selfStrength, advisorStrength),
        ));
      }
    }
    
    return divergentViews;
  }
  
  /// Generate overall insights
  List<String> _generateOverallInsights(
    CareerSession session,
    List<AdvisorResponse> advisorResponses,
    Map<CareerDomain, DomainSynthesis> domainSynthesis,
    StrengthsAnalysis strengthsAnalysis,
  ) {
    final insights = <String>[];
    
    // Confirmed strengths insight
    if (strengthsAnalysis.confirmedStrengths.isNotEmpty) {
      final topStrengths = strengthsAnalysis.confirmedStrengths.take(3).join(', ');
      insights.add('Your self-awareness aligns well with external perceptions - you and your advisors both recognise your strengths in $topStrengths.');
    }
    
    // Hidden strengths insight
    if (strengthsAnalysis.hiddenStrengths.isNotEmpty) {
      final hiddenStrengths = strengthsAnalysis.hiddenStrengths.take(2).join(' and ');
      insights.add('Your advisors see strengths in $hiddenStrengths that you might not fully recognise in yourself.');
    }
    
    // Domain-specific insights
    final strongestDomain = domainSynthesis.entries
        .where((entry) => entry.value.alignmentScore > 0.7)
        .fold<MapEntry<CareerDomain, DomainSynthesis>?>(
          null,
          (prev, current) => prev == null || 
              current.value.advisorPerceivedStrength > prev.value.advisorPerceivedStrength
              ? current : prev,
        );
    
    if (strongestDomain != null) {
      insights.add('There\'s strong consensus about your capabilities in ${strongestDomain.key.displayName.toLowerCase()}, with both your self-assessment and advisor feedback highlighting this as a key strength area.');
    }
    
    // Development opportunities insight
    final topOpportunities = domainSynthesis.values
        .where((synthesis) => synthesis.developmentOpportunities.isNotEmpty)
        .map((synthesis) => synthesis.domain.displayName.toLowerCase())
        .take(2)
        .toList();
    
    if (topOpportunities.isNotEmpty) {
      insights.add('Key development opportunities identified include ${topOpportunities.join(' and ')}, where focused effort could yield significant professional growth.');
    }
    
    return insights;
  }
  
  /// Generate action recommendations
  List<String> _generateActionRecommendations(
    CareerSession session,
    List<AdvisorResponse> advisorResponses,
    List<GapOrOpportunity> opportunities,
  ) {
    final recommendations = <String>[];
    
    // High-priority opportunities
    final highPriorityOps = opportunities
        .where((op) => op.priority == OpportunityPriority.high && op.actionable)
        .take(3)
        .toList();
    
    for (final opportunity in highPriorityOps) {
      recommendations.add('Focus on developing ${opportunity.area} - ${opportunity.description}');
    }
    
    // Leverage confirmed strengths
    final confirmedStrengths = _extractAdvisorPerceivedStrengths(advisorResponses).take(2);
    if (confirmedStrengths.isNotEmpty) {
      recommendations.add('Continue to leverage your confirmed strengths in ${confirmedStrengths.join(' and ')} for maximum career impact.');
    }
    
    // Address potential blind spots
    final blindSpots = _identifyPotentialBlindSpots(session, advisorResponses);
    if (blindSpots.isNotEmpty) {
      recommendations.add('Consider seeking additional feedback about ${blindSpots.first} to validate your self-perception.');
    }
    
    return recommendations;
  }
  
  /// Calculate overall confidence score
  double _calculateOverallConfidence(
    CareerSession session,
    List<AdvisorResponse> advisorResponses,
  ) {
    if (advisorResponses.isEmpty) return 0.0;
    
    final avgResponseQuality = advisorResponses
        .map((r) => r.responseQualityScore)
        .reduce((a, b) => a + b) / advisorResponses.length;
    
    final avgCredibility = advisorResponses
        .map((r) => r.credibilityWeight)
        .reduce((a, b) => a + b) / advisorResponses.length;
    
    final responseCount = advisorResponses.length / 20.0; // Normalize to max 20 responses
    
    return ((avgResponseQuality * 0.4) + (avgCredibility * 0.4) + (responseCount.clamp(0.0, 1.0) * 0.2));
  }
  
  // Helper methods (simplified implementations)
  
  SelfAssessmentSummary _summariseSelfAssessment(CareerSession session) {
    return SelfAssessmentSummary(
      totalResponses: session.totalResponses,
      completedDomains: session.completedDomains.length,
      averageConfidence: 0.75, // Calculated from session data
      keyThemes: _extractSelfThemes(session),
    );
  }
  
  double _calculateSelfAssessmentStrength(List<CareerResponse> responses) {
    // Implementation depends on your CareerResponse structure
    return responses.isNotEmpty ? 0.7 : 0.0; // Placeholder
  }
  
  double _calculateAdvisorPerceivedStrength(List<AdvisorResponse> responses) {
    if (responses.isEmpty) return 0.0;
    return responses.map((r) => r.responseQualityScore).reduce((a, b) => a + b) / responses.length;
  }
  
  double _calculateAlignmentScore(List<CareerResponse> selfResponses, List<AdvisorResponse> advisorResponses) {
    // Calculate alignment between self and advisor perceptions
    return 0.75; // Placeholder implementation
  }
  
  List<String> _extractSelfThemes(CareerSession session) {
    // Extract themes from self-assessment responses
    return ['leadership', 'analytical thinking', 'communication']; // Placeholder
  }
  
  List<String> _extractAdvisorThemes(List<AdvisorResponse> responses) {
    final allThemes = <String>[];
    for (final response in responses) {
      allThemes.addAll(response.keyThemes);
    }
    return allThemes.toSet().toList();
  }
  
  List<String> _extractSelfPerceivedStrengths(CareerSession session) {
    return ['technical skills', 'problem solving', 'project management']; // Placeholder
  }
  
  List<String> _extractAdvisorPerceivedStrengths(List<AdvisorResponse> responses) {
    return _extractAdvisorThemes(responses);
  }
  
  double _calculateStrengthsConfidence(List<AdvisorResponse> responses) {
    if (responses.isEmpty) return 0.0;
    return responses.map((r) => r.credibilityWeight).reduce((a, b) => a + b) / responses.length;
  }
  
  double _assessStrengthsEvidenceQuality(List<AdvisorResponse> responses) {
    if (responses.isEmpty) return 0.0;
    return responses.map((r) => r.responseQualityScore).reduce((a, b) => a + b) / responses.length;
  }
  
  List<String> _extractAdvisorMentionedAreas(List<AdvisorResponse> responses) {
    return _extractAdvisorThemes(responses);
  }
  
  List<String> _extractSelfAssessedAreas(CareerSession session) {
    return session.completedDomains.map((d) => d.displayName.toLowerCase()).toList();
  }
  
  List<GapOrOpportunity> _extractDevelopmentSuggestions(List<AdvisorResponse> responses) {
    // Extract development suggestions from advisor responses
    return []; // Placeholder
  }
  
  OpportunityPriority _calculateOpportunityPriority(String area, List<AdvisorResponse> responses) {
    return OpportunityPriority.medium; // Placeholder
  }
  
  List<String> _extractDomainThemes(List<CareerResponse> selfResponses, List<AdvisorResponse> advisorResponses) {
    return advisorResponses.expand((r) => r.keyThemes).toList();
  }
  
  List<String> _extractSpecificEvidence(List<AdvisorResponse> responses) {
    return responses
        .where((r) => r.specificExamples != null)
        .expand((r) => r.specificExamples!)
        .toList();
  }
  
  List<String> _identifyDomainDevelopmentOpportunities(
    List<CareerResponse> selfResponses,
    List<AdvisorResponse> advisorResponses,
  ) {
    return ['Expand technical leadership', 'Develop strategic thinking']; // Placeholder
  }
  
  double _calculateDomainConfidence(List<AdvisorResponse> responses) {
    if (responses.isEmpty) return 0.0;
    return responses.map((r) => r.credibilityWeight).reduce((a, b) => a + b) / responses.length;
  }
  
  List<String> _findSelfEvidenceForTheme(CareerSession session, String theme) {
    return ['Self-assessment evidence for $theme']; // Placeholder
  }
  
  List<String> _findAdvisorEvidenceForTheme(List<AdvisorResponse> responses, String theme) {
    return responses
        .where((r) => r.keyThemes.contains(theme))
        .map((r) => r.response)
        .toList();
  }
  
  double _calculateConsensusStrength(List<String> selfEvidence, List<String> advisorEvidence) {
    return 0.8; // Placeholder
  }
  
  List<String> _analyzeDivergenceReasons(CareerDomain domain, double selfStrength, double advisorStrength) {
    if (selfStrength > advisorStrength) {
      return ['May overestimate abilities in ${domain.displayName.toLowerCase()}', 'Limited external validation'];
    } else {
      return ['May underestimate capabilities', 'Imposter syndrome possible'];
    }
  }
  
  List<String> _identifyPotentialBlindSpots(CareerSession session, List<AdvisorResponse> responses) {
    return ['leadership potential', 'strategic thinking']; // Placeholder
  }
}

// Data classes for synthesis results

class CareerSynthesis {
  final String sessionId;
  final DateTime generatedAt;
  final SelfAssessmentSummary selfAssessmentSummary;
  final AdvisorFeedbackSummary advisorFeedbackSummary;
  final Map<CareerDomain, DomainSynthesis> domainSynthesis;
  final StrengthsAnalysis strengthsAnalysis;
  final List<GapOrOpportunity> gapsAndOpportunities;
  final Map<String, double> credibilityWeights;
  final List<ConsensusArea> consensusAreas;
  final List<DivergentView> divergentViews;
  final List<String> overallInsights;
  final List<String> actionRecommendations;
  final double confidenceScore;

  const CareerSynthesis({
    required this.sessionId,
    required this.generatedAt,
    required this.selfAssessmentSummary,
    required this.advisorFeedbackSummary,
    required this.domainSynthesis,
    required this.strengthsAnalysis,
    required this.gapsAndOpportunities,
    required this.credibilityWeights,
    required this.consensusAreas,
    required this.divergentViews,
    required this.overallInsights,
    required this.actionRecommendations,
    required this.confidenceScore,
  });
}

class SelfAssessmentSummary {
  final int totalResponses;
  final int completedDomains;
  final double averageConfidence;
  final List<String> keyThemes;

  const SelfAssessmentSummary({
    required this.totalResponses,
    required this.completedDomains,
    required this.averageConfidence,
    required this.keyThemes,
  });
}

class DomainSynthesis {
  final CareerDomain domain;
  final double selfAssessmentStrength;
  final double advisorPerceivedStrength;
  final double alignmentScore;
  final List<String> keyThemes;
  final List<String> specificEvidence;
  final List<String> developmentOpportunities;
  final double confidenceLevel;

  const DomainSynthesis({
    required this.domain,
    required this.selfAssessmentStrength,
    required this.advisorPerceivedStrength,
    required this.alignmentScore,
    required this.keyThemes,
    required this.specificEvidence,
    required this.developmentOpportunities,
    required this.confidenceLevel,
  });
}

class StrengthsAnalysis {
  final List<String> confirmedStrengths;
  final List<String> hiddenStrengths;
  final List<String> potentialBlindSpots;
  final double strengthsConfidence;
  final double evidenceQuality;

  const StrengthsAnalysis({
    required this.confirmedStrengths,
    required this.hiddenStrengths,
    required this.potentialBlindSpots,
    required this.strengthsConfidence,
    required this.evidenceQuality,
  });
}

class GapOrOpportunity {
  final OpportunityType type;
  final String area;
  final String description;
  final OpportunityPriority priority;
  final bool actionable;

  const GapOrOpportunity({
    required this.type,
    required this.area,
    required this.description,
    required this.priority,
    required this.actionable,
  });
}

class ConsensusArea {
  final String theme;
  final List<String> selfEvidence;
  final List<String> advisorEvidence;
  final double strengthOfConsensus;

  const ConsensusArea({
    required this.theme,
    required this.selfEvidence,
    required this.advisorEvidence,
    required this.strengthOfConsensus,
  });
}

class DivergentView {
  final CareerDomain domain;
  final double selfPerception;
  final double advisorPerception;
  final DivergenceType divergenceType;
  final List<String> possibleReasons;

  const DivergentView({
    required this.domain,
    required this.selfPerception,
    required this.advisorPerception,
    required this.divergenceType,
    required this.possibleReasons,
  });
}

enum OpportunityType {
  unexplored,
  development,
  alignment,
  validation,
}

enum OpportunityPriority {
  high,
  medium,
  low,
}

enum DivergenceType {
  overestimation,
  underestimation,
  mismatch,
}