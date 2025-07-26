import 'package:hive/hive.dart';
import 'career_insight.dart';

part 'career_experiment.g.dart';

/// Represents a small-scale career experiment to test insights or hypotheses
/// Enables practical validation of career insights through real-world testing
@HiveType(typeId: 50)
class CareerExperiment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final ExperimentType type;

  @HiveField(4)
  final String hypothesis; // What we're testing

  @HiveField(5)
  final List<String> relatedInsightIds; // Insights this experiment tests

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime? startedAt;

  @HiveField(8)
  final DateTime? completedAt;

  @HiveField(9)
  final ExperimentStatus status;

  @HiveField(10)
  final ExperimentScope scope;

  @HiveField(11)
  final int estimatedDurationDays;

  @HiveField(12)
  final List<String> successCriteria; // How we'll measure success

  @HiveField(13)
  final List<ExperimentMetric> metrics; // Specific measurements

  @HiveField(14)
  final List<String> requiredResources; // What's needed to run the experiment

  @HiveField(15)
  final List<String> potentialBarriers; // Anticipated challenges

  @HiveField(16)
  final ExperimentPriority priority;

  @HiveField(17)
  final String? sessionId;

  @HiveField(18)
  final Map<String, dynamic>? metadata;

  @HiveField(19)
  final List<String>? tags;

  @HiveField(20)
  final String? preparationNotes;

  CareerExperiment({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.hypothesis,
    required this.relatedInsightIds,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    required this.status,
    required this.scope,
    required this.estimatedDurationDays,
    required this.successCriteria,
    required this.metrics,
    required this.requiredResources,
    required this.potentialBarriers,
    required this.priority,
    this.sessionId,
    this.metadata,
    this.tags,
    this.preparationNotes,
  });

  CareerExperiment copyWith({
    String? id,
    String? title,
    String? description,
    ExperimentType? type,
    String? hypothesis,
    List<String>? relatedInsightIds,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    ExperimentStatus? status,
    ExperimentScope? scope,
    int? estimatedDurationDays,
    List<String>? successCriteria,
    List<ExperimentMetric>? metrics,
    List<String>? requiredResources,
    List<String>? potentialBarriers,
    ExperimentPriority? priority,
    String? sessionId,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    String? preparationNotes,
  }) {
    return CareerExperiment(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      hypothesis: hypothesis ?? this.hypothesis,
      relatedInsightIds: relatedInsightIds ?? this.relatedInsightIds,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      scope: scope ?? this.scope,
      estimatedDurationDays: estimatedDurationDays ?? this.estimatedDurationDays,
      successCriteria: successCriteria ?? this.successCriteria,
      metrics: metrics ?? this.metrics,
      requiredResources: requiredResources ?? this.requiredResources,
      potentialBarriers: potentialBarriers ?? this.potentialBarriers,
      priority: priority ?? this.priority,
      sessionId: sessionId ?? this.sessionId,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
      preparationNotes: preparationNotes ?? this.preparationNotes,
    );
  }

  /// Get the duration of the experiment if completed
  Duration? get actualDuration {
    if (startedAt == null || completedAt == null) return null;
    return completedAt!.difference(startedAt!);
  }

  /// Get the planned duration
  Duration get plannedDuration => Duration(days: estimatedDurationDays);

  /// Check if the experiment is overdue (started but not completed within estimated time)
  bool get isOverdue {
    if (startedAt == null || completedAt != null) return false;
    final expectedEndDate = startedAt!.add(plannedDuration);
    return DateTime.now().isAfter(expectedEndDate);
  }

  /// Get days since experiment started
  int? get daysSinceStarted {
    if (startedAt == null) return null;
    return DateTime.now().difference(startedAt!).inDays;
  }

  /// Get days until experiment is due
  int? get daysUntilDue {
    if (startedAt == null) return null;
    final dueDate = startedAt!.add(plannedDuration);
    final difference = dueDate.difference(DateTime.now()).inDays;
    return difference > 0 ? difference : 0;
  }

  /// Check if this experiment is ready to start
  bool get isReadyToStart {
    return status == ExperimentStatus.planned && 
           requiredResources.isNotEmpty && 
           successCriteria.isNotEmpty;
  }

  /// Get the complexity level of this experiment
  ExperimentComplexity get complexity {
    int complexityScore = 0;
    
    // Duration complexity
    if (estimatedDurationDays > 30) complexityScore += 2;
    else if (estimatedDurationDays > 7) complexityScore += 1;
    
    // Resource complexity
    if (requiredResources.length > 5) complexityScore += 2;
    else if (requiredResources.length > 2) complexityScore += 1;
    
    // Metrics complexity
    if (metrics.length > 3) complexityScore += 1;
    
    // Scope complexity
    switch (scope) {
      case ExperimentScope.personal:
        break; // No additional complexity
      case ExperimentScope.team:
        complexityScore += 1;
        break;
      case ExperimentScope.organisational:
        complexityScore += 2;
        break;
      case ExperimentScope.external:
        complexityScore += 3;
        break;
    }
    
    if (complexityScore >= 6) return ExperimentComplexity.high;
    if (complexityScore >= 3) return ExperimentComplexity.medium;
    return ExperimentComplexity.low;
  }

  /// Generate experiment summary for review
  String generateSummary() {
    final buffer = StringBuffer();
    
    buffer.writeln('Career Experiment: $title');
    buffer.writeln('=====================================');
    buffer.writeln('');
    buffer.writeln('Type: ${type.displayName}');
    buffer.writeln('Status: ${status.displayName}');
    buffer.writeln('Priority: ${priority.displayName}');
    buffer.writeln('Scope: ${scope.displayName}');
    buffer.writeln('Complexity: ${complexity.displayName}');
    buffer.writeln('');
    buffer.writeln('Hypothesis:');
    buffer.writeln(hypothesis);
    buffer.writeln('');
    buffer.writeln('Duration: $estimatedDurationDays days');
    
    if (startedAt != null) {
      buffer.writeln('Started: ${startedAt!.toIso8601String().split('T')[0]}');
      if (isOverdue) {
        buffer.writeln('⚠️  OVERDUE by ${daysSinceStarted! - estimatedDurationDays} days');
      } else if (daysUntilDue != null) {
        buffer.writeln('Due in: $daysUntilDue days');
      }
    }
    
    buffer.writeln('');
    buffer.writeln('Success Criteria:');
    for (final criterion in successCriteria) {
      buffer.writeln('• $criterion');
    }
    
    if (requiredResources.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Required Resources:');
      for (final resource in requiredResources) {
        buffer.writeln('• $resource');
      }
    }
    
    if (potentialBarriers.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Potential Barriers:');
      for (final barrier in potentialBarriers) {
        buffer.writeln('• $barrier');
      }
    }
    
    return buffer.toString();
  }

  /// Start the experiment
  CareerExperiment start() {
    return copyWith(
      status: ExperimentStatus.active,
      startedAt: DateTime.now(),
    );
  }

  /// Complete the experiment
  CareerExperiment complete() {
    return copyWith(
      status: ExperimentStatus.completed,
      completedAt: DateTime.now(),
    );
  }

  /// Pause the experiment
  CareerExperiment pause() {
    return copyWith(
      status: ExperimentStatus.paused,
    );
  }

  /// Cancel the experiment
  CareerExperiment cancel() {
    return copyWith(
      status: ExperimentStatus.cancelled,
    );
  }

  /// Export experiment data to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'hypothesis': hypothesis,
      'relatedInsightIds': relatedInsightIds,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'status': status.name,
      'scope': scope.name,
      'estimatedDurationDays': estimatedDurationDays,
      'successCriteria': successCriteria,
      'metrics': metrics.map((m) => m.toJson()).toList(),
      'requiredResources': requiredResources,
      'potentialBarriers': potentialBarriers,
      'priority': priority.name,
      'sessionId': sessionId,
      'metadata': metadata,
      'tags': tags,
      'preparationNotes': preparationNotes,
      'analysis': {
        'actualDuration': actualDuration?.inDays,
        'plannedDuration': plannedDuration.inDays,
        'isOverdue': isOverdue,
        'daysSinceStarted': daysSinceStarted,
        'daysUntilDue': daysUntilDue,
        'isReadyToStart': isReadyToStart,
        'complexity': complexity.name,
      },
    };
  }

  /// Create a new career experiment
  static CareerExperiment create({
    required String title,
    required String description,
    required ExperimentType type,
    required String hypothesis,
    required List<String> relatedInsightIds,
    required ExperimentScope scope,
    required int estimatedDurationDays,
    required List<String> successCriteria,
    required List<ExperimentMetric> metrics,
    required List<String> requiredResources,
    required List<String> potentialBarriers,
    required ExperimentPriority priority,
    String? sessionId,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    String? preparationNotes,
  }) {
    return CareerExperiment(
      id: 'experiment_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      type: type,
      hypothesis: hypothesis,
      relatedInsightIds: relatedInsightIds,
      createdAt: DateTime.now(),
      status: ExperimentStatus.planned,
      scope: scope,
      estimatedDurationDays: estimatedDurationDays,
      successCriteria: successCriteria,
      metrics: metrics,
      requiredResources: requiredResources,
      potentialBarriers: potentialBarriers,
      priority: priority,
      sessionId: sessionId,
      metadata: metadata,
      tags: tags,
      preparationNotes: preparationNotes,
    );
  }

  @override
  String toString() {
    return 'CareerExperiment{id: $id, title: $title, status: ${status.name}, '
           'type: ${type.name}, priority: ${priority.name}}';
  }
}

