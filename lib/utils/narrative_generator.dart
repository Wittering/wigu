import 'dart:math';
import '../models/career_response.dart';
import '../models/advisor_response.dart';
import '../models/five_insights_model.dart';
import '../models/career_experiment.dart';
import '../utils/logger.dart';

/// Sophisticated narrative generator that creates meaningful career insights
/// by referencing specific user quotes and building coherent stories.
/// Implements Australian workplace context and terminology throughout.
class NarrativeGenerator {
  
  /// Generate comprehensive narrative for Five Insights Model
  Future<String> generateFiveInsightsSummary({
    required List<EnergisrengStrength> energisingStrengths,
    required List<HiddenStrength> hiddenStrengths,
    required List<OverusedTalent> overusedTalents,
    required List<AspirationalStrength> aspirationalStrengths,
    required List<MisalignedEnergy> misalignedEnergies,
  }) async {
    AppLogger.debug('Generating Five Insights narrative summary');

    final buffer = StringBuffer();
    buffer.writeln('Your Career Profile: A Balanced Perspective');
    buffer.writeln('');

    // Opening narrative with Australian context
    buffer.writeln('This comprehensive analysis of your career profile reflects both your own insights and the perspectives of colleagues who know your work well. In the Australian workplace context, understanding this balance between self-perception and external recognition is crucial for strategic career development.');
    buffer.writeln('');

    // Energising Strengths narrative
    if (energisingStrengths.isNotEmpty) {
      buffer.writeln('🚀 **Your Energising Strengths**');
      buffer.writeln('These are your sweet spot areas where high skill meets high energy and strong recognition from others:');
      buffer.writeln('');
      
      for (int i = 0; i < energisingStrengths.take(3).length; i++) {
        final strength = energisingStrengths[i];
        buffer.writeln('**${i + 1}. ${strength.title}**');
        buffer.writeln(strength.description);
        
        if (strength.evidenceFromSelf.isNotEmpty) {
          buffer.writeln('*Your reflection:* "${_selectBestQuote(strength.evidenceFromSelf)}"');
        }
        if (strength.evidenceFromOthers.isNotEmpty) {
          buffer.writeln('*Others observe:* "${_selectBestQuote(strength.evidenceFromOthers)}"');
        }
        if (strength.actionableAdvice != null) {
          buffer.writeln('*Strategic opportunity:* ${strength.actionableAdvice}');
        }
        buffer.writeln('');
      }
    }

    // Hidden Strengths narrative
    if (hiddenStrengths.isNotEmpty) {
      buffer.writeln('💎 **Your Hidden Strengths**');
      buffer.writeln('These capabilities are more visible to others than to yourself—untapped potential for greater impact:');
      buffer.writeln('');
      
      for (int i = 0; i < hiddenStrengths.take(3).length; i++) {
        final strength = hiddenStrengths[i];
        buffer.writeln('**${i + 1}. ${strength.title}**');
        buffer.writeln(strength.description);
        
        buffer.writeln('*Recognition gap:* ${strength.recognitionGap} point${strength.recognitionGap != 1 ? 's' : ''} between your self-assessment and others\' observations.');
        
        if (strength.developmentStrategy != null) {
          buffer.writeln('*Development pathway:* ${strength.developmentStrategy}');
        }
        buffer.writeln('');
      }
    }

    // Overused Talents narrative
    if (overusedTalents.isNotEmpty) {
      buffer.writeln('⚠️ **Areas of Potential Overuse**');
      buffer.writeln('Strong talents that may need rebalancing to prevent burnout and maintain effectiveness:');
      buffer.writeln('');
      
      for (final talent in overusedTalents.take(2)) {
        buffer.writeln('**${talent.title}**');
        buffer.writeln(talent.description);
        
        if (talent.requiresImmediateAttention) {
          buffer.writeln('*Priority:* This area requires immediate attention to prevent burnout.');
        }
        
        if (talent.rebalancingStrategy != null) {
          buffer.writeln('*Rebalancing approach:* ${talent.rebalancingStrategy}');
        }
        buffer.writeln('');
      }
    }

    // Aspirational Strengths narrative
    if (aspirationalStrengths.isNotEmpty) {
      buffer.writeln('🌟 **Your Aspirational Strengths**');
      buffer.writeln('Areas where your passion meets potential—prime targets for strategic development:');
      buffer.writeln('');
      
      for (final aspiration in aspirationalStrengths.take(3)) {
        buffer.writeln('**${aspiration.title}**');
        buffer.writeln(aspiration.description);
        
        buffer.writeln('*Development priority score:* ${aspiration.developmentPriority.toStringAsFixed(1)}/5.0');
        
        if (aspiration.developmentPlan != null) {
          buffer.writeln('*Development pathway:* ${aspiration.developmentPlan}');
        }
        buffer.writeln('');
      }
    }

    // Misaligned Energies narrative
    if (misalignedEnergies.isNotEmpty) {
      buffer.writeln('🔄 **Energy Misalignments**');
      buffer.writeln('Activities that drain your energy despite demonstrated competence—opportunities for redesign:');
      buffer.writeln('');
      
      for (final misalignment in misalignedEnergies.take(2)) {
        buffer.writeln('**${misalignment.title}**');
        buffer.writeln(misalignment.description);
        
        if (misalignment.requiresUrgentAttention) {
          buffer.writeln('*Impact:* High priority for intervention due to significant energy drain.');
        }
        
        if (misalignment.mitigationStrategy != null) {
          buffer.writeln('*Mitigation approach:* ${misalignment.mitigationStrategy}');
        }
        buffer.writeln('');
      }
    }

    // Closing insights
    buffer.writeln('---');
    buffer.writeln('**Strategic Insights for Australian Workplace Success:**');
    buffer.writeln('This profile suggests opportunities to leverage your energising strengths more strategically while addressing areas of imbalance. The Australian workplace values authentic leadership and sustainable performance—your hidden strengths represent untapped potential for increased impact and recognition.');

    return buffer.toString();
  }

