import 'package:hive/hive.dart';
import 'career_session.dart';

part 'completion_status.g.dart';

/// Comprehensive completion status tracking for the career insight engine
/// Tracks what's been completed, what's outstanding, and next steps
@HiveType(typeId: 110)
class CompletionStatus extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String sessionId;

  @HiveField(2)
  final DateTime lastUpdated;

  @HiveField(3)
  final Map<CompletionCategory, CategoryStatus> categoryStatus;

  @HiveField(4)
  final List<CompletionItem> completedItems;

  @HiveField(5)
  final List<CompletionItem> pendingItems;

  @HiveField(6)
  final List<CompletionItem> optionalItems;

  @HiveField(7)
  final double overallCompletion; // 0.0 to 1.0

  @HiveField(8)
  final CompletionLevel completionLevel;

  @HiveField(9)
  final List<String> nextSteps;

  @HiveField(10)
  final List<String> blockers; // Things preventing progress

  @HiveField(11)
  final Map<String, DateTime> importantDeadlines;

  @HiveField(12)
  final UserReadiness readinessAssessment;

  @HiveField(13)
  final List<String> recommendations;

  @HiveField(14)
  final Map<String, dynamic>? metadata;

  CompletionStatus({
    required this.id,
    required this.sessionId,
    required this.lastUpdated,
    required this.categoryStatus,
    required this.completedItems,
    required this.pendingItems,
    required this.optionalItems,
    required this.overallCompletion,
    required this.completionLevel,
    required this.nextSteps,
    required this.blockers,
    required this.importantDeadlines,
    required this.readinessAssessment,
    required this.recommendations,
    this.metadata,
  });

  CompletionStatus copyWith({
    String? id,
    String? sessionId,
    DateTime? lastUpdated,
    Map<CompletionCategory, CategoryStatus>? categoryStatus,
    List<CompletionItem>? completedItems,
    List<CompletionItem>? pendingItems,
    List<CompletionItem>? optionalItems,
    double? overallCompletion,
    CompletionLevel? completionLevel,
    List<String>? nextSteps,
    List<String>? blockers,
    Map<String, DateTime>? importantDeadlines,
    UserReadiness? readinessAssessment,
    List<String>? recommendations,
    Map<String, dynamic>? metadata,
  }) {
    return CompletionStatus(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      categoryStatus: categoryStatus ?? this.categoryStatus,
      completedItems: completedItems ?? this.completedItems,
      pendingItems: pendingItems ?? this.pendingItems,
      optionalItems: optionalItems ?? this.optionalItems,
      overallCompletion: overallCompletion ?? this.overallCompletion,
      completionLevel: completionLevel ?? this.completionLevel,
      nextSteps: nextSteps ?? this.nextSteps,
      blockers: blockers ?? this.blockers,
      importantDeadlines: importantDeadlines ?? this.importantDeadlines,
      readinessAssessment: readinessAssessment ?? this.readinessAssessment,
      recommendations: recommendations ?? this.recommendations,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get high-priority pending items
  List<CompletionItem> get highPriorityPending {
    return pendingItems
        .where((item) => item.priority == ItemPriority.high || 
                        item.priority == ItemPriority.critical)
        .toList()
        ..sort((a, b) => b.priority.index.compareTo(a.priority.index));
  }

  /// Get overdue items
  List<CompletionItem> get overdueItems {
    final now = DateTime.now();
    return pendingItems
        .where((item) => item.targetDate != null && 
                        item.targetDate!.isBefore(now))
        .toList();
  }

  /// Get items due soon (within next 7 days)
  List<CompletionItem> get itemsDueSoon {
    final weekFromNow = DateTime.now().add(const Duration(days: 7));
    return pendingItems
        .where((item) => item.targetDate != null && 
                        item.targetDate!.isBefore(weekFromNow) &&
                        item.targetDate!.isAfter(DateTime.now()))
        .toList();
  }

  /// Check if ready for next major phase
  bool get isReadyForNextPhase {
    return overallCompletion >= 0.8 && 
           readinessAssessment.index >= UserReadiness.ready.index &&
           blockers.isEmpty;
  }

  /// Get completion score (weighted by priority)
  double get weightedCompletionScore {
    final allItems = [...completedItems, ...pendingItems, ...optionalItems];
    if (allItems.isEmpty) return 1.0;
    
    int totalWeight = 0;
    int completedWeight = 0;
    
    for (final item in allItems) {
      final weight = _getItemWeight(item);
      totalWeight += weight;
      
      if (item.isCompleted) {
        completedWeight += weight;
      }
    }
    
    return totalWeight > 0 ? completedWeight / totalWeight : 1.0;
  }

  /// Get item weight based on priority
  int _getItemWeight(CompletionItem item) {
    switch (item.priority) {
      case ItemPriority.critical:
        return 5;
      case ItemPriority.high:
        return 3;
      case ItemPriority.medium:
        return 2;
      case ItemPriority.low:
        return 1;
    }
  }

  /// Calculate completion for a specific category
  double getCategoryCompletion(CompletionCategory category) {
    final status = categoryStatus[category];
    if (status == null) return 0.0;
    
    final categoryItems = [...completedItems, ...pendingItems, ...optionalItems]
        .where((item) => item.category == category)
        .toList();
    
    if (categoryItems.isEmpty) return 1.0;
    
    final completed = categoryItems.where((item) => item.isCompleted).length;
    return completed / categoryItems.length;
  }

  /// Get categories that are behind schedule
  List<CompletionCategory> getCategoriesBehindSchedule() {
    return categoryStatus.entries
        .where((entry) => entry.value.isBehindSchedule)
        .map((entry) => entry.key)
        .toList();
  }

  /// Generate status summary
  String generateStatusSummary() {
    final buffer = StringBuffer();
    
    buffer.writeln('Career Exploration Status Summary');
    buffer.writeln('================================');
    buffer.writeln('');
    buffer.writeln('Overall Completion: ${(overallCompletion * 100).round()}%');
    buffer.writeln('Weighted Score: ${(weightedCompletionScore * 100).round()}%');
    buffer.writeln('Completion Level: ${completionLevel.displayName}');
    buffer.writeln('Readiness: ${readinessAssessment.displayName}');
    buffer.writeln('Last Updated: ${lastUpdated.toIso8601String().split('T')[0]}');
    buffer.writeln('');
    
    // Category breakdown
    buffer.writeln('Category Progress:');
    for (final category in CompletionCategory.values) {
      final completion = getCategoryCompletion(category);
      final status = categoryStatus[category];
      final statusIndicator = status?.isBehindSchedule == true ? '⚠️' : '✅';
      buffer.writeln('$statusIndicator ${category.displayName}: ${(completion * 100).round()}%');
    }
    buffer.writeln('');
    
    // Priority items
    if (highPriorityPending.isNotEmpty) {
      buffer.writeln('🔥 High Priority Items (${highPriorityPending.length}):');
      for (final item in highPriorityPending.take(5)) {
        buffer.writeln('• ${item.title}');
      }
      buffer.writeln('');
    }
    
    // Overdue items
    if (overdueItems.isNotEmpty) {
      buffer.writeln('❗ Overdue Items (${overdueItems.length}):');
      for (final item in overdueItems.take(3)) {
        buffer.writeln('• ${item.title}');
      }
      buffer.writeln('');
    }
    
    // Due soon
    if (itemsDueSoon.isNotEmpty) {
      buffer.writeln('⏰ Due This Week (${itemsDueSoon.length}):');
      for (final item in itemsDueSoon.take(3)) {
        final daysUntil = item.targetDate!.difference(DateTime.now()).inDays;
        buffer.writeln('• ${item.title} (${daysUntil} days)');
      }
      buffer.writeln('');
    }
    
    // Blockers
    if (blockers.isNotEmpty) {
      buffer.writeln('🚧 Current Blockers:');
      for (final blocker in blockers) {
        buffer.writeln('• $blocker');
      }
      buffer.writeln('');
    }
    
    // Next steps
    if (nextSteps.isNotEmpty) {
      buffer.writeln('➡️  Next Steps:');
      for (final step in nextSteps.take(5)) {
        buffer.writeln('• $step');
      }
      buffer.writeln('');
    }
    
    // Recommendations
    if (recommendations.isNotEmpty) {
      buffer.writeln('💡 Recommendations:');
      for (final rec in recommendations.take(3)) {
        buffer.writeln('• $rec');
      }
    }
    
    return buffer.toString();
  }

  /// Mark an item as completed
  CompletionStatus markItemCompleted(String itemId) {
    final updatedPending = pendingItems.where((item) => item.id != itemId).toList();
    final updatedOptional = optionalItems.where((item) => item.id != itemId).toList();
    
    final completedItem = [...pendingItems, ...optionalItems]
        .firstWhere((item) => item.id == itemId);
    
    final updatedCompleted = [
      ...completedItems,
      completedItem.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      ),
    ];
    
    // Recalculate overall completion
    final newCompletion = _calculateOverallCompletion(
      updatedCompleted,
      updatedPending,
      updatedOptional,
    );
    
    return copyWith(
      completedItems: updatedCompleted,
      pendingItems: updatedPending,
      optionalItems: updatedOptional,
      overallCompletion: newCompletion,
      lastUpdated: DateTime.now(),
    );
  }

  /// Calculate overall completion percentage
  double _calculateOverallCompletion(
    List<CompletionItem> completed,
    List<CompletionItem> pending,
    List<CompletionItem> optional,
  ) {
    final coreItems = [...completed, ...pending]
        .where((item) => item.priority != ItemPriority.low)
        .toList();
    
    if (coreItems.isEmpty) return 1.0;
    
    final completedCount = coreItems.where((item) => item.isCompleted).length;
    return completedCount / coreItems.length;
  }

  /// Export to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'lastUpdated': lastUpdated.toIso8601String(),
      'categoryStatus': categoryStatus.map((k, v) => MapEntry(k.name, v.toJson())),
      'completedItems': completedItems.map((item) => item.toJson()).toList(),
      'pendingItems': pendingItems.map((item) => item.toJson()).toList(),
      'optionalItems': optionalItems.map((item) => item.toJson()).toList(),
      'overallCompletion': overallCompletion,
      'completionLevel': completionLevel.name,
      'nextSteps': nextSteps,
      'blockers': blockers,
      'importantDeadlines': importantDeadlines.map((k, v) => MapEntry(k, v.toIso8601String())),
      'readinessAssessment': readinessAssessment.name,
      'recommendations': recommendations,
      'metadata': metadata,
      'analysis': {
        'weightedCompletionScore': weightedCompletionScore,
        'highPriorityPending': highPriorityPending.length,
        'overdueItems': overdueItems.length,
        'itemsDueSoon': itemsDueSoon.length,
        'isReadyForNextPhase': isReadyForNextPhase,
        'categoriesBehindSchedule': getCategoriesBehindSchedule().map((c) => c.name).toList(),
      },
    };
  }

  /// Create a new completion status
  static CompletionStatus create({
    required String sessionId,
    required Map<CompletionCategory, CategoryStatus> categoryStatus,
    required List<CompletionItem> initialItems,
    Map<String, dynamic>? metadata,
  }) {
    return CompletionStatus(
      id: 'completion_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: sessionId,
      lastUpdated: DateTime.now(),
      categoryStatus: categoryStatus,
      completedItems: [],
      pendingItems: initialItems,
      optionalItems: [],
      overallCompletion: 0.0,
      completionLevel: CompletionLevel.starting,
      nextSteps: [],
      blockers: [],
      importantDeadlines: {},
      readinessAssessment: UserReadiness.notReady,
      recommendations: [],
      metadata: metadata,
    );
  }

  @override
  String toString() {
    return 'CompletionStatus{id: $id, session: $sessionId, '
           'completion: ${(overallCompletion * 100).round()}%, level: ${completionLevel.name}}';
  }
}