/// Specific metric to measure in an experiment
@HiveType(typeId: 51)
class ExperimentMetric extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final MetricType type;

  @HiveField(3)
  final String measurementMethod;

  @HiveField(4)
  final String? targetValue;

  @HiveField(5)
  final String? baseline;

  @HiveField(6)
  final MetricFrequency frequency;

  ExperimentMetric({
    required this.name,
    required this.description,
    required this.type,
    required this.measurementMethod,
    this.targetValue,
    this.baseline,
    required this.frequency,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'type': type.name,
      'measurementMethod': measurementMethod,
      'targetValue': targetValue,
      'baseline': baseline,
      'frequency': frequency.name,
    };
  }

  @override
  String toString() {
    return 'ExperimentMetric{name: $name, type: ${type.name}, frequency: ${frequency.name}}';
  }
}

/// Types of career experiments
@HiveType(typeId: 52)
enum ExperimentType {
  @HiveField(0)
  skillBuilding('Skill Building', 'Testing ability to develop new capabilities'),
  
  @HiveField(1)
  roleExploration('Role Exploration', 'Testing fit with different types of work'),
  
  @HiveField(2)
  networking('Networking', 'Testing approaches to building professional relationships'),
  
  @HiveField(3)
  visibilityBuilding('Visibility Building', 'Testing ways to increase professional visibility'),
  