  /// Generate narrative for Three Truths framework
  Future<String> generateTruthsNarrative(
    List<Map<String, dynamic>> truths,
    List<CareerResponse> selfResponses,
    List<AdvisorResponse> advisorResponses,
  ) async {
    AppLogger.debug('Generating Three Truths narrative');

    final buffer = StringBuffer();
    buffer.writeln('## Three Core Truths About Your Career Profile');
    buffer.writeln('');
    buffer.writeln('These fundamental insights emerge consistently across both your self-reflection and external feedback:');
    buffer.writeln('');

    for (int i = 0; i < truths.length && i < 3; i++) {
      final truth = truths[i];
      final title = truth['title'] ?? 'Core Truth ${i + 1}';
      final description = truth['description'] ?? '';
      final confidence = truth['confidence'] ?? 0.0;
      final supportingEvidence = truth['supporting_evidence'] as List<String>? ?? [];

      buffer.writeln('### Truth ${i + 1}: $title');
      buffer.writeln(description);
      buffer.writeln('');
      buffer.writeln('*Confidence level:* ${(confidence * 100).round()}%');
      buffer.writeln('');

      // Add supporting quotes
      if (supportingEvidence.isNotEmpty) {
        buffer.writeln('**Supporting evidence:**');
        for (final evidence in supportingEvidence.take(2)) {
          buffer.writeln('> "$evidence"');
        }
        buffer.writeln('');
      }

      // Add contextual insights
      buffer.writeln(_generateTruthContextualInsight(title, description, i + 1));
      buffer.writeln('');
    }

    buffer.writeln('---');
    buffer.writeln('*These truths form the foundation of your career strategy. They represent areas of strong alignment between your self-perception and others\' observations, providing a reliable basis for career planning in the Australian professional context.*');

    return buffer.toString();
  }