/// Individual completion item
@HiveType(typeId: 111)
class CompletionItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final CompletionCategory category;

  @HiveField(4)
  final ItemPriority priority;

  @HiveField(5)
  final bool isCompleted;

  @HiveField(6)
  final DateTime? completedAt;

  @HiveField(7)
  final DateTime? targetDate;

  @HiveField(8)
  final List<String> dependencies; // Other item IDs this depends on

  @HiveField(9)
  final String? notes;

  @HiveField(10)
  final double estimatedHours;

  CompletionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.isCompleted,
    this.completedAt,
    this.targetDate,
    this.dependencies = const [],
    this.notes,
    this.estimatedHours = 1.0,
  });

  CompletionItem copyWith({
    String? id,
    String? title,
    String? description,
    CompletionCategory? category,
    ItemPriority? priority,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? targetDate,
    List<String>? dependencies,
    String? notes,
    double? estimatedHours,
  }) {
    return CompletionItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      targetDate: targetDate ?? this.targetDate,
      dependencies: dependencies ?? this.dependencies,
      notes: notes ?? this.notes,
      estimatedHours: estimatedHours ?? this.estimatedHours,
    );
  }

  /// Check if this item is overdue
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
      'category': category.name,
      'priority': priority.name,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'dependencies': dependencies,
      'notes': notes,
      'estimatedHours': estimatedHours,
      'isOverdue': isOverdue,
      'daysUntilTarget': daysUntilTarget,
    };
  }

  @override
  String toString() {
    return 'CompletionItem{title: $title, category: ${category.name}, '
           'priority: ${priority.name}, completed: $isCompleted}';
  }
}

