import 'dart:math';
import '../models/career_response.dart';
import '../models/advisor_response.dart';
import '../models/five_insights_model.dart';
import '../utils/logger.dart';

/// Sophisticated utility for categorizing career insights into the 5 framework categories.
/// Uses pattern recognition and sentiment analysis to identify:
/// - Energising Strength (high self + high others)
/// - Hidden Strength (low self + high others) 
/// - Overused Talent (high self + mixed others with caveats)
/// - Aspirational (high self desire + low others recognition)
/// - Misaligned Energy (high self energy + low others value)
class InsightCategorizer {
  
  /// Identify Energising Strengths: High skill + high energy + recognised by others
  Future<List<EnergisrengStrength>> identifyEnergisingStrengths({
    required List<CareerResponse> selfResponses,
    required List<AdvisorResponse> advisorResponses,
  }) async {
    AppLogger.debug('Identifying energising strengths');

    final strengths = <EnergisrengStrength>[];
    final selfStrengthMap = _extractSelfStrengthIndicators(selfResponses);
    final advisorStrengthMap = _extractAdvisorStrengthIndicators(advisorResponses);

    for (final selfStrength in selfStrengthMap.entries) {
      final strengthName = selfStrength.key;
      final selfData = selfStrength.value;
      
      // Look for corresponding advisor recognition
      final advisorData = advisorStrengthMap[strengthName];
      
      if (advisorData != null && _isEnergisingStrength(selfData, advisorData)) {
        final strength = await _createEnergisingStrength(
          strengthName: strengthName,
          selfData: selfData,
          advisorData: advisorData,
          selfResponses: selfResponses,
          advisorResponses: advisorResponses,
        );
        
        if (strength != null) {
          strengths.add(strength);
        }
      }
    }

    // Sort by overall score (skill + energy + recognition + leverageability)
    strengths.sort((a, b) => b.overallScore.compareTo(a.overallScore));
    
    AppLogger.info('Identified ${strengths.length} energising strengths');
    return strengths.take(5).toList(); // Limit to top 5
  }

  /// Identify Hidden Strengths: High competence but underrecognised or underutilised
  Future<List<HiddenStrength>> identifyHiddenStrengths({
    required List<CareerResponse> selfResponses,
    required List<AdvisorResponse> advisorResponses,
  }) async {
    AppLogger.debug('Identifying hidden strengths');

    final hiddenStrengths = <HiddenStrength>[];
    final selfStrengthMap = _extractSelfStrengthIndicators(selfResponses);
    final advisorStrengthMap = _extractAdvisorStrengthIndicators(advisorResponses);

    // Look for strengths mentioned by advisors but undervalued by self
    for (final advisorStrength in advisorStrengthMap.entries) {
      final strengthName = advisorStrength.key;
      final advisorData = advisorStrength.value;
      final selfData = selfStrengthMap[strengthName];

      if (_isHiddenStrength(selfData, advisorData)) {
        final hiddenStrength = await _createHiddenStrength(
          strengthName: strengthName,
          selfData: selfData,
          advisorData: advisorData,
          selfResponses: selfResponses,
          advisorResponses: advisorResponses,
        );
        
        if (hiddenStrength != null) {
          hiddenStrengths.add(hiddenStrength);
        }
      }
    }

    // Also check for patterns where advisors consistently mention things self doesn't
    final additionalHidden = await _findAdditionalHiddenStrengths(selfResponses, advisorResponses);
    hiddenStrengths.addAll(additionalHidden);

    // Sort by potential impact and recognition gap
    hiddenStrengths.sort((a, b) {
      final scoreA = a.potentialImpact + a.recognitionGap;
      final scoreB = b.potentialImpact + b.recognitionGap;
      return scoreB.compareTo(scoreA);
    });

    AppLogger.info('Identified ${hiddenStrengths.length} hidden strengths');
    return hiddenStrengths.take(4).toList(); // Limit to top 4
  }

  /// Identify Overused Talents: Strong skill but potentially overused, leading to fatigue
  Future<List<OverusedTalent>> identifyOverusedTalents({
    required List<CareerResponse> selfResponses,
    required List<AdvisorResponse> advisorResponses,
  }) async {
    AppLogger.debug('Identifying overused talents');

    final overusedTalents = <OverusedTalent>[];
    
    // Look for patterns of high skill but energy drain or burnout indicators
    final selfEnergyPatterns = _extractEnergyPatterns(selfResponses);
    final advisorObservations = _extractAdvisorBurnoutObservations(advisorResponses);
    
    for (final pattern in selfEnergyPatterns.entries) {
      final talentName = pattern.key;
      final energyData = pattern.value;
      
      if (_isOverusedTalent(energyData, advisorObservations[talentName])) {
        final overusedTalent = await _createOverusedTalent(
          talentName: talentName,
          energyData: energyData,
          advisorData: advisorObservations[talentName],
          selfResponses: selfResponses,
          advisorResponses: advisorResponses,
        );
        
        if (overusedTalent != null) {
          overusedTalents.add(overusedTalent);
        }
      }
    }

    // Sort by burnout risk and usage frequency
    overusedTalents.sort((a, b) {
      final riskA = a.burnoutRisk + a.usageFrequency;
      final riskB = b.burnoutRisk + b.usageFrequency;
      return riskB.compareTo(riskA);
    });

    AppLogger.info('Identified ${overusedTalents.length} overused talents');
    return overusedTalents.take(3).toList(); // Limit to top 3
  }

  /// Identify Aspirational Strengths: Areas of high interest with development potential
  Future<List<AspirationalStrength>> identifyAspirationalStrengths({
    required List<CareerResponse> selfResponses,
    required List<AdvisorResponse> advisorResponses,
  }) async {
    AppLogger.debug('Identifying aspirational strengths');

    final aspirationalStrengths = <AspirationalStrength>[];
    
    // Look for areas of high self-interest but lower current competence
    final selfAspirations = _extractSelfAspirations(selfResponses);
    final advisorPotentialAssessments = _extractAdvisorPotentialAssessments(advisorResponses);
    
    for (final aspiration in selfAspirations.entries) {
      final areaName = aspiration.key;
      final aspirationData = aspiration.value;
      final advisorData = advisorPotentialAssessments[areaName];
      
      if (_isAspirationalStrength(aspirationData, advisorData)) {
        final aspirationalStrength = await _createAspirationalStrength(
          areaName: areaName,
          aspirationData: aspirationData,
          advisorData: advisorData,
          selfResponses: selfResponses,
          advisorResponses: advisorResponses,
        );
        
        if (aspirationalStrength != null) {
          aspirationalStrengths.add(aspirationalStrength);
        }
      }
    }

    // Sort by development priority (interest + potential)
    aspirationalStrengths.sort((a, b) => b.developmentPriority.compareTo(a.developmentPriority));

    AppLogger.info('Identified ${aspirationalStrengths.length} aspirational strengths');
    return aspirationalStrengths.take(4).toList(); // Limit to top 4
  }