  /// Generate narrative for Two Tensions framework
  Future<String> generateTensionsNarrative(
    List<Map<String, dynamic>> tensions,
    List<CareerResponse> selfResponses,
    List<AdvisorResponse> advisorResponses,
  ) async {
    AppLogger.debug('Generating Two Tensions narrative');

    final buffer = StringBuffer();
    buffer.writeln('## Two Creative Tensions for Growth');
    buffer.writeln('');
    buffer.writeln('These productive tensions represent areas where differing perspectives create opportunities for career development:');
    buffer.writeln('');

    for (int i = 0; i < tensions.length && i < 2; i++) {
      final tension = tensions[i];
      final title = tension['title'] ?? 'Creative Tension ${i + 1}';
      final description = tension['description'] ?? '';
      final selfPerspective = tension['self_perspective'] ?? '';
      final othersPerspective = tension['others_perspective'] ?? '';
      final opportunity = tension['opportunity'] ?? '';
      final opportunityScore = tension['opportunity_score'] ?? 0.0;

      buffer.writeln('### Tension ${i + 1}: $title');
      buffer.writeln(description);
      buffer.writeln('');

      buffer.writeln('**Your perspective:** $selfPerspective');
      buffer.writeln('');
      buffer.writeln('**Others\' perspective:** $othersPerspective');
      buffer.writeln('');

      buffer.writeln('**The opportunity:** $opportunity');
      buffer.writeln('*Growth potential:* ${(opportunityScore * 100).round()}%');
      buffer.writeln('');

      // Add tension-specific insights
      buffer.writeln(_generateTensionInsight(title, selfPerspective, othersPerspective, i + 1));
      buffer.writeln('');
    }

    buffer.writeln('---');
    buffer.writeln('*These tensions aren\'t problems to be solved but creative forces to be harnessed. In the Australian workplace, the ability to hold multiple perspectives simultaneously is highly valued and often leads to innovative solutions and career advancement.*');

    return buffer.toString();
  }

  /// Generate narrative for One Experiment framework
  Future<String> generateExperimentNarrative(
    CareerExperiment experiment,
    List<CareerResponse> selfResponses,
    List<AdvisorResponse> advisorResponses,
  ) async {
    AppLogger.debug('Generating One Experiment narrative');

    final buffer = StringBuffer();
    buffer.writeln('## Your Strategic Career Experiment');
    buffer.writeln('');
    buffer.writeln('Based on the insights from your profile, here\'s a focused experiment designed to test and develop a key career hypothesis:');
    buffer.writeln('');

    buffer.writeln('### ${experiment.title}');
    buffer.writeln(experiment.description);
    buffer.writeln('');

    buffer.writeln('**The hypothesis:** ${experiment.hypothesis}');
    buffer.writeln('');

    buffer.writeln('**Why this experiment matters:**');
    buffer.writeln(_generateExperimentRationale(experiment, selfResponses, advisorResponses));
    buffer.writeln('');

    buffer.writeln('**Your ${experiment.estimatedDurationDays}-day experiment:**');
    for (int i = 0; i < experiment.successCriteria.length; i++) {
      buffer.writeln('${i + 1}. ${experiment.successCriteria[i]}');
    }
    buffer.writeln('');

    buffer.writeln('**Success indicators:**');
    for (final metric in experiment.metrics) {
      buffer.writeln('• ${metric.description}');
    }
    buffer.writeln('');

    buffer.writeln('**Australian workplace considerations:**');
    buffer.writeln(_generateAustralianWorkplaceConsiderations(experiment));
    buffer.writeln('');

    buffer.writeln('**Feasibility assessment:** ${(experiment.complexity == ExperimentComplexity.low ? 0.8 : experiment.complexity == ExperimentComplexity.medium ? 0.6 : 0.4 * 100).round()}%');
    buffer.writeln('**Expected timeframe:** ${(experiment.estimatedDurationDays / 7).ceil()} weeks');
    buffer.writeln('');

    buffer.writeln('---');
    buffer.writeln('*This experiment is designed to provide concrete data about a career development opportunity while requiring minimal risk. The Australian professional environment values evidence-based decision-making, making this experimental approach particularly valuable for career planning.*');

    return buffer.toString();
  }