/// Status for each completion category
@HiveType(typeId: 112)
class CategoryStatus extends HiveObject {
  @HiveField(0)
  final CompletionCategory category;

  @HiveField(1)
  final double completion; // 0.0 to 1.0

  @HiveField(2)
  final bool isBehindSchedule;

  @HiveField(3)
  final DateTime? expectedCompletionDate;

  @HiveField(4)
  final String? statusNotes;

  CategoryStatus({
    required this.category,
    required this.completion,
    required this.isBehindSchedule,
    this.expectedCompletionDate,
    this.statusNotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category.name,
      'completion': completion,
      'isBehindSchedule': isBehindSchedule,
      'expectedCompletionDate': expectedCompletionDate?.toIso8601String(),
      'statusNotes': statusNotes,
    };
  }

  @override
  String toString() {
    return 'CategoryStatus{category: ${category.name}, completion: ${(completion * 100).round()}%}';
  }
}

/// Categories of completion items
@HiveType(typeId: 113)
enum CompletionCategory {
  @HiveField(0)
  exploration('Exploration', 'Self-exploration and reflection activities'),
  
  @HiveField(1)
  advisorFeedback('Advisor Feedback', 'Gathering external perspectives'),
  
  @HiveField(2)
  insightGeneration('Insight Generation', 'AI-powered insight analysis'),
  
