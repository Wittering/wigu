import 'package:hive/hive.dart';
import 'career_session.dart';

part 'career_progress.g.dart';

/// Tracks progress through the career exploration journey
/// Monitors completion, engagement, and development over time
@HiveType(typeId: 100)
class CareerProgress extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String sessionId;

  @HiveField(2)
  final DateTime startedAt;

  @HiveField(3)
  final DateTime lastUpdated;

  @HiveField(4)
  final double overallCompletion; // 0.0 to 1.0

  @HiveField(5)
  final Map<CareerDomain, DomainProgress> domainProgress;

  @HiveField(6)
  final List<ProgressMilestone> milestones;

  @HiveField(7)
  final ProgressPhase currentPhase;

  @HiveField(8)
  final Map<String, int> engagementMetrics; // Various engagement measures

  @HiveField(9)
  final List<String> completedQuestionIds;

  @HiveField(10)
  final List<String> skippedQuestionIds;

  @HiveField(11)
  final int totalTimeSpentMinutes;

  @HiveField(12)
  final ProgressQuality qualityAssessment;

  @HiveField(13)
  final List<String> insights; // Key insights about progress

  @HiveField(14)
  final Map<String, dynamic>? metadata;

  CareerProgress({
    required this.id,
    required this.sessionId,
    required this.startedAt,
    required this.lastUpdated,
    required this.overallCompletion,
    required this.domainProgress,
    required this.milestones,
    required this.currentPhase,
    required this.engagementMetrics,
    required this.completedQuestionIds,
    required this.skippedQuestionIds,
    required this.totalTimeSpentMinutes,
    required this.qualityAssessment,
    required this.insights,
    this.metadata,
  });

  CareerProgress copyWith({
    String? id,
    String? sessionId,
    DateTime? startedAt,
    DateTime? lastUpdated,
    double? overallCompletion,
    Map<CareerDomain, DomainProgress>? domainProgress,
    List<ProgressMilestone>? milestones,
    ProgressPhase? currentPhase,
    Map<String, int>? engagementMetrics,
    List<String>? completedQuestionIds,
    List<String>? skippedQuestionIds,
    int? totalTimeSpentMinutes,
    ProgressQuality? qualityAssessment,
    List<String>? insights,
    Map<String, dynamic>? metadata,
  }) {
    return CareerProgress(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      startedAt: startedAt ?? this.startedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      overallCompletion: overallCompletion ?? this.overallCompletion,
      domainProgress: domainProgress ?? this.domainProgress,
      milestones: milestones ?? this.milestones,
      currentPhase: currentPhase ?? this.currentPhase,
      engagementMetrics: engagementMetrics ?? this.engagementMetrics,
      completedQuestionIds: completedQuestionIds ?? this.completedQuestionIds,
      skippedQuestionIds: skippedQuestionIds ?? this.skippedQuestionIds,
      totalTimeSpentMinutes: totalTimeSpentMinutes ?? this.totalTimeSpentMinutes,
      qualityAssessment: qualityAssessment ?? this.qualityAssessment,
      insights: insights ?? this.insights,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get total duration of the journey so far
  Duration get totalDuration {
    return lastUpdated.difference(startedAt);
  }

  /// Get average time per question
  double get averageTimePerQuestion {
    if (completedQuestionIds.isEmpty) return 0.0;
    return totalTimeSpentMinutes / completedQuestionIds.length;
  }

  /// Calculate engagement score (0.0 to 1.0)
  double get engagementScore {
    double score = 0.0;
    
    // Completion rate factor
    score += overallCompletion * 0.3;
    
    // Quality factor
    switch (qualityAssessment) {
      case ProgressQuality.excellent:
        score += 0.3;
        break;
      case ProgressQuality.good:
        score += 0.25;
        break;
      case ProgressQuality.fair:
        score += 0.15;
        break;
      case ProgressQuality.poor:
        score += 0.05;
        break;
    }
    
    // Consistency factor (based on regularity of updates)
    final daysSinceStart = totalDuration.inDays;
    if (daysSinceStart > 0) {
      final updatesPerDay = milestones.length / daysSinceStart;
      score += (updatesPerDay * 7).clamp(0.0, 0.2); // Up to 0.2 for daily updates
    }
    
    // Depth factor (based on time spent)
    final expectedTimePerQuestion = 15.0; // minutes
    final timeRatio = (averageTimePerQuestion / expectedTimePerQuestion).clamp(0.0, 2.0);
    score += (timeRatio - 1.0).abs() < 0.5 ? 0.2 : 0.1;
    
    return score.clamp(0.0, 1.0);
  }

  /// Get the most advanced domain
  CareerDomain? get mostAdvancedDomain {
    if (domainProgress.isEmpty) return null;
    
    return domainProgress.entries
        .reduce((a, b) => a.value.completion > b.value.completion ? a : b)
        .key;
  }

  /// Get domains that need attention
  List<CareerDomain> get domainsNeedingAttention {
    return domainProgress.entries
        .where((entry) => entry.value.completion < 0.3)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get completed milestones
  List<ProgressMilestone> get completedMilestones {
    return milestones.where((m) => m.isCompleted).toList();
  }

  /// Get next milestone to work on
  ProgressMilestone? get nextMilestone {
    final incomplete = milestones.where((m) => !m.isCompleted).toList();
    if (incomplete.isEmpty) return null;
    
    // Sort by priority and target date
    incomplete.sort((a, b) {
      final priorityComparison = b.priority.index.compareTo(a.priority.index);
      if (priorityComparison != 0) return priorityComparison;
      
      if (a.targetDate != null && b.targetDate != null) {
        return a.targetDate!.compareTo(b.targetDate!);
      }
      return 0;
    });
    
    return incomplete.first;
  }

  /// Check if the user is on track
  bool get isOnTrack {
    // Consider on track if engagement score is good and regular progress
    return engagementScore >= 0.6 && 
           overallCompletion >= 0.3 &&
           qualityAssessment.index >= ProgressQuality.fair.index;
  }

  /// Get progress insights
  List<String> generateProgressInsights() {
    final insights = <String>[];
    
    // Completion insights
    if (overallCompletion >= 0.8) {
      insights.add('Excellent progress - you\'re nearing completion of your career exploration!');
    } else if (overallCompletion >= 0.5) {
      insights.add('Good momentum - you\'re over halfway through your career journey.');
    } else if (overallCompletion >= 0.3) {
      insights.add('Solid start - keep building on your career exploration foundation.');
    } else {
      insights.add('Early stages - take your time to build a thorough understanding.');
    }
    
    // Engagement insights
    if (engagementScore >= 0.8) {
      insights.add('Outstanding engagement - you\'re deeply invested in this process.');
    } else if (engagementScore >= 0.6) {
      insights.add('Good engagement - you\'re actively participating in the process.');
    } else if (engagementScore >= 0.4) {
      insights.add('Moderate engagement - consider ways to deepen your involvement.');
    } else {
      insights.add('Low engagement - you might benefit from a different approach or timing.');
    }
    
    // Domain insights
    if (mostAdvancedDomain != null) {
      insights.add('Strongest progress in ${mostAdvancedDomain!.displayName} - this may indicate a natural affinity.');
    }
    
    if (domainsNeedingAttention.isNotEmpty) {
      final domainNames = domainsNeedingAttention.map((d) => d.displayName).take(2).join(' and ');
      insights.add('Consider focusing more attention on $domainNames.');
    }
    
    // Time insights
    if (averageTimePerQuestion > 20) {
      insights.add('You\'re taking thoughtful time with each question - this thorough approach is valuable.');
    } else if (averageTimePerQuestion < 5) {
      insights.add('You\'re moving quickly through questions - consider taking more time for deeper reflection.');
    }
    
    // Quality insights
    switch (qualityAssessment) {
      case ProgressQuality.excellent:
        insights.add('The quality of your responses is excellent - rich, detailed, and thoughtful.');
        break;
      case ProgressQuality.good:
        insights.add('Good quality responses - you\'re providing helpful detail and context.');
        break;
      case ProgressQuality.fair:
        insights.add('Fair quality responses - consider adding more examples and personal reflection.');
        break;
      case ProgressQuality.poor:
        insights.add('Your responses could benefit from more detail and personal examples.');
        break;
    }
    
    return insights;
  }

  /// Update progress with new completion data
  CareerProgress updateProgress({
    required double newCompletion,
    required Map<CareerDomain, DomainProgress> updatedDomainProgress,
    List<ProgressMilestone>? newMilestones,
    ProgressPhase? newPhase,
    Map<String, int>? updatedEngagementMetrics,
    List<String>? newCompletedQuestions,
    List<String>? newSkippedQuestions,
    int? additionalTimeMinutes,
    ProgressQuality? newQualityAssessment,
  }) {
    final updatedMilestones = newMilestones ?? milestones;
    final updatedEngagement = updatedEngagementMetrics ?? engagementMetrics;
    final updatedCompleted = newCompletedQuestions ?? completedQuestionIds;
    final updatedSkipped = newSkippedQuestions ?? skippedQuestionIds;
    final updatedTime = totalTimeSpentMinutes + (additionalTimeMinutes ?? 0);
    
    return copyWith(
      lastUpdated: DateTime.now(),
      overallCompletion: newCompletion,
      domainProgress: updatedDomainProgress,
      milestones: updatedMilestones,
      currentPhase: newPhase ?? currentPhase,
      engagementMetrics: updatedEngagement,
      completedQuestionIds: updatedCompleted,
      skippedQuestionIds: updatedSkipped,
      totalTimeSpentMinutes: updatedTime,
      qualityAssessment: newQualityAssessment ?? qualityAssessment,
      insights: generateProgressInsights(),
    );
  }

  /// Export progress data to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'startedAt': startedAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'overallCompletion': overallCompletion,
      'domainProgress': domainProgress.map((k, v) => MapEntry(k.name, v.toJson())),
      'milestones': milestones.map((m) => m.toJson()).toList(),
      'currentPhase': currentPhase.name,
      'engagementMetrics': engagementMetrics,
      'completedQuestionIds': completedQuestionIds,
      'skippedQuestionIds': skippedQuestionIds,
      'totalTimeSpentMinutes': totalTimeSpentMinutes,
      'qualityAssessment': qualityAssessment.name,
      'insights': insights,
      'metadata': metadata,
      'analysis': {
        'totalDuration': totalDuration.inDays,
        'averageTimePerQuestion': averageTimePerQuestion,
        'engagementScore': engagementScore,
        'mostAdvancedDomain': mostAdvancedDomain?.name,
        'domainsNeedingAttention': domainsNeedingAttention.map((d) => d.name).toList(),
        'completedMilestones': completedMilestones.length,
        'nextMilestone': nextMilestone?.title,
        'isOnTrack': isOnTrack,
      },
    };
  }

  /// Create a new career progress tracker
  static CareerProgress create({
    required String sessionId,
    required Map<CareerDomain, DomainProgress> initialDomainProgress,
    List<ProgressMilestone>? initialMilestones,
    ProgressPhase currentPhase = ProgressPhase.exploration,
    Map<String, dynamic>? metadata,
  }) {
    return CareerProgress(
      id: 'progress_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: sessionId,
      startedAt: DateTime.now(),
      lastUpdated: DateTime.now(),
      overallCompletion: 0.0,
      domainProgress: initialDomainProgress,
      milestones: initialMilestones ?? [],
      currentPhase: currentPhase,
      engagementMetrics: {},
      completedQuestionIds: [],
      skippedQuestionIds: [],
      totalTimeSpentMinutes: 0,
      qualityAssessment: ProgressQuality.fair,
      insights: [],
      metadata: metadata,
    );
  }

  @override
  String toString() {
    return 'CareerProgress{id: $id, session: $sessionId, '
           'completion: ${(overallCompletion * 100).round()}%, '
           'engagement: ${(engagementScore * 100).round()}%, phase: ${currentPhase.name}}';
  }
}