  /// Identify Misaligned Energies: Activities that drain energy despite competence
  Future<List<MisalignedEnergy>> identifyMisalignedEnergies({
    required List<CareerResponse> selfResponses,
    required List<AdvisorResponse> advisorResponses,
  }) async {
    AppLogger.debug('Identifying misaligned energies');

    final misalignedEnergies = <MisalignedEnergy>[];
    
    // Look for activities that drain energy despite competence
    final selfDrainPatterns = _extractSelfEnergyDrainPatterns(selfResponses);
    final advisorCompetenceObservations = _extractAdvisorCompetenceObservations(advisorResponses);
    
    for (final drainPattern in selfDrainPatterns.entries) {
      final activityName = drainPattern.key;
      final drainData = drainPattern.value;
      final competenceData = advisorCompetenceObservations[activityName];
      
      if (_isMisalignedEnergy(drainData, competenceData)) {
        final misalignedEnergy = await _createMisalignedEnergy(
          activityName: activityName,
          drainData: drainData,
          competenceData: competenceData,
          selfResponses: selfResponses,
          advisorResponses: advisorResponses,
        );
        
        if (misalignedEnergy != null) {
          misalignedEnergies.add(misalignedEnergy);
        }
      }
    }

    // Sort by impact priority (energy drain + frequency)
    misalignedEnergies.sort((a, b) => b.impactPriority.compareTo(a.impactPriority));

    AppLogger.info('Identified ${misalignedEnergies.length} misaligned energies');
    return misalignedEnergies.take(3).toList(); // Limit to top 3
  }

  // ===== PRIVATE HELPER METHODS =====

  /// Extract strength indicators from self-responses
  Map<String, Map<String, dynamic>> _extractSelfStrengthIndicators(List<CareerResponse> responses) {
    final strengthMap = <String, Map<String, dynamic>>{};
    
    for (final response in responses) {
      // Look for strength-related keywords and patterns
      final content = response.response.toLowerCase();
      final themes = response.keyThemes;
      
      // Extract energy indicators
      final energyLevel = _calculateEnergyLevel(content);
      final skillLevel = _calculateSelfAssessedSkillLevel(content, themes);
      final confidenceLevel = _calculateSelfConfidence(content);
      
      for (final theme in themes) {
        final normalizedTheme = _normalizeTheme(theme);
        
        strengthMap.putIfAbsent(normalizedTheme, () => {
          'energy_scores': <double>[],
          'skill_scores': <double>[],
          'confidence_scores': <double>[],
          'evidence': <String>[],
          'question_types': <String>[],
        });
        
        strengthMap[normalizedTheme]!['energy_scores'].add(energyLevel);
        strengthMap[normalizedTheme]!['skill_scores'].add(skillLevel);
        strengthMap[normalizedTheme]!['confidence_scores'].add(confidenceLevel);
        strengthMap[normalizedTheme]!['evidence'].add(response.response);
        strengthMap[normalizedTheme]!['question_types'].add(response.domain.name);
      }
    }
    
    // Calculate aggregate scores
    for (final entry in strengthMap.entries) {
      final data = entry.value;
      data['avg_energy'] = _calculateAverage(data['energy_scores']);
      data['avg_skill'] = _calculateAverage(data['skill_scores']);
      data['avg_confidence'] = _calculateAverage(data['confidence_scores']);
      data['frequency'] = data['evidence'].length;
    }
    
    return strengthMap;
  }

  /// Extract strength indicators from advisor responses
  Map<String, Map<String, dynamic>> _extractAdvisorStrengthIndicators(List<AdvisorResponse> responses) {
    final strengthMap = <String, Map<String, dynamic>>{};
    
    for (final response in responses) {
      final content = response.response.toLowerCase();
      final themes = response.keyThemes;
      
      // Extract recognition indicators
      final recognitionLevel = _calculateAdvisorRecognitionLevel(content);
      final competenceLevel = _calculateAdvisorCompetenceAssessment(content);
      final credibilityWeight = response.credibilityWeight;
      
      for (final theme in themes) {
        final normalizedTheme = _normalizeTheme(theme);
        
        strengthMap.putIfAbsent(normalizedTheme, () => {
          'recognition_scores': <double>[],
          'competence_scores': <double>[],
          'credibility_weights': <double>[],
          'evidence': <String>[],
          'advisor_contexts': <String>[],
        });
        
        strengthMap[normalizedTheme]!['recognition_scores'].add(recognitionLevel);
        strengthMap[normalizedTheme]!['competence_scores'].add(competenceLevel);
        strengthMap[normalizedTheme]!['credibility_weights'].add(credibilityWeight);
        strengthMap[normalizedTheme]!['evidence'].add(response.response);
        strengthMap[normalizedTheme]!['advisor_contexts'].add(response.observationPeriodDescription);
      }
    }
    
    // Calculate weighted aggregate scores
    for (final entry in strengthMap.entries) {
      final data = entry.value;
      data['weighted_recognition'] = _calculateWeightedAverage(
        data['recognition_scores'], 
        data['credibility_weights']
      );
      data['weighted_competence'] = _calculateWeightedAverage(
        data['competence_scores'], 
        data['credibility_weights']
      );
      data['frequency'] = data['evidence'].length;
      data['total_credibility'] = _calculateSum(data['credibility_weights']);
    }
    
    return strengthMap;
  }

  /// Check if a combination indicates an energising strength
  bool _isEnergisingStrength(Map<String, dynamic> selfData, Map<String, dynamic> advisorData) {
    final selfEnergy = selfData['avg_energy'] ?? 0.0;
    final selfSkill = selfData['avg_skill'] ?? 0.0;
    final advisorRecognition = advisorData['weighted_recognition'] ?? 0.0;
    final advisorCompetence = advisorData['weighted_competence'] ?? 0.0;
    
    return selfEnergy >= 3.5 && 
           selfSkill >= 3.0 && 
           advisorRecognition >= 3.0 && 
           advisorCompetence >= 3.0;
  }