  /// Generate comprehensive career synthesis narrative
  Future<String> generateSynthesisNarrative({
    required List<CareerResponse> selfResponses,
    required List<AdvisorResponse> advisorResponses,
    required double alignmentScore,
    required Map<String, dynamic> johariWindow,
  }) async {
    AppLogger.debug('Generating comprehensive synthesis narrative');

    final buffer = StringBuffer();
    
    // Opening synthesis
    buffer.writeln('# Your Career Mirror: Self-Perception Meets External Reality');
    buffer.writeln('');
    buffer.writeln('This synthesis compares your self-reflections with feedback from ${advisorResponses.length} colleagues, mentors, and peers who know your work. The goal is to create a "mirror effect" that reveals both alignment and opportunities in your career profile.');
    buffer.writeln('');

    // Alignment overview
    final alignmentPercentage = (alignmentScore * 100).round();
    buffer.writeln('## Overall Alignment: $alignmentPercentage%');
    buffer.writeln('');
    buffer.writeln(_generateAlignmentNarrative(alignmentScore, selfResponses, advisorResponses));
    buffer.writeln('');

    // Johari Window insights
    buffer.writeln('## The Johari Window: What\'s Known and Unknown');
    buffer.writeln('');
    buffer.writeln(_generateJohariNarrative(johariWindow));
    buffer.writeln('');

    // Pattern analysis
    buffer.writeln('## Key Pattern Recognition');
    buffer.writeln('');
    buffer.writeln(await _generatePatternAnalysisNarrative(selfResponses, advisorResponses));
    buffer.writeln('');

    // Australian workplace implications
    buffer.writeln('## Australian Workplace Implications');
    buffer.writeln('');
    buffer.writeln(_generateAustralianWorkplaceImplications(selfResponses, advisorResponses, alignmentScore));
    buffer.writeln('');

    return buffer.toString();
  }

  /// Generate role hypothesis narrative with quotes
  Future<String> generateRoleHypothesisNarrative(
    Map<String, dynamic> roleHypothesis,
    List<CareerResponse> selfResponses,
    List<AdvisorResponse> advisorResponses,
  ) async {
    final roleName = roleHypothesis['role_name'] ?? 'Strategic Role';
    final fitScore = roleHypothesis['fit_score'] ?? 0.0;
    final keyStrengths = roleHypothesis['key_strengths'] as List<String>? ?? [];
    final developmentAreas = roleHypothesis['development_areas'] as List<String>? ?? [];
    final supportingQuotes = roleHypothesis['supporting_quotes'] as List<String>? ?? [];

    final buffer = StringBuffer();
    buffer.writeln('## Role Hypothesis: $roleName');
    buffer.writeln('');
    buffer.writeln('**Fit assessment:** ${(fitScore * 100).round()}% match');
    buffer.writeln('');

    buffer.writeln('**Why this role aligns with your profile:**');
    for (final strength in keyStrengths.take(3)) {
      buffer.writeln('• $strength');
    }
    buffer.writeln('');

    if (supportingQuotes.isNotEmpty) {
      buffer.writeln('**Evidence from your responses:**');
      for (final quote in supportingQuotes.take(2)) {
        buffer.writeln('> "$quote"');
      }
      buffer.writeln('');
    }

    if (developmentAreas.isNotEmpty) {
      buffer.writeln('**Areas for development:**');
      for (final area in developmentAreas.take(3)) {
        buffer.writeln('• $area');
      }
      buffer.writeln('');
    }

    buffer.writeln('**Australian market context:**');
    buffer.writeln(_generateAustralianMarketContext(roleName, fitScore));

    return buffer.toString();
  }

