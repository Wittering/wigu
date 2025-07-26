import 'package:hive/hive.dart';
import 'career_experiment.dart';

part 'experiment_result.g.dart';

/// Results and learnings from a completed career experiment
/// Captures outcomes, insights, and lessons learned for future application
@HiveType(typeId: 60)
class ExperimentResult extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String experimentId;

  @HiveField(2)
  final DateTime completedAt;

  @HiveField(3)
  final ExperimentOutcome outcome;

  @HiveField(4)
  final List<MetricResult> metricResults;

  @HiveField(5)
  final String executiveSummary;

  @HiveField(6)
  final List<String> keyLearnings;

  @HiveField(7)
  final List<String> unexpectedOutcomes;

  @HiveField(8)
  final String hypothesisValidation; // How well was the hypothesis validated

  @HiveField(9)
  final double successScore; // 0.0 to 1.0 based on success criteria

  @HiveField(10)
  final List<String> challengesFaced;

  @HiveField(11)
  final List<String> successFactors;

  @HiveField(12)
  final List<String> nextSteps; // What to do based on these results

  @HiveField(13)
  final List<String> futureExperimentIdeas;

  @HiveField(14)
  final ResultConfidence confidence;

  @HiveField(15)
  final Map<String, String>? stakeholderFeedback; // Feedback from others involved

  @HiveField(16)
  final List<String>? evidenceFiles; // Supporting documentation/files

  @HiveField(17)
  final String? personalReflection;

  @HiveField(18)
  final Map<String, dynamic>? metadata;

  @HiveField(19)
  final DateTime? lastUpdated;

  ExperimentResult({
    required this.id,
    required this.experimentId,
    required this.completedAt,
    required this.outcome,
    required this.metricResults,
    required this.executiveSummary,
    required this.keyLearnings,
    required this.unexpectedOutcomes,
    required this.hypothesisValidation,
    required this.successScore,
    required this.challengesFaced,
    required this.successFactors,
    required this.nextSteps,
    required this.futureExperimentIdeas,
    required this.confidence,
    this.stakeholderFeedback,
    this.evidenceFiles,
    this.personalReflection,
    this.metadata,
    this.lastUpdated,
  });

  ExperimentResult copyWith({
    String? id,
    String? experimentId,
    DateTime? completedAt,
    ExperimentOutcome? outcome,
    List<MetricResult>? metricResults,
    String? executiveSummary,
    List<String>? keyLearnings,
    List<String>? unexpectedOutcomes,
    String? hypothesisValidation,
    double? successScore,
    List<String>? challengesFaced,
    List<String>? successFactors,
    List<String>? nextSteps,
    List<String>? futureExperimentIdeas,
    ResultConfidence? confidence,
    Map<String, String>? stakeholderFeedback,
    List<String>? evidenceFiles,
    String? personalReflection,
    Map<String, dynamic>? metadata,
    DateTime? lastUpdated,
  }) {
    return ExperimentResult(
      id: id ?? this.id,
      experimentId: experimentId ?? this.experimentId,
      completedAt: completedAt ?? this.completedAt,
      outcome: outcome ?? this.outcome,
      metricResults: metricResults ?? this.metricResults,
      executiveSummary: executiveSummary ?? this.executiveSummary,
      keyLearnings: keyLearnings ?? this.keyLearnings,
      unexpectedOutcomes: unexpectedOutcomes ?? this.unexpectedOutcomes,
      hypothesisValidation: hypothesisValidation ?? this.hypothesisValidation,
      successScore: successScore ?? this.successScore,
      challengesFaced: challengesFaced ?? this.challengesFaced,
      successFactors: successFactors ?? this.successFactors,
      nextSteps: nextSteps ?? this.nextSteps,
      futureExperimentIdeas: futureExperimentIdeas ?? this.futureExperimentIdeas,
      confidence: confidence ?? this.confidence,
      stakeholderFeedback: stakeholderFeedback ?? this.stakeholderFeedback,
      evidenceFiles: evidenceFiles ?? this.evidenceFiles,
      personalReflection: personalReflection ?? this.personalReflection,
      metadata: metadata ?? this.metadata,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Check if the experiment was successful based on success score
  bool get wasSuccessful => successScore >= 0.7;

  /// Check if the experiment produced valuable learnings regardless of success
  bool get producedValueableLearnings => keyLearnings.length >= 2;

  /// Get the overall result rating
  ResultRating get overallRating {
    if (successScore >= 0.9) return ResultRating.excellent;
    if (successScore >= 0.7) return ResultRating.good;
    if (successScore >= 0.5) return ResultRating.mixed;
    if (successScore >= 0.3) return ResultRating.poor;
    return ResultRating.failed;
  }

  /// Get metrics that met their targets
  List<MetricResult> get successfulMetrics {
    return metricResults.where((metric) => metric.metTarget).toList();
  }

  /// Get metrics that didn't meet their targets
  List<MetricResult> get unsuccessfulMetrics {
    return metricResults.where((metric) => !metric.metTarget).toList();
  }

  /// Calculate the percentage of metrics that were successful
  double get metricSuccessRate {
    if (metricResults.isEmpty) return 0.0;
    return successfulMetrics.length / metricResults.length;
  }

  /// Check if there were significant unexpected outcomes
  bool get hadSignificantUnexpectedOutcomes {
    return unexpectedOutcomes.length >= 2;
  }

  /// Get the learning density (learnings per week of experiment)
  double getLearningDensity(int experimentDurationDays) {
    if (experimentDurationDays <= 0) return 0.0;
    final weeks = experimentDurationDays / 7.0;
    return keyLearnings.length / weeks;
  }

  /// Generate comprehensive result summary
  String generateComprehensiveReport() {
    final buffer = StringBuffer();
    
    buffer.writeln('Experiment Result Report');
    buffer.writeln('===========================');
    buffer.writeln('');
    buffer.writeln('Completed: ${completedAt.toIso8601String().split('T')[0]}');
    buffer.writeln('Outcome: ${outcome.displayName}');
    buffer.writeln('Success Score: ${(successScore * 100).round()}%');
    buffer.writeln('Overall Rating: ${overallRating.displayName}');
    buffer.writeln('Confidence: ${confidence.displayName}');
    buffer.writeln('');
    
    buffer.writeln('Executive Summary:');
    buffer.writeln(executiveSummary);
    buffer.writeln('');
    
    buffer.writeln('Hypothesis Validation:');
    buffer.writeln(hypothesisValidation);
    buffer.writeln('');
    
    if (metricResults.isNotEmpty) {
      buffer.writeln('Metric Results (${(metricSuccessRate * 100).round()}% success rate):');
      for (final metric in metricResults) {
        final status = metric.metTarget ? '✅' : '❌';
        buffer.writeln('$status ${metric.metricName}: ${metric.actualValue}');
        if (metric.commentary != null) {
          buffer.writeln('   ${metric.commentary}');
        }
      }
      buffer.writeln('');
    }
    
    if (keyLearnings.isNotEmpty) {
      buffer.writeln('Key Learnings:');
      for (final learning in keyLearnings) {
        buffer.writeln('• $learning');
      }
      buffer.writeln('');
    }
    
    if (unexpectedOutcomes.isNotEmpty) {
      buffer.writeln('Unexpected Outcomes:');
      for (final outcome in unexpectedOutcomes) {
        buffer.writeln('• $outcome');
      }
      buffer.writeln('');
    }
    
    if (challengesFaced.isNotEmpty) {
      buffer.writeln('Challenges Faced:');
      for (final challenge in challengesFaced) {
        buffer.writeln('• $challenge');
      }
      buffer.writeln('');
    }
    
    if (successFactors.isNotEmpty) {
      buffer.writeln('Success Factors:');
      for (final factor in successFactors) {
        buffer.writeln('• $factor');
      }
      buffer.writeln('');
    }
    
    if (nextSteps.isNotEmpty) {
      buffer.writeln('Next Steps:');
      for (final step in nextSteps) {
        buffer.writeln('• $step');
      }
      buffer.writeln('');
    }
    
    if (futureExperimentIdeas.isNotEmpty) {
      buffer.writeln('Future Experiment Ideas:');
      for (final idea in futureExperimentIdeas) {
        buffer.writeln('• $idea');
      }
      buffer.writeln('');
    }
    
    if (stakeholderFeedback != null && stakeholderFeedback!.isNotEmpty) {
      buffer.writeln('Stakeholder Feedback:');
      stakeholderFeedback!.forEach((stakeholder, feedback) {
        buffer.writeln('$stakeholder: "$feedback"');
      });
      buffer.writeln('');
    }
    
    if (personalReflection != null && personalReflection!.isNotEmpty) {
      buffer.writeln('Personal Reflection:');
      buffer.writeln(personalReflection);
    }
    
    return buffer.toString();
  }

  /// Generate action plan based on results
  List<String> generateActionPlan() {
    final actions = <String>[];
    
    // Add next steps
    actions.addAll(nextSteps);
    
    // Add actions based on unsuccessful metrics
    for (final metric in unsuccessfulMetrics) {
      if (metric.improvementSuggestion != null) {
        actions.add('Address ${metric.metricName}: ${metric.improvementSuggestion}');
      }
    }
    
    // Add actions based on challenges
    if (challengesFaced.isNotEmpty) {
      actions.add('Develop strategies to address challenges: ${challengesFaced.take(2).join(', ')}');
    }
    
    // Add follow-up experiments
    if (futureExperimentIdeas.isNotEmpty) {
      actions.add('Consider follow-up experiment: ${futureExperimentIdeas.first}');
    }
    
    return actions.take(5).toList();
  }

  /// Export result to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'experimentId': experimentId,
      'completedAt': completedAt.toIso8601String(),
      'outcome': outcome.name,
      'metricResults': metricResults.map((m) => m.toJson()).toList(),
      'executiveSummary': executiveSummary,
      'keyLearnings': keyLearnings,
      'unexpectedOutcomes': unexpectedOutcomes,
      'hypothesisValidation': hypothesisValidation,
      'successScore': successScore,
      'challengesFaced': challengesFaced,
      'successFactors': successFactors,
      'nextSteps': nextSteps,
      'futureExperimentIdeas': futureExperimentIdeas,
      'confidence': confidence.name,
      'stakeholderFeedback': stakeholderFeedback,
      'evidenceFiles': evidenceFiles,
      'personalReflection': personalReflection,
      'metadata': metadata,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'analysis': {
        'wasSuccessful': wasSuccessful,
        'producedValueableLearnings': producedValueableLearnings,
        'overallRating': overallRating.name,
        'metricSuccessRate': metricSuccessRate,
        'hadSignificantUnexpectedOutcomes': hadSignificantUnexpectedOutcomes,
        'successfulMetrics': successfulMetrics.length,
        'unsuccessfulMetrics': unsuccessfulMetrics.length,
      },
    };
  }

  /// Create a new experiment result
  static ExperimentResult create({
    required String experimentId,
    required ExperimentOutcome outcome,
    required List<MetricResult> metricResults,
    required String executiveSummary,
    required List<String> keyLearnings,
    required List<String> unexpectedOutcomes,
    required String hypothesisValidation,
    required double successScore,
    required List<String> challengesFaced,
    required List<String> successFactors,
    required List<String> nextSteps,
    required List<String> futureExperimentIdeas,
    required ResultConfidence confidence,
    Map<String, String>? stakeholderFeedback,
    List<String>? evidenceFiles,
    String? personalReflection,
    Map<String, dynamic>? metadata,
  }) {
    return ExperimentResult(
      id: 'result_${DateTime.now().millisecondsSinceEpoch}',
      experimentId: experimentId,
      completedAt: DateTime.now(),
      outcome: outcome,
      metricResults: metricResults,
      executiveSummary: executiveSummary,
      keyLearnings: keyLearnings,
      unexpectedOutcomes: unexpectedOutcomes,
      hypothesisValidation: hypothesisValidation,
      successScore: successScore,
      challengesFaced: challengesFaced,
      successFactors: successFactors,
      nextSteps: nextSteps,
      futureExperimentIdeas: futureExperimentIdeas,
      confidence: confidence,
      stakeholderFeedback: stakeholderFeedback,
      evidenceFiles: evidenceFiles,
      personalReflection: personalReflection,
      metadata: metadata,
    );
  }

  @override
  String toString() {
    return 'ExperimentResult{id: $id, experimentId: $experimentId, '
           'outcome: ${outcome.name}, successScore: ${(successScore * 100).round()}%}';
  }
}