  /// Check if a combination indicates a hidden strength
  bool _isHiddenStrength(Map<String, dynamic>? selfData, Map<String, dynamic> advisorData) {
    final advisorRecognition = advisorData['weighted_recognition'] ?? 0.0;
    final advisorCompetence = advisorData['weighted_competence'] ?? 0.0;
    
    // Hidden if advisor sees strength but self doesn't mention or undervalues
    if (advisorRecognition >= 3.5 && advisorCompetence >= 3.5) {
      if (selfData == null) return true; // Not mentioned by self at all
      
      final selfSkill = selfData['avg_skill'] ?? 0.0;
      final selfConfidence = selfData['avg_confidence'] ?? 0.0;
      
      return selfSkill < 3.0 || selfConfidence < 3.0; // Undervalued by self
    }
    
    return false;
  }

  /// Check if a combination indicates an overused talent
  bool _isOverusedTalent(Map<String, dynamic> energyData, Map<String, dynamic>? advisorData) {
    final selfSkill = energyData['avg_skill'] ?? 0.0;
    final energyDrain = energyData['drain_level'] ?? 0.0;
    final usageFrequency = energyData['usage_frequency'] ?? 0.0;
    
    // High skill but showing signs of overuse/drain
    if (selfSkill >= 3.5 && energyDrain >= 3.0 && usageFrequency >= 3.5) {
      // Check if advisor also notices overuse patterns
      if (advisorData != null) {
        final advisorBurnoutConcern = advisorData['burnout_concern'] ?? 0.0;
        return advisorBurnoutConcern >= 2.0;
      }
      return true; // Self-reported overuse is sufficient
    }
    
    return false;
  }

  /// Check if a combination indicates an aspirational strength
  bool _isAspirationalStrength(Map<String, dynamic> aspirationData, Map<String, dynamic>? advisorData) {
    final selfInterest = aspirationData['interest_level'] ?? 0.0;
    final currentLevel = aspirationData['current_level'] ?? 0.0;
    final selfPotentialBelief = aspirationData['potential_belief'] ?? 0.0;
    
    // High interest but lower current competence
    if (selfInterest >= 4.0 && currentLevel <= 3.0 && selfPotentialBelief >= 3.0) {
      // Check if advisor sees potential
      if (advisorData != null) {
        final advisorPotential = advisorData['development_potential'] ?? 0.0;
        return advisorPotential >= 2.5;
      }
      return true; // Self-interest is primary indicator
    }
    
    return false;
  }

  /// Check if a combination indicates misaligned energy
  bool _isMisalignedEnergy(Map<String, dynamic> drainData, Map<String, dynamic>? competenceData) {
    final energyDrain = drainData['drain_level'] ?? 0.0;
    final frequency = drainData['frequency'] ?? 0.0;
    final selfCompetence = drainData['competence_despite_drain'] ?? 0.0;
    
    // High drain despite competence
    if (energyDrain >= 3.5 && frequency >= 3.0 && selfCompetence >= 3.0) {
      // Check if advisor confirms competence
      if (competenceData != null) {
        final advisorCompetence = competenceData['competence_level'] ?? 0.0;
        return advisorCompetence >= 3.0;
      }
      return true; // Self-reported drain with competence is sufficient
    }
    
    return false;
  }

  // ===== ENERGY AND SKILL CALCULATION METHODS =====

  double _calculateEnergyLevel(String content) {
    final energyKeywords = {
      'high_energy': ['energise', 'energize', 'love', 'passionate', 'excited', 'thrive', 'flow', 'effortless'],
      'medium_energy': ['enjoy', 'like', 'interested', 'engaged', 'motivated'],
      'low_energy': ['drain', 'exhaust', 'difficult', 'struggle', 'tedious', 'bore'],
    };
    
    double score = 2.5; // Neutral baseline
    
    final highCount = _countKeywords(content, energyKeywords['high_energy']!);
    final mediumCount = _countKeywords(content, energyKeywords['medium_energy']!);  
    final lowCount = _countKeywords(content, energyKeywords['low_energy']!);
    
    score += (highCount * 0.8) + (mediumCount * 0.4) - (lowCount * 0.6);
    
    return score.clamp(1.0, 5.0);
  }

  double _calculateSelfAssessedSkillLevel(String content, List<String> themes) {
    final skillKeywords = {
      'high_skill': ['expert', 'excellent', 'outstanding', 'exceptional', 'mastery', 'excel'],
      'medium_skill': ['good', 'capable', 'competent', 'skilled', 'proficient'],
      'developing': ['learning', 'developing', 'improving', 'growing', 'building'],
    };
    
    double score = 2.5; // Neutral baseline
    
    final highCount = _countKeywords(content, skillKeywords['high_skill']!);
    final mediumCount = _countKeywords(content, skillKeywords['medium_skill']!);
    final developingCount = _countKeywords(content, skillKeywords['developing']!);
    
    score += (highCount * 0.9) + (mediumCount * 0.6) + (developingCount * 0.2);
    
    // Boost score if multiple related themes indicate depth
    if (themes.length >= 3) score += 0.3;
    
    return score.clamp(1.0, 5.0);
  }

  double _calculateSelfConfidence(String content) {
    final confidenceKeywords = {
      'high_confidence': ['confident', 'certain', 'sure', 'definite', 'strong'],
      'medium_confidence': ['think', 'believe', 'feel', 'seem'],
      'low_confidence': ['maybe', 'perhaps', 'uncertain', 'not sure', 'doubt'],
    };
    
    double score = 3.0; // Slightly positive baseline
    
    final highCount = _countKeywords(content, confidenceKeywords['high_confidence']!);
    final mediumCount = _countKeywords(content, confidenceKeywords['medium_confidence']!);
    final lowCount = _countKeywords(content, confidenceKeywords['low_confidence']!);
    
    score += (highCount * 0.6) + (mediumCount * 0.2) - (lowCount * 0.8);
    
    return score.clamp(1.0, 5.0);
  }

