import '../models/advisor_response.dart';

/// Comprehensive validator for advisor responses
/// Ensures high-quality, meaningful feedback with Australian context
class AdvisorResponseValidator {
  /// Minimum word count for a substantial response
  static const int minWordCount = 15;
  
  /// Maximum word count to prevent overly long responses
  static const int maxWordCount = 500;
  
  /// Minimum character count for specific examples
  static const int minExampleLength = 10;
  
  /// Common low-quality response patterns to detect
  static const List<String> lowQualityPatterns = [
    'good worker',
    'nice person',
    'works hard',
    'very good',
    'excellent',
    'no comment',
    'n/a',
    'na',
    'not sure',
    'dont know',
    "don't know",
    'idk',
    'unsure',
    'maybe',
    'i think',
    'probably',
    'seems like',
  ];
  
  /// Validate a complete advisor response submission
  static ValidationResult validateResponse({
    required String questionId,
    required String response,
    List<String>? specificExamples,
    int? confidenceLevel,
    required AdvisorObservationPeriod observationPeriod,
    required AdvisorConfidenceContext confidenceContext,
  }) {
    final errors = <String>[];
    final warnings = <String>[];
    final suggestions = <String>[];
    
    // Basic response validation
    final responseValidation = validateResponseText(response);
    if (!responseValidation.isValid) {
      errors.addAll(responseValidation.errors);
    }
    warnings.addAll(responseValidation.warnings);
    suggestions.addAll(responseValidation.suggestions);
    
    // Confidence level validation
    if (confidenceLevel != null) {
      final confidenceValidation = validateConfidenceLevel(confidenceLevel);
      if (!confidenceValidation.isValid) {
        errors.addAll(confidenceValidation.errors);
      }
      warnings.addAll(confidenceValidation.warnings);
      suggestions.addAll(confidenceValidation.suggestions);
    }
    
    // Examples validation
    if (specificExamples != null && specificExamples.isNotEmpty) {
      final examplesValidation = validateSpecificExamples(specificExamples);
      warnings.addAll(examplesValidation.warnings);
      suggestions.addAll(examplesValidation.suggestions);
    }
    
    // Context consistency validation
    final contextValidation = validateContextConsistency(
      confidenceLevel: confidenceLevel,
      observationPeriod: observationPeriod,
      confidenceContext: confidenceContext,
      hasExamples: specificExamples?.isNotEmpty ?? false,
    );
    warnings.addAll(contextValidation.warnings);
    suggestions.addAll(contextValidation.suggestions);
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
      suggestions: suggestions,
    );
  }
  
  /// Validate the main response text
  static ValidationResult validateResponseText(String response) {
    final errors = <String>[];
    final warnings = <String>[];
    final suggestions = <String>[];
    
    final trimmedResponse = response.trim();
    
    // Check if response is empty
    if (trimmedResponse.isEmpty) {
      errors.add('Please provide a response to this question');
      return ValidationResult(isValid: false, errors: errors);
    }
    
    // Word count validation
    final words = trimmedResponse.split(RegExp(r'\s+'));
    final wordCount = words.length;
    
    if (wordCount < minWordCount) {
      errors.add('Please provide a more detailed response (at least $minWordCount words)');
      return ValidationResult(isValid: false, errors: errors);
    }
    
    if (wordCount > maxWordCount) {
      warnings.add('Your response is quite long (${wordCount} words). Consider focusing on the most important points.');
    }
    
    // Quality checks
    final qualityScore = calculateResponseQuality(trimmedResponse);
    
    if (qualityScore < 0.3) {
      warnings.add('Your response seems quite brief. Adding specific examples would make it more valuable.');
      suggestions.add('Try including concrete situations or examples you\'ve observed.');
    } else if (qualityScore < 0.6) {
      suggestions.add('Consider adding more specific details or examples to strengthen your response.');
    }
    
    // Check for low-quality patterns
    final lowerResponse = trimmedResponse.toLowerCase();
    final foundPatterns = lowQualityPatterns.where((pattern) => 
      lowerResponse.contains(pattern.toLowerCase())
    ).toList();
    
    if (foundPatterns.isNotEmpty) {
      suggestions.add('Consider providing more specific details rather than general descriptions.');
    }
    
    // Check for Australian spelling and context
    final australianIssues = checkAustralianContext(trimmedResponse);
    suggestions.addAll(australianIssues);
    
    return ValidationResult(
      isValid: true,
      errors: errors,
      warnings: warnings,
      suggestions: suggestions,
    );
  }
  
  /// Validate confidence level
  static ValidationResult validateConfidenceLevel(int confidenceLevel) {
    final warnings = <String>[];
    final suggestions = <String>[];
    
    if (confidenceLevel < 1 || confidenceLevel > 5) {
      return ValidationResult(
        isValid: false,
        errors: ['Confidence level must be between 1 and 5'],
      );
    }
    
    if (confidenceLevel <= 2) {
      warnings.add('Low confidence level - consider if you have enough information to provide meaningful feedback.');
      suggestions.add('If you\'re unsure about your assessment, it\'s better to be honest about your limited observations.');
    }
    
    return ValidationResult(
      isValid: true,
      warnings: warnings,
      suggestions: suggestions,
    );
  }
  
  /// Validate specific examples
  static ValidationResult validateSpecificExamples(List<String> examples) {
    final warnings = <String>[];
    final suggestions = <String>[];
    
    final validExamples = examples.where((e) => e.trim().isNotEmpty).toList();
    
    if (validExamples.isEmpty) {
      suggestions.add('Adding specific examples would make your feedback more valuable.');
      return ValidationResult(isValid: true, suggestions: suggestions);
    }
    
    // Check example quality
    for (final example in validExamples) {
      if (example.trim().length < minExampleLength) {
        warnings.add('One or more examples seem quite brief - more detail would be helpful.');
        break;
      }
    }
    
    // Check for vague examples
    final vaguePatterns = [
      'always does well',
      'good at everything',
      'works hard',
      'very professional',
      'nice to work with',
    ];
    
    for (final example in validExamples) {
      final lowerExample = example.toLowerCase();
      if (vaguePatterns.any((pattern) => lowerExample.contains(pattern))) {
        suggestions.add('Try to make your examples more specific - describe particular situations or achievements.');
        break;
      }
    }
    
    return ValidationResult(
      isValid: true,
      warnings: warnings,
      suggestions: suggestions,
    );
  }
  
  /// Validate consistency between different context factors
  static ValidationResult validateContextConsistency({
    int? confidenceLevel,
    required AdvisorObservationPeriod observationPeriod,
    required AdvisorConfidenceContext confidenceContext,
    required bool hasExamples,
  }) {
    final warnings = <String>[];
    final suggestions = <String>[];
    
    // Check observation period vs confidence consistency
    if (observationPeriod == AdvisorObservationPeriod.lessThanMonth) {
      if (confidenceContext == AdvisorConfidenceContext.veryConfident ||
          confidenceContext == AdvisorConfidenceContext.confident) {
        warnings.add('High confidence with limited observation time - ensure your assessment is based on solid evidence.');
      }
      
      if (!hasExamples) {
        suggestions.add('With limited observation time, specific examples would strengthen your feedback.');
      }
    }
    
    // Check confidence level vs confidence context consistency
    if (confidenceLevel != null) {
      if (confidenceLevel >= 4 && 
          confidenceContext == AdvisorConfidenceContext.uncertain) {
        warnings.add('High confidence rating conflicts with uncertain confidence context.');
      }
      
      if (confidenceLevel <= 2 && 
          confidenceContext == AdvisorConfidenceContext.veryConfident) {
        warnings.add('Low confidence rating conflicts with very confident context.');
      }
    }
    
    // Long observation period suggestions
    if (observationPeriod == AdvisorObservationPeriod.moreThanThreeYears) {
      if (!hasExamples) {
        suggestions.add('With extensive observation time, you likely have great examples to share.');
      }
    }
    
    return ValidationResult(
      isValid: true,
      warnings: warnings,
      suggestions: suggestions,
    );
  }
  
  /// Calculate response quality score
  static double calculateResponseQuality(String response) {
    double score = 0.0;
    
    final words = response.trim().split(RegExp(r'\s+'));
    final wordCount = words.length;
    
    // Base score from word count
    if (wordCount >= minWordCount) {
      score += 0.3;
    }
    
    if (wordCount >= 30) {
      score += 0.2;
    }
    
    if (wordCount >= 50) {
      score += 0.1;
    }
    
    // Score for specific indicators
    final lowerResponse = response.toLowerCase();
    
    // Positive indicators
    final positiveIndicators = [
      'for example',
      'specifically',
      'in particular',
      'i observed',
      'i noticed',
      'i\'ve seen',
      'when they',
      'during',
      'situation',
      'project',
      'instance',
      'demonstrate',
      'showed',
      'ability to',
      'skilled at',
      'strength in',
    ];
    
    for (final indicator in positiveIndicators) {
      if (lowerResponse.contains(indicator)) {
        score += 0.05;
      }
    }
    
    // Negative indicators
    final negativeIndicators = lowQualityPatterns;
    for (final indicator in negativeIndicators) {
      if (lowerResponse.contains(indicator.toLowerCase())) {
        score -= 0.1;
      }
    }
    
    return score.clamp(0.0, 1.0);
  }
  
  /// Check for Australian context and spelling
  static List<String> checkAustralianContext(String response) {
    final suggestions = <String>[];
    
    // Check for American vs Australian spellings
    final americanSpellings = [
      ['organize', 'organise'],
      ['realize', 'realise'],
      ['analyze', 'analyse'],
      ['color', 'colour'],
      ['honor', 'honour'],
      ['center', 'centre'],
      ['theater', 'theatre'],
    ];
    
    final lowerResponse = response.toLowerCase();
    
    for (final spellingPair in americanSpellings) {
      if (lowerResponse.contains(spellingPair[0])) {
        suggestions.add('Consider using Australian spelling: "${spellingPair[1]}" instead of "${spellingPair[0]}"');
      }
    }
    
    return suggestions;
  }
  
  /// Generate overall feedback about response quality
  static String generateQualityFeedback(ValidationResult validation, double qualityScore) {
    if (!validation.isValid) {
      return 'Please address the required fields before submitting.';
    }
    
    if (qualityScore >= 0.8) {
      return 'Excellent response! Your detailed feedback will be very valuable.';
    } else if (qualityScore >= 0.6) {
      return 'Good response. Consider adding more specific examples if possible.';
    } else if (qualityScore >= 0.4) {
      return 'Reasonable response. More detail and examples would strengthen your feedback.';
    } else {
      return 'Your response could benefit from more detail and specific examples.';
    }
  }
}

/// Result of validation with detailed feedback
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final List<String> suggestions;
  
  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
    this.suggestions = const [],
  });
  
  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasSuggestions => suggestions.isNotEmpty;
  bool get hasFeedback => hasWarnings || hasSuggestions;
}