  // ===== PRIVATE HELPER METHODS =====

  /// Select the most impactful quote from a list
  String _selectBestQuote(List<String> quotes) {
    if (quotes.isEmpty) return 'No specific quote available';
    
    // Prefer longer, more detailed quotes
    quotes.sort((a, b) => b.length.compareTo(a.length));
    
    // Take the first substantial quote (at least 20 characters)
    for (final quote in quotes) {
      if (quote.trim().length >= 20) {
        return _truncateQuote(quote.trim());
      }
    }
    
    return _truncateQuote(quotes.first.trim());
  }

  /// Truncate quote to reasonable length while preserving meaning
  String _truncateQuote(String quote, {int maxLength = 120}) {
    if (quote.length <= maxLength) return quote;
    
    // Find the last complete sentence or clause within limit
    final truncated = quote.substring(0, maxLength);
    final lastPeriod = truncated.lastIndexOf('.');
    final lastComma = truncated.lastIndexOf(',');
    
    if (lastPeriod > maxLength * 0.7) {
      return quote.substring(0, lastPeriod + 1);
    } else if (lastComma > maxLength * 0.8) {
      return '${quote.substring(0, lastComma)}...';
    }
    
    return '$truncated...';
  }

  /// Generate contextual insight for a truth
  String _generateTruthContextualInsight(String title, String description, int truthNumber) {
    final insights = [
      'This represents a fundamental strength you can confidently build your career strategy around.',
      'This core truth provides a stable foundation for making career decisions and taking on new challenges.',
      'This insight suggests a reliable pattern that will likely serve you well across different roles and contexts.',
    ];
    
    if (truthNumber <= insights.length) {
      return '*Strategic implication:* ${insights[truthNumber - 1]}';
    }
    
    return '*Strategic implication:* This core truth provides reliable guidance for your career development.';
  }

  /// Generate insight for a tension
  String _generateTensionInsight(String title, String selfPerspective, String othersPerspective, int tensionNumber) {
    final insights = [
      'This tension suggests an opportunity to expand how you present and position your capabilities.',
      'The gap between these perspectives indicates potential for increased visibility and recognition.',
    ];
    
    if (tensionNumber <= insights.length) {
      return '*Growth insight:* ${insights[tensionNumber - 1]}';
    }
    
    return '*Growth insight:* This tension represents valuable feedback for career development.';
  }

  /// Generate rationale for an experiment
  String _generateExperimentRationale(
    CareerExperiment experiment,
    List<CareerResponse> selfResponses,
    List<AdvisorResponse> advisorResponses,
  ) {
    final buffer = StringBuffer();
    
    buffer.writeln('This experiment addresses a key insight from your career synthesis. ');
    
    if (experiment.type == ExperimentType.visibilityBuilding) {
      buffer.writeln('Your advisor feedback suggests capabilities that you may be undervaluing or underutilising. Testing this through structured visibility will help you understand the market value of these skills.');
    } else if (experiment.type == ExperimentType.skillBuilding) {
      buffer.writeln('Your interest and passion in this area, combined with development potential, makes this an ideal area for strategic investment of time and energy.');
    } else if (experiment.type == ExperimentType.workEnvironment) {
      buffer.writeln('The evidence suggests you may be overusing a strength to the point of diminishing returns. This experiment will help you find better balance.');
    } else {
      buffer.writeln('This experiment will provide concrete data to inform your career development decisions.');
    }
    
    buffer.writeln('The 30-day timeframe allows for meaningful testing while minimising risk.');
    
    return buffer.toString();
  }