  @HiveField(3)
  synthesis('Synthesis', 'Combining self and advisor perspectives'),
  
  @HiveField(4)
  experimentation('Experimentation', 'Career experiments and testing'),
  
  @HiveField(5)
  planning('Planning', 'Creating development and action plans'),
  
  @HiveField(6)
  reporting('Reporting', 'Generating and sharing reports');

  const CompletionCategory(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// Priority levels for completion items
@HiveType(typeId: 114)
enum ItemPriority {
  @HiveField(0)
  low('Low', 'Nice to complete but not essential'),
  
  @HiveField(1)
  medium('Medium', 'Important for good outcomes'),
  
  @HiveField(2)
  high('High', 'Critical for meaningful results'),
  
  @HiveField(3)
  critical('Critical', 'Must be completed for process to work');

  const ItemPriority(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// Overall completion levels
@HiveType(typeId: 115)
enum CompletionLevel {
  @HiveField(0)
  starting('Starting', 'Just beginning the journey'),
  
  @HiveField(1)
  exploring('Exploring', 'Actively exploring and gathering insights'),
  
  @HiveField(2)
  deepening('Deepening', 'Deepening understanding and analysis'),
  
  @HiveField(3)
  synthesising('Synthesising', 'Bringing insights together'),
  
  @HiveField(4)
  planning('Planning', 'Creating actionable plans'),
  
  @HiveField(5)
  implementing('Implementing', 'Taking action on insights'),
  
  @HiveField(6)
  complete('Complete', 'Journey substantially complete');

  const CompletionLevel(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// User readiness for next steps
@HiveType(typeId: 116)
enum UserReadiness {
  @HiveField(0)
  notReady('Not Ready', 'Not ready for next major steps'),
  
  @HiveField(1)
  gettingReady('Getting Ready', 'Building readiness for next steps'),
  
  @HiveField(2)
  ready('Ready', 'Ready to move forward'),
  
  @HiveField(3)
  veryReady('Very Ready', 'Eager and well-prepared for next steps');

  const UserReadiness(this.displayName, this.description);
  
  final String displayName;
  final String description;
}