  @HiveField(4)
  leadershipDevelopment('Leadership Development', 'Testing leadership capabilities and approaches'),
  
  @HiveField(5)
  workEnvironment('Work Environment', 'Testing different work settings or arrangements'),
  
  @HiveField(6)
  industryExploration('Industry Exploration', 'Testing interest and fit in different industries'),
  
  @HiveField(7)
  valueAlignment('Value Alignment', 'Testing work that aligns with personal values'),
  
  @HiveField(8)
  creativityExpression('Creativity Expression', 'Testing creative outlets in professional context'),
  
  @HiveField(9)
  mentoring('Mentoring', 'Testing ability and interest in developing others');

  const ExperimentType(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// Status of an experiment
@HiveType(typeId: 53)
enum ExperimentStatus {
  @HiveField(0)
  planned('Planned', 'Experiment is designed but not yet started'),
  
  @HiveField(1)
  active('Active', 'Experiment is currently running'),
  
  @HiveField(2)
  paused('Paused', 'Experiment is temporarily paused'),
  
  @HiveField(3)
  completed('Completed', 'Experiment has finished successfully'),
  
  @HiveField(4)
  cancelled('Cancelled', 'Experiment was cancelled before completion');

  const ExperimentStatus(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// Scope of an experiment
@HiveType(typeId: 54)
enum ExperimentScope {
  @HiveField(0)
  personal('Personal', 'Involves only the individual'),
  
  @HiveField(1)
  team('Team', 'Involves the individual\'s immediate team'),
  
  @HiveField(2)
  organisational('Organisational', 'Involves broader organisational context'),
  
  @HiveField(3)
  external('External', 'Involves external parties or organisations');

  const ExperimentScope(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// Priority level of an experiment
@HiveType(typeId: 55)
enum ExperimentPriority {
  @HiveField(0)
  low('Low', 'Nice to do but not urgent'),
  
  @HiveField(1)
  medium('Medium', 'Important for development'),
  
  @HiveField(2)
  high('High', 'Critical for career progress'),
  
  @HiveField(3)
  urgent('Urgent', 'Time-sensitive opportunity');

  const ExperimentPriority(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// Complexity level of an experiment
@HiveType(typeId: 56)
enum ExperimentComplexity {
  @HiveField(0)
  low('Low', 'Simple experiment with minimal resources'),
  
  @HiveField(1)
  medium('Medium', 'Moderate complexity with some coordination needed'),
  
  @HiveField(2)
  high('High', 'Complex experiment requiring significant planning and resources');

  const ExperimentComplexity(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// Types of metrics to measure
@HiveType(typeId: 57)
enum MetricType {
  @HiveField(0)
  quantitative('Quantitative', 'Numerical measurements'),
  
  @HiveField(1)
  qualitative('Qualitative', 'Descriptive observations'),
  
  @HiveField(2)
  behavioral('Behavioral', 'Changes in behavior or habits'),
  
  @HiveField(3)
  feedback('Feedback', 'Input from others'),
  
  @HiveField(4)
  outcome('Outcome', 'Concrete results or achievements');

  const MetricType(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// Frequency of metric measurement
@HiveType(typeId: 58)
enum MetricFrequency {
  @HiveField(0)
  daily('Daily', 'Measured every day'),
  
  @HiveField(1)
  weekly('Weekly', 'Measured once per week'),
  
  @HiveField(2)
  biweekly('Bi-weekly', 'Measured every two weeks'),
  
  @HiveField(3)
  monthly('Monthly', 'Measured once per month'),
  
  @HiveField(4)
  atCompletion('At Completion', 'Measured only when experiment ends');

  const MetricFrequency(this.displayName, this.description);
  
  final String displayName;
  final String description;
}