  /// Generate Australian workplace considerations for an experiment
  String _generateAustralianWorkplaceConsiderations(CareerExperiment experiment) {
    final considerations = [
      'Australian workplaces value collaborative approaches, so consider involving your team in relevant aspects of this experiment.',
      'The Australian professional culture appreciates direct communication, making this an ideal environment for seeking feedback.',
      'Consider timing this experiment around performance review cycles to maximise the visibility of results.',
      'Australian organisations often support professional development initiatives, so explore whether this aligns with existing programs.',
    ];
    
    final random = Random();
    return considerations[random.nextInt(considerations.length)];
  }

  /// Generate alignment narrative based on score
  String _generateAlignmentNarrative(
    double alignmentScore,
    List<CareerResponse> selfResponses,
    List<AdvisorResponse> advisorResponses,
  ) {
    if (alignmentScore >= 0.8) {
      return 'Your self-perception strongly aligns with how others see you. This high alignment suggests strong self-awareness and indicates that you\'re well-positioned to make confident career decisions. The consistency between internal and external perspectives provides a solid foundation for strategic career planning.';
    } else if (alignmentScore >= 0.6) {
      return 'There\'s good general alignment between your self-perception and external feedback, with some interesting areas of divergence. These differences represent opportunities for growth—either by developing new capabilities or by better communicating existing strengths. The balance of alignment and divergence is healthy for continued development.';
    } else if (alignmentScore >= 0.4) {
      return 'Your self-perception and external feedback show moderate alignment with several significant differences. This pattern often indicates either hidden strengths that others see but you undervalue, or aspirational areas where you see potential that others haven\'t yet recognised. These gaps represent rich opportunities for career development conversations and strategic positioning.';
    } else {
      return 'There are substantial differences between your self-perception and external feedback. This isn\'t necessarily problematic—it often indicates either significant hidden potential or areas where better communication about your capabilities could dramatically improve recognition. The low alignment suggests high potential for strategic career moves through better positioning and visibility.';
    }
  }

  /// Generate Johari Window narrative
  String _generateJohariNarrative(Map<String, dynamic> johariWindow) {
    final buffer = StringBuffer();
    
    final openArena = johariWindow['open_arena'] as Map<String, dynamic>? ?? {};
    final blindSpot = johariWindow['blind_spot'] as Map<String, dynamic>? ?? {};
    final hiddenArena = johariWindow['hidden_arena'] as Map<String, dynamic>? ?? {};
    final unknownArena = johariWindow['unknown_arena'] as Map<String, dynamic>? ?? {};
    
    final openCount = openArena['count'] ?? 0;
    final blindCount = blindSpot['count'] ?? 0;
    final hiddenCount = hiddenArena['count'] ?? 0;
    final unknownCount = unknownArena['count'] ?? 0;
    
    buffer.writeln('**Open Arena (${openCount} themes):** ${openArena['description']}');
    if (openCount > 0) {
      buffer.writeln('These represent your most reliable strengths for career positioning.');
    }
    buffer.writeln('');
    
    buffer.writeln('**Blind Spot (${blindCount} themes):** ${blindSpot['description']}');
    if (blindCount > 0) {
      buffer.writeln('Focus here for quick wins in self-awareness and capability recognition.');
    }
    buffer.writeln('');
    
    buffer.writeln('**Hidden Arena (${hiddenCount} themes):** ${hiddenArena['description']}');
    if (hiddenCount > 0) {
      buffer.writeln('These areas offer opportunities for increased visibility and recognition.');
    }
    buffer.writeln('');
    
    buffer.writeln('**Unknown Arena (${unknownCount} themes):** ${unknownArena['description']}');
    if (unknownCount > 0) {
      buffer.writeln('Consider these for longer-term exploration and development.');
    }
    
    return buffer.toString();
  }