/// Progress tracking for individual career domains
@HiveType(typeId: 101)
class DomainProgress extends HiveObject {
  @HiveField(0)
  final CareerDomain domain;

  @HiveField(1)
  final double completion; // 0.0 to 1.0

  @HiveField(2)
  final int questionsCompleted;

  @HiveField(3)
  final int totalQuestions;

  @HiveField(4)
  final DateTime? lastActivity;

  @HiveField(5)
  final int timeSpentMinutes;

  @HiveField(6)
  final DomainEngagement engagement;

  @HiveField(7)
  final List<String> keyInsights;

  @HiveField(8)
  final double qualityScore; // 0.0 to 1.0

  DomainProgress({
    required this.domain,
    required this.completion,
    required this.questionsCompleted,
    required this.totalQuestions,
    this.lastActivity,
    required this.timeSpentMinutes,
    required this.engagement,
    required this.keyInsights,
    required this.qualityScore,
  });

  /// Check if this domain is completed
  bool get isCompleted => completion >= 1.0;

  /// Check if this domain is well-progressed
  bool get isWellProgressed => completion >= 0.7 && qualityScore >= 0.6;

  /// Get average time per question for this domain
  double get averageTimePerQuestion {
    return questionsCompleted > 0 ? timeSpentMinutes / questionsCompleted : 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'domain': domain.name,
      'completion': completion,
      'questionsCompleted': questionsCompleted,
      'totalQuestions': totalQuestions,
      'lastActivity': lastActivity?.toIso8601String(),
      'timeSpentMinutes': timeSpentMinutes,
      'engagement': engagement.name,
      'keyInsights': keyInsights,
      'qualityScore': qualityScore,
      'isCompleted': isCompleted,
      'isWellProgressed': isWellProgressed,
      'averageTimePerQuestion': averageTimePerQuestion,
    };
  }

  @override
  String toString() {
    return 'DomainProgress{domain: ${domain.name}, completion: ${(completion * 100).round()}%}';
  }
}