  double _calculateAdvisorRecognitionLevel(String content) {
    final recognitionKeywords = {
      'strong_recognition': ['always', 'consistently', 'repeatedly', 'known for', 'famous for', 'goes to'],
      'medium_recognition': ['often', 'usually', 'frequently', 'regularly', 'good at'],
      'limited_recognition': ['sometimes', 'occasionally', 'can be', 'might be'],
    };
    
    double score = 2.5; // Neutral baseline
    
    final strongCount = _countKeywords(content, recognitionKeywords['strong_recognition']!);
    final mediumCount = _countKeywords(content, recognitionKeywords['medium_recognition']!);
    final limitedCount = _countKeywords(content, recognitionKeywords['limited_recognition']!);
    
    score += (strongCount * 1.0) + (mediumCount * 0.6) + (limitedCount * 0.2);
    
    return score.clamp(1.0, 5.0);
  }

  double _calculateAdvisorCompetenceAssessment(String content) {
    final competenceKeywords = {
      'high_competence': ['expert', 'exceptional', 'outstanding', 'brilliant', 'masterful'],
      'good_competence': ['skilled', 'competent', 'capable', 'proficient', 'strong'],
      'developing_competence': ['learning', 'improving', 'developing', 'growing'],
      'concerns': ['struggle', 'difficulty', 'challenge', 'weak', 'needs work'],
    };
    
    double score = 3.0; // Positive baseline (advisors tend to focus on positives)
    
    final highCount = _countKeywords(content, competenceKeywords['high_competence']!);
    final goodCount = _countKeywords(content, competenceKeywords['good_competence']!);
    final developingCount = _countKeywords(content, competenceKeywords['developing_competence']!);
    final concernCount = _countKeywords(content, competenceKeywords['concerns']!);
    
    score += (highCount * 0.8) + (goodCount * 0.5) + (developingCount * 0.2) - (concernCount * 0.7);
    
    return score.clamp(1.0, 5.0);
  }

  // ===== PATTERN EXTRACTION METHODS =====

  Map<String, Map<String, dynamic>> _extractEnergyPatterns(List<CareerResponse> responses) {
    final patterns = <String, Map<String, dynamic>>{};
    
    for (final response in responses) {
      final content = response.response.toLowerCase();
      
      // Look for drain/overuse patterns
      final drainLevel = _calculateDrainLevel(content);
      final usageFrequency = _calculateUsageFrequency(content);
      final skillLevel = _calculateSelfAssessedSkillLevel(content, response.keyThemes);
      
      for (final theme in response.keyThemes) {
        final normalizedTheme = _normalizeTheme(theme);
        
        patterns.putIfAbsent(normalizedTheme, () => {
          'drain_scores': <double>[],
          'usage_scores': <double>[],
          'skill_scores': <double>[],
          'evidence': <String>[],
        });
        
        patterns[normalizedTheme]!['drain_scores'].add(drainLevel);
        patterns[normalizedTheme]!['usage_scores'].add(usageFrequency);
        patterns[normalizedTheme]!['skill_scores'].add(skillLevel);
        patterns[normalizedTheme]!['evidence'].add(response.response);
      }
    }
    
    // Calculate aggregates
    for (final entry in patterns.entries) {
      final data = entry.value;
      data['drain_level'] = _calculateAverage(data['drain_scores']);
      data['usage_frequency'] = _calculateAverage(data['usage_scores']);
      data['avg_skill'] = _calculateAverage(data['skill_scores']);
    }
    
    return patterns;
  }

  Map<String, Map<String, dynamic>> _extractSelfAspirations(List<CareerResponse> responses) {
    final aspirations = <String, Map<String, dynamic>>{};
    
    for (final response in responses) {
      final content = response.response.toLowerCase();
      
      // Look for aspirational language
      final interestLevel = _calculateInterestLevel(content);
      final currentLevel = _calculateCurrentLevel(content);
      final potentialBelief = _calculatePotentialBelief(content);
      
      if (interestLevel >= 3.0) { // Only consider things they're interested in
        for (final theme in response.keyThemes) {
          final normalizedTheme = _normalizeTheme(theme);
          
          aspirations.putIfAbsent(normalizedTheme, () => {
            'interest_scores': <double>[],
            'current_scores': <double>[],
            'potential_scores': <double>[],
            'evidence': <String>[],
          });
          
          aspirations[normalizedTheme]!['interest_scores'].add(interestLevel);
          aspirations[normalizedTheme]!['current_scores'].add(currentLevel);
          aspirations[normalizedTheme]!['potential_scores'].add(potentialBelief);
          aspirations[normalizedTheme]!['evidence'].add(response.response);
        }
      }
    }
    
    // Calculate aggregates
    for (final entry in aspirations.entries) {
      final data = entry.value;
      data['interest_level'] = _calculateAverage(data['interest_scores']);
      data['current_level'] = _calculateAverage(data['current_scores']);
      data['potential_belief'] = _calculateAverage(data['potential_scores']);
    }
    
    return aspirations;
  }

  Map<String, Map<String, dynamic>> _extractSelfEnergyDrainPatterns(List<CareerResponse> responses) {
    final drainPatterns = <String, Map<String, dynamic>>{};
    
    for (final response in responses) {
      final content = response.response.toLowerCase();
      
      // Look for energy drain patterns
      final drainLevel = _calculateDrainLevel(content);
      final frequency = _calculateActivityFrequency(content);
      final competence = _calculateCompetenceDespiteDrain(content);
      
      if (drainLevel >= 3.0) { // Only consider draining activities
        for (final theme in response.keyThemes) {
          final normalizedTheme = _normalizeTheme(theme);
          
          drainPatterns.putIfAbsent(normalizedTheme, () => {
            'drain_scores': <double>[],
            'frequency_scores': <double>[],
            'competence_scores': <double>[],
            'evidence': <String>[],
          });
          
          drainPatterns[normalizedTheme]!['drain_scores'].add(drainLevel);
          drainPatterns[normalizedTheme]!['frequency_scores'].add(frequency);
          drainPatterns[normalizedTheme]!['competence_scores'].add(competence);
          drainPatterns[normalizedTheme]!['evidence'].add(response.response);
        }
      }
    }
    
    // Calculate aggregates
    for (final entry in drainPatterns.entries) {
      final data = entry.value;
      data['drain_level'] = _calculateAverage(data['drain_scores']);
      data['frequency'] = _calculateAverage(data['frequency_scores']);
      data['competence_despite_drain'] = _calculateAverage(data['competence_scores']);
    }
    
    return drainPatterns;
  }