/// Result for a specific metric in an experiment
@HiveType(typeId: 61)
class MetricResult extends HiveObject {
  @HiveField(0)
  final String metricName;

  @HiveField(1)
  final String expectedValue;

  @HiveField(2)
  final String actualValue;

  @HiveField(3)
  final bool metTarget;

  @HiveField(4)
  final String? commentary;

  @HiveField(5)
  final MetricResultType resultType;

  @HiveField(6)
  final double? quantitativeScore; // 0.0 to 1.0 for quantitative metrics

  @HiveField(7)
  final String? improvementSuggestion;

  @HiveField(8)
  final List<String>? supportingEvidence;

  MetricResult({
    required this.metricName,
    required this.expectedValue,
    required this.actualValue,
    required this.metTarget,
    this.commentary,
    required this.resultType,
    this.quantitativeScore,
    this.improvementSuggestion,
    this.supportingEvidence,
  });

  MetricResult copyWith({
    String? metricName,
    String? expectedValue,
    String? actualValue,
    bool? metTarget,
    String? commentary,
    MetricResultType? resultType,
    double? quantitativeScore,
    String? improvementSuggestion,
    List<String>? supportingEvidence,
  }) {
    return MetricResult(
      metricName: metricName ?? this.metricName,
      expectedValue: expectedValue ?? this.expectedValue,
      actualValue: actualValue ?? this.actualValue,
      metTarget: metTarget ?? this.metTarget,
      commentary: commentary ?? this.commentary,
      resultType: resultType ?? this.resultType,
      quantitativeScore: quantitativeScore ?? this.quantitativeScore,
      improvementSuggestion: improvementSuggestion ?? this.improvementSuggestion,
      supportingEvidence: supportingEvidence ?? this.supportingEvidence,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metricName': metricName,
      'expectedValue': expectedValue,
      'actualValue': actualValue,
      'metTarget': metTarget,
      'commentary': commentary,
      'resultType': resultType.name,
      'quantitativeScore': quantitativeScore,
      'improvementSuggestion': improvementSuggestion,
      'supportingEvidence': supportingEvidence,
    };
  }