  /// Generate pattern analysis narrative
  Future<String> _generatePatternAnalysisNarrative(
    List<CareerResponse> selfResponses,
    List<AdvisorResponse> advisorResponses,
  ) async {
    final buffer = StringBuffer();
    
    // Analyze response patterns
    final selfThemes = _extractAllThemes(selfResponses);
    final advisorThemes = _extractAllAdvisorThemes(advisorResponses);
    
    final mostCommonSelfTheme = _findMostCommonTheme(selfThemes);
    final mostCommonAdvisorTheme = _findMostCommonTheme(advisorThemes);
    
    buffer.writeln('**Most prominent theme in your responses:** $mostCommonSelfTheme');
    buffer.writeln('**Most prominent theme in advisor feedback:** $mostCommonAdvisorTheme');
    buffer.writeln('');
    
    if (mostCommonSelfTheme == mostCommonAdvisorTheme) {
      buffer.writeln('The strong alignment on this theme suggests it\'s a core part of your professional identity and a reliable foundation for career strategy.');
    } else {
      buffer.writeln('The difference between these themes highlights an opportunity to bridge self-perception with external recognition or to better communicate your strengths.');
    }
    
    return buffer.toString();
  }

  /// Generate Australian workplace implications
  String _generateAustralianWorkplaceImplications(
    List<CareerResponse> selfResponses,
    List<AdvisorResponse> advisorResponses,
    double alignmentScore,
  ) {
    final buffer = StringBuffer();
    
    buffer.writeln('In the Australian professional context, this synthesis suggests several strategic considerations:');
    buffer.writeln('');
    
    if (alignmentScore >= 0.7) {
      buffer.writeln('• **High self-awareness advantage:** Australian employers value authenticity and self-awareness. Your strong alignment positions you well for leadership opportunities.');
      buffer.writeln('• **Confident positioning:** You can speak confidently about your strengths knowing they\'re externally validated.');
    } else {
      buffer.writeln('• **Growth opportunity:** The Australian workplace culture supports direct feedback and development conversations. Use these insights to initiate meaningful discussions with managers and mentors.');
      buffer.writeln('• **Positioning strategy:** Consider how to better communicate your strengths or address perception gaps through strategic visibility initiatives.');
    }
    
    buffer.writeln('• **Cultural fit:** Australian organisations appreciate collaborative team players who contribute to positive workplace culture while delivering results.');
    buffer.writeln('• **Career conversations:** This synthesis provides excellent fodder for performance reviews, career planning discussions, and professional development conversations.');
    
    return buffer.toString();
  }

  /// Generate Australian market context for a role
  String _generateAustralianMarketContext(String roleName, double fitScore) {
    final marketInsights = [
      'The Australian market shows strong demand for professionals who combine technical capability with collaborative leadership skills.',
      'Australian organisations increasingly value professionals who can navigate both strategic thinking and practical implementation.',
      'The local market appreciates authentic leadership styles that balance confidence with humility and team focus.',
      'Australian employers seek professionals who can contribute to positive workplace culture while driving business results.',
    ];
    
    final baseInsight = marketInsights[Random().nextInt(marketInsights.length)];
    
    if (fitScore >= 0.8) {
      return '$baseInsight Your high alignment with this role positions you strongly for the Australian market.';
    } else if (fitScore >= 0.6) {
      return '$baseInsight With targeted development in key areas, you could be highly competitive for this type of role.';
    } else {
      return '$baseInsight While this represents a stretch opportunity, the Australian market values growth-oriented professionals who take on challenges.';
    }
  }

  // ===== UTILITY METHODS =====

  List<String> _extractAllThemes(List<CareerResponse> responses) {
    return responses.expand((r) => r.keyThemes).toList();
  }

  List<String> _extractAllAdvisorThemes(List<AdvisorResponse> responses) {
    return responses.expand((r) => r.keyThemes).toList();
  }

  String _findMostCommonTheme(List<String> themes) {
    if (themes.isEmpty) return 'No themes identified';
    
    final themeCount = <String, int>{};
    for (final theme in themes) {
      themeCount[theme] = (themeCount[theme] ?? 0) + 1;
    }
    
    return themeCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}