  // ===== ADDITIONAL CALCULATION METHODS =====

  double _calculateDrainLevel(String content) {
    final drainKeywords = ['exhaust', 'drain', 'tire', 'burn out', 'overwhelming', 'stressful', 'difficult'];
    final energyKeywords = ['energise', 'energize', 'love', 'enjoy', 'thrive'];
    
    final drainCount = _countKeywords(content, drainKeywords);
    final energyCount = _countKeywords(content, energyKeywords);
    
    double score = 2.5; // Neutral
    score += (drainCount * 0.8) - (energyCount * 0.6);
    
    return score.clamp(1.0, 5.0);
  }

  double _calculateUsageFrequency(String content) {
    final frequencyKeywords = {
      'high': ['always', 'constantly', 'continuously', 'all the time', 'daily'],
      'medium': ['often', 'regularly', 'frequently', 'usually'],
      'low': ['sometimes', 'occasionally', 'rarely', 'seldom']
    };
    
    double score = 2.5;
    
    score += _countKeywords(content, frequencyKeywords['high']!) * 0.8;
    score += _countKeywords(content, frequencyKeywords['medium']!) * 0.5;
    score += _countKeywords(content, frequencyKeywords['low']!) * 0.2;
    
    return score.clamp(1.0, 5.0);
  }

  double _calculateInterestLevel(String content) {
    final interestKeywords = {
      'high': ['love', 'passionate', 'fascinated', 'excited', 'dream', 'aspire'],
      'medium': ['interested', 'like', 'enjoy', 'attracted', 'curious'],
      'low': ['not interested', 'boring', 'uninteresting']
    };
    
    double score = 2.5;
    
    score += _countKeywords(content, interestKeywords['high']!) * 1.0;
    score += _countKeywords(content, interestKeywords['medium']!) * 0.6;
    score -= _countKeywords(content, interestKeywords['low']!) * 0.8;
    
    return score.clamp(1.0, 5.0);
  }

  double _calculateCurrentLevel(String content) {
    final currentKeywords = {
      'high': ['expert', 'advanced', 'proficient', 'skilled'],
      'medium': ['intermediate', 'developing', 'learning', 'improving'],
      'low': ['beginner', 'new', 'inexperienced', 'just starting']
    };
    
    double score = 2.5;
    
    score += _countKeywords(content, currentKeywords['high']!) * 0.8;
    score += _countKeywords(content, currentKeywords['medium']!) * 0.4;
    score += _countKeywords(content, currentKeywords['low']!) * 0.1;
    
    return score.clamp(1.0, 5.0);
  }

  double _calculatePotentialBelief(String content) {
    final potentialKeywords = {
      'high': ['potential', 'could', 'able to', 'capable of', 'believe I can'],
      'medium': ['might', 'maybe', 'possibly', 'think I could'],
      'low': ['doubt', 'unlikely', 'probably not', 'don\'t think']
    };
    
    double score = 3.0; // Slightly optimistic baseline
    
    score += _countKeywords(content, potentialKeywords['high']!) * 0.6;
    score += _countKeywords(content, potentialKeywords['medium']!) * 0.3;
    score -= _countKeywords(content, potentialKeywords['low']!) * 0.8;
    
    return score.clamp(1.0, 5.0);
  }

  double _calculateActivityFrequency(String content) {
    return _calculateUsageFrequency(content); // Same logic
  }

  double _calculateCompetenceDespiteDrain(String content) {
    final competenceKeywords = ['good at', 'skilled', 'capable', 'competent', 'successful'];
    final drainKeywords = ['but', 'however', 'although', 'even though', 'despite'];
    
    double score = 2.5;
    
    // Look for patterns like "I'm good at X but it drains me"
    if (_containsKeywords(content, competenceKeywords) && _containsKeywords(content, drainKeywords)) {
      score += 1.0;
    }
    
    score += _countKeywords(content, competenceKeywords) * 0.4;
    
    return score.clamp(1.0, 5.0);
  }

  // ===== UTILITY METHODS =====

  String _normalizeTheme(String theme) {
    return theme.toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }

  int _countKeywords(String content, List<String> keywords) {
    int count = 0;
    for (final keyword in keywords) {
      if (content.contains(keyword.toLowerCase())) {
        count++;
      }
    }
    return count;
  }

  bool _containsKeywords(String content, List<String> keywords) {
    return keywords.any((keyword) => content.contains(keyword.toLowerCase()));
  }

  double _calculateAverage(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  double _calculateWeightedAverage(List<double> values, List<double> weights) {
    if (values.isEmpty || weights.isEmpty || values.length != weights.length) return 0.0;
    
    double weightedSum = 0.0;
    double totalWeight = 0.0;
    
    for (int i = 0; i < values.length; i++) {
      weightedSum += values[i] * weights[i];
      totalWeight += weights[i];
    }
    
    return totalWeight > 0 ? weightedSum / totalWeight : 0.0;
  }

  double _calculateSum(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b);
  }

  // Placeholder methods for advisor-specific extractions
  Map<String, Map<String, dynamic>> _extractAdvisorBurnoutObservations(List<AdvisorResponse> responses) => {};
  Map<String, Map<String, dynamic>> _extractAdvisorPotentialAssessments(List<AdvisorResponse> responses) => {};
  Map<String, Map<String, dynamic>> _extractAdvisorCompetenceObservations(List<AdvisorResponse> responses) => {};
  
  Future<List<HiddenStrength>> _findAdditionalHiddenStrengths(List<CareerResponse> self, List<AdvisorResponse> advisor) async => [];
  