  @override
  String toString() {
    return 'MetricResult{metric: $metricName, met: $metTarget, '
           'expected: $expectedValue, actual: $actualValue}';
  }
}

/// Outcome of an experiment
@HiveType(typeId: 62)
enum ExperimentOutcome {
  @HiveField(0)
  successful('Successful', 'Experiment achieved its objectives'),
  
  @HiveField(1)
  partiallySuccessful('Partially Successful', 'Some objectives met, others not'),
  
  @HiveField(2)
  unsuccessful('Unsuccessful', 'Experiment did not meet its objectives'),
  
  @HiveField(3)
  inconclusive('Inconclusive', 'Results were unclear or insufficient'),
  
  @HiveField(4)
  unexpectedSuccess('Unexpected Success', 'Different but valuable outcomes achieved');

  const ExperimentOutcome(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// Confidence in the results
@HiveType(typeId: 63)
enum ResultConfidence {
  @HiveField(0)
  high('High', 'Very confident in the accuracy and completeness of results'),
  
  @HiveField(1)
  medium('Medium', 'Reasonably confident but some uncertainty'),
  
  @HiveField(2)
  low('Low', 'Limited confidence due to various factors');

  const ResultConfidence(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// Overall rating of experiment results
@HiveType(typeId: 64)
enum ResultRating {
  @HiveField(0)
  excellent('Excellent', 'Outstanding results with significant learnings'),
  
  @HiveField(1)
  good('Good', 'Positive results with valuable insights'),
  
  @HiveField(2)
  mixed('Mixed', 'Some positive and some negative results'),
  
  @HiveField(3)
  poor('Poor', 'Limited success but some learnings'),
  
  @HiveField(4)
  failed('Failed', 'Did not achieve objectives or provide insights');

  const ResultRating(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// Type of metric result
@HiveType(typeId: 65)
enum MetricResultType {
  @HiveField(0)
  exceeded('Exceeded', 'Result exceeded expectations'),
  
  @HiveField(1)
  met('Met', 'Result met expectations exactly'),
  
  @HiveField(2)
  nearlyMet('Nearly Met', 'Result was close to expectations'),
  
  @HiveField(3)
  missed('Missed', 'Result fell short of expectations'),
  
  @HiveField(4)
  significantlyMissed('Significantly Missed', 'Result was far from expectations');

  const MetricResultType(this.displayName, this.description);
  
  final String displayName;
  final String description;
}