/// Individual milestone in the career exploration journey
@HiveType(typeId: 102)
class ProgressMilestone extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final MilestoneType type;

  @HiveField(4)
  final MilestonePriority priority;

  @HiveField(5)
  final bool isCompleted;

  @HiveField(6)
  final DateTime? completedAt;

  @HiveField(7)
  final DateTime? targetDate;

  @HiveField(8)
  final List<String> successCriteria;

  @HiveField(9)
  final String? notes;

  ProgressMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.isCompleted,
    this.completedAt,
    this.targetDate,
    required this.successCriteria,
    this.notes,
  });

  /// Check if this milestone is overdue
  bool get isOverdue {
    return !isCompleted && 
           targetDate != null && 
           DateTime.now().isAfter(targetDate!);
  }

  /// Get days until target date
  int? get daysUntilTarget {
    if (targetDate == null) return null;
    return targetDate!.difference(DateTime.now()).inDays;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'priority': priority.name,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'successCriteria': successCriteria,
      'notes': notes,
      'isOverdue': isOverdue,
      'daysUntilTarget': daysUntilTarget,
    };
  }

  @override
  String toString() {
    return 'ProgressMilestone{title: $title, type: ${type.name}, completed: $isCompleted}';
  }
}

/// Phases of the career exploration journey
@HiveType(typeId: 103)
enum ProgressPhase {
  @HiveField(0)
  setup('Setup', 'Initial setup and orientation'),
  