  // Creation methods to create the actual model objects
  Future<EnergisrengStrength?> _createEnergisingStrength({
    required String strengthName,
    required Map<String, dynamic> selfData,
    required Map<String, dynamic> advisorData,
    required List<CareerResponse> selfResponses,
    required List<AdvisorResponse> advisorResponses,
  }) async {
    try {
      final skillLevel = (selfData['avg_skill'] ?? 0.0).round().clamp(1, 5);
      final energyLevel = (selfData['avg_energy'] ?? 0.0).round().clamp(1, 5);
      final recognitionLevel = (advisorData['weighted_recognition'] ?? 0.0).round().clamp(1, 5);
      
      // Calculate leverageability based on application contexts
      final applicationAreas = _identifyApplicationAreas(strengthName, selfResponses, advisorResponses);
      final leverageability = _calculateLeverageability(skillLevel, energyLevel, recognitionLevel, applicationAreas.length);
      
      return EnergisrengStrength(
        id: 'energising_${strengthName.replaceAll(' ', '_').toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
        title: _formatStrengthTitle(strengthName),
        description: 'This represents a core area where your high skill level, natural energy, and external recognition align perfectly. It\'s a sweet spot for sustainable high performance.',
        skillLevel: skillLevel,
        energyLevel: energyLevel,
        recognitionLevel: recognitionLevel,
        leverageability: leverageability,
        evidenceFromSelf: (selfData['evidence'] as List<String>? ?? []).take(3).toList(),
        evidenceFromOthers: (advisorData['evidence'] as List<String>? ?? []).take(3).toList(),
        actionableAdvice: _generateEnergisingStrengthAdvice(strengthName, leverageability),
        applicationAreas: applicationAreas,
        confidence: _calculateEnergisingConfidence(selfData, advisorData),
      );
    } catch (e) {
      AppLogger.error('Error creating energising strength: $strengthName', e);
      return null;
    }
  }
  
  Future<HiddenStrength?> _createHiddenStrength({
    required String strengthName,
    Map<String, dynamic>? selfData,
    required Map<String, dynamic> advisorData,
    required List<CareerResponse> selfResponses,
    required List<AdvisorResponse> advisorResponses,
  }) async {
    try {
      final competenceLevel = (advisorData['weighted_competence'] ?? 0.0).round().clamp(1, 5);
      final currentRecognition = (selfData?['avg_confidence'] ?? 1.0).round().clamp(1, 5);
      final potentialImpact = _calculatePotentialImpact(competenceLevel, advisorData);
      
      final hiddenFactors = _identifyHiddenFactors(strengthName, selfData, advisorData);
      final visibilityOpportunities = _identifyVisibilityOpportunities(strengthName, advisorResponses);
      
      return HiddenStrength(
        id: 'hidden_${strengthName.replaceAll(' ', '_').toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
        title: _formatStrengthTitle(strengthName),
        description: 'This capability is more visible to others than to yourself, representing significant untapped potential for career advancement.',
        competenceLevel: competenceLevel,
        currentRecognition: currentRecognition,
        potentialImpact: potentialImpact,
        hiddenFactors: hiddenFactors,
        developmentStrategy: _generateHiddenStrengthStrategy(strengthName, potentialImpact),
        visibilityOpportunities: visibilityOpportunities,
        confidence: _calculateHiddenStrengthConfidence(advisorData),
      );
    } catch (e) {
      AppLogger.error('Error creating hidden strength: $strengthName', e);
      return null;
    }
  }
  
  Future<OverusedTalent?> _createOverusedTalent({
    required String talentName,
    required Map<String, dynamic> energyData,
    Map<String, dynamic>? advisorData,
    required List<CareerResponse> selfResponses,
    required List<AdvisorResponse> advisorResponses,
  }) async {
    try {
      final talentLevel = (energyData['avg_skill'] ?? 0.0).round().clamp(1, 5);
      final usageFrequency = (energyData['usage_frequency'] ?? 0.0).round().clamp(1, 5);
      final burnoutRisk = (energyData['drain_level'] ?? 0.0).round().clamp(1, 5);
      
      final overuseIndicators = _identifyOveruseIndicators(talentName, energyData);
      final alternativeApplications = _identifyAlternativeApplications(talentName);
      
      return OverusedTalent(
        id: 'overused_${talentName.replaceAll(' ', '_').toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
        title: _formatStrengthTitle(talentName),
        description: 'While this is clearly a strength, there are signs it may be overused, potentially leading to diminishing returns and energy drain.',
        talentLevel: talentLevel,
        usageFrequency: usageFrequency,
        burnoutRisk: burnoutRisk,
        overuseIndicators: overuseIndicators,
        rebalancingStrategy: _generateRebalancingStrategy(talentName, usageFrequency, burnoutRisk),
        alternativeApplications: alternativeApplications,
        confidence: _calculateOverusedTalentConfidence(energyData, advisorData),
      );
    } catch (e) {
      AppLogger.error('Error creating overused talent: $talentName', e);
      return null;
    }
  }
  
  Future<AspirationalStrength?> _createAspirationalStrength({
    required String areaName,
    required Map<String, dynamic> aspirationData,
    Map<String, dynamic>? advisorData,
    required List<CareerResponse> selfResponses,
    required List<AdvisorResponse> advisorResponses,
  }) async {
    try {
      final currentLevel = (aspirationData['current_level'] ?? 0.0).round().clamp(1, 5);
      final interestLevel = (aspirationData['interest_level'] ?? 0.0).round().clamp(1, 5);
      final developmentPotential = _calculateDevelopmentPotential(interestLevel, advisorData);
      
      final requiredResources = _identifyRequiredResources(areaName);
      final timeframe = _estimateTimeframe(currentLevel, interestLevel, developmentPotential);
      
      return AspirationalStrength(
        id: 'aspirational_${areaName.replaceAll(' ', '_').toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
        title: _formatStrengthTitle(areaName),
        description: 'This area represents high personal interest and potential for development, making it a strategic investment opportunity.',
        currentLevel: currentLevel,
        interestLevel: interestLevel,
        developmentPotential: developmentPotential,
        developmentPlan: _generateDevelopmentPlan(areaName, currentLevel, developmentPotential),
        requiredResources: requiredResources,
        timeframe: timeframe,
        confidence: _calculateAspirationalConfidence(aspirationData, advisorData),
      );
    } catch (e) {
      AppLogger.error('Error creating aspirational strength: $areaName', e);
      return null;
    }
  }
  
  Future<MisalignedEnergy?> _createMisalignedEnergy({
    required String activityName,
    required Map<String, dynamic> drainData,
    Map<String, dynamic>? competenceData,
    required List<CareerResponse> selfResponses,
    required List<AdvisorResponse> advisorResponses,
  }) async {
    try {
      final competenceLevel = (drainData['avg_skill'] ?? 0.0).round().clamp(1, 5);
      final energyDrainLevel = (drainData['drain_level'] ?? 0.0).round().clamp(1, 5);
      final frequency = (drainData['frequency'] ?? 0.0).round().clamp(1, 5);
      
      final drainFactors = _identifyDrainFactors(activityName, drainData);
      final alternativeApproaches = _identifyAlternativeApproaches(activityName);
      
      return MisalignedEnergy(
        id: 'misaligned_${activityName.replaceAll(' ', '_').toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
        title: _formatStrengthTitle(activityName),
        description: 'This activity drains your energy despite demonstrated competence, indicating a misalignment between capability and personal satisfaction.',
        competenceLevel: competenceLevel,
        energyDrainLevel: energyDrainLevel,
        frequency: frequency,
        drainFactors: drainFactors,
        mitigationStrategy: _generateMitigationStrategy(activityName, energyDrainLevel, frequency),
        alternativeApproaches: alternativeApproaches,
        confidence: _calculateMisalignedEnergyConfidence(drainData),
      );
    } catch (e) {
      AppLogger.error('Error creating misaligned energy: $activityName', e);
      return null;
    }
  }
  
  // ===== HELPER METHODS FOR OBJECT CREATION =====
  
  String _formatStrengthTitle(String strengthName) {
    return strengthName.split('_').map((word) => 
        word[0].toUpperCase() + word.substring(1)).join(' ');
  }
  
  List<String> _identifyApplicationAreas(String strengthName, List<CareerResponse> selfResponses, List<AdvisorResponse> advisorResponses) {
    final areas = <String>[];
    
    // Extract application contexts from responses
    final allResponses = [
      ...selfResponses.map((r) => r.response),
      ...advisorResponses.map((r) => r.response),
    ];
    
    final contexts = ['leadership', 'technical', 'strategic', 'creative', 'analytical', 'interpersonal'];
    for (final context in contexts) {
      if (allResponses.any((response) => response.toLowerCase().contains(context))) {
        areas.add(context);
      }
    }
    
    return areas.isEmpty ? ['general_application'] : areas;
  }
  
  int _calculateLeverageability(int skillLevel, int energyLevel, int recognitionLevel, int applicationCount) {
    final averageScore = (skillLevel + energyLevel + recognitionLevel) / 3.0;
    final applicationBonus = min(1.0, applicationCount / 3.0);
    return (averageScore + applicationBonus).round().clamp(1, 5);
  }
  
  String? _generateEnergisingStrengthAdvice(String strengthName, int leverageability) {
    if (leverageability >= 4) {
      return 'Seek high-impact projects and leadership opportunities that maximize your ${strengthName.toLowerCase()} capabilities.';
    } else {
      return 'Look for ways to apply your ${strengthName.toLowerCase()} in new contexts to increase your impact and visibility.';
    }
  }
  
  double _calculateEnergisingConfidence(Map<String, dynamic> selfData, Map<String, dynamic> advisorData) {
    final selfConfidence = selfData['avg_confidence'] ?? 0.0;
    final advisorCredibility = advisorData['total_credibility'] ?? 0.0;
    return ((selfConfidence / 5.0) * 0.4 + (advisorCredibility / 5.0) * 0.6).clamp(0.0, 1.0);
  }
  
  int _calculatePotentialImpact(int competenceLevel, Map<String, dynamic> advisorData) {
    final baseImpact = competenceLevel;
    final credibilityBonus = ((advisorData['total_credibility'] ?? 0.0) >= 3.0) ? 1 : 0;
    return (baseImpact + credibilityBonus).clamp(1, 5);
  }
  
  List<String> _identifyHiddenFactors(String strengthName, Map<String, dynamic>? selfData, Map<String, dynamic> advisorData) {
    final factors = <String>[];
    
    if (selfData == null || (selfData['frequency'] ?? 0) == 0) {
      factors.add('Not mentioned in self-assessment');
    }
    
    if ((selfData?['avg_confidence'] ?? 0.0) < 3.0) {
      factors.add('Low self-confidence in this area');
    }
    
    if ((advisorData['frequency'] ?? 0) >= 3) {
      factors.add('Consistently mentioned by multiple advisors');
    }
    
    return factors.isEmpty ? ['Unrecognized capability'] : factors;
  }
  
  List<String> _identifyVisibilityOpportunities(String strengthName, List<AdvisorResponse> advisorResponses) {
    return [
      'Showcase ${strengthName.toLowerCase()} through presentations or leading projects',
      'Seek feedback specifically about ${strengthName.toLowerCase()} capabilities',
      'Volunteer for assignments that highlight ${strengthName.toLowerCase()} skills',
    ];
  }
  
  String? _generateHiddenStrengthStrategy(String strengthName, int potentialImpact) {
    if (potentialImpact >= 4) {
      return 'Prioritize increasing visibility of your ${strengthName.toLowerCase()} through strategic projects and communication.';
    } else {
      return 'Explore ways to develop and demonstrate your ${strengthName.toLowerCase()} capabilities.';
    }
  }
  
  double _calculateHiddenStrengthConfidence(Map<String, dynamic> advisorData) {
    final credibility = advisorData['total_credibility'] ?? 0.0;
    final frequency = advisorData['frequency'] ?? 0;
    return ((credibility / 5.0) * 0.7 + min<double>(1.0, frequency / 3.0) * 0.3).clamp(0.0, 1.0);
  }
  
  List<String> _identifyDrainFactors(String activityName, Map<String, dynamic> drainData) {
    final factors = <String>[];
    
    if ((drainData['drain_level'] ?? 0.0) >= 4.0) {
      factors.add('High energy drain reported');
    }
    
    if ((drainData['usage_frequency'] ?? 0.0) >= 4.0) {
      factors.add('Frequently required activity');
    }
    
    factors.add('Competence without enjoyment');
    
    return factors;
  }
  
  List<String> _identifyAlternativeApproaches(String activityName) {
    return [
      'Delegate ${activityName.toLowerCase()} where possible',
      'Restructure ${activityName.toLowerCase()} to be more engaging',
      'Limit time spent on ${activityName.toLowerCase()}',
      'Find ways to automate ${activityName.toLowerCase()} tasks',
    ];
  }
  