  @HiveField(1)
  exploration('Exploration', 'Active exploration and questioning'),
  
  @HiveField(2)
  deepening('Deepening', 'Deeper reflection and probing'),
  
  @HiveField(3)
  synthesis('Synthesis', 'Synthesising insights and patterns'),
  
  @HiveField(4)
  planning('Planning', 'Creating action plans and next steps'),
  
  @HiveField(5)
  implementation('Implementation', 'Taking action and experimenting'),
  
  @HiveField(6)
  review('Review', 'Reviewing progress and outcomes');

  const ProgressPhase(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// Quality assessment of progress
@HiveType(typeId: 104)
enum ProgressQuality {
  @HiveField(0)
  poor('Poor', 'Limited depth and engagement'),
  
  @HiveField(1)
  fair('Fair', 'Adequate depth with some good insights'),
  
  @HiveField(2)
  good('Good', 'Good depth and meaningful insights'),
  
  @HiveField(3)
  excellent('Excellent', 'Exceptional depth and transformative insights');

  const ProgressQuality(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// Engagement level for specific domains
@HiveType(typeId: 105)
enum DomainEngagement {
  @HiveField(0)
  low('Low', 'Minimal engagement or interest'),
  
  @HiveField(1)
  moderate('Moderate', 'Average engagement and participation'),
  
  @HiveField(2)
  high('High', 'Strong engagement and deep exploration'),
  
  @HiveField(3)
  exceptional('Exceptional', 'Outstanding engagement with breakthrough insights');

  const DomainEngagement(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// Types of milestones
@HiveType(typeId: 106)
enum MilestoneType {
  @HiveField(0)
  exploration('Exploration', 'Complete exploration in a domain'),
  
  @HiveField(1)
  insight('Insight', 'Generate meaningful insights'),
  
  @HiveField(2)
  synthesis('Synthesis', 'Complete synthesis activity'),
  
  @HiveField(3)
  experiment('Experiment', 'Complete a career experiment'),
  
  @HiveField(4)
  planning('Planning', 'Create development or action plan'),
  
  @HiveField(5)
  reflection('Reflection', 'Deep reflection milestone');

  const MilestoneType(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// Priority levels for milestones
@HiveType(typeId: 107)
enum MilestonePriority {
  @HiveField(0)
  low('Low', 'Nice to complete but not urgent'),
  
  @HiveField(1)
  medium('Medium', 'Important for good progress'),
  
  @HiveField(2)
  high('High', 'Critical for meaningful outcomes'),
  
  @HiveField(3)
  urgent('Urgent', 'Time-sensitive completion required');

  const MilestonePriority(this.displayName, this.description);
  
  final String displayName;
  final String description;
}