  String? _generateMitigationStrategy(String activityName, int energyDrainLevel, int frequency) {
    if (energyDrainLevel >= 4 && frequency >= 4) {
      return 'Urgently address ${activityName.toLowerCase()} through delegation, automation, or role restructuring.';
    } else if (energyDrainLevel >= 3) {
      return 'Gradually reduce involvement in ${activityName.toLowerCase()} or find ways to make it more energizing.';
    } else {
      return 'Monitor ${activityName.toLowerCase()} to prevent it from becoming more draining over time.';
    }
  }
  
  double _calculateMisalignedEnergyConfidence(Map<String, dynamic> drainData) {
    final evidenceCount = (drainData['evidence'] as List?)?.length ?? 0;
    final drainLevel = drainData['drain_level'] ?? 0.0;
    return ((drainLevel / 5.0) * 0.6 + min(1.0, evidenceCount / 3.0) * 0.4).clamp(0.0, 1.0);
  }
  
  // Additional helper methods for Overused Talent and Aspirational Strength
  
  List<String> _identifyOveruseIndicators(String talentName, Map<String, dynamic> energyData) {
    final indicators = <String>[];
    
    if ((energyData['drain_level'] ?? 0.0) >= 4.0) {
      indicators.add('High energy drain despite competence');
    }
    
    if ((energyData['usage_frequency'] ?? 0.0) >= 4.0) {
      indicators.add('Very frequent use of this talent');
    }
    
    final evidence = energyData['evidence'] as List<String>? ?? [];
    for (final item in evidence) {
      if (item.toLowerCase().contains('too much') || item.toLowerCase().contains('overused')) {
        indicators.add('Explicit mention of overuse');
        break;
      }
    }
    
    return indicators.isEmpty ? ['Potential for overuse'] : indicators;
  }
  
  List<String> _identifyAlternativeApplications(String talentName) {
    return [
      'Apply ${talentName.toLowerCase()} in mentoring others',
      'Use ${talentName.toLowerCase()} in strategic rather than operational contexts',
      'Channel ${talentName.toLowerCase()} into innovation projects',
      'Leverage ${talentName.toLowerCase()} for teaching and knowledge sharing',
    ];
  }
  
  String? _generateRebalancingStrategy(String talentName, int usageFrequency, int burnoutRisk) {
    if (burnoutRisk >= 4) {
      return 'Implement immediate boundaries around ${talentName.toLowerCase()} usage. Delegate tasks and restructure role to reduce frequency.';
    } else if (usageFrequency >= 4) {
      return 'Gradually reduce direct application of ${talentName.toLowerCase()} while maintaining strategic oversight.';
    } else {
      return 'Monitor ${talentName.toLowerCase()} usage to maintain balance and prevent future overuse.';
    }
  }
  
  double _calculateOverusedTalentConfidence(Map<String, dynamic> energyData, Map<String, dynamic>? advisorData) {
    final selfEvidence = (energyData['evidence'] as List?)?.length ?? 0;
    final drainLevel = energyData['drain_level'] ?? 0.0;
    final advisorConfirmation = (advisorData != null && (advisorData['burnout_concern'] ?? 0.0) >= 2.0) ? 0.3 : 0.0;
    
    return ((drainLevel / 5.0) * 0.5 + min(1.0, selfEvidence / 3.0) * 0.2 + advisorConfirmation).clamp(0.0, 1.0);
  }
  
  int _calculateDevelopmentPotential(int interestLevel, Map<String, dynamic>? advisorData) {
    int potential = max(1, interestLevel - 1); // Base on interest, but cap at 4 initially
    
    if (advisorData != null) {
      final advisorPotential = (advisorData['development_potential'] ?? 0.0).round();
      if (advisorPotential >= 3) {
        potential = min(5, potential + 1); // Boost if advisor sees potential
      }
    }
    
    return potential.clamp(1, 5);
  }
  
  List<String> _identifyRequiredResources(String areaName) {
    final resourceMap = {
      'leadership': ['Leadership training', 'Mentoring relationship', 'Leadership opportunities'],
      'technical': ['Technical courses', 'Hands-on projects', 'Expert guidance'],
      'communication': ['Presentation skills training', 'Writing workshops', 'Speaking opportunities'],
      'strategic': ['Strategic thinking frameworks', 'Business education', 'Cross-functional exposure'],
      'creative': ['Creative workshops', 'Design thinking training', 'Innovation projects'],
    };
    
    for (final entry in resourceMap.entries) {
      if (areaName.toLowerCase().contains(entry.key)) {
        return entry.value;
      }
    }
    
    return ['Structured learning program', 'Practice opportunities', 'Expert feedback'];
  }
  
  int _estimateTimeframe(int currentLevel, int interestLevel, int developmentPotential) {
    final complexity = 5 - currentLevel; // Higher current level = less time needed
    final motivation = interestLevel; // Higher interest = faster development
    final potential = developmentPotential; // Higher potential = more efficient learning
    
    final baseMonths = 6; // Base timeframe
    final complexityAdjustment = complexity * 2; // 2 months per complexity point
    final motivationAdjustment = (5 - motivation) * 1; // Reduce time for higher motivation
    final potentialAdjustment = (5 - potential) * 1; // Reduce time for higher potential
    
    final totalMonths = baseMonths + complexityAdjustment - motivationAdjustment - potentialAdjustment;
    
    return totalMonths.clamp(3, 24); // Between 3 months and 2 years
  }
  
  String? _generateDevelopmentPlan(String areaName, int currentLevel, int developmentPotential) {
    if (developmentPotential >= 4) {
      return 'Create an intensive development plan for ${areaName.toLowerCase()} with specific milestones, learning resources, and practice opportunities.';
    } else if (developmentPotential >= 3) {
      return 'Develop ${areaName.toLowerCase()} through structured learning and gradual skill building over time.';
    } else {
      return 'Explore ${areaName.toLowerCase()} through small experiments and learning opportunities to test interest and aptitude.';
    }
  }
  
  double _calculateAspirationalConfidence(Map<String, dynamic> aspirationData, Map<String, dynamic>? advisorData) {
    final interestLevel = aspirationData['interest_level'] ?? 0.0;
    final evidenceCount = (aspirationData['evidence'] as List?)?.length ?? 0;
    final advisorSupport = (advisorData != null && (advisorData['development_potential'] ?? 0.0) >= 2.0) ? 0.2 : 0.0;
    
    return ((interestLevel / 5.0) * 0.6 + min(1.0, evidenceCount / 3.0) * 0.2 + advisorSupport).clamp(0.0, 1.0